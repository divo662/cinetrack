import 'package:cinetrack/core/res/app_strings.dart';
import 'package:cinetrack/core/utils/app_color.dart';
import 'package:cinetrack/features/home%20directory/screens/watch_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import '../../profile directory/screens/profile_settings_page.dart';
import 'home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final String token;
  const BottomNavScreen({super.key, required this.token});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int pageIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeScreen(token: widget.token),
      const WatchlistScreen(),
      ProfileSettingsPage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      body: pages[pageIndex],
      bottomNavigationBar: Container(
        decoration:  const BoxDecoration(
          color: AppColor.fillColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
        ),
        child: GNav(
          color: Colors.grey.shade400,
          tabMargin: const EdgeInsets.all(4),
          gap: 5,
          onTabChange: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          selectedIndex: pageIndex,
          activeColor: AppColor.primaryColor,
          iconSize: 27,
          textStyle: TextStyle(
            fontFamily: AppStrings.poppins,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            color:AppColor.primaryColor,
          ),

          padding:  EdgeInsets.all(17.sp),
          tabs: const [
            GButton(
              icon: Remix.movie_2_line,
              text: "Movies",
            ),
            GButton(
              icon: Remix.bookmark_2_line,
              text: "Watchlist",
            ),
            GButton(
              icon: Remix.account_circle_fill,
              text: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
