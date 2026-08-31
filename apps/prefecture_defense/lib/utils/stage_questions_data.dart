/// Stage 1-5 地理クイズ問題データ
/// 各ステージ15問 × 5 = 60問
/// s1q1 ～ s5q15 の形式

class StageQuestion {
  final String id; // s1q1, s1q2, etc.
  final String stageId; // s1, s2, etc.
  final int questionNumber; // 1-15
  final String region; // 北海道、東北、関東、近畿、九州
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation; // 学習用：詳しい解説
  final String difficulty; // easy, normal, hard
  final List<String> keywords; // キーワード（学習支援）

  const StageQuestion({
    required this.id,
    required this.stageId,
    required this.questionNumber,
    required this.region,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.keywords,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAGE 1: 北海道（15問）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const List<StageQuestion> stageOneQuestions = [
  // s1q1
  StageQuestion(
    id: 's1q1',
    stageId: 's1',
    questionNumber: 1,
    region: '北海道',
    question: '北海道の面積は日本全体の何パーセント？',
    options: ['約15%', '約22%', '約30%', '約8%'],
    correctIndex: 1,
    explanation:
        '北海道は日本最大の面積（約83,424km²）を持つ地域で、全国の22%を占めています。広大な土地を活かした農業がさかんで、じゃがいも・小麦・ビートなどの生産量が全国1位です。北海道ほどの広さがあれば、オーストリアやハンガリーなどのヨーロッパの国と同じくらいの大きさです。',
    difficulty: 'normal',
    keywords: ['面積', '広大', '22%', '農業生産'],
  ),

  // s1q2
  StageQuestion(
    id: 's1q2',
    stageId: 's1',
    questionNumber: 2,
    region: '北海道',
    question: '北海道産のじゃがいも生産量は全国の何パーセント？',
    options: ['約60%', '約80%', '約50%', '約40%'],
    correctIndex: 1,
    explanation:
        '北海道は全国のじゃがいも生産の80%を占める、日本最大の産地です。冷涼な気候とやせた火山灰土がじゃがいも栽培に適しており、「男爵」や「メークイン」などの主要品種が生産されています。毎年200万トン以上が生産され、家庭用から工業用（スナック菓子など）まで幅広く利用されます。',
    difficulty: 'normal',
    keywords: ['じゃがいも', '80%', '冷涼気候', '火山灰土'],
  ),

  // s1q3
  StageQuestion(
    id: 's1q3',
    stageId: 's1',
    questionNumber: 3,
    region: '北海道',
    question: '北海道の気候区分は？',
    options: ['温帯', '亜寒帯', '冷温帯', '寒帯'],
    correctIndex: 2,
    explanation:
        '北海道は冷温帯（亜冷帯）に属し、冬が長く厳しいのが特徴です。札幌の年平均気温は約9℃で、東京（約16℃）より7℃も低くなっています。この冷涼な気候こそが、じゃがいも・玉ねぎ・小麦などの大規模農業を支えています。また積雪量も多く、冬の農業は実質的に休止となります。',
    difficulty: 'normal',
    keywords: ['冷温帯', '冬が長い', '積雪', '年平均気温'],
  ),

  // s1q4
  StageQuestion(
    id: 's1q4',
    stageId: 's1',
    questionNumber: 4,
    region: '北海道',
    question: '北海道産の小麦生産量は全国のどのくらい？',
    options: ['約30%', '約60%', '約75%', '約45%'],
    correctIndex: 2,
    explanation:
        '北海道は全国の小麦生産の約75%を占める最大産地です。「春よ恋」「きたほなみ」などの品種が栽培され、パンやうどんの原料として利用されています。広大な農地と機械化農業により、大規模な小麦栽培が実現しており、毎年30万トン以上が生産されています。',
    difficulty: 'normal',
    keywords: ['小麦生産', '75%', '春よ恋', '機械化農業'],
  ),

  // s1q5
  StageQuestion(
    id: 's1q5',
    stageId: 's1',
    questionNumber: 5,
    region: '北海道',
    question: '北海道の玉ねぎ生産量は全国の何パーセント？',
    options: ['約40%', '約55%', '約75%', '約25%'],
    correctIndex: 2,
    explanation:
        '北海道は全国の玉ねぎ生産の約75%を占める圧倒的1位です。十勝地方などの大規模農地で栽培され、毎年80万トン以上が全国に出荷されています。貯蔵性に優れているため、通年を通じて供給可能で、「北海道玉ねぎ」はブランド品として高く評価されています。',
    difficulty: 'normal',
    keywords: ['玉ねぎ生産', '75%', '十勝', '貯蔵性'],
  ),

  // s1q6
  StageQuestion(
    id: 's1q6',
    stageId: 's1',
    questionNumber: 6,
    region: '北海道',
    question: '北海道の主要水産物は？（複数当てはまる場合は最も生産量が多いもの）',
    options: ['マグロ', 'イカ', 'ホタテ', 'サケ'],
    correctIndex: 2,
    explanation:
        'ホタテは北海道を代表する水産物で、生産量は全国の90%以上を占めています。陸奥湾と根室海峡が主な産地で、毎年20万トン以上が生産されます。高級食材として国内外で人気があり、北海道の漁業産出額の大部分を占めています。イカも有名な産物で、スルメイカが北洋で多く捕獲されます。',
    difficulty: 'normal',
    keywords: ['ホタテ生産', '90%以上', '陸奥湾', '高級食材'],
  ),

  // s1q7
  StageQuestion(
    id: 's1q7',
    stageId: 's1',
    questionNumber: 7,
    region: '北海道',
    question: '北海道の酪農生産量は全国の何パーセント？',
    options: ['約40%', '約55%', '約75%', '約30%'],
    correctIndex: 2,
    explanation:
        '北海道の酪農生産量は全国の約75%を占め、日本最大の酪農地帯です。冷涼な気候は牛にとって理想的で、ホルスタイン種が広く飼育されています。毎年800万トン以上の生乳が生産され、乳製品（バター・チーズ・ヨーグルト）の原料となります。帯広や釧路などが有名な酪農地帯です。',
    difficulty: 'normal',
    keywords: ['酪農', '75%', '冷涼気候', '乳製品'],
  ),

  // s1q8
  StageQuestion(
    id: 's1q8',
    stageId: 's1',
    questionNumber: 8,
    region: '北海道',
    question: '北海道の人口は約何万人？',
    options: ['約300万人', '約500万人', '約800万人', '約1000万人'],
    correctIndex: 1,
    explanation:
        '北海道の人口は約510万人で、全国で7番目の人口数です。面積が広いわりに人口密度は低く、1㎢あたり約60人で、全国平均（約340人）の5分の1程度です。人口の約1割が札幌市に集中しており、地方の過疎化が進んでいるのが課題です。',
    difficulty: 'easy',
    keywords: ['人口510万人', '人口密度低い', '札幌集中', '過疎化'],
  ),

  // s1q9
  StageQuestion(
    id: 's1q9',
    stageId: 's1',
    questionNumber: 9,
    region: '北海道',
    question: '札幌市の人口は北海道全体の何パーセント程度？',
    options: ['約5%', '約10%', '約20%', '約15%'],
    correctIndex: 2,
    explanation:
        '札幌市の人口は約195万人で、北海道全体の約19%を占めており、著しい一極集中が起きています。行政機能・商業・高等教育などが札幌に集中しているため、若年層が札幌への転出が続く傾向があります。この集中構造は、地方の人口減少と産業空洞化を加速させています。',
    difficulty: 'normal',
    keywords: ['札幌市195万人', '19%一極集中', '行政機能集中'],
  ),

  // s1q10
  StageQuestion(
    id: 's1q10',
    stageId: 's1',
    questionNumber: 10,
    region: '北海道',
    question: '北海道の平均気温は東京比でどのくらい低い？',
    options: ['約2℃', '約5℃', '約7℃', '約10℃'],
    correctIndex: 2,
    explanation:
        '北海道の年平均気温は東京より約7℃低く、年間を通じて涼しい地域です。札幌の年平均気温が約9℃に対し、東京は約16℃です。冬の厳しさと短い夏がもたらす温度差が大きく、農業の形態も大きく異なります。この気温差が「北の大地」での独特な経済・生活文化を生み出しています。',
    difficulty: 'normal',
    keywords: ['年平均気温7℃低い', '札幌9℃', '東京16℃'],
  ),

  // s1q11
  StageQuestion(
    id: 's1q11',
    stageId: 's1',
    questionNumber: 11,
    region: '北海道',
    question: '北海道の天然ガス産出量は全国の何パーセント？',
    options: ['約30%', '約50%', '約70%', '約20%'],
    correctIndex: 2,
    explanation:
        '北海道は全国の天然ガス産出量の約70%を占め、エネルギー供給の重要な地域です。南樺太油田などで採掘されており、北海道内の工業・発電・暖房用途で利用されています。石油・石炭の減少に伴い、天然ガスへの依存度がますます高まっています。',
    difficulty: 'hard',
    keywords: ['天然ガス70%', '南樺太油田', 'エネルギー供給'],
  ),

  // s1q12
  StageQuestion(
    id: 's1q12',
    stageId: 's1',
    questionNumber: 12,
    region: '北海道',
    question: 'アイヌ民族の伝統文化が特に色濃く残る北海道の地域は？',
    options: ['札幌周辺', '道南', '道東・釧路地方', '札幌と旭川の中間'],
    correctIndex: 2,
    explanation:
        'アイヌ民族の伝統文化は、特に道東（釧路・阿寒地方）に色濃く残っており、伝統工芸（イタ・トゥイ織など）や古式舞踊が今なお受け継がれています。2020年には白老町にアイヌ文化復興・研究推進のための施設「ウポポイ」（民族共生象徴空間）が開設されました。北海道はアイヌ文化の発祥地であり、その保存・伝承は重要な課題です。',
    difficulty: 'hard',
    keywords: ['アイヌ民族', '道東釧路', 'ウポポイ', '文化継承'],
  ),

  // s1q13
  StageQuestion(
    id: 's1q13',
    stageId: 's1',
    questionNumber: 13,
    region: '北海道',
    question: '北海道の積雪深が最も深い地域は？',
    options: ['札幌', 'トマム', '知床', '紋別'],
    correctIndex: 1,
    explanation:
        '北海道の積雪深は地域によって大きく異なります。特に山越地方やトマム周辺の日本海側は積雪が多く、年間最大積雪深が5～10mに達する地域もあります。札幌は平均約60～100cm程度ですが、周辺の山地ではより多くの雪が降ります。この豊富な雪資源はスキー場の運営を支えています。',
    difficulty: 'hard',
    keywords: ['積雪深', '日本海側多雪', 'スキー場'],
  ),

  // s1q14
  StageQuestion(
    id: 's1q14',
    stageId: 's1',
    questionNumber: 14,
    region: '北海道',
    question: '北海道における森林面積の割合は？',
    options: ['約30%', '約45%', '約70%', '約55%'],
    correctIndex: 2,
    explanation:
        '北海道の森林面積は約7万km²で、北海道全体の約70%を占めています。落葉広葉樹林と針葉樹林が混在し、日本有数の林業地となっています。また木材産出量も全国の10%程度を占めており、森林資源の活用が経済に大きな役割を果たしています。林業の成長産業化は北海道の重要な施策です。',
    difficulty: 'normal',
    keywords: ['森林面積70%', '7万km²', '林業地', '木材産出'],
  ),

  // s1q15
  StageQuestion(
    id: 's1q15',
    stageId: 's1',
    questionNumber: 15,
    region: '北海道',
    question: '北海道の自然エネルギー（再生可能エネルギー）利用率は全国と比べてどう？',
    options: ['全国より低い', '全国と同等', '全国より高い', 'データがない'],
    correctIndex: 2,
    explanation:
        '北海道は風力発電と水力発電に恵まれており、再生可能エネルギーの利用率が全国より高くなっています。特に風力発電は稚内などの日本海側で盛んで、導入量が全国で上位です。また水力発電も多く、旭川・釧路などの地方電力会社が活用しています。脱炭素社会実現に向け、再生可能エネルギーの一層の活用が期待されています。',
    difficulty: 'hard',
    keywords: ['再生可能エネルギー', '風力発電', '水力発電', '脱炭素'],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAGE 2: 東北（15問）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const List<StageQuestion> stageTwoQuestions = [
  // s2q1
  StageQuestion(
    id: 's2q1',
    stageId: 's2',
    questionNumber: 1,
    region: '東北',
    question: '東北地方に含まれる都道府県は全部で何個？',
    options: ['5個', '6個', '7個', '8個'],
    correctIndex: 1,
    explanation:
        '東北地方は青森県、岩手県、宮城県、秋田県、山形県、福島県の6つの県で構成されています。面積は約66,400km²で北海道に次ぐ広さを持っています。日本の縦軸の北部に位置し、冬場の降雪が多く、脈々と厳しい自然環境を持つ地域です。各県の特色や産業は異なり、多様性に富んだ地域です。',
    difficulty: 'easy',
    keywords: ['東北6県', '青森岩手宮城秋田山形福島', '面積66400km²'],
  ),

  // s2q2
  StageQuestion(
    id: 's2q2',
    stageId: 's2',
    questionNumber: 2,
    region: '東北',
    question: '東北地方の冬季降雪量が最も多い県は？',
    options: ['青森県', '岩手県', '秋田県', '新潟県'],
    correctIndex: 2,
    explanation:
        '秋田県は東北地方で最も冬季降雪量が多く、能代や大館などの日本海沿岸部では年間積雪深が3～5mに達します。この豊富な雪は農業（水田の灌漑）や水力発電に利用されてきました。一方で雪害も深刻な問題となり、防雪設備の整備が急務です。秋田県のスキー場は粉雪に恵まれた名所として知られています。',
    difficulty: 'normal',
    keywords: ['秋田県多雪', '降雪量最大', '日本海側', 'スキー場'],
  ),

  // s2q3
  StageQuestion(
    id: 's2q3',
    stageId: 's2',
    questionNumber: 3,
    region: '東北',
    question: '東北地方の米（こめ）生産量は全国のおおよそ何パーセント？',
    options: ['約20%', '約35%', '約50%', '約65%'],
    correctIndex: 2,
    explanation:
        '東北地方は全国の米生産量の約50%を占める日本最大の米どころです。特に秋田県・宮城県・山形県が有名で、「あきたこまち」「ササニシキ」「つや姫」などの良質米が栽培されています。冷涼な気候と豊富な水が米作に適しており、農業産出額の大部分を占めています。東北の経済・生活は米を中心に発展してきました。',
    difficulty: 'normal',
    keywords: ['米生産50%', 'あきたこまち', 'ササニシキ', 'つや姫'],
  ),

  // s2q4
  StageQuestion(
    id: 's2q4',
    stageId: 's2',
    questionNumber: 4,
    region: '東北',
    question: '青森県の特産物は何か？',
    options: ['りんご', 'ミカン', 'スイカ', 'メロン'],
    correctIndex: 0,
    explanation:
        '青森県はりんご生産量で全国1位（約60万トン/年）を占めており、「つがる」「ふじ」などの主要品種が栽培されています。県の総面積の3分の1がりんご畑で占められ、産業全体の中で最も重要な農産物です。また北津軽のにんにく生産も全国1位で、経済的に大きな役割を果たしています。',
    difficulty: 'easy',
    keywords: ['りんご生産1位', '60万トン', 'つがる・ふじ', 'にんにくも1位'],
  ),

  // s2q5
  StageQuestion(
    id: 's2q5',
    stageId: 's2',
    questionNumber: 5,
    region: '東北',
    question: '東北地方で最も人口が多い都市は？',
    options: ['盛岡市', '仙台市', '秋田市', '青森市'],
    correctIndex: 1,
    explanation:
        '仙台市は東北地方の経済・文化の中心地で、人口は約109万人です。宮城県の県庁所在地として行政機能が集中し、東北大学などの高等教育機関も立地しています。2011年の東日本大震災では大きな被害を受けましたが、現在は復興が進んでいます。東北地方を代表する都市として、さらなる発展が期待されています。',
    difficulty: 'easy',
    keywords: ['仙台市109万人', '東北地方中心', '県庁所在地', '震災復興'],
  ),

  // s2q6
  StageQuestion(
    id: 's2q6',
    stageId: 's2',
    questionNumber: 6,
    region: '東北',
    question: '岩手県の代表的な産業は？（複数ある場合は最も産出額が多いもの）',
    options: ['鉱業', '農業', '林業', '漁業'],
    correctIndex: 0,
    explanation:
        '岩手県は古くから鉱業が発達した地域で、北上山地の豊富な鉱物資源を背景に産業が発展してきました。鉱山から産出される鉄鉱石・銅・石灰石などは製鉄・化学工業の主要原料となっています。また農業も重要で、水稲・麦・野菜などが栽培されています。林業も盛んで、木材産出量は全国でも上位です。',
    difficulty: 'normal',
    keywords: ['岩手県鉱業', '北上山地', '鉄鉱石・銅', '複合産業'],
  ),

  // s2q7
  StageQuestion(
    id: 's2q7',
    stageId: 's2',
    questionNumber: 7,
    region: '東北',
    question: '宮城県の水産物生産額は全国の何パーセント程度？',
    options: ['約5%', '約10%', '約15%', '約20%'],
    correctIndex: 2,
    explanation:
        '宮城県は日本を代表する水産県で、水産物生産額が全国の約15%を占めています。特にカキの生産量は全国1位で、宮城県は全国の約60%の生産シェアを持っています。また仙台湾のホタテ、気仙沼のマグロなども有名です。2011年の東日本大震災では甚大な被害を受けましたが、現在は生産量が回復してきています。',
    difficulty: 'normal',
    keywords: ['宮城県水産15%', 'カキ生産1位', '仙台湾', '気仙沼マグロ'],
  ),

  // s2q8
  StageQuestion(
    id: 's2q8',
    stageId: 's2',
    questionNumber: 8,
    region: '東北',
    question: '福島県の原子力発電所被害から復興進度は？',
    options: ['ほぼ完了', '進行中', 'ほぼ遅れている', 'データなし'],
    correctIndex: 1,
    explanation:
        '福島県は2011年東日本大震災による東京電力福島第一原発事故で甚大な被害を受けました。約12年経った現在、復興事業が進行中で、避難指示区域の解除や産業再生に向けた取り組みが続いています。農業・漁業・観光業など多くの産業が影響を受け、風評被害の払拭が課題となっています。復興庁は2031年度までの復興期間を設定し、全力で対応しています。',
    difficulty: 'hard',
    keywords: ['福島原発事故', '東日本大震災', '復興進行中', '風評被害'],
  ),

  // s2q9
  StageQuestion(
    id: 's2q9',
    stageId: 's2',
    questionNumber: 9,
    region: '東北',
    question: '山形県の平均気温は全国と比べてどう？',
    options: ['全国平均より高い', '全国平均と同じ', '全国平均より低い', 'データなし'],
    correctIndex: 2,
    explanation:
        '山形県は冷涼な気候が特徴で、山辺での年平均気温は約11℃で全国平均より3℃程度低くなっています。この涼しさが、さくらんぼ・スイカ・枝豆などの特産物栽培に適しており、高級フルーツの産地として知られています。特に「佐藤錦」というさくらんぼは高級品として全国で珍重されています。',
    difficulty: 'normal',
    keywords: ['山形県冷涼', '年平均気温11℃', 'さくらんぼ・佐藤錦'],
  ),

  // s2q10
  StageQuestion(
    id: 's2q10',
    stageId: 's2',
    questionNumber: 10,
    region: '東北',
    question: '東北地方で最も面積が大きい県は？',
    options: ['青森県', '岩手県', '宮城県', '秋田県'],
    correctIndex: 1,
    explanation:
        '岩手県は東北地方で最も面積が大きく、約15,275km²（日本全体の4.0%）を占めています。北上山地など山が多く、人口密度は低いのが特徴です。県内の産業は鉱業・農業・林業・水産業と多様で、盛岡市に県庁機能が集中しています。自然環境に恵まれており、観光資源が豊富です。',
    difficulty: 'normal',
    keywords: ['岩手県面積最大', '15275km²', '北上山地'],
  ),

  // s2q11
  StageQuestion(
    id: 's2q11',
    stageId: 's2',
    questionNumber: 11,
    region: '東北',
    question: '秋田県の稲作が盛んな理由は何か？',
    options: ['温暖な気候', '豊富な水資源と肥沃な土壌', '労働力が豊富', 'すべて'],
    correctIndex: 1,
    explanation:
        '秋田県の稲作が盛んな理由は、①雄物川・子吉川などの豊富な水資源と②秋田平野の肥沃な黒ボク土が揃っているからです。ただし、冷涼な気候（年平均気温11℃程度）により、昔は冷害が頻繁に発生していました。戦後の品種改良（あきたこまちなど）により冷害に強い品種が開発され、現在は全国有数の米産地になりました。',
    difficulty: 'normal',
    keywords: ['秋田県稲作', '豊富な水資源', '肥沃な土壌', 'あきたこまち'],
  ),

  // s2q12
  StageQuestion(
    id: 's2q12',
    stageId: 's2',
    questionNumber: 12,
    region: '東北',
    question: '東北地方の林業産出量は全国の何パーセント程度？',
    options: ['約10%', '約20%', '約30%', '約15%'],
    correctIndex: 2,
    explanation:
        '東北地方の林業産出量は全国の約30%を占める日本有数の林業地帯です。特に岩手県・秋田県・福島県の産出量が多く、スギ・ヒノキなどの建築用材や木材パルプの原料として供給されています。また、きのこ栽培（シイタケなど）も盛んで、農林業の重要な産業となっています。',
    difficulty: 'normal',
    keywords: ['林業産出30%', 'スギ・ヒノキ', 'きのこ栽培'],
  ),

  // s2q13
  StageQuestion(
    id: 's2q13',
    stageId: 's2',
    questionNumber: 13,
    region: '東北',
    question: '江戸時代の仙台藩の知行地面積は東北地方全体のどのくらい？',
    options: ['約30%', '約50%', '約70%', 'データなし'],
    correctIndex: 2,
    explanation:
        '仙台藩は江戸時代に東北地方で最大の藩で、面積は約70万石（約28,000km²）と推定され、東北地方全体の70%程度を支配していました。伊達政宗が開設した仙台は城下町として発展し、現在の宮城県の経済・文化の中心地となっています。この歴史的背景が仙台市の現在の発展に大きく影響しています。',
    difficulty: 'hard',
    keywords: ['仙台藩70万石', '東北地方70%', '伊達政宗', '城下町'],
  ),

  // s2q14
  StageQuestion(
    id: 's2q14',
    stageId: 's2',
    questionNumber: 14,
    region: '東北',
    question: '青森県の漁業産出量は全国の何パーセント程度？',
    options: ['約5%', '約10%', '約15%', '約20%'],
    correctIndex: 1,
    explanation:
        '青森県は全国有数の漁業県で、漁業産出量が全国の約10%を占めています。津軽海峡と陸奥湾に面し、スルメイカの漁獲量は全国1位（全国の約30%）です。またホタテも全国の有数産地であり、養殖も盛んです。青森県の海の幸は新鮮で高品質として、全国で高く評価されています。',
    difficulty: 'normal',
    keywords: ['青森県漁業10%', 'スルメイカ全国1位', 'ホタテ養殖'],
  ),

  // s2q15
  StageQuestion(
    id: 's2q15',
    stageId: 's2',
    questionNumber: 15,
    region: '東北',
    question: '東北地方の人口減少率は全国と比べてどう？',
    options: ['全国より低い', '全国と同等', '全国より高い', 'データなし'],
    correctIndex: 2,
    explanation:
        '東北地方は全国より高い人口減少率を示しており、若年層の流出が深刻な課題となっています。東京への一極集中により、特に地方都市や農村部での人口減少が顕著です。1980年の東北地方の人口は約950万人でしたが、2020年は約880万人と約8%減少しました。人口減少は地域経済・農業・地域文化の維持に大きな影響を与えています。',
    difficulty: 'hard',
    keywords: ['人口減少率高い', '若年層流出', '一極集中', '地域経済課題'],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAGE 3: 関東（15問）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const List<StageQuestion> stageThreeQuestions = [
  // s3q1
  StageQuestion(
    id: 's3q1',
    stageId: 's3',
    questionNumber: 1,
    region: '関東',
    question: '関東地方に含まれる都道府県は全部で何個？',
    options: ['5個', '6個', '7個', '8個'],
    correctIndex: 2,
    explanation:
        '関東地方は茨城県、栃木県、群馬県、埼玉県、千葉県、東京都、神奈川県の7つの都道府県で構成されています。面積は約32,400km²で北海道・東北地方より小さいですが、日本最大の人口（約3,700万人）を持つ地域です。日本経済の中心地であり、政治・経済・文化の中枢機能が集中しています。',
    difficulty: 'easy',
    keywords: ['関東7都道府県', '茨城栃木群馬埼玉千葉東京神奈川', '人口3700万'],
  ),

  // s3q2
  StageQuestion(
    id: 's3q2',
    stageId: 's3',
    questionNumber: 2,
    region: '関東',
    question: '関東地方の総人口は日本全体の何パーセント程度？',
    options: ['約20%', '約30%', '約40%', '約50%'],
    correctIndex: 2,
    explanation:
        '関東地方の総人口は約3,700万人で、日本全体（約1億2,500万人）の約30%を占めています。実は関東の人口集中度は過去20年で高まる傾向にあり、経済格差の拡大が課題になっています。東京都の人口が1,400万人で関東全体の38%を占めており、著しい一極集中が生じています。',
    difficulty: 'normal',
    keywords: ['関東人口30%', '3700万人', '東京1400万人', '一極集中'],
  ),

  // s3q3
  StageQuestion(
    id: 's3q3',
    stageId: 's3',
    questionNumber: 3,
    region: '関東',
    question: '東京都の人口は全国の何パーセント程度？',
    options: ['約5%', '約10%', '約12%', '約15%'],
    correctIndex: 2,
    explanation:
        '東京都の人口は約1,400万人で、全国の約11%を占めており、日本最大の都市です。面積は2,194km²と決して大きくないのに対し、人口密度は約6,400人/km²で全国平均の約19倍です。江戸時代の江戸から現在まで、政治・経済・文化の中心地として栄え続けています。',
    difficulty: 'normal',
    keywords: ['東京都1400万人', '全国11%', '人口密度6400人/km²'],
  ),

  // s3q4
  StageQuestion(
    id: 's3q4',
    stageId: 's3',
    questionNumber: 4,
    region: '関東',
    question: '関東地方の工業生産額は全国の何パーセント程度？',
    options: ['約20%', '約30%', '約40%', '約50%'],
    correctIndex: 2,
    explanation:
        '関東地方の工業生産額は全国の約40%を占め、日本最大の工業地帯です。自動車・電子機器・化学・機械などの幅広い産業が立地しており、京浜工業地帯（東京・横浜）と京葉工業地帯（千葉）が中心です。首都直下型地震など自然災害に対する脆弱性が懸念されているため、産業の分散化が課題です。',
    difficulty: 'normal',
    keywords: ['工業生産40%', '京浜工業地帯', '京葉工業地帯', '自動車産業'],
  ),

  // s3q5
  StageQuestion(
    id: 's3q5',
    stageId: 's3',
    questionNumber: 5,
    region: '関東',
    question: '神奈川県の人口は約何万人？',
    options: ['約500万人', '約700万人', '約900万人', '約1100万人'],
    correctIndex: 2,
    explanation:
        '神奈川県の人口は約920万人で、全国で2番目に多い都道府県です。横浜市（約375万人）は東京都に次ぐ日本第2の都市であり、港湾都市として経済・文化の中心地です。京急・相模鉄道などの鉄道網が発達し、東京のベッドタウンとしても機能しています。',
    difficulty: 'normal',
    keywords: ['神奈川県920万人', '全国2位', '横浜市375万人', 'ベッドタウン'],
  ),

  // s3q6
  StageQuestion(
    id: 's3q6',
    stageId: 's3',
    questionNumber: 6,
    region: '関東',
    question: '埼玉県の特徴は？',
    options: ['内陸県', '沿岸県', '山岳県', '島しょ県'],
    correctIndex: 0,
    explanation:
        '埼玉県は内陸県で、海に面していない日本で最大の内陸県です。人口は約760万人で、東京のベッドタウンとして発展してきました。さいたま市は県庁所在地であり、行政機能が集中しています。農業（米・野菜）も盛んで、都市部と農村部が共存する地域です。',
    difficulty: 'easy',
    keywords: ['埼玉県内陸県', '760万人', 'さいたま市', 'ベッドタウン'],
  ),

  // s3q7
  StageQuestion(
    id: 's3q7',
    stageId: 's3',
    questionNumber: 7,
    region: '関東',
    question: '千葉県の農業産出額は全国の何パーセント程度？',
    options: ['約3%', '約5%', '約7%', '約10%'],
    correctIndex: 2,
    explanation:
        '千葉県は全国を代表する農業県で、農業産出額が全国の約7%を占めています。特に野菜生産は全国の12%程度で、トマト・ほうれん草・ダイコン・キャベツなどが栽培されています。また酪農も盛んで、乳牛の飼育数は全国で上位です。京葉工業地帯に隣接しながらも、農業が重要な産業です。',
    difficulty: 'normal',
    keywords: ['千葉県農業産出7%', '野菜12%', 'トマト・ほうれん草'],
  ),

  // s3q8
  StageQuestion(
    id: 's3q8',
    stageId: 's3',
    questionNumber: 8,
    region: '関東',
    question: '茨城県の農業産出額は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約12%', '約15%'],
    correctIndex: 2,
    explanation:
        '茨城県は全国有数の農業県で、農業産出額が全国の約12%を占める圧倒的1位です。鬼怒川・利根川の豊富な水資源と関東平野の肥沃な土壌により、水稲・野菜・果実など多様な農産物が栽培されています。特にメロン・イチゴ・レンコン生産では全国的に知られています。',
    difficulty: 'normal',
    keywords: ['茨城県農業12%', '全国1位', 'メロン・イチゴ・レンコン'],
  ),

  // s3q9
  StageQuestion(
    id: 's3q9',
    stageId: 's3',
    questionNumber: 9,
    region: '関東',
    question: '栃木県の主要産業は？',
    options: ['農業', '鉱業', '製造業', 'すべて'],
    correctIndex: 3,
    explanation:
        '栃木県は農業・製造業・観光業が共存する多様な産業構造を持っています。農業では水稲・麦・野菜・いちご・ぶどうなどが栽培され、特にいちご生産は全国2位です。製造業では機械・自動車・電子機器などが立地しており、中部地方への工業の波及効果が見られます。また日光・鬼怒川などの観光地も有名です。',
    difficulty: 'normal',
    keywords: ['栃木県多角産業', 'いちご生産2位', '日光・鬼怒川観光'],
  ),

  // s3q10
  StageQuestion(
    id: 's3q10',
    stageId: 's3',
    questionNumber: 10,
    region: '関東',
    question: '群馬県の自動車産業の特徴は？',
    options: ['乗用車中心', '商用車中心', '部品産業中心', '自動車産業は少ない'],
    correctIndex: 2,
    explanation:
        '群馬県は自動車部品産業が集中する地域で、エンジン・トランスミッション・電子部品などを生産する企業が多く立地しています。完成車メーカーの製造工場も複数あり、日本の自動車産業の重要な拠点です。中山間地域にも工業団地が整備され、地域経済を支える主要産業です。',
    difficulty: 'normal',
    keywords: ['群馬県自動車部品', 'エンジン・トランスミッション', '工業団地'],
  ),

  // s3q11
  StageQuestion(
    id: 's3q11',
    stageId: 's3',
    questionNumber: 11,
    region: '関東',
    question: '関東の三大工業地帯は？',
    options: ['京浜・京葉・中京', '京浜・京葉・阪神', '京浜・中京・阪神', '京浜・北関東・京葉'],
    correctIndex: 0,
    explanation:
        '関東の主要工業地帯は①京浜工業地帯（東京・横浜）②京葉工業地帯（千葉）③北関東工業地域（宇都宮・栃木・群馬）です。京浜工業地帯は日本最大の工業地帯で、自動車・電子機器・化学などが集中しています。京葉工業地帯は石油化学・製造業が中心で、両地帯合わせて関東工業の約70%を占めています。',
    difficulty: 'hard',
    keywords: ['京浜工業地帯', '京葉工業地帯', '北関東工業地域'],
  ),

  // s3q12
  StageQuestion(
    id: 's3q12',
    stageId: 's3',
    questionNumber: 12,
    region: '関東',
    question: '東京オリンピック（2020年）開催に伴う関東地域への経済効果は？',
    options: ['約5兆円', '約10兆円', '約15兆円', '約20兆円'],
    correctIndex: 1,
    explanation:
        '2020年東京オリンピックの経済効果は公式発表で約10兆円と推定されており、建設・IT・観光などの産業に大きな需要が生まれました。競技施設・選手村・交通インフラなどの整備に約3年かけて約2兆円以上が投資されました。ただしコロナ禍の影響で、期待された観光振興や国際交流の効果は限定的でした。',
    difficulty: 'hard',
    keywords: ['東京オリンピック2020', '経済効果10兆円', 'インフラ投資'],
  ),

  // s3q13
  StageQuestion(
    id: 's3q13',
    stageId: 's3',
    questionNumber: 13,
    region: '関東',
    question: '首都直下型地震の経済的影響は年GDP比でどのくらい？',
    options: ['約3%', '約5%', '約10%', '約15%'],
    correctIndex: 2,
    explanation:
        '首都直下型地震の経済的影響は、国の中央防災会議による試算で年GDP比約10%程度（約50兆円）と推定されています。関東地方は日本経済の中枢機能（金融・情報・行政）が集中しており、大規模地震は日本全体の経済活動に深刻な影響を与えます。そのため耐震化・防災インフラ整備が急務です。',
    difficulty: 'hard',
    keywords: ['首都直下型地震', '経済影響10%GDP', '50兆円'],
  ),

  // s3q14
  StageQuestion(
    id: 's3q14',
    stageId: 's3',
    questionNumber: 14,
    region: '関東',
    question: '関東地方のサービス業（金融・情報・商業）の産出額は全国の何パーセント程度？',
    options: ['約20%', '約35%', '約50%', '約60%'],
    correctIndex: 3,
    explanation:
        '関東地方のサービス業産出額は全国の約60%を占め、日本経済の中枢です。東京都のみで約50%を占めており、金融（証券取引所・銀行本店）・情報通信（テレビ・新聞・IT企業）・商業（百貨店・流通）などが集中しています。この過度な集中は地方経済の停滞をもたらし、均衡ある発展が課題です。',
    difficulty: 'hard',
    keywords: ['サービス業60%', '東京中枢機能', '金融・情報・商業'],
  ),

  // s3q15
  StageQuestion(
    id: 's3q15',
    stageId: 's3',
    questionNumber: 15,
    region: '関東',
    question: '関東地方の観光客数は全国の何パーセント程度？',
    options: ['約15%', '約25%', '約35%', '約45%'],
    correctIndex: 3,
    explanation:
        '関東地方を訪れる観光客数は全国の約45%（外国人含む）を占め、日本最大の観光地域です。スカイツリー・浅草・日光・箱根・伊豆など、有名な観光地が多く存在します。東京都への外国人観光客数は全国の約35%を占めており、2019年はコロナ前で約1,300万人が訪れました。訪日観光の重要な拠点です。',
    difficulty: 'hard',
    keywords: ['観光客45%', 'スカイツリー・浅草', '日光・箱根・伊豆'],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAGE 4: 近畿（15問）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const List<StageQuestion> stageFourQuestions = [
  // s4q1
  StageQuestion(
    id: 's4q1',
    stageId: 's4',
    questionNumber: 1,
    region: '近畿',
    question: '近畿地方に含まれる都道府県は全部で何個？',
    options: ['5個', '6個', '7個', '8個'],
    correctIndex: 2,
    explanation:
        '近畿地方は滋賀県、京都府、大阪府、兵庫県、奈良県、和歌山県、三重県の7つの都道府県で構成されています。面積は約27,300km²で関東地方より小さいですが、人口は約2,000万人と全国第2位です。関西地方とも呼ばれ、京都・大阪・兵庫を中心に、日本古来の文化・歴史が色濃く残っています。',
    difficulty: 'easy',
    keywords: ['近畿7都道府県', '滋賀京都大阪兵庫奈良和歌山三重', '人口2000万'],
  ),

  // s4q2
  StageQuestion(
    id: 's4q2',
    stageId: 's4',
    questionNumber: 2,
    region: '近畿',
    question: '大阪府の経済規模（名目GDP）は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約12%', '約15%'],
    correctIndex: 2,
    explanation:
        '大阪府の名目GDPは約45兆円で、全国の約12%を占め、東京都（約100兆円）に次ぐ日本第2位です。金融・商業・製造業が発達しており、阪神工業地帯は日本を代表する工業地帯です。大阪市は近畿地方の経済・文化の中心地であり、東京に次ぐビジネスハブとして機能しています。',
    difficulty: 'normal',
    keywords: ['大阪GDP45兆円', '全国12%', '第2位', '阪神工業地帯'],
  ),

  // s4q3
  StageQuestion(
    id: 's4q3',
    stageId: 's4',
    questionNumber: 3,
    region: '近畿',
    question: '京都の伝統工芸品で最も有名なものは？',
    options: ['陶磁器', '京友禅', '組紐', '京漆器'],
    correctIndex: 1,
    explanation:
        '京都を代表する伝統工芸品は京友禅（きょうゆうぜん）で、手描きと友禅染めの技術で知られています。また陶磁器（清水焼）・組紐・京漆器など多くの工芸品が京都に集中しており、年間約50万人の観光客が訪れます。千年都として栄えた京都は、日本の文化・工芸の中心地です。',
    difficulty: 'normal',
    keywords: ['京友禅', '清水焼', '伝統工芸品', '千年都京都'],
  ),

  // s4q4
  StageQuestion(
    id: 's4q4',
    stageId: 's4',
    questionNumber: 4,
    region: '近畿',
    question: '兵庫県の工業産出額は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約12%', '約15%'],
    correctIndex: 2,
    explanation:
        '兵庫県の工業産出額は全国の約12%を占め、関東地方に次ぐ日本第2位の工業県です。阪神工業地帯（神戸・尼崎・西宮）を中心に、鉄鋼・機械・化学・造船などの重工業が発達してきました。1995年の阪神淡路大震災から復興し、現在は自動車・電子機器などの先端産業も増えています。',
    difficulty: 'normal',
    keywords: ['兵庫県工業12%', '第2位', '阪神工業地帯', '神戸・尼崎'],
  ),

  // s4q5
  StageQuestion(
    id: 's4q5',
    stageId: 's4',
    questionNumber: 5,
    region: '近畿',
    question: '神戸港の取扱量は日本の何パーセント程度？',
    options: ['約3%', '約8%', '約15%', '約20%'],
    correctIndex: 2,
    explanation:
        '神戸港は日本を代表する国際港湾で、年間貨物取扱量が全国の約15%を占めます。コンテナ取扱量でもアジア有数（世界30位程度）の規模を誇っており、高度な機械化施設を備えています。明治時代から国際貿易の中心地として栄え、現在も日本経済の重要な流通拠点です。',
    difficulty: 'normal',
    keywords: ['神戸港15%', '国際港湾', 'コンテナ取扱', '高度機械化'],
  ),

  // s4q6
  StageQuestion(
    id: 's4q6',
    stageId: 's4',
    questionNumber: 6,
    region: '近畿',
    question: '滋賀県の特徴は？',
    options: ['最大の製造業県', '琵琶湖を有する内陸県', '漁業が最も盛ん', 'すべて'],
    correctIndex: 1,
    explanation:
        '滋賀県は琵琶湖（日本最大の面積673km²）を有する内陸県です。琵琶湖の水は滋賀県民の飲料水・農業・工業用水の水源であり、また京都・大阪にも供給されています。古墳時代には近江国として栄え、現在も文化遺産が多く残っています。製造業も盛んで、特に電子機器・機械製造が発達しています。',
    difficulty: 'normal',
    keywords: ['滋賀県琵琶湖', '日本最大面積673km²', '水源', '近江国'],
  ),

  // s4q7
  StageQuestion(
    id: 's4q7',
    stageId: 's4',
    questionNumber: 7,
    region: '近畿',
    question: '奈良県の文化遺産で最も有名なものは？',
    options: ['奈良大仏', '奈良公園の鹿', '古都奈良の奈良県', 'すべて'],
    correctIndex: 3,
    explanation:
        '奈良県は日本を代表する歴史・文化の地です。特に奈良大仏（東大寺）・奈良公園（奈良鹿）・奈良県立美術館など、世界的に知られた文化遺産が多数あります。奈良県の観光客数は年間約1,500万人で、日本を代表する観光地です。710年から794年まで奈良時代として日本の政治・文化の中心地でした。',
    difficulty: 'easy',
    keywords: ['奈良大仏', '東大寺', '奈良公園の鹿', '奈良時代'],
  ),

  // s4q8
  StageQuestion(
    id: 's4q8',
    stageId: 's4',
    questionNumber: 8,
    region: '近畿',
    question: '和歌山県の基幹産業は？',
    options: ['農業', '漁業', '観光業', 'すべて'],
    correctIndex: 3,
    explanation:
        '和歌山県は農業・漁業・観光業が共存する産業構造を持っています。農業では梅・みかん・紀州梅干しが有名で、特に梅生産は全国の約60%を占めます。漁業も盛んで、マグロ・イセエビなどが主要産物です。また高野山・熊野古道などの観光資源も豊富で、年間約800万人の観光客が訪れます。',
    difficulty: 'normal',
    keywords: ['和歌山梅60%', 'みかん・梅干し', '高野山・熊野古道'],
  ),

  // s4q9
  StageQuestion(
    id: 's4q9',
    stageId: 's4',
    questionNumber: 9,
    region: '近畿',
    question: '三重県が複数の地域圏に属する理由は？',
    options: ['面積が大きい', '経済圏が複数', '地形が複雑', 'すべて'],
    correctIndex: 1,
    explanation:
        '三重県は複雑な行政・経済構造を持つ県です。北部は愛知県と一体の経済圏（中部地方に分類される場合も）、南部は和歌山県・奈良県と関係が深く（近畿地方に分類）、東部は太平洋側の独立した産業を持っています。特に自動車産業は中部地方の豊田地域と結びついており、複数の産業圏に属する特異な県です。',
    difficulty: 'hard',
    keywords: ['三重県複数圏', '経済圏複雑', '自動車産業'],
  ),

  // s4q10
  StageQuestion(
    id: 's4q10',
    stageId: 's4',
    questionNumber: 10,
    region: '近畿',
    question: '近畿地方の人口は全国の何パーセント程度？',
    options: ['約10%', '約15%', '約20%', '約25%'],
    correctIndex: 2,
    explanation:
        '近畿地方の人口は約2,000万人で、全国の約16%を占めます。東京圏（関東地方）に次ぐ日本第2位の人口集中地域です。大阪・京都・兵庫が人口の中心で、特に大阪府と兵庫県の人口が多いです。近畿地方の人口は過去20年で減少傾向が続いており、少子高齢化の課題が深刻です。',
    difficulty: 'normal',
    keywords: ['近畿人口2000万', '全国16%', '第2位', '減少傾向'],
  ),

  // s4q11
  StageQuestion(
    id: 's4q11',
    stageId: 's4',
    questionNumber: 11,
    region: '近畿',
    question: 'ひょうご経済圏（兵庫県中心）の工業産出額は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約12%', '約15%'],
    correctIndex: 2,
    explanation:
        'ひょうご経済圏（兵庫県全体）の工業産出額は全国の約12%で、日本第2位です。阪神工業地帯を中心に鉄鋼・造船・自動車などの重工業が発達し、特に神戸・尼崎・西宮に集中しています。1995年の阪神淡路大震災からの復興は着実に進み、現在は先端産業への転換も進んでいます。',
    difficulty: 'normal',
    keywords: ['兵庫県工業12%', '阪神工業地帯', '復興着実'],
  ),

  // s4q12
  StageQuestion(
    id: 's4q12',
    stageId: 's4',
    questionNumber: 12,
    region: '近畿',
    question: '京都市の観光客数は全国の何パーセント程度？',
    options: ['約3%', '約5%', '約8%', '約10%'],
    correctIndex: 2,
    explanation:
        '京都市は国内外を代表する観光都市で、年間観光客数が全国の約8%（国内約800万人、外国人約400万人）に相当します。清水寺・伏見稲荷・金閣寺・銀閣寺など、世界的に知られた文化遺産が多数あり、特に外国人観光客に人気です。古都としての歴史・伝統が観光資源の中心です。',
    difficulty: 'normal',
    keywords: ['京都市観光8%', '清水寺・伏見稲荷', '古都千年'],
  ),

  // s4q13
  StageQuestion(
    id: 's4q13',
    stageId: 's4',
    questionNumber: 13,
    region: '近畿',
    question: '琵琶湖の水は何県に供給されている？',
    options: ['滋賀県のみ', '滋賀・京都のみ', '滋賀・京都・大阪', '5県以上'],
    correctIndex: 3,
    explanation:
        '琵琶湖の水は滋賀県民だけでなく、京都府・大阪府・兵庫県・奈良県・福井県など広域に供給されており、関西圏約1,800万人の飲料水・農業用水の水源です。日本最大の統一水系として、近畿地方経済の基盤となっています。琵琶湖の水質保全は関西全域の重要課題です。',
    difficulty: 'hard',
    keywords: ['琵琶湖広域水供給', '関西1800万人', '水質保全'],
  ),

  // s4q14
  StageQuestion(
    id: 's4q14',
    stageId: 's4',
    questionNumber: 14,
    region: '近畿',
    question: '阪神淡路大震災による兵庫県の経済損失は？',
    options: ['約5兆円', '約10兆円', '約15兆円', '約20兆円'],
    correctIndex: 1,
    explanation:
        '1995年1月17日の阪神淡路大震災は兵庫県などに約10兆円（当時の試算）の経済損失をもたらしました。死者6,434人、全壊建物10万棟以上という甚大な被害から、約27年かけて復興が進んでいます。この震災は日本に大規模災害対策・防災意識の重要性を認識させ、現在も防災インフラ整備が継続しています。',
    difficulty: 'hard',
    keywords: ['阪神淡路大震災', '経済損失10兆円', '死者6434人', '防災'],
  ),

  // s4q15
  StageQuestion(
    id: 's4q15',
    stageId: 's4',
    questionNumber: 15,
    region: '近畿',
    question: '近畿地方のサービス業産出額は全国の何パーセント程度？',
    options: ['約15%', '約20%', '約25%', '約30%'],
    correctIndex: 3,
    explanation:
        '近畿地方のサービス業産出額は全国の約30%を占め、関東地方に次ぐ日本第2位です。大阪・京都・兵庫が商業・観光・金融などのサービス産業の中心地であり、特に京都の観光関連産業とその他都市の流通・金融機能が大きいです。伝統文化を活かした観光産業の成長が注目されています。',
    difficulty: 'hard',
    keywords: ['近畿サービス業30%', '第2位', '大阪・京都・兵庫'],
  ),
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STAGE 5: 九州・沖縄（15問）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const List<StageQuestion> stageFiveQuestions = [
  // s5q1
  StageQuestion(
    id: 's5q1',
    stageId: 's5',
    questionNumber: 1,
    region: '九州',
    question: '九州に含まれる都道府県は全部で何個？',
    options: ['6個', '7個', '8個', '9個'],
    correctIndex: 2,
    explanation:
        '九州は福岡県、佐賀県、長崎県、熊本県、大分県、宮崎県、鹿児島県、沖縄県の8つの県で構成されています。面積は約22,100km²で、西南日本最大の島嶼地帯です。日本の南西端に位置し、アジア大陸に最も近い地理的特性から、古来より国際交易・文化交流の中心地でした。',
    difficulty: 'easy',
    keywords: ['九州8県', '福岡佐賀長崎熊本大分宮崎鹿児島沖縄', '面積22100km²'],
  ),

  // s5q2
  StageQuestion(
    id: 's5q2',
    stageId: 's5',
    questionNumber: 2,
    region: '九州',
    question: '九州の総人口は日本全体の何パーセント程度？',
    options: ['約7%', '約10%', '約12%', '約15%'],
    correctIndex: 1,
    explanation:
        '九州の総人口は約1,300万人で、日本全体（約1億2,500万人）の約10%を占めています。福岡県が九州全体の40%以上の人口を占めており、著しい一極集中が生じています。九州全体では人口が減少傾向にあり、特に山間部・離島での過疎化が深刻化しています。',
    difficulty: 'normal',
    keywords: ['九州人口10%', '1300万人', '福岡一極集中', '過疎化'],
  ),

  // s5q3
  StageQuestion(
    id: 's5q3',
    stageId: 's5',
    questionNumber: 3,
    region: '九州',
    question: '福岡県の経済規模（名目GDP）は全国の何パーセント程度？',
    options: ['約3%', '約5%', '約7%', '約10%'],
    correctIndex: 2,
    explanation:
        '福岡県の名目GDPは約23兆円で、全国の約7%を占めます。九州地方では圧倒的に高く、福岡市は博多港の国際港湾機能と商業・金融の集中により、九州の経済中心地となっています。特にIT産業・自動車産業の拠点として注目されており、アジア経済との接点としても重要な位置にあります。',
    difficulty: 'normal',
    keywords: ['福岡県GDP7%', '23兆円', '九州経済中心', 'IT・自動車産業'],
  ),

  // s5q4
  StageQuestion(
    id: 's5q4',
    stageId: 's5',
    questionNumber: 4,
    region: '九州',
    question: '博多港の国際的な重要性は？',
    options: ['東アジア物流の中心', '国内流通の中心', '九州地方内での流通', '特に重要ではない'],
    correctIndex: 0,
    explanation:
        '博多港は福岡県にある国際港湾で、東アジア物流の重要な結節点です。中国・韓国・東南アジアとの国際海運ルートの中心地であり、コンテナ取扱量が全国上位を占めています。特に造船業・自動車産業の輸出拠点として機能しており、九州経済の大動脈です。',
    difficulty: 'normal',
    keywords: ['博多港国際港湾', '東アジア物流中心', 'コンテナ取扱'],
  ),

  // s5q5
  StageQuestion(
    id: 's5q5',
    stageId: 's5',
    questionNumber: 5,
    region: '九州',
    question: '佐賀県の農業産出額は全国の何パーセント程度？',
    options: ['約1%', '約2%', '約3%', '約4%'],
    correctIndex: 2,
    explanation:
        '佐賀県の農業産出額は約400億円で、全国の約3%を占めます。有明海の干潟を活用した海苔養殖が特に有名で、全国の約30%の生産シェアを持っています。また水稲・麦・野菜栽培も盛んで、農業が地域経済の重要な産業です。玄界灘での漁業も活発です。',
    difficulty: 'normal',
    keywords: ['佐賀県農業3%', '有明海海苔30%', 'の海苔養殖'],
  ),

  // s5q6
  StageQuestion(
    id: 's5q6',
    stageId: 's5',
    questionNumber: 6,
    region: '九州',
    question: '長崎県の特徴は？',
    options: ['農業県', 'リアス式海岸の漁業県', '工業県', 'すべて'],
    correctIndex: 1,
    explanation:
        '長崎県は複雑なリアス式海岸を持つ漁業県で、水産業産出額が全国5位です。特にイカ・トラフグ・ヒオウギガイなどが主要産物で、五島列島やつじみ地方が有名な漁場です。また東シナ海・九州西沖での遠洋漁業も盛んです。江戸時代の鎖国時代には唯一の対外貿易地であり、国際交易の拠点でもありました。',
    difficulty: 'normal',
    keywords: ['長崎県漁業', 'リアス式海岸', 'イカ・トラフグ', '鎖国時代貿易'],
  ),

  // s5q7
  StageQuestion(
    id: 's5q7',
    stageId: 's5',
    questionNumber: 7,
    region: '九州',
    question: '熊本県の農業産出額は全国の何パーセント程度？',
    options: ['約2%', '約3%', '約4%', '約5%'],
    correctIndex: 3,
    explanation:
        '熊本県の農業産出額は約1,800億円で、全国の約5%を占める有数の農業県です。熊本平野での水稲栽培のほか、トマト・スイカ・メロン・グリーンアスパラなどの野菜栽培が盛んで、特にトマト生産は全国3位です。また畜産業も発達し、熊本牛は高級和牛として知られています。',
    difficulty: 'normal',
    keywords: ['熊本県農業5%', 'トマト・スイカ・メロン', '熊本牛'],
  ),

  // s5q8
  StageQuestion(
    id: 's5q8',
    stageId: 's5',
    questionNumber: 8,
    region: '九州',
    question: '大分県の工業産出額は全国の何パーセント程度？',
    options: ['約1%', '約2%', '約3%', '約4%'],
    correctIndex: 2,
    explanation:
        '大分県の工業産出額は全国の約3%で、九州内では福岡・熊本に次ぐ規模です。石油化学・自動車部品・電子機器などが主要産業で、特に中津・臼杵地方の工業団地が発展してきました。また地熱発電も全国で有数であり、再生可能エネルギーの拠点として注目されています。',
    difficulty: 'normal',
    keywords: ['大分県工業3%', '石油化学・自動車部品', '地熱発電'],
  ),

  // s5q9
  StageQuestion(
    id: 's5q9',
    stageId: 's5',
    questionNumber: 9,
    region: '九州',
    question: '宮崎県の農業産出額は全国の何パーセント程度？',
    options: ['約2%', '約3%', '約4%', '約5%'],
    correctIndex: 2,
    explanation:
        '宮崎県の農業産出額は約1,600億円で、全国の約4%を占める重要な農業県です。温暖な気候を活かしたマンゴー・きゅうり・トマト・えんどう豆などの野菜・果実栽培が盛んで、特にマンゴー（太陽のタマゴ）は高級ブランドとして知られています。また宮崎牛も全国的に有名です。',
    difficulty: 'normal',
    keywords: ['宮崎県農業4%', 'マンゴー・太陽のタマゴ', '宮崎牛'],
  ),

  // s5q10
  StageQuestion(
    id: 's5q10',
    stageId: 's5',
    questionNumber: 10,
    region: '九州',
    question: '鹿児島県の特徴は？',
    options: ['農業県', '水産県', '観光県', 'すべて'],
    correctIndex: 3,
    explanation:
        '鹿児島県は農業・水産業・観光業が共存する多角産業県です。農業では薩摩いも・茶・野菜栽培が盛ん（農業産出額全国5位程度）で、特に薩摩いもは全国シェアの約30%を占めます。また黒豚・黒牛などの畜産品も有名です。桜島・屋久島などの観光資源も豊富で、年間約1,000万人の観光客が訪れます。',
    difficulty: 'normal',
    keywords: ['鹿児島県多角産業', '薩摩いも30%', '黒豚・黒牛', '桜島・屋久島'],
  ),

  // s5q11
  StageQuestion(
    id: 's5q11',
    stageId: 's5',
    questionNumber: 11,
    region: '九州',
    question: '沖縄県の特徴は？',
    options: ['唯一の島しょ県', '亜熱帯気候', 'アメリカ影響が大きい', 'すべて'],
    correctIndex: 3,
    explanation:
        '沖縄県は日本唯一の亜熱帯県であり、離島県です。年平均気温が約22℃と全国平均より10℃以上高く、独特の島嶼社会を形成しています。米国の統治を経て1972年に日本に復帰し、現在も米軍基地が集中（日本の基地の約70%）しており、独特の歴史・政治背景を持っています。観光産業が重要で、年間約900万人が訪れます。',
    difficulty: 'normal',
    keywords: ['沖縄県亜熱帯', '年平均気温22℃', '米軍基地70%', '観光900万人'],
  ),

  // s5q12
  StageQuestion(
    id: 's5q12',
    stageId: 's5',
    questionNumber: 12,
    region: '九州',
    question: '九州の火山活動の特徴は？',
    options: ['活発ではない', 'やや活発', '非常に活発', 'データなし'],
    correctIndex: 2,
    explanation:
        '九州は日本でも有数の火山活動地帯で、桜島（鹿児島）・阿蘇山（熊本）・霧島山（宮崎）など多くの活火山があります。特に桜島は年間200～300回の噴火が発生し、世界的に有名な活火山です。一方で温泉資源も豊富（全国の約40%が九州）であり、観光・発電などの産業に活用されています。火山防災の対策が重要課題です。',
    difficulty: 'hard',
    keywords: ['九州火山活発', '桜島・阿蘇山', '温泉資源40%', '火山防災'],
  ),

  // s5q13
  StageQuestion(
    id: 's5q13',
    stageId: 's5',
    questionNumber: 13,
    region: '九州',
    question: '九州地方の人口減少率は全国と比べてどう？',
    options: ['全国より低い', '全国と同等', '全国より高い', 'データなし'],
    correctIndex: 2,
    explanation:
        '九州地方は全国より高い人口減少率を示す地域です。1980年の九州の人口は約1,450万人でしたが、2020年は約1,300万人と約10%減少しました。特に山間地・離島での過疎化が深刻で、福岡への一極集中が続いています。若年層の東京・大阪への転出が続いており、地方経済の停滞が課題です。',
    difficulty: 'hard',
    keywords: ['九州人口減少率高い', '10%減少', '福岡一極集中', '過疎化深刻'],
  ),

  // s5q14
  StageQuestion(
    id: 's5q14',
    stageId: 's5',
    questionNumber: 14,
    region: '九州',
    question: '九州地方の工業産出額は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約10%', '約12%'],
    correctIndex: 2,
    explanation:
        '九州地方の工業産出額は全国の約10%を占めます。福岡・熊本・大分を中心に自動車・電子機器・化学・造船などの産業が立地しており、特に自動車産業（トヨタ関連工場など）が重要です。しかし製造業の空洞化も進んでおり、サービス産業へのシフトが課題です。',
    difficulty: 'normal',
    keywords: ['九州工業10%', '自動車産業', '製造業空洞化', 'サービス産業'],
  ),

  // s5q15
  StageQuestion(
    id: 's5q15',
    stageId: 's5',
    questionNumber: 15,
    region: '九州',
    question: '九州地方の観光客数は全国の何パーセント程度？',
    options: ['約5%', '約8%', '約10%', '約12%'],
    correctIndex: 2,
    explanation:
        '九州地方の観光客数は全国の約10%を占め、国内観光地として重要な位置にあります。福岡市・熊本城・別府温泉・長崎（異国情緒）・沖縄（ビーチリゾート）など、多様な観光資源が存在します。特に沖縄への外国人観光客は増加傾向で、アジア圏から多くの観光客が訪れており、観光産業が地域経済を支える重要な産業です。',
    difficulty: 'hard',
    keywords: ['九州観光客10%', '福岡・熊本城・別府', '長崎・沖縄', '外国人増加'],
  ),
];

/// すべてのステージ問題を統合したリスト
const List<StageQuestion> allStageQuestions = [
  ...stageOneQuestions,
  ...stageTwoQuestions,
  ...stageThreeQuestions,
  ...stageFourQuestions,
  ...stageFiveQuestions,
];

/// ステージIDでフィルタリング
List<StageQuestion> getQuestionsByStage(String stageId) {
  return allStageQuestions
      .where((q) => q.stageId == stageId)
      .toList();
}

/// 問題IDで単一問題を取得
StageQuestion? getQuestionById(String questionId) {
  try {
    return allStageQuestions.firstWhere((q) => q.id == questionId);
  } catch (_) {
    return null;
  }
}
