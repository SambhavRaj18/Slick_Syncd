import '../../../core/models/api_response.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

/// Contract for Authentication operations.
///
/// When adding a real backend, create a class like `RealAuthRepository`
/// that implements this interface and makes actual API calls.
abstract class IAuthRepository {
  Future<ApiResponse<User>> login(String email, String password);
  Future<ApiResponse<User>> register(String name, String email, String password);
  Future<void> logout();
}

// ─────────────────────────────────────────────────────────────────────────────
// TODO: BACKEND INTEGRATION POINT
// When your backend is ready, create a RealAuthRepository here:
//
// class RealAuthRepository implements IAuthRepository {
//   final ApiClient _apiClient;
//   RealAuthRepository(this._apiClient);
//
//   @override
//   Future<ApiResponse<User>> login(String email, String password) async {
//     final response = await _apiClient.post('/auth/login', { ... });
//     ...
//   }
// }
// ─────────────────────────────────────────────────────────────────────────────

/// Mock implementation for development without a backend.
/// Uses local data & simulated delays to mimic real API behavior.
class MockAuthRepository implements IAuthRepository {
  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.contains('error')) {
      return ApiResponse.error('Invalid credentials');
    }

    final user = User(
      id: 'mock_user_123',
      name: email.split('@')[0],
      email: email,
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await StorageService.setToken(user.token!);
    await StorageService.setUserEmail(user.email);
    await StorageService.setUserName(user.name);

    return ApiResponse.success(user);
  }

  @override
  Future<ApiResponse<User>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: 'mock_user_reg_123',
      name: name,
      email: email,
      token: 'mock_jwt_token_reg_${DateTime.now().millisecondsSinceEpoch}',
    );

    await StorageService.setToken(user.token!);
    await StorageService.setUserEmail(user.email);
    await StorageService.setUserName(user.name);

    return ApiResponse.success(user);
  }

  @override
  Future<void> logout() async {
    await StorageService.clearAll();
  }
}
