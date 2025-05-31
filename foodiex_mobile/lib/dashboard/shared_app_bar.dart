import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../auth/login.dart';
import '../meal_analysis.dart';
import 'notifications_screen.dart';

class SharedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showCloseButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onClosePressed;

  const SharedAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.showCloseButton = false,
    this.onBackPressed,
    this.onClosePressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  _SharedAppBarState createState() => _SharedAppBarState();
}

class _SharedAppBarState extends State<SharedAppBar> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingProfile = false;

  bool _isUserAuthenticated() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    return firebaseUser != null;
  }

  Future<void> _onProfileTap() async {
    if (!_isUserAuthenticated()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        setState(() { _isUploadingProfile = true; });
        final url = await ImageService.uploadProfileImage(File(image.path), user.uid);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImage': url,
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload profile image')),
        );
      } finally {
        setState(() { _isUploadingProfile = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = _isUserAuthenticated();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600];

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Profile Section
          if (isAuthenticated && user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                String userName = 'Explorer';
                String? profileImageUrl;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    userName = data['displayName'] ?? user.displayName ?? 'Explorer';
                    profileImageUrl = data['profileImage'] as String?;
                  }
                }
                return Row(
                  children: [
                    GestureDetector(
                      onTap: _onProfileTap,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _isUploadingProfile
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2, 
                                        color: isDark ? Colors.black : Colors.white
                                      ),
                                    ),
                                  ),
                                )
                              : (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(profileImageUrl),
                                      radius: 20,
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 24,
                                        color: isDark ? Colors.white70 : Colors.grey[400],
                                      ),
                                    ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 14,
                            color: iconColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          if (!isAuthenticated)
            Row(
              children: [
                GestureDetector(
                  onTap: _onProfileTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 24,
                      color: isDark ? Colors.white70 : Colors.grey[400],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Explorer',
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      actions: [
        if (widget.showBackButton)
          IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
          ),
        if (widget.showCloseButton)
          IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: widget.onClosePressed ?? () => Navigator.of(context).pop(),
          ),
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: textColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          },
        ),
      ],
    );
  }
} 