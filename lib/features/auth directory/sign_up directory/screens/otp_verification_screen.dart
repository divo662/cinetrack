import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/config_file.dart';
import '../../../../core/res/app_strings.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/widgets/default_button.dart';
import '../../../../core/widgets/small_text.dart';
import '../../../../providers/profile_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  int _remainingTime = 59;
  Timer? _timer;
  final bool _isLoading = false;
  bool _canResend = false;

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResend = true;
          _timer!.cancel();
        }
      });
    });
  }

  String _concatenateOtp() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _remainingTime = 60;
      _canResend = false;
    });
    _startTimer();
    try {
      final response = await http.post(
        Uri.parse(resendVerification),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        _showSnackBar("OTP resent successfully");
      } else {
        _showSnackBar("Error resending OTP");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  void _showSnackBar(String message) {
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
              style: TextStyle(
                color: Colors.white,
                fontFamily: AppStrings.poppins,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
              title: SmallText(
                text: "Verify OTP sent",
                fontWeight: FontWeight.w400,
                color: AppColor.blueTitleColor,
                size: 20.sp,
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
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
                                fillColor:
                                    Colors.blueGrey.shade100.withOpacity(0.1),
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
                            provider.verifyOtp(context, widget.email, otp);
                          },
                          title: 'Continue',
                          buttonWidth: double.infinity,
                        ),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 6.0,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppStrings.poppins,
                          ),
                          children: [
                            TextSpan(
                              text: "Didn't get a code? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppStrings.poppins,
                              ),
                            ),
                            TextSpan(
                              text: _canResend
                                  ? 'Resend now'
                                  : 'Resend in ($_remainingTime)s',
                              style: TextStyle(
                                color: _canResend
                                    ? AppColor.primaryColor
                                    : Colors.grey,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppStrings.poppins,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _canResend ? _resendOtp : null,
                            ),
                          ],
                        ),
                      ),
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
}
