import 'package:dio/dio.dart';
import '../services/secure_storage_service.dart';
import '../../routes/app_routes.dart';
import '../../routes/app_router.dart';
import '../../data/repositories/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  bool _isRefreshing = false;
  final List<_FailedRequest> _failedRequests = [];

  AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final uri = options.uri;
    final isAwsS3 = uri.host.contains('amazonaws.com') ||
        uri.queryParameters.containsKey('X-Amz-Algorithm') ||
        uri.queryParameters.containsKey('X-Amz-Signature') ||
        uri.queryParameters.containsKey('x-amz-signature') ||
        uri.queryParameters.containsKey('Signature');

    if (isAwsS3) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Explicitly remove the header if no token is present
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // If the 401 is from the refresh token endpoint, we should logout directly
      if (err.requestOptions.path.contains('/auth/refresh')) {
        await _storageService.clearTokens();
        AppRouter.router.go(Routes.LOGIN);
        return handler.next(err);
      }

      if (_isRefreshing) {
        _failedRequests.add(_FailedRequest(err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;
      _failedRequests.add(_FailedRequest(err.requestOptions, handler));

      try {
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken == null) {
          throw DioException(
            requestOptions: err.requestOptions,
            error: 'No refresh token found',
          );
        }

        // Call refresh API using a separate Dio instance to avoid interceptor loop
        final response = await AuthRepository().refreshToken(refreshToken);
        
        if (response.success && response.data != null) {
          final newAccessToken = response.data!.accessToken;
          final newRefreshToken = response.data!.refreshToken;

          await _storageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry all failed requests
          final dio = Dio(); // Basic dio for retries
          for (var request in _failedRequests) {
            final options = request.options;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await dio.fetch(options);
            request.handler.resolve(retryResponse);
          }
          _failedRequests.clear();
        } else {
          throw Exception("Refresh failed with status false");
        }
      } catch (e) {
        // Logout on failure
        await _storageService.clearTokens();
        AppRouter.router.go(Routes.LOGIN);
        
        for (var request in _failedRequests) {
          request.handler.reject(err);
        }
        _failedRequests.clear();
      } finally {
        _isRefreshing = false;
      }
      return;
    }
    handler.next(err);
  }
}

class _FailedRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
  _FailedRequest(this.options, this.handler);
}
