import 'dart:convert';
import 'dart:io';
import 'package:cinetrack/core/config/config_file.dart';
import 'package:cinetrack/core/res/app_strings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileProvider with ChangeNotifier {
  late SharedPreferences preferences;

  Future<void> initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController resetEmailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isValidEmail = false;
  bool _isValidPassword = false;
  bool _isValidConfirmPassword = false;
  bool _isLoading = false;

  bool get isValidEmail => _isValidEmail;
  bool get isValidPassword => _isValidPassword;
  bool get isValidConfirmPassword => _isValidConfirmPassword;
  bool get isLoading => _isLoading;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  ProfileProvider() {
    initSharedPref();
    emailController.addListener(_validateFields);
    passwordController.addListener(_validateFields);
    confirmPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar("Please enter your email and password", context);
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords don't match", context);
      return;
    }
    if (!_validatePassword(passwordController.text)) {
      _showSnackBar("Password must be more than 6 characters", context);
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      var regBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };
      var response = await http.post(
        Uri.parse(registrationUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Check if the response contains userId
        if (responseData['status'] == true && responseData.containsKey('userId')) {
          // Save userId using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', responseData['userId']);
          context.go('/otp_verify_screen?email=${emailController.text.trim()}');

        } else {
          _showSnackBar("Failed to retrieve user ID. Please try again.", context);
        }
      } else {
        _showSnackBar("Registration failed. Please try again.", context);
      }
    } catch (e) {
      _showSnackBar("An unexpected error occurred. Please try again later.", context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(BuildContext context, String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Retrieve the stored user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) {
        // If user ID is not found, show an error message
        _showSnackBar("User ID not found. Please try again.", context);
        _isLoading = false;
        notifyListeners();
        return;
      }
      // Prepare OTP verification request body
      var otpBody = {
        "email": email,
        "otp": otp,
        "userId": userId,
      };

      var response = await http.post(
        Uri.parse(otpVerification),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(otpBody),
      );
      if (response.statusCode == 200) {
        // OTP verification successful
        _showSnackBar("OTP verified successfully!", context);
        context.go('/account_setup_screen');
      } else {
        // OTP verification failed
        _showSnackBar("Invalid OTP. Please try again.", context);
      }
    } catch (e) {
      // Debug print
      _showSnackBar("An error occurred. Please try again later.", context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String username, String? profilePicPath, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        _showSnackBar("User ID not found. Please log in again.", context);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (profilePicPath != null) {
        final file = File(profilePicPath);
        final bytes = await file.readAsBytes();
        const maxFileSize = 5 * 1024 * 1024; // 5MB

        if (bytes.length > maxFileSize) {
          _showSnackBar("Profile picture is too large. Please select a smaller file.", context);
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final Map<String, dynamic> requestBody = {
        'username': username,
        'profilePic': profilePicPath != null ? base64Encode(await File(profilePicPath).readAsBytes()) : null,
        'userID': userId,
      };

      final response = await http.post(
        Uri.parse(updateAccountInfo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          _showSnackBar(responseData['message'] ?? "Successfully updated profile", context);
          context.go('/login_screen');
          return true;
        } else {
          _showSnackBar(responseData['message'] ?? "Failed to update profile", context);
          return false;
        }
      } else {
        _showSnackBar("Failed to update profile: ${response.statusCode}", context);
        return false;
      }
    } catch (e) {
      _showSnackBar("An error occurred while updating profile", context);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String?>> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    String? userName = prefs.getString('userName');
    String? profilePicture = prefs.getString('profilePicture');

    return {
      'userName': userName,
      'profilePicture': profilePicture,
    };
  }

  Future<bool> changeProfile(String username, String? profilePicPath, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        _showSnackBar("User ID not found. Please log in again.", context);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> requestBody = {
        'username': username,
        'userID': userId,
      };

      if (profilePicPath != null) {
        final file = File(profilePicPath);
        final bytes = await file.readAsBytes();
        const maxFileSize = 5 * 1024 * 1024; // 5MB

        if (bytes.length > maxFileSize) {
          _showSnackBar("Profile picture is too large. Please select a smaller file.", context);
          _isLoading = false;
          notifyListeners();
          return false;
        }

        requestBody['profilePic'] = base64Encode(bytes);
      }

      final response = await http.post(
        Uri.parse(updateAccountInfo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          prefs.setString('userName', username);
          if (profilePicPath != null) {
            prefs.setString('profilePicture', base64Encode(await File(profilePicPath).readAsBytes()));
          }
          _showSnackBar(responseData['message'] ?? "Successfully updated profile", context);
          Navigator.pop(context);
          return true;
        } else {
          _showSnackBar(responseData['message'] ?? "Failed to update profile", context);
          return false;
        }
      } else {
        _showSnackBar("Failed to update profile: ${response.statusCode}", context);
        return false;
      }
    } catch (e) {
      _showSnackBar("An error occurred while updating profile", context);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loginUser(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("Please enter your email and password", context);
      return;
    }
    if (!_validatePassword(passwordController.text)) {
      _showSnackBar("Password must be more than 6 characters", context);
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      var loginBody = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };
      var response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginBody),
      );
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var myToken = jsonResponse['token'];
        var userName = jsonResponse['userName'];
        var profilePicture = jsonResponse['profilePicture'] ?? "";
        var userIdFromServer = jsonResponse['userId'] ?? "";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', myToken);
        await prefs.setString('userName', userName);
        await prefs.setString('profilePicture', profilePicture);
        await prefs.setString('userId', userIdFromServer);

        context.go('/bottom_nav_screen', extra: myToken);
      } else if (response.statusCode == 500) {
        _showSnackBar("Incorrect email or password. Please try again.", context);
      } else {
        _showSnackBar("Login failed. Please try again.", context);
      }
    } catch (e) {
      // Debug print
      _showSnackBar("An unexpected error occurred. Please try again later.", context);
    } finally {
      _isLoading = false;
      notifyListeners();
      // Debug print
    }
  }
  Future<void> requestPasswordReset(BuildContext context) async {
    if (resetEmailController.text.isEmpty) {
      _showSnackBar("Please enter your email", context);
      return;
    }
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(requestEmailForNewPassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': resetEmailController.text.trim()}),
      );

      _handleResponse(response, "OTP sent to your email", context);
      context.go('/forgot_password_otp_screen?email=${resetEmailController.text.trim()}');
    } catch (e) {
      _showSnackBar("An error occurred. Please try again later.", context);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyResetOtp(BuildContext context, String email, String otp) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse(verifyResetPasswordOTP), // Ensure this URL is correct
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );
      if (_handleResponse(response, "verified. You can now reset your password.", context)) {
        context.go('/reset_password_screen?email=${Uri.encodeComponent(email)}'); // Encode the email
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again later.", context);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      _showSnackBar("Please enter your new password", context);
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showSnackBar("Passwords do not match", context);
      return;
    }
    _setLoading(true);
    try {
      final response = await http.post(
        Uri.parse(newPasswordUpdate),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPasswordController.text.trim(),
        }),
      );
      if (_handleResponse(response, "Password reset successfully!", context)) {
        context.go('/login_screen');
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again later.", context);
    } finally {
      _setLoading(false);
    }
  }
  Future<void> changePassword(BuildContext context) async {
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      _showSnackBar("Please enter your new password", context);
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showSnackBar("Passwords do not match", context);
      return;
    }
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        _showSnackBar("User ID not found. Please log in again.", context);
        _setLoading(false);
        return;
      }
      final response = await http.post(
        Uri.parse(changePasswordUpdate), // Use the correct endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'newPassword': newPasswordController.text.trim(),
        }),
      );
      if (_handleResponse(response, "Password changed successfully!", context)) {
        Navigator.pop(context); // Navigate back to settings page
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again later.", context);
    } finally {
      _setLoading(false);
    }
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
              style:  TextStyle(
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _handleResponse(http.Response response, String successMessage, BuildContext context) {
    if (response.statusCode == 200) {
      _showSnackBar(successMessage, context);
      return true;
    } else {
      _showSnackBar("Operation failed. Please try again.", context);
      return false;
    }
  }

  void _validateFields() {
    _isValidEmail = _validateEmail(emailController.text);
    _isValidPassword = _validatePassword(passwordController.text) &&
        passwordController.text == confirmPasswordController.text;
    notifyListeners();
  }

  bool _validateEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }
}


