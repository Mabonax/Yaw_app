import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../api/api_exception.dart';

abstract interface class WorkosBrowser {
  Future<String> authenticate(String url, String callbackScheme);
}

class SystemWorkosBrowser implements WorkosBrowser {
  const SystemWorkosBrowser();

  @override
  Future<String> authenticate(String url, String callbackScheme) async {
    try {
      return await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: callbackScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: true),
      );
    } on PlatformException catch (error) {
      throw ApiException(
        type: ApiExceptionType.validation,
        message: error.code == 'CANCELED'
            ? 'Sign-in was cancelled. You can try again.'
            : 'The secure sign-in browser could not open. Please try again.',
      );
    }
  }
}
