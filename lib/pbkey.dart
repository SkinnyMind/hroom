import 'package:cryptography/cryptography.dart';

class Pbkey {
  static Future<List<int>> getPbKey({required String password}) async {
    final salt = 'saltysalt';

    final pbKeyAlgo = Pbkdf2(
      macAlgorithm: Hmac.sha1(),
      iterations: 1,
      bits: 128, // 16 byte length
    );
    final pbkey = await pbKeyAlgo.deriveKeyFromPassword(
      password: password,
      nonce: salt.codeUnits,
    );
    return pbkey.extractBytes();
  }
}
