import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/previous_works_viewmodel.dart';
import '../models/profile_model.dart';
import '../../../core/localization/app_localizations.dart';

class PreviousWorksView extends StatelessWidget {
  final ProfileModel profile;

  const PreviousWorksView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PreviousWorksViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('previous_works') != 'previous_works'
              ? context.tr('previous_works')
              : 'الأعمال السابقة',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF637381)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5CA4B8)),
            )
          : vm.errorMessage != null
          ? Center(
              child: Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : vm.works.isEmpty
          ? RefreshIndicator(
              color: Colors.grey,
              backgroundColor: Colors.white,
              onRefresh: vm.fetchWorks,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text('لا توجد أعمال سابقة')),
                ],
              ),
            )
          : RefreshIndicator(
              color: Colors.grey,
              backgroundColor: Colors.white,
              onRefresh: vm.fetchWorks,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: vm.works.length,
                itemBuilder: (context, index) {
                  final work = vm.works[index];
                  return _buildWorkCard(context, work);
                },
              ),
            ),
    );
  }

  Widget _buildWorkCard(BuildContext context, dynamic work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header: Avatar & Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.jobTitle} • الرياض',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF637381),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: profile.avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage(
                              'assets/images/default_avatar.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Work Image
          if (work.imageUrl.isNotEmpty)
            Image.network(
              work.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            ),

          // Actions Space
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.bookmark, color: Color(0xFF5CA4B8)),
                Row(
                  children: const [
                    Icon(Icons.send, color: Color(0xFF637381)),
                    SizedBox(width: 16),
                    Icon(Icons.chat_bubble, color: Color(0xFF637381)),
                    SizedBox(width: 16),
                    Icon(Icons.favorite, color: Color(0xFF5CA4B8)),
                  ],
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  work.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  work.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF637381),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          // Tags
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTag('#الرياض'),
                const SizedBox(width: 8),
                _buildTag('#صيانة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F3F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Color(0xFF5CA4B8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
