import '../models/user_model.dart';
import '../storage/local_storage_service.dart';
import '../constants/app_constants.dart';

class AuthService {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> init() async {
    final token = LocalStorageService.getString(AppConstants.keyToken);
    if (token != null) {
      _isAuthenticated = true;
      _currentUser = UserModel.defaultUser;
    }
  }

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    bool rememberMe = true,
  }) async {
    // Simulated realistic authentication
    await Future.delayed(const Duration(milliseconds: 600));

    if (password.length < 4) {
      throw Exception('Invalid password');
    }

    _currentUser = UserModel.defaultUser.copyWith(
      email: emailOrPhone.contains('@') ? emailOrPhone : 'rahul@gmail.com',
      phone: !emailOrPhone.contains('@') ? emailOrPhone : '+91 98765 43210',
    );
    _isAuthenticated = true;

    if (rememberMe) {
      await LocalStorageService.setString(AppConstants.keyToken, 'mock_jwt_token_arthiq_rahul');
    }

    return _currentUser!;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required double initialIncome,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: '',
      monthlyIncome: initialIncome,
    );
    _isAuthenticated = true;
    await LocalStorageService.setString(AppConstants.keyToken, 'mock_jwt_token_arthiq_rahul');
    return _currentUser!;
  }

  Future<void> logout() async {
    await LocalStorageService.remove(AppConstants.keyToken);
    _currentUser = null;
    _isAuthenticated = false;
  }
}
