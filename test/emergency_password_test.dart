import 'package:flutter_test/flutter_test.dart';
import 'package:blur_glass/services/privacy_controller.dart';
import 'package:blur_glass/services/privacy_channel.dart';

class MockPrivacyChannel extends PrivacyChannel {
  bool hasPass = false;
  String? savedPass;

  @override
  Future<bool> hasEmergencyPassword() async => hasPass;

  @override
  Future<bool> setEmergencyPassword(String password) async {
    savedPass = password;
    hasPass = true;
    return true;
  }

  @override
  Future<bool> verifyEmergencyPassword(String password) async {
    return hasPass && savedPass == password;
  }

  @override
  Future<bool> clearEmergencyPassword() async {
    savedPass = null;
    hasPass = false;
    return true;
  }

  @override
  Future<String> cameraPermission() async => 'authorized';

  @override
  Future<bool> hasOwnerTemplate() async => true;

  @override
  Future<bool> isProtecting() async => false;

  @override
  Stream<AttentionSnapshot> snapshots() => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PrivacyController emergency password workflow', () async {
    final channel = MockPrivacyChannel();
    final controller = PrivacyController(channel: channel);

    expect(await controller.hasEmergencyPassword(), isFalse);

    final setOk = await controller.setEmergencyPassword('secret123');
    expect(setOk, isTrue);
    expect(await controller.hasEmergencyPassword(), isTrue);

    expect(await controller.verifyEmergencyPassword('secret123'), isTrue);
    expect(await controller.verifyEmergencyPassword('wrong'), isFalse);

    await controller.clearEmergencyPassword();
    expect(await controller.hasEmergencyPassword(), isFalse);
  });
}
