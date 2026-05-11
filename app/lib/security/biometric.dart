import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    return await _auth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Xác thực để mở ứng dụng',
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}