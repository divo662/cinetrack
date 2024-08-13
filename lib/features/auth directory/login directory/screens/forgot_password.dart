import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/form_text.dart';
import '../../../../core/widgets/small_text.dart';
import '../../../../providers/profile_provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                        ),
                        SmallText(
                          text: 'Forgot Password',
                          color: AppColor.secondTextColor,
                          fontWeight: FontWeight.w600,
                          size: 24.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    SmallText(
                      text: 'Input your email address to get an OTP to reset your password.',
                      color: AppColor.greyColor5,
                      size: 14.sp,
                    ),
                    SizedBox(height: 27.h),
                    SmallText(
                      text: 'Email',
                      color: AppColor.greyColor5,
                      fontWeight: FontWeight.w600,
                      size: 14.sp,
                    ),
                    SizedBox(height: 8.h),
                    FormText(
                      borderRadius: 19.r,
                      textColor: AppColor.textColor,
                      controller: profileProvider.resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      hintText: 'xyz@example.com',
                    ),
                    SizedBox(height: 50.h),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        DefaultButton(
                          onpressed: () {
                            profileProvider.requestPasswordReset(context);
                          },
                          title: 'Proceed',
                          buttonWidth: double.infinity,
                        ),
                        if (profileProvider.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 6.0,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 17.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmallText(
                          text: "Remember password?",
                          color: AppColor.subColor,
                          size: 16.sp,
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login_screen');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                          child: SmallText(
                            text: 'Log In',
                            color: AppColor.primaryColor,
                            size: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
