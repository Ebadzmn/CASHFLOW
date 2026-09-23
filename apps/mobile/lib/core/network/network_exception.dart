import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioError(DioException error) {
    String message = "Something went wrong";
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.connectionError:
        message = "No internet connection";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(error.response?.statusCode, error.response?.data);
        break;
      default:
        message = "Unexpected error occurred";
        break;
    }
    return NetworkException(message: message, statusCode: statusCode);
  }

  static String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return error['message'] ?? 'Bad request';
      case 401:
        return error['message'] ?? 'Unauthorized';
      case 403:
        return error['message'] ?? 'Forbidden';
      case 404:
        return error['message'] ?? 'Not found';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return 'Oops! Something went wrong';
    }
  }

  @override
  String toString() => message;
}
