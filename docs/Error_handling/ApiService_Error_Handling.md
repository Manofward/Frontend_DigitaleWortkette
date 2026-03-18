# ApiService Error Handling Guide

This guide provides best practices for adding robust error handling to the `ApiService` class in your Flutter application. The `ApiService` handles HTTP requests to your backend API, making it crucial to handle network errors, server errors, and data parsing issues gracefully.

## Common Error Scenarios

1. **Network Connectivity Issues**: Device offline, poor connection, timeouts.
2. **Server Errors**: 4xx (client errors) and 5xx (server errors) status codes.
3. **Data Parsing Errors**: Invalid JSON, unexpected response structure.
4. **Authentication Errors**: Unauthorized access, expired tokens.
5. **Timeout Errors**: Requests taking too long to complete.

## Best Practices

- Use try-catch blocks around all HTTP calls.
- Check HTTP status codes and handle different responses appropriately.
- Provide meaningful error messages to users.
- Implement retry logic for transient failures.
- Log errors for debugging while avoiding sensitive information in logs.
- Use custom exception classes for different error types.

## Code Examples

### 1. Enhanced GET Method with Error Handling

**Before:**
```dart
static Future<dynamic> get(String endpoint) async {
  try {
    final res = await http.get(Uri.parse('$baseUrl/$endpoint'));
    debugPrint("$res");
    debugPrint("Endpoint param: $endpoint (${endpoint.runtimeType})");

    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint("GET OK");
      return await jsonDecode(res.body);
    }

    if (res.statusCode == 204) {
      debugPrint("GET 204");
      return [];
    }

    return null;
  } catch (e) {
    debugPrint("GET error: $e");
    return null;
  }
}
```

**After:**
```dart
static Future<dynamic> get(String endpoint) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint')).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Request timed out'),
    );

    debugPrint("GET request to $endpoint - Status: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to parse response JSON: $e');
      }
    }

    if (response.statusCode == 204) {
      return [];
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    }

    if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    }

    throw ApiException('Request failed with status: ${response.statusCode}');
  } on SocketException catch (e) {
    debugPrint("Network error: $e");
    throw NetworkException('No internet connection');
  } on TimeoutException catch (e) {
    debugPrint("Timeout error: $e");
    throw NetworkException('Request timed out');
  } catch (e) {
    debugPrint("Unexpected error: $e");
    if (e is ApiException) rethrow;
    throw ApiException('Unexpected error: $e');
  }
}
```

### 2. Enhanced POST Method with Retry Logic

**Before:**
```dart
static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
  try {
    final res = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: data,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      debugPrint("POST: $res.body");
      return jsonDecode(res.body);
    }

    return null;
  } catch (e) {
    debugPrint("POST error: $e");
    return null;
  }
}
```

**After:**
```dart
static Future<dynamic> post(String endpoint, Map<String, dynamic> data, {int maxRetries = 3}) async {
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: data,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      debugPrint("POST request to $endpoint - Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw ApiException('Failed to parse response JSON: $e');
        }
      }

      if (response.statusCode == 400) {
        throw ValidationException('Invalid request data');
      }

      if (response.statusCode == 409) {
        throw ConflictException('Resource conflict');
      }

      if (response.statusCode >= 500 && attempts < maxRetries - 1) {
        attempts++;
        await Future.delayed(Duration(seconds: attempts * 2));
        continue;
      }

      throw ApiException('Request failed with status: ${response.statusCode}');
    } on SocketException catch (e) {
      if (attempts < maxRetries - 1) {
        attempts++;
        await Future.delayed(Duration(seconds: attempts * 2));
        continue;
      }
      throw NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      if (attempts < maxRetries - 1) {
        attempts++;
        await Future.delayed(Duration(seconds: attempts * 2));
        continue;
      }
      throw NetworkException('Request timed out');
    } catch (e) {
      debugPrint("POST error on attempt ${attempts + 1}: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  throw ApiException('Max retries exceeded');
}
```

### 3. Custom Exception Classes

Add these to a separate file like `lib/exceptions/api_exceptions.dart`:

```dart
abstract class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ConflictException extends ApiException {
  ConflictException(String message) : super(message);
}
```

### 4. Updated Method Usage Example

```dart
static Future<List<dynamic>> homepageGet() async {
  try {
    final response = await get("home");
    if (response == null || response is List && response.isEmpty) {
      return [];
    }
    if (response is! List) {
      throw ApiException('Unexpected response type');
    }
    return response.map((e) => {
      "lobbyID": e["lobbyID"],
      "topic": e["subjectName"],
      "players": e["maxPlayers"],
    }).toList();
  } on NetworkException catch (e) {
    debugPrint('Network error in homepageGet: $e');
    // Show offline message to user
    return [];
  } on ApiException catch (e) {
    debugPrint('API error in homepageGet: $e');
    // Show error message to user
    return [];
  } catch (e) {
    debugPrint('Unexpected error in homepageGet: $e');
    return [];
  }
}
```

## Conclusion

Implementing comprehensive error handling in your ApiService will make your app more robust and provide better user experience. Remember to:

- Always handle exceptions at the call site
- Provide user-friendly error messages
- Log errors for debugging
- Implement retry logic for transient failures
- Use custom exceptions for better error categorization

For more advanced error handling, consider using packages like `dio` for HTTP requests, which provide built-in error handling and interceptors.
