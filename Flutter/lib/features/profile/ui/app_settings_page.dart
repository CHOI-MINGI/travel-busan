import 'package:flutter/material.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool darkMode = false;
  bool autoPlayVideo = true;
  bool saveMobileData = false;
  String language = '한국어';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('앱 설정'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: darkMode,
                  onChanged: (v) => setState(() => darkMode = v),
                  title: const Text('다크 모드'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: autoPlayVideo,
                  onChanged: (v) => setState(() => autoPlayVideo = v),
                  title: const Text('동영상 자동 재생'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: saveMobileData,
                  onChanged: (v) => setState(() => saveMobileData = v),
                  title: const Text('데이터 절약 모드'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('언어'),
                  subtitle: Text(language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await showModalBottomSheet<String>(
                      context: context,
                      builder: (_) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('한국어'),
                                onTap: () => Navigator.pop(context, '한국어'),
                              ),
                              ListTile(
                                title: const Text('English'),
                                onTap: () => Navigator.pop(context, 'English'),
                              ),
                              ListTile(
                                title: const Text('日本語'),
                                onTap: () => Navigator.pop(context, '日本語'),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (selected != null) {
                      setState(() => language = selected);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}