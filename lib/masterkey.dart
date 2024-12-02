import 'package:dbus/dbus.dart';

class Masterkey {
  static Future<String> extract() async {
    var masterKey = 'peanuts';

    const secretsName = 'org.freedesktop.secrets';
    final dbus = DBusClient.session();
    final secretService = DBusRemoteObject(
      dbus,
      name: secretsName,
      path: DBusObjectPath('/org/freedesktop/secrets'),
    );

    final sessionPath = await secretService.callMethod(
      'org.freedesktop.Secret.Service',
      'OpenSession',
      const [DBusString('plain'), DBusVariant(DBusString(''))],
    );

    final items = await secretService.callMethod(
      'org.freedesktop.Secret.Service',
      'SearchItems',
      [DBusDict(DBusSignature('s'), DBusSignature('s'))],
    );

    final collections = await secretService.callMethod(
      'org.freedesktop.Secret.Service',
      'GetSecrets',
      [
        DBusArray(DBusSignature('o'), items.values.first.asArray()),
        sessionPath.values.last.asObjectPath(),
      ],
    );

    for (var i = 0; i < collections.values.length; i++) {
      for (final collection in collections.values[i].asDict().keys) {
        final itemObject = DBusRemoteObject(
          dbus,
          name: secretsName,
          path: collection.asObjectPath(),
        );
        final label = await itemObject.getProperty(
          'org.freedesktop.Secret.Item',
          'Label',
        );
        if (label.asString() == 'Chrome Safe Storage') {
          final item = await itemObject.callMethod(
            'org.freedesktop.Secret.Item',
            'GetSecret',
            [sessionPath.values.last.asObjectPath()],
          );
          masterKey = String.fromCharCodes(
            item.values.first.asStruct()[2].asByteArray(),
          );
        }
      }
    }

    final session = DBusRemoteObject(
      dbus,
      name: secretsName,
      path: sessionPath.values.last.asObjectPath(),
    );

    await session.callMethod('org.freedesktop.Secret.Session', 'Close', []);
    await dbus.close();

    return masterKey;
  }
}
