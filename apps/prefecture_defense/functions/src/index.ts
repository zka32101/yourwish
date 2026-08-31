import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

// ─── ランキング登録 ──────────────────────────────────────────────────────
// クライアントから呼び出し: score, prefectureCode, difficulty, playerName

export const submitScore = functions
  .region("asia-northeast1")
  .https.onCall(async (data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "ログインが必要です");

    const { score, prefectureCode, difficulty, playerName, showInRanking } = data;

    if (typeof score !== "number" || score < 0) {
      throw new functions.https.HttpsError("invalid-argument", "スコアが不正です");
    }

    const entryRef = db
      .collection("rankings")
      .doc(prefectureCode)
      .collection("entries")
      .doc(uid);

    const existing = await entryRef.get();
    const existingScore = existing.exists ? (existing.data()?.score ?? 0) : 0;

    // 自己ベストのみ更新
    if (score <= existingScore) {
      return { updated: false, bestScore: existingScore };
    }

    await entryRef.set({
      uid,
      playerName: showInRanking ? (playerName ?? "名無し") : "***",
      score,
      difficulty,
      prefectureCode,
      showInRanking: showInRanking ?? true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 都道府県集計を更新
    await db.collection("rankings").doc(prefectureCode).set({
      totalPlayers: admin.firestore.FieldValue.increment(existing.exists ? 0 : 1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return { updated: true, bestScore: score };
  });

// ─── ランキング取得（上位20件）──────────────────────────────────────────
export const getRanking = functions
  .region("asia-northeast1")
  .https.onCall(async (data, _context) => {
    const { prefectureCode } = data;
    if (!prefectureCode) {
      throw new functions.https.HttpsError("invalid-argument", "都道府県コードが必要です");
    }

    const snapshot = await db
      .collection("rankings")
      .doc(prefectureCode)
      .collection("entries")
      .orderBy("score", "desc")
      .limit(20)
      .get();

    const entries = snapshot.docs.map((doc, i) => ({
      rank: i + 1,
      playerName: doc.data().playerName,
      score: doc.data().score,
      difficulty: doc.data().difficulty,
      uid: doc.data().uid,
    }));

    return { entries };
  });

// ─── 全国ランキング（全都道府県のベストスコア合計）────────────────────────
export const getGlobalRanking = functions
  .region("asia-northeast1")
  .https.onCall(async (_data, _context) => {
    // ユーザー別の全都道府県スコア合計を集計
    const snapshot = await db
      .collectionGroup("entries")
      .orderBy("score", "desc")
      .limit(50)
      .get();

    // uid ごとに合算
    const userScores: Record<string, { playerName: string; totalScore: number; count: number }> = {};
    snapshot.docs.forEach((doc) => {
      const d = doc.data();
      if (!userScores[d.uid]) {
        userScores[d.uid] = { playerName: d.playerName, totalScore: 0, count: 0 };
      }
      userScores[d.uid].totalScore += d.score;
      userScores[d.uid].count++;
    });

    const sorted = Object.entries(userScores)
      .sort((a, b) => b[1].totalScore - a[1].totalScore)
      .slice(0, 20)
      .map(([uid, v], i) => ({
        rank: i + 1,
        uid,
        playerName: v.playerName,
        totalScore: v.totalScore,
        prefectureCount: v.count,
      }));

    return { entries: sorted };
  });

// ─── デイリーボーナス（サーバーサイド確認）──────────────────────────────
export const claimDailyBonus = functions
  .region("asia-northeast1")
  .https.onCall(async (_data, context) => {
    const uid = context.auth?.uid;
    if (!uid) throw new functions.https.HttpsError("unauthenticated", "ログインが必要です");

    const bonusRef = db.collection("daily_bonuses").doc(uid);
    const doc = await bonusRef.get();

    const now = admin.firestore.Timestamp.now();
    const todayStr = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

    if (doc.exists) {
      const lastClaim: string = doc.data()?.lastClaimDate ?? "";
      if (lastClaim === todayStr) {
        return { claimed: false, reason: "already_claimed" };
      }
    }

    const streak: number = doc.exists
      ? _calcStreak(doc.data()?.lastClaimDate ?? "", doc.data()?.streak ?? 0)
      : 1;

    const goldReward = _calcGoldReward(streak);
    const expReward = _calcExpReward(streak);

    await bonusRef.set({
      uid,
      lastClaimDate: todayStr,
      streak,
      totalClaims: admin.firestore.FieldValue.increment(1),
      lastClaimAt: now,
    }, { merge: true });

    return {
      claimed: true,
      streak,
      goldReward,
      expReward,
    };
  });

// ─── ヘルパー ────────────────────────────────────────────────────────────

function _calcStreak(lastDate: string, currentStreak: number): number {
  if (!lastDate) return 1;
  const last = new Date(lastDate);
  const today = new Date();
  const diff = Math.floor((today.getTime() - last.getTime()) / 86400000);
  if (diff === 1) return currentStreak + 1; // 連続
  if (diff === 0) return currentStreak;     // 当日（通常来ない）
  return 1;                                  // 途切れ
}

function _calcGoldReward(streak: number): number {
  // 7日毎に大ボーナス
  if (streak % 7 === 0) return 300;
  return 50 + Math.min(streak * 10, 150);
}

function _calcExpReward(streak: number): number {
  if (streak % 7 === 0) return 500;
  return 100 + Math.min(streak * 20, 300);
}
