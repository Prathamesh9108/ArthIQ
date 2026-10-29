import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiClient _apiClient = ApiClient();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user ?? UserModel.defaultUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    await _authService.init();

    // Fetch live user profile from TiDB Cloud via backend
    try {
      final res = await _apiClient.get('/user/profile');
      if (res['success'] == true && res['data'] is Map<String, dynamic>) {
        _user = UserModel.fromJson(res['data'] as Map<String, dynamic>);
        if (kDebugMode) {
          debugPrint('👤 [AuthProvider] Profile loaded from TiDB Cloud: ${_user?.name}');
        }
      } else {
        _user = _authService.currentUser ?? UserModel.defaultUser;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [AuthProvider] Failed to fetch profile from TiDB Cloud: $e');
      }
      _user = _authService.currentUser ?? UserModel.defaultUser;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String emailOrPhone, String password, {bool rememberMe = true}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
        rememberMe: rememberMe,
      );

      // Refresh live profile from TiDB Cloud if available
      try {
        final res = await _apiClient.get('/user/profile');
        if (res['success'] == true && res['data'] is Map<String, dynamic>) {
          _user = UserModel.fromJson(res['data'] as Map<String, dynamic>);
        }
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, double income) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        initialIncome: income,
      );

      // Persist profile to TiDB Cloud
      try {
        await _apiClient.put('/user/profile', data: {
          'name': name,
          'email': email,
          'monthlyIncome': income,
        });
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({String? name, String? email, String? phone}) async {
    if (_user == null) return false;
    final updated = _user!.copyWith(name: name, email: email, phone: phone);

    try {
      final res = await _apiClient.put('/user/profile', data: updated.toJson());
      if (res['success'] == true) {
        _user = updated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [AuthProvider] Failed to persist profile to TiDB: $e');
      }
    }

    _user = updated;
    notifyListeners();
    return true;
  }
}
