import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';

class FatwaScreen extends StatefulWidget {
  const FatwaScreen({super.key});

  @override
  State<FatwaScreen> createState() => _FatwaScreenState();
}

class _FatwaScreenState extends State<FatwaScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Fatwa>> _fatawaFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _fatawaFuture = _apiService.fetchFatawa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Fatwa & Q&A"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Ask Question"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppTheme.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search for fatwas or questions...",
                      hintStyle: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 15),
                      icon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ),

              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Knowledge is Light",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Browse over 10,000 verified answers from leading scholars.",
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF16A085),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                elevation: 0,
                              ),
                              child: Text(
                                "EXPLORE ARCHIVE",
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.2), size: 100),
                    ],
                  ),
                ),
              ),

              // Categories
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categories",
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "View All",
                        style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _buildCategoryCard("Marriage", Icons.favorite, const Color(0xFFFFEBEE), Colors.redAccent),
                    _buildCategoryCard("Finance", Icons.account_balance, const Color(0xFFE8EAF6), Colors.indigoAccent),
                    _buildCategoryCard("Worship", Icons.mosque_rounded, const Color(0xFFE8F5E9), Colors.green),
                    _buildCategoryCard("Inheritance", Icons.groups_rounded, const Color(0xFFFFF3E0), Colors.orangeAccent),
                  ],
                ),
              ),

              // Recently Answered
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Recently Answered",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              FutureBuilder<List<Fatwa>>(
                future: _fatawaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return _buildDemoFatwaList(); // Demo list if backend fails
                  }
                  final fatawa = snapshot.data ?? [];
                  if (fatawa.isEmpty) {
                    return const Center(child: Text("No fatawa found."));
                  }
                  return Column(
                    children: fatawa.map((f) => _buildFatwaCard(f)).toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoFatwaList() {
    return Column(
      children: [
        _buildFatwaCard(Fatwa(
          id: 0,
          category: "Finance",
          date: "2 hours ago",
          question: "Is it permissible to trade cryptocurrency for long-term investment?",
          answer: "In principle, trading is permissible provided the assets do not involve Riba...",
          scholar: "Mufti A. Rahman",
        )),
        _buildFatwaCard(Fatwa(
          id: 1,
          category: "Marriage",
          date: "5 hours ago",
          question: "The status of a marriage contract performed via video conference?",
          answer: "Scholars have discussed the modern application of Nikah through digital means...",
          scholar: "Dr. Sarah Khalil",
        )),
      ],
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFatwaCard(Fatwa fatwa) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: fatwa.category == "Finance" ? const Color(0xFFE0F2F1) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fatwa.category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: fatwa.category == "Finance" ? const Color(0xFF00796B) : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                fatwa.date, // Backend usually returns relative time string or we format it
                style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            fatwa.question,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            fatwa.answer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(color: AppTheme.textGrey, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFFE8F8F5), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                fatwa.scholar,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark),
              ),
              const Spacer(),
              Text(
                "Read More",
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primaryGreen, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
