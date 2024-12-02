import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class Decrypter {
  /// [key] is bytes of Pbkdf2 key.
  ///
  /// [encryptedPassword] is hex string.
  static String decrypt({
    required List<int> key,
    required String encryptedPassword,
  }) {
    final iv = List.filled(16, 32);
    final encrypter = Encrypter(
      AES(
        Key(Uint8List.fromList(key)),
        mode: AESMode.cbc,
      ),
    );
    return encrypter.decrypt16(
      encryptedPassword.substring(6), // skip first 3 chars (v10... or v11...)
      iv: IV(Uint8List.fromList(iv)),
    );
  }
}
