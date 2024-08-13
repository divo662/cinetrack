import 'dart:io';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:cinetrack/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/form_text.dart';
import '../../../../core/widgets/small_text.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  TextEditingController nameController = TextEditingController();
  File? _avatarImage;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    // Request permission
    var status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          // Crop the image
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: AppColor.primaryColor,
                toolbarWidgetColor: AppColor.fillColor,
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
        _showSnackBar('Error picking image: $e', context);
      }
    } else if (status.isDenied) {
      // Handle denied permission
      _showSnackBar('Permission to access gallery was denied', context);
    } else if (status.isPermanentlyDenied) {
      // Handle permanently denied permission
      _showSnackBar('Gallery access is permanently denied. Please enable it in settings.', context);
      await openAppSettings();
    }
  }

  void _updateProfile(ProfileProvider provider) {
    if (_formKey.currentState!.validate()) {
      String username = nameController.text.trim();
      String? profilePicPath = _avatarImage?.path;

      provider.updateProfile(username, profilePicPath, context).then((success) {
        if (success) {
        } else {
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColor.bg,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        SmallText(
                          text: "Create Profile",
                          color: AppColor.whiteTextColor,
                          fontWeight: FontWeight.w500,
                          size: 24.sp,
                        ),
                        SizedBox(height: 50.h),
                        Center(
                          child: GestureDetector(
                            onTap: () => pickImage(),
                            child: CircleAvatar(
                              radius: 120.r,
                              backgroundColor: Colors.grey[900],
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : null,
                              child: _avatarImage == null
                                  ? Icon(
                                Icons.add_a_photo_rounded,
                                color: Colors.grey[300],
                                size: 153,
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
                            child: SmallText(
                              text: "Remove Picture",
                              color: AppColor.whiteTextColor,
                              fontWeight: FontWeight.w500,
                              size: 17.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        _buildTextField("Username", nameController,
                            TextInputType.text, "Enter username"),
                        SizedBox(height: 30.h),
                        _buildContinueButton(provider)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, String hint) {
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
          onpressed: () => _updateProfile(provider),
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


  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        dismissDirection: DismissDirection.startToEnd,
        content: Container(
          width: 190,
          height: 56,
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
              ),
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
