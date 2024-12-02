import 'dart:io';

import 'package:hroom/decrypter.dart';
import 'package:hroom/login_data_creds.dart';
import 'package:hroom/masterkey.dart';
import 'package:hroom/pbkey.dart';
import 'package:hroom/shared.dart';

Future<void> main() async {
  final encryptedCreds = LoginDataCreds.extract();
  final masterKey = await Masterkey.extract();
  final pbKey = await Pbkey.getPbKey(password: masterKey);

  final decryptedCreds = <Creds>[];
  for (final creds in encryptedCreds) {
    final decrypted = Decrypter.decrypt(
      key: pbKey,
      encryptedPassword: creds.password,
    );
    decryptedCreds.add(
      Creds(
        url: creds.url,
        username: creds.username,
        password: decrypted,
      ),
    );
  }

  for (final creds in decryptedCreds) {
    stdout.writeln('url: ${creds.url}');
    stdout.writeln('username: ${creds.username}');
    stdout.writeln('password: ${creds.password}');
    stdout.writeln();
  }
}
