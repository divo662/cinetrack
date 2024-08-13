import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/res/app_strings.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/small_text.dart';
import '../../../../providers/profile_provider.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());

  String _concatenateOtp() {
    return otpControllers.map((controller) => controller.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColor.bg,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: SmallText(
              text: "Verify OTP sent",
              fontWeight: FontWeight.w400,
              color: AppColor.blueTitleColor,
              size: 20.sp,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmallText(
                    text: 'Enter OTP Code',
                    fontWeight: FontWeight.w400,
                    color: AppColor.secondTextColor,
                    size: 20.sp,
                  ),
                  SizedBox(height: 8.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppStrings.poppins,
                      ),
                      children: [
                        TextSpan(
                          text: "We have just sent an otp to ",
                          style: TextStyle(
                            color: AppColor.subColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppStrings.poppins,
                          ),
                        ),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppStrings.poppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          height: 56.h,
                          width: 56.w,
                          child: TextFormField(
                            autofocus: false,
                            controller: otpControllers[index],
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 32.sp,
                              fontFamily: AppStrings.poppins,
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: "",
                              fillColor: Colors.blueGrey.shade100.withOpacity(0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColor.primaryColor,
                                  width: 1.5.w,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  width: 1.5.w,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 50.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      DefaultButton(
                        onpressed: () {
                          String otp = _concatenateOtp();
                          provider.verifyResetOtp(context, widget.email, otp);
                        },
                        title: 'Continue',
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
    );
  }
}
