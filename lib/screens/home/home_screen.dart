import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shield_logo.dart';
import '../report/create_report_screen.dart';
import '../report/my_reports_screen.dart';
import '../report/report_detail_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  String _selectedFilter = 'All Reports';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const AppShieldLogo(size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Incident Feed',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryCoral),
            tooltip: 'File New Report',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateReportScreen()),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 6),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primaryCoral,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.onCoralText,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _selectedNavIndex == 0
          ? _buildFeedBody()
          : _selectedNavIndex == 1
              ? const MyReportsScreen()
              : _selectedNavIndex == 2
                  ? const MapScreen()
                  : const ProfileScreen(),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateReportScreen()),
              ),
              backgroundColor: AppColors.primaryCoral,
              foregroundColor: AppColors.onCoralText,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 30),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) => setState(() => _selectedNavIndex = index),
          backgroundColor: AppColors.bg,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryCoral,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedBody() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        // User Trust Score Mini Header Banner
        if (uid != null)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final score = data?['trustScore'] ?? 100;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            size: 18, color: AppColors.trustGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Trust Score',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$score / 100',
                      style: const TextStyle(
                        color: AppColors.trustGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Live Feed Sub-Header (Matching Image 5)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.trustGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE FEED',
                    style: TextStyle(
                      color: AppColors.trustGreen,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  children: [
                    TextSpan(text: 'Active Reports  '),
                    TextSpan(
                      text: '12',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Bar (Matching Image 5)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search report ID, location...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),

        // Filter Pills Row (Matching Image 5)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('All Reports'),
              const SizedBox(width: 8),
              _buildFilterChip('High Severity'),
              const SizedBox(width: 8),
              _buildFilterChip('Pending Review'),
            ],
          ),
        ),

        // StreamBuilder Feed List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.criticalRed)),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryCoral),
                );
              }

              final docs = snapshot.data!.docs;

              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final desc = (data['description'] ?? '').toString().toLowerCase();
                final loc = (data['location']?['address'] ?? '').toString().toLowerCase();
                final id = doc.id.toLowerCase();

                final matchesSearch = _searchQuery.isEmpty ||
                    desc.contains(_searchQuery) ||
                    loc.contains(_searchQuery) ||
                    id.contains(_searchQuery);

                if (!matchesSearch) return false;

                if (_selectedFilter == 'High Severity') {
                  final priority = (data['priority'] ?? '').toString().toUpperCase();
                  return priority == 'HIGH' || priority == 'CRITICAL';
                }
                if (_selectedFilter == 'Pending Review') {
                  final verdict = (data['verdict'] ?? '').toString().toLowerCase();
                  return verdict.isEmpty || verdict == 'pending';
                }
                return true;
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredDocs.isEmpty ? 4 : filteredDocs.length + 1,
                itemBuilder: (context, index) {
                  if (filteredDocs.isEmpty) {
                    return _buildDemoCard(index);
                  }

                  if (index == 1) {
                    return _buildProximityMapTile(context);
                  }

                  final docIndex = index > 1 ? index - 1 : index;
                  if (docIndex >= filteredDocs.length) return const SizedBox();

                  final doc = filteredDocs[docIndex];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildReportCard(context, doc.id, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCoral : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryCoral : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.onCoralText : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String reportId, Map<String, dynamic> data) {
    final desc = data['description'] ?? 'Suspicious Activity Reported';
    final locationText = data['location']?['address'] ?? 'Grand Central Terminal, Area 4';
    final priority = (data['priority'] ?? 'CRITICAL').toString().toUpperCase();
    final ts = (data['createdAt'] as Timestamp?)?.toDate();
    final timeStr = ts != null ? DateFormat('HH:mm').format(ts) : '2 mins ago';

    Color badgeColor = AppColors.criticalRed;
    if (priority == 'MEDIUM') badgeColor = AppColors.highPriorityAmber;
    if (priority == 'LOW') badgeColor = AppColors.lowPriorityGrey;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${reportId.substring(0, reportId.length > 7 ? 7 : reportId.length).toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationText,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined, size: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.videocam_outlined, size: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(report: data),
                  ),
                ),
                child: Row(
                  children: const [
                    Text(
                      'REVIEW DETAILS',
                      style: TextStyle(
                        color: AppColors.primaryCoral,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.primaryCoral),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProximityMapTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2028),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.map_outlined,
                size: 60,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bg.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Text(
                  'Live Proximity Map',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(int index) {
    final mockData = [
      {
        'id': 'DR-8821',
        'priority': 'CRITICAL',
        'title': 'Suspicious Exchange',
        'location': 'Grand Central Terminal, Area 4',
        'time': '2 mins ago',
      },
      {
        'id': 'DR-8819',
        'priority': 'MEDIUM',
        'title': 'Abandoned Package',
        'location': '14th Street Subway Station',
        'time': '15 mins ago',
      },
      {
        'id': 'DR-8815',
        'priority': 'LOW',
        'title': 'Graffiti/Vandalism',
        'location': 'Washington Square Park',
        'time': '42 mins ago',
      },
    ];

    if (index == 1) return _buildProximityMapTile(context);
    final data = mockData[index > 1 ? index - 1 : index];

    return _buildReportCard(
      context,
      data['id']!,
      {
        'description': data['title'],
        'priority': data['priority'],
        'location': {'address': data['location']},
        'createdAt': Timestamp.now(),
      },
    );
  }
}
