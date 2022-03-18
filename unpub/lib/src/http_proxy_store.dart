import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'models.dart';

class HttpProxyStore {
  final String remoteUrl;

  final http.Client client = http.Client();
  final Uri baseUrl;

  HttpProxyStore(this.remoteUrl) : baseUrl = Uri.parse(remoteUrl);

  _convertToUnpubPackage(String name, List<dynamic> versions) {
    DateTime time = DateTime.now();
    List<UnpubVersion> unpubVersions = versions
        .map((package) => UnpubVersion(package["version"], package["pubspec"],
            null, null, null, null, time))
        .toList();
    return UnpubPackage(name, unpubVersions, false, null, time, time, null);
  }

  Future<UnpubPackage?> queryPackage(String name) async {
    Uri versionUrl =
        baseUrl.resolve('/api/packages/${Uri.encodeComponent(name)}');

    var response = await client.get(versionUrl);

    if (response.statusCode != 200) {
      return null;
    }

    var json = convert.json.decode(response.body);
    var versions = json['versions'] as List<dynamic>?;
    if (versions == null) {
      return null;
    }
    print(versions);

    return _convertToUnpubPackage(name, versions);
  }

  Future<Stream<List<int>>> download(String name, String version) async {
    print('Downloading package $name/$version.');

    var packageUrl = baseUrl.resolve(
        '/packages/${Uri.encodeComponent(name)}/versions/${Uri.encodeComponent(version)}.tar.gz');
    var response = await client.send(http.Request('GET', packageUrl));

    return response.stream;
  }
}
