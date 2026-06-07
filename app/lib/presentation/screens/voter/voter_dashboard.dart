// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mslr/data/local_secure/secure_storage.dart';
import 'package:mslr/domain/models/referendum_model.dart';
import 'package:mslr/domain/services/referendum_services.dart';
import 'package:mslr/presentation/components/text_custom.dart';
import 'package:mslr/presentation/helpers/modal_loading.dart';
import 'package:mslr/presentation/helpers/show_message.dart';
import 'package:mslr/presentation/themes/colors_custom.dart';

class VoterDashboard extends StatefulWidget {
  const VoterDashboard({super.key});

  @override
  State<VoterDashboard> createState() => _VoterDashboardState();
}

class _VoterDashboardState extends State<VoterDashboard> {
  String voterName = "";
  bool _isLoading = false;
  List<VoterReferendum> referendums = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadReferendums();
  }

  Future<void> _loadUserData() async {
    final userData = await secureStorage.getUserData();
    if (mounted) {
      setState(() => voterName = userData['name'] ?? 'Voter');
    }
  }

  Future<void> _loadReferendums() async {
    setState(() => _isLoading = true);
    final result = await referendumService.getAllReferendums();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        final VoterReferendumModel model = result['data'];
        setState(() => referendums = model.referendums);
      } else {
        ShowMessage.error(context, result['message']);
      }
    }
  }

  Future<void> _handleVote(
    VoterReferendum referendum,
    VoterOption option,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const TextCustom(
          text: 'Confirm Vote',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              text: 'Are you sure you want to vote for:',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorsCustom.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextCustom(
                text: option.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            TextCustom(
              text: 'This action cannot be undone.',
              fontSize: 13,
              color: Colors.orange.shade700,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TextCustom(text: 'Cancel', color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsCustom.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const TextCustom(
              text: 'Confirm',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      LoadingModal.show(context, message: 'Casting your vote...');

      final result = await referendumService.castVote(
        referendumId: referendum.id,
        optionId: option.id,
      );

      LoadingModal.dismiss(context);

      if (mounted) {
        if (result['success']) {
          ShowMessage.success(context, 'Vote cast successfully!');
          _loadReferendums();
        } else {
          ShowMessage.error(context, result['message']);
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsCustom.backgroundColor,
      appBar: AppBar(
        backgroundColor: ColorsCustom.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const TextCustom(
          text: 'Referendums',
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
        children: [
          const TextCustom(
            text: 'Welcome,',
            fontSize: 16,
            color: Colors.white70,
          ),
          const SizedBox(height: 4),
          TextCustom(
            text: voterName.isNotEmpty ? voterName : 'Loading...',
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildCard(VoterReferendum referendum) {
    final isOpen = referendum.isOpen;
    final hasVoted = referendum.voted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? ColorsCustom.secondaryColor.withOpacity(0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextCustom(
                        text: isOpen ? 'OPEN' : 'CLOSED',
                        fontSize: 11,
                        color: isOpen
                            ? ColorsCustom.secondaryColor
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasVoted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsCustom.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: ColorsCustom.primaryColor,
                            ),
                            SizedBox(width: 4),
                            TextCustom(
                              text: 'VOTED',
                              fontSize: 11,
                              color: ColorsCustom.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                TextCustom(
                  text: referendum.title,
                  fontSize: 17,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 6),
                TextCustom(
                  text: referendum.description,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade200),

          // Options section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: referendum.options.map((option) {
                final isUserVote = referendum.selectedOption?.id == option.id;
                // final showResults = hasVoted || !isOpen;

                return GestureDetector(
                  onTap: (isOpen && !hasVoted)
                      ? () => _handleVote(referendum, option)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserVote
                          ? ColorsCustom.primaryColor.withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUserVote
                            ? ColorsCustom.primaryColor
                            : Colors.grey.shade200,
                        width: isUserVote ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio or check icon
                        if (isOpen && !hasVoted)
                          Icon(
                            Icons.radio_button_unchecked,
                            size: 20,
                            color: Colors.grey.shade400,
                          )
                        else if (isUserVote)
                          const Icon(
                            Icons.check_circle,
                            size: 20,
                            color: ColorsCustom.primaryColor,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            size: 20,
                            color: Colors.grey.shade300,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextCustom(
                            text: option.text,
                            fontSize: 14,
                            color: isUserVote
                                ? ColorsCustom.primaryColor
                                : Colors.black87,
                            fontWeight: isUserVote
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        // if (showResults)
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 8,
                        //       vertical: 4,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: isUserVote
                        //           ? ColorsCustom.primaryColor.withOpacity(0.2)
                        //           : Colors.grey.shade200,
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(
                        //           Icons.person,
                        //           size: 14,
                        //           color: isUserVote
                        //               ? ColorsCustom.primaryColor
                        //               : Colors.grey.shade600,
                        //         ),
                        //         const SizedBox(width: 4),
                        //         TextCustom(
                        //           text: '${option.voteCount}',
                        //           fontSize: 13,
                        //           fontWeight: FontWeight.w600,
                        //           color: isUserVote
                        //               ? ColorsCustom.primaryColor
                        //               : Colors.grey.shade600,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
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
          Icon(
            Icons.how_to_vote_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const TextCustom(
            text: 'No referendums available',
            fontSize: 16,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const TextCustom(
            text: 'Check back later for new questions',
            fontSize: 13,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
