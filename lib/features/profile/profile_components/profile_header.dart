import 'package:flutter/material.dart';
import '../../../themes/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profilePictureUrl;
  final bool isLoading;
  final bool isEditing;
  final Color primaryColor;
  final VoidCallback onEditPicture;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.isLoading,
    required this.isEditing,
    required this.primaryColor,
    required this.onEditPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: context.divider,
                  backgroundImage: profilePictureUrl != null
                      ? NetworkImage(profilePictureUrl!)
                      : null,
                  child: profilePictureUrl == null
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: context.textHint,
                  )
                      : null,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black54,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              if (isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: isLoading ? null : onEditPicture,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: context.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}