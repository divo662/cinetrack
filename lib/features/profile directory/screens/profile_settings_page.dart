import 'dart:io';
import 'dart:ui';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:cinetrack/features/profile%20directory/screens/change_password_screen.dart';
import 'package:cinetrack/providers/profile_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/res/app_images.dart';
import '../../../core/res/app_strings.dart';
import '../../../core/widgets/default_button.dart';
import '../../../core/widgets/form_text.dart';
import '../../../core/widgets/small_text.dart';
import 'package:http/http.dart' as http;

import '../../../services/api/tmdb_api.dart';
import '../../auth directory/login directory/screens/login_screen.dart';

class ProfileSettingsPage extends StatefulWidget {
  final String? token;

  const ProfileSettingsPage({super.key, this.token});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late Future<Map<String, String?>> _userProfileFuture;
  TextEditingController nameController = TextEditingController();
  File? _avatarImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchUserProfile();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userProfileFuture = fetchUserProfile();
    });
  }

  Future<Map<String, String>> fetchUserProfile() async {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token!);
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString("userName") ?? "User";
    final profilePicture = jwtDecodedToken['profilePicture'] ?? '';
    final email = jwtDecodedToken['email'] ?? 'Email not found';
    return {
      'userName': userName,
      'profilePicture': profilePicture,
      'email': email,
    };
  }

  Future<void> pickImage() async {
    // Request permission
    var status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile =
            await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          // Crop the image
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'Crop Image',
              ),
            ],
          );

          if (croppedFile != null) {
            setState(() {
              _avatarImage = File(croppedFile.path);
            });
          }
        }
      } catch (e) {
        Navigator.pop(context);
        _showSnackBar('Error picking image: $e', context);
      }
    } else if (status.isDenied) {
      // Handle denied permission
      Navigator.pop(context);
      _showSnackBar('Permission to access gallery was denied', context);
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied permission
      _showSnackBar(
          'Gallery access is permanently denied. Please enable it in settings.',
          context);
      await openAppSettings();
    }
  }

  void updateProfile(ProfileProvider provider) async {
    if (_formKey.currentState?.validate() ?? false) {
      String username = nameController.text.trim();

      if (username.isNotEmpty) {
        try {
          Map<String, String?> profile = await provider.fetchUserProfile();

          bool success = await provider.changeProfile(
            username,
            null,
            context,
          );

          if (success) {
            setState(() {
              nameController.text = username;
              _userProfileFuture = provider.fetchUserProfile();
            });
            _showSnackBar('Username updated successfully!', context);
          } else {
            Navigator.pop(context);
            _showSnackBar('Failed to update username.', context);
          }
        } catch (error) {
          Navigator.pop(context);
          _showSnackBar('Error updating username: $error', context);
        }
      } else {
        _showSnackBar('Please provide a new username.', context);
      }
    } else {
      Navigator.pop(context);
      _showSnackBar('Form validation failed.', context);
    }
  }

  Future<void> sendFeedback(BuildContext context) async {
    const email = 'divzeh001@gmail.com';
    const subject = 'Feedback on CineTrack';
    const body = 'Please write your feedback here...';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: AppColor.fillColor,
              title: Text(
                'Send Feedback',
                style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColor.whiteTextColor,
                    fontFamily: AppStrings.poppins,
                    fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Would you like to send feedback',
                style: TextStyle(
                    color: AppColor.subColor,
                    fontFamily: AppStrings.poppins,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.green,
                        fontFamily: AppStrings.poppins,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'No',
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: AppStrings.poppins,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldSend == true) {
      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          // Fallback: copy email to clipboard
          await Clipboard.setData(const ClipboardData(text: email));
          _showSnackBar('Email address copied to clipboard', context);
        }
      } catch (e) {
        _showSnackBar('Error: $e', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token != null && JwtDecoder.isExpired(widget.token!)) {
      return const LoginScreen();
    }
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColor.primaryColor,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      backgroundColor: AppColor.bg,
      child: FutureBuilder<Map<String, String>>(
        future: fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColor.bg,
              body: Center(
                  child: CircularProgressIndicator(
                color: AppColor.primaryColor,
              )),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: AppColor.bg,
              body: Center(child: errorMessage(snapshot)),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final profilePictureUrl = data['profilePicture'] ?? '';
            final userName = data['userName'] ?? 'User';
            final email = data['email'] ?? 'No email';

            return Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  backgroundColor: AppColor.bg,
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 45.h),
                        Center(
                          child: Container(
                            height: 160.h,
                            width: 160.w,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(
                                      AppImages.defaultProfilePicture),
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28).r,
                              child: Image.network(
                                profilePictureUrl,
                                filterQuality: FilterQuality.high,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return const Icon(Icons.error,
                                      color: Colors.red);
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.h,
                        ),
                        Center(
                          child: Text(
                            userName,
                            style: TextStyle(
                                fontFamily: AppStrings.poppins,
                                fontSize: 22.sp,
                                color: Colors.white,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Center(
                          child: Text(
                            email,
                            style: TextStyle(
                                fontFamily: AppStrings.poppins,
                                fontSize: 15.sp,
                                color: AppColor.subColor,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildListTile(
                                icon: Remix.account_circle_fill,
                                text: "Update Profile",
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) =>
                                        _showUpdateProfileModal(
                                            context,
                                            profilePictureUrl,
                                            profileProvider,
                                            userName),
                                    isScrollControlled: true,
                                  );
                                },
                              ),
                              _buildListTile(
                                icon: Remix.lock_password_fill,
                                text: "Change Password Settings",
                                onTap: () {
                                  context.go('/change_password_screen');
                                },
                              ),
                              _buildListTile(
                                icon: Remix.mail_add_fill,
                                text: "Send Feedback",
                                onTap: () => sendFeedback(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        DefaultButton(
                          onpressed: () {
                            context.go('/login_screen');
                          },
                          title: "Logout",
                          buttonWidth: double.infinity,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Scaffold(
              backgroundColor: AppColor.bg,
              body: Center(
                  child: Text(
                'No data',
                style: TextStyle(
                  color: AppColor.whiteTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.sp,
                ),
              )),
            );
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmallText(
          text: label,
          color: AppColor.subColor,
          fontWeight: FontWeight.w500,
          size: 14.sp,
        ),
        SizedBox(height: 8.h),
        FormText(
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          controller: controller,
          hintText: hint,
          fillColor: AppColor.fillColor,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  _buildContinueButton(ProfileProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DefaultButton(
          onpressed: () => updateProfile(provider),
          title: "Save",
          buttonWidth: double.infinity,
        ),
        if (provider.isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 6.0,
            ),
          ),
      ],
    );
  }

  Widget _showUpdateProfileModal(BuildContext context, String profilePictureUrl,
      ProfileProvider profileProvider, String hintUsername) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(
          height: 700.h,
          decoration: BoxDecoration(
            color: AppColor.bg.withOpacity(0.9),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      CupertinoIcons.xmark,
                      color: AppColor.whiteTextColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(height: 20.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 80.r,
                            backgroundColor: Colors.grey[900],
                            backgroundImage: _avatarImage != null
                                ? FileImage(_avatarImage!)
                                : (profilePictureUrl.isNotEmpty
                                    ? NetworkImage(profilePictureUrl)
                                        as ImageProvider
                                    : null),
                            child: _avatarImage == null &&
                                    (profilePictureUrl.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _avatarImage = null;
                            });
                          },
                          child: Text(
                            "Remove Picture",
                            style: TextStyle(
                              color: AppColor.whiteTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      _buildTextField("Username", nameController,
                          TextInputType.text, hintUsername),
                      SizedBox(height: 30.h),
                      _buildContinueButton(profileProvider),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _buildListTile(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return Container(
      height: 75.h,
      margin: EdgeInsets.all(7.sp),
      decoration: BoxDecoration(
          color: AppColor.fillColor, borderRadius: BorderRadius.circular(15.r)),
      child: Center(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppColor.primaryColor,
            child: Icon(icon, color: Colors.black),
          ),
          title: SmallText(
            text: text,
            size: 16.sp,
            color: AppColor.secondTextColor,
            fontWeight: FontWeight.w500,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_sharp),
        ),
      ),
    );
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        dismissDirection: DismissDirection.startToEnd,
        content: Container(
          width: 190.w,
          height: 56.h,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(45),
            color: Colors.redAccent,
          ),
          child: Center(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: AppStrings.poppins),
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget errorMessage(AsyncSnapshot<Map<String, String>> snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AppImages.errorPicture),
        Text(
          'Error: ${snapshot.error}',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColor.whiteTextColor,
              fontFamily: AppStrings.poppins,
              fontSize: 20.sp),
        ),
      ],
    );
  }
}
