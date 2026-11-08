import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_health_app/features/profile/profile_components/account_stats_card.dart';
import 'package:mental_health_app/features/profile/profile_components/image_source_dialog.dart';
import 'package:mental_health_app/features/profile/profile_components/profile_header.dart';
import 'package:mental_health_app/features/profile/profile_components/profile_info_card.dart';
import '../auth/presentation/cubits/auth_cubit.dart';
import 'data/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      final imageFile = File(image.path);
      await _userProfileService.uploadProfilePicture(imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ImageSourceDialog(
          onCameraSelected: _pickImage,
          onGallerySelected: _pickImage,
          onRemovePhoto: () async {
            setState(() => _isLoading = true);
            await _userProfileService.deleteProfilePicture();
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile picture removed')),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userProfileService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      context.read<AuthCubit>().refreshUser();

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  void _resetControllers(Map<String, dynamic> profile) {
    _nameController.text = profile['name'] ?? '';
    _emailController.text = profile['email'] ?? '';
    _bioController.text = profile['bio'] ?? '';
    _phoneController.text = profile['phoneNumber'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isLoading ? null : _saveProfile,
            ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _userProfileService.getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No profile data found'),
            );
          }

          final profile = snapshot.data!;

          if (!_isEditing && _nameController.text.isEmpty) {
            _resetControllers(profile);
          }

          final profilePictureUrl = profile['profilePictureUrl'] as String?;

          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  name: profile['name'] ?? 'User',
                  email: profile['email'] ?? '',
                  profilePictureUrl: profilePictureUrl,
                  isLoading: _isLoading,
                  isEditing: _isEditing,
                  primaryColor: primaryColor,
                  onEditPicture: _showImageSourceDialog,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileInfoCard(
                        icon: Icons.person_outline,
                        label: 'Name',
                        controller: _nameController,
                        enabled: _isEditing,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        controller: _emailController,
                        enabled: false,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      ProfileInfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        controller: _phoneController,
                        enabled: _isEditing,
                        primaryColor: primaryColor,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      ProfileInfoCard(
                        icon: Icons.info_outline,
                        label: 'Bio',
                        controller: _bioController,
                        enabled: _isEditing,
                        primaryColor: primaryColor,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      AccountStatsCard(
                        profile: profile,
                        primaryColor: primaryColor,
                      ),
                      if (_isEditing) _buildActionButtons(profile),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> profile) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  setState(() => _isEditing = false);
                  _resetControllers(profile);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}