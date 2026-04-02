import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color qalaamGreen = Color(0xFF2ECC71);
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 30),
          _buildSectionHeader("Account"),
          _buildSettingTile(Icons.person_outline, "Edit Profile", "Change name, email and phone", () {}),
          _buildSettingTile(Icons.lock_outline, "Privacy & Security", "Change password and security settings", () {}),
          const SizedBox(height: 20),
          _buildSectionHeader("Preferences"),
          _buildSwitchTile(Icons.notifications_none, "Push Notifications", "Receive prayer alerts and news", _notificationsEnabled, (val) {
            setState(() => _notificationsEnabled = val);
          }),
          _buildSettingTile(Icons.language, "App Language", "English (US)", () {}),
          _buildSettingTile(Icons.location_on_outlined, "Location", "Manage location permissions", () {}),
          const SizedBox(height: 20),
          _buildSectionHeader("Support"),
          _buildSettingTile(Icons.help_outline, "Help Center", "FAQs and support guides", () {}),
          _buildSettingTile(Icons.info_outline, "About Qalaam Pro", "Version 2.0.1", () {}),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("LOGOUT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: qalaamGreen.withOpacity(0.1),
            child: const Icon(Icons.person, size: 35, color: qalaamGreen),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assalamu Alaikum,",
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "Ibrahim Zuma",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: qalaamGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "PRO MEMBER",
                    style: GoogleFonts.outfit(color: qalaamGreen, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: qalaamGreen),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        activeColor: qalaamGreen,
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: qalaamGreen),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
