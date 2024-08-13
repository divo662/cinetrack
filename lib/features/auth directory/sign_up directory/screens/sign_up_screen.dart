import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_strings.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/form_text.dart';
import '../../../../core/widgets/small_text.dart';
import '../../../../providers/profile_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColor.bg,
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 45.h),
                    SmallText(
                      text: 'Welcome to CineTrack',
                      color: AppColor.secondTextColor,
                      fontWeight: FontWeight.bold,
                      size: 24.sp,
                    ),
                    SizedBox(height: 15.h),
                    SmallText(
                      text: "Let's get you started now!",
                      color: AppColor.subColor,
                      fontWeight: FontWeight.w500,
                      size: 15.sp,
                    ),
                    SizedBox(height: 15.h),
                    _buildTextField('Email', provider.emailController, TextInputType.emailAddress, 'xyz@gmail.com'),
                    SizedBox(height: 15.h),
                    _buildPasswordField('Password', provider.passwordController, provider.isPasswordVisible, () {
                      provider.togglePasswordVisibility();
                    }),
                    SizedBox(height: 15.h),
                    _buildPasswordField('Confirm Password', provider.confirmPasswordController, provider.isConfirmPasswordVisible, () {
                      provider.toggleConfirmPasswordVisibility();
                    }),
                    SizedBox(height: 45.h),
                    _buildContinueButton(provider),
                    SizedBox(height: 15.h),
                    SizedBox(height: 15.h),
                    _buildSignInLink(),
                  ],
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

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText,VoidCallback onpressed) {
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
          textColor: AppColor.textColor,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          controller: controller,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off_outlined : Icons.visibility,
            ),
            onPressed: onpressed,
          ),
          hintText: label == 'Password' ? 'Must be at least 6 characters' : 'Re-enter password',
          hintStyle: TextStyle(
            color: AppColor.greyColor5,
            fontWeight: FontWeight.w500,
            fontSize: 17.sp,
            fontFamily: AppStrings.poppins,
          ),
          obscureText: obscureText,
        ),
      ],
    );
  }

  _buildContinueButton(ProfileProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DefaultButton(
          onpressed: (){
            provider.signUp(context);
          },
          title: "Continue",
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
  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SmallText(
          text: "Already have an account?",
          color: AppColor.subColor,
          size: 16,
        ),
        TextButton(
          onPressed: () {
            context.go('/login_screen');
          },
          child: const SmallText(
            text: "Sign In",
            color: AppColor.textColor,
            size: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
