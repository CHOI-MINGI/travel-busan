import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool reservationNotification = true;
  bool eventNotification = true;
  bool marketingNotification = false;
  bool pushSound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(
            children: [
              _switchTile('예약 및 일정 알림', reservationNotification, (v) {
                setState(() => reservationNotification = v);
              }),
              _divider(),
              _switchTile('이벤트 및 혜택 알림', eventNotification, (v) {
                setState(() => eventNotification = v);
              }),
              _divider(),
              _switchTile('마케팅 수신 동의', marketingNotification, (v) {
                setState(() => marketingNotification = v);
              }),
              _divider(),
              _switchTile('푸시 알림 소리', pushSound, (v) {
                setState(() => pushSound = v);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFEEF1F5));
}