import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool profilePublic = true;
  bool locationShare = false;
  bool reviewPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('개인정보 보호'),
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
                  value: profilePublic,
                  onChanged: (v) => setState(() => profilePublic = v),
                  title: const Text('프로필 공개'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: locationShare,
                  onChanged: (v) => setState(() => locationShare = v),
                  title: const Text('위치 정보 사용'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: reviewPublic,
                  onChanged: (v) => setState(() => reviewPublic = v),
                  title: const Text('리뷰 공개'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}