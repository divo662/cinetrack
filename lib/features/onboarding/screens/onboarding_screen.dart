import 'dart:ui';
import 'package:cinetrack/core/res/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/res/app_strings.dart';
import '../../../core/utils/app_color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingComplete', true);
   context.go('/login_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(AppImages.onboardImage1),
              ),
            ),
          ),
          // Content Container
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
                  decoration: BoxDecoration(
                    color: AppColor.bg.withOpacity(0.9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome to CineTrack',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontFamily: AppStrings.poppins,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Discover a world of cinema with \nrecommendations curated just for you. Start exploring now and find your next \nfavorite movie.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: AppStrings.poppins,
                            color: AppColor.subColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      // Buttons
                      ElevatedButton(
                        onPressed: () {
                          _completeOnboarding();
                          context.pushReplacement('/sign_up_screen');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 55.h),
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: AppStrings.poppins,
                            color: AppColor.whiteTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () {
                          context.pushReplacement('/login_screen');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 55.h),
                          backgroundColor: AppColor.bg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            side: const BorderSide(color: AppColor.primaryColor),
                          ),
                        ),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: AppStrings.poppins,
                            color: AppColor.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
