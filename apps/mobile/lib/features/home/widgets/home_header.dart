import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile/profile_controller.dart';

class HomeHeader extends GetView<ProfileController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final profile = controller.userProfile.value;
            final imageUrl = controller.profileImageUrl;

            return Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : const DecorationImage(
                            image: AssetImage(
                              'assets/images/profile_placeholder.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: imageUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      controller.isLoading.value
                          ? 'Fetching profile...'
                          : (profile?.name.isNotEmpty == true
                                ? profile!.name
                                : 'User'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
