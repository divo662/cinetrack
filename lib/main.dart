import 'package:cinetrack/providers/movie_provider.dart';
import 'package:cinetrack/providers/profile_provider.dart';
import 'package:cinetrack/services/api/tmdb_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/res/app_strings.dart';
import 'core/routes/app_routing_logic.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final client = http.Client();
  final tmdbApi = TmdbApi(client: client);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider(tmdbApi)),
      ],
      child:  CineTrack(token: prefs.getString("token"),),
    ),
  );
}

class CineTrack extends StatelessWidget {
  final String? token;
  const CineTrack({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          title: AppStrings.appName,
        );

      },
    );
  }
}

// mjlZJUXIzCY2OSnc


