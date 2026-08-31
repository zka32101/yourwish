import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_puzzle_king/config/app_config.dart';
import 'package:geography_puzzle_king/config/constants.dart';
import 'package:geography_puzzle_king/providers/auth_provider.dart';
import 'package:geography_puzzle_king/services/audio_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableSoundEffects = true;
  bool _enableBgm = true;
  String _selectedLanguage = 'ja';
  String _playerName = 'ゲストプレイヤー';
  bool _hideFromRanking = false;

  @override
  void initState() {
    super.initState();
    final audio = AudioService();
    _enableBgm = audio.bgmEnabled;
    _enableSoundEffects = audio.sfxEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Profile Section
          _buildSection(
            title: 'ユーザー情報',
            children: [
              _buildSettingTile(
                icon: Icons.person,
                title: 'プレイヤー名',
                subtitle: _playerName,
                onTap: _showPlayerNameDialog,
              ),
              _buildSettingTile(
                icon: Icons.email,
                title: 'メールアドレス',
                subtitle: 'not.logged.in@example.com',
                onTap: () {},
              ),
            ],
          ),
          // Notification Settings
          _buildSection(
            title: '通知設定',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'プッシュ通知',
                subtitle: 'デイリーイベント・対戦通知',
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
            ],
          ),
          // Sound & Vibration
          _buildSection(
            title: 'サウンド設定',
            children: [
              _buildSwitchTile(
                icon: Icons.music_note,
                title: 'BGM',
                subtitle: 'バックグラウンドミュージック',
                value: _enableBgm,
                onChanged: (value) {
                  setState(() {
                    _enableBgm = value;
                  });
                  AudioService().setBgmEnabled(value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: '効果音',
                subtitle: 'ゲーム内の効果音を有効',
                value: _enableSoundEffects,
                onChanged: (value) {
                  setState(() {
                    _enableSoundEffects = value;
                  });
                  AudioService().setSfxEnabled(value);
                },
              ),
            ],
          ),
          // Language Settings
          _buildSection(
            title: '言語設定',
            children: [
              _buildDropdownTile(
                icon: Icons.language,
                title: '言語',
                value: _selectedLanguage,
                items: const {
                  'ja': '日本語',
                  'en': 'English',
                },
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
            ],
          ),
          // Privacy & Legal
          _buildSection(
            title: 'プライバシー・その他',
            children: [
              _buildSwitchTile(
                icon: Icons.visibility_off,
                title: 'ランキング表示',
                subtitle: _hideFromRanking ? '非表示' : 'プレイヤー名を表示',
                value: !_hideFromRanking,
                onChanged: (value) {
                  setState(() {
                    _hideFromRanking = !value;
                  });
                },
              ),
              _buildSettingTile(
                icon: Icons.shield,
                title: 'プライバシーポリシー',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ブラウザで開く: 実装予定'),
                    ),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.description,
                title: '利用規約',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ブラウザで開く: 実装予定'),
                    ),
                  );
                },
              ),
            ],
          ),
          // Version Info
          _buildSection(
            title: 'アプリ情報',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'バージョン',
                          style: AppTextStyles.subtitle1,
                        ),
                        Text(
                          AppConfig.appVersion,
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ビルド番号',
                          style: AppTextStyles.subtitle1,
                        ),
                        Text(
                          AppConfig.buildNumber.toString(),
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Danger Zone
          _buildSection(
            title: 'その他',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showLogoutDialog();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('ログアウト'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(
                            color: AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showDeleteAccountDialog();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('アカウント削除'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            title,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.subtitle1),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.subtitle1),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.subtitle1),
      trailing: DropdownButton<String>(
        value: value,
        items: items.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text(
              'ログアウト',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アカウント削除'),
        content: const Text(
          'このアクションは取り消せません。本当にアカウントを削除しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('アカウント削除: 実装予定'),
                ),
              );
            },
            child: const Text(
              '削除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerNameDialog() {
    final nameController = TextEditingController(text: _playerName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プレイヤー名を変更'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '個人を特定する情報（本名、住所など）は入力しないでください。他のプレイヤーに表示される可能性があります。',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'プレイヤー名',
                hintText: 'ゲストプレイヤー',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _playerName = nameController.text.isEmpty
                    ? 'ゲストプレイヤー'
                    : nameController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
