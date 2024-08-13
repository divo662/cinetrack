import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_strings.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/form_text.dart';
import '../../../../core/widgets/small_text.dart';
import '../../../../providers/profile_provider.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}
class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColor.bg,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title:  Text(
                "Reset Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontFamily: AppStrings.poppins,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondTextColor,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      "Enter your new Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontFamily: AppStrings.poppins,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondTextColor,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _buildPasswordField('New Password', provider.newPasswordController, _obscurePassword, () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }),
                    SizedBox(height: 15.h),
                    _buildPasswordField('Confirm New Password', provider.confirmNewPasswordController, _obscureConfirmPassword, () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    }),
                    SizedBox(height: 50.h),
                    SizedBox(height: 50.h),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        DefaultButton(
                          onpressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              provider.resetPassword(context,widget.email);
                            }
                          },
                          title: 'Reset Password',
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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

}
