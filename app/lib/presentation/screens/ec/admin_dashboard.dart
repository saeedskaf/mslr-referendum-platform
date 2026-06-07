// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mslr/data/local_secure/secure_storage.dart';
import 'package:mslr/domain/models/admin_referendum_model.dart';
import 'package:mslr/domain/services/referendum_services.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = false;
  List<AdminReferendum> referendums = [];
  int totalReferendums = 0;
  int openReferendums = 0;
  int closedReferendums = 0;

  @override
  void initState() {
    super.initState();
    _loadReferendums();
  }

  Future<void> _loadReferendums() async {
    setState(() => _isLoading = true);
    final result = await referendumService.getAllAdminReferendums();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        final AdminReferendumModel model = result['data'];
        setState(() {
          referendums = model.referendums;
          _calculateStats();
        });
      } else {
        ShowMessage.error(context, result['message']);
      }
    }
  }

  void _calculateStats() {
    totalReferendums = referendums.length;
    openReferendums = referendums.where((r) => r.isOpen).length;
    closedReferendums = referendums.where((r) => r.isClosed).length;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const TextCustom(
          text: 'Logout',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: const TextCustom(
          text: 'Are you sure you want to logout?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextCustom(text: 'Cancel', color: Colors.grey),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const TextCustom(
              text: 'Logout',
              color: ColorsCustom.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      LoadingModal.show(context, message: 'Logging out...');
      await secureStorage.clearAll();
      LoadingModal.dismiss(context);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    }
  }

  Future<void> _createNewReferendum() async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/create-referendum',
    );
    if (result == true) {
      _loadReferendums();
    }
  }

  Future<void> _toggleReferendumStatus(AdminReferendum referendum) async {
    final action = referendum.isOpen ? 'close' : 'open';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: TextCustom(
          text:
              '${action.substring(0, 1).toUpperCase()}${action.substring(1)} Referendum',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: TextCustom(
          text: 'Are you sure you want to $action this referendum?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextCustom(text: 'Cancel', color: Colors.grey),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: TextCustom(
              text: action.substring(0, 1).toUpperCase() + action.substring(1),
              color: referendum.isOpen
                  ? ColorsCustom.errorColor
                  : ColorsCustom.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      LoadingModal.show(
        context,
        message:
            '${action.substring(0, 1).toUpperCase()}${action.substring(1)}ing referendum...',
      );

      final newStatus = referendum.isOpen ? 'closed' : 'open';
      final result = await referendumService.toggleReferendumStatus(
        referendum.id,
        newStatus,
      );

      LoadingModal.dismiss(context);

      if (mounted) {
        if (result['success']) {
          ShowMessage.success(context, 'Referendum ${action}ed successfully');
          _loadReferendums();
        } else {
          ShowMessage.error(context, result['message']);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsCustom.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const TextCustom(
          text: 'Election Commission',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReferendums,
        color: ColorsCustom.primaryColor,
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: ColorsCustom.primaryColor,
                      ),
                    )
                  : referendums.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewReferendum,
        backgroundColor: ColorsCustom.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const TextCustom(
          text: 'New Referendum',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: ColorsCustom.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TextCustom(text: 'Welcome,', fontSize: 16, color: Colors.white70),
          SizedBox(height: 4),
          TextCustom(
            text: 'Election Commission',
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.how_to_vote,
              label: 'Total',
              value: totalReferendums.toString(),
              color: ColorsCustom.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.lock_open,
              label: 'Open',
              value: openReferendums.toString(),
              color: ColorsCustom.secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.lock,
              label: 'Closed',
              value: closedReferendums.toString(),
              color: ColorsCustom.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          TextCustom(
            text: value,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          const SizedBox(height: 4),
          TextCustom(text: label, fontSize: 11, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: referendums.length,
      itemBuilder: (context, index) => _buildCard(referendums[index]),
    );
  }

  Widget _buildCard(AdminReferendum referendum) {
    final isOpen = referendum.isOpen;
    // Can only edit if referendum has NEVER been opened (is_locked = false)
    final canEdit = !referendum.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusBadge(isOpen),
                    if (referendum.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 10,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            TextCustom(
                              text: 'READ-ONLY',
                              fontSize: 10,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'edit' && canEdit) {
                    Navigator.pushNamed(
                      context,
                      '/admin/edit-referendum',
                      arguments: referendum,
                    ).then((result) {
                      if (result == true) _loadReferendums();
                    });
                  } else if (value == 'toggle') {
                    _toggleReferendumStatus(referendum);
                  }
                },
                itemBuilder: (context) => [
                  if (canEdit)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          const TextCustom(text: 'Edit', fontSize: 14),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isOpen ? Icons.lock : Icons.lock_open,
                          size: 18,
                          color: isOpen
                              ? ColorsCustom.errorColor
                              : ColorsCustom.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        TextCustom(
                          text: isOpen ? 'Close' : 'Open',
                          fontSize: 14,
                          color: isOpen
                              ? ColorsCustom.errorColor
                              : ColorsCustom.secondaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextCustom(
            text: referendum.title,
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          TextCustom(
            text: referendum.description,
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const TextCustom(
            text: 'Options & Votes:',
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          ...referendum.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorsCustom.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.how_to_vote,
                      size: 14,
                      color: ColorsCustom.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextCustom(
                      text: option.optionText,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsCustom.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextCustom(
                      text: '${option.voteCount}',
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsCustom.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextCustom(
                  text: 'Total Votes:',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                TextCustom(
                  text: '${referendum.totalVotes}',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? ColorsCustom.secondaryColor.withOpacity(0.1)
            : ColorsCustom.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.lock_open : Icons.lock,
            size: 12,
            color: isOpen
                ? ColorsCustom.secondaryColor
                : ColorsCustom.errorColor,
          ),
          const SizedBox(width: 4),
          TextCustom(
            text: isOpen ? 'OPEN' : 'CLOSED',
            fontSize: 11,
            color: isOpen
                ? ColorsCustom.secondaryColor
                : ColorsCustom.errorColor,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const TextCustom(
            text: 'No referendums created yet',
            fontSize: 16,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const TextCustom(
            text: 'Tap the button below to create your first referendum',
            fontSize: 13,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
