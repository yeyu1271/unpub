import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import 'utils.dart';
import 'credentials_ext.dart';

const _tokenEndpoint = 'https://oauth2.googleapis.com/token';
const _authEndpoint = 'https://accounts.google.com/o/oauth2/auth';
const _scopes = ['openid', 'https://www.googleapis.com/auth/userinfo.email'];

get _identifier => utf8.decode(base64.decode(
    r'NDY4NDkyNDU2MjM5LTJja2wxdTB1dGloOHRzZWtnMGxpZ2NpY2VqYm8wbnZkLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29t'));
get _secret => utf8
    .decode(base64.decode(r'R09DU1BYLUxHMWZTV052UjA0S0NrWVZRMTVGS3J1cGJ5bFk='));

Future<void> run({bool verbose = false, bool silence = false}) async {
  if (verbose) Utils.enableVerbose();
  if (silence) Utils.enableSilence();

  final credentials = await readCredentialsFromLocal();

  if (credentials?.isValid() ?? false) {
    /// unpub-credentials.json is valid.
    /// Refresh and write it to file.
    await refreshCredentials(credentials!);
  } else {
    /// unpub-credentials.json is not exist or invalid.
    /// We should get a new Credentials file.
    final client = await clientWithAuthorization();
    await writeNewCredentials(client.credentials);
    Utils.verbosePrint(client.credentials.toJson());
  }
  return;
}

/// Write the new credentials file to unpub-credentials.json
Future<void> writeNewCredentials(oauth2.Credentials credentials) async {
  File(Utils.credentialsFilePath).writeAsStringSync(credentials.toJson());
}

/// Refresh `accessToken` of credentials
Future<void> refreshCredentials(oauth2.Credentials credentials) async {
  await oauth2.Client(oauth2.Credentials.fromJson(credentials.toJson()),
      identifier: _identifier,
      secret: _secret, onCredentialsRefreshed: (credential) async {
    await writeNewCredentials(credential);
  }).refreshCredentials();
}

/// Create a client with authorization.
Future<oauth2.Client> clientWithAuthorization() async {
  final grant = oauth2.AuthorizationCodeGrant(
      _identifier, Uri.parse(_authEndpoint), Uri.parse(_tokenEndpoint),
      secret: _secret, basicAuth: false, httpClient: http.Client());

  final completer = Completer();

  final server = await Utils.bindServer('localhost', 43230);
  shelf_io.serveRequests(server, (request) {
    if (request.url.path == 'authorized') {
      /// That's safe.
      /// see [dart-lang/pub/lib/src/oauth2.dart#L238:L240](https://github.com/dart-lang/pub/blob/400f21e9883ce6555b66d3ef82f0b732ba9b9fc8/lib/src/oauth2.dart#L238:L240)
      server.close();
      return shelf.Response.ok(r'unpub Authorized Successfully.');
    }

    if (request.url.path.isNotEmpty) {
      /// Forbid all other requests.
      return shelf.Response.notFound('Invalid URI.');
    }

    Utils.stdoutPrint('Authorization received, processing...');

    /// Redirect to authorized page.
    final resp =
        shelf.Response.found('http://localhost:${server.port}/authorized');

    completer.complete(
        grant.handleAuthorizationResponse(Utils.queryToMap(request.url.query)));

    return resp;
  });

  final authUrl = grant
          .getAuthorizationUrl(Uri.parse('http://localhost:${server.port}'),
              scopes: _scopes)
          .toString() +
      '&access_type=offline&approval_prompt=force';
  Utils.stdoutPrint(
      'unpub needs your authorization to upload packages on your behalf.\n'
      'In a web browser, go to $authUrl\n'
      'Then click "Allow access".\n\n'
      'Waiting for your authorization...');

  var client = await completer.future;
  Utils.stdoutPrint('Successfully authorized.\n');
  return client;
}

/// Read credential file from local path.
Future<oauth2.Credentials?> readCredentialsFromLocal() async {
  final credentialFile = File(Utils.credentialsFilePath);

  final exists = await credentialFile.exists();
  if (!exists) {
    Utils.verbosePrint('${Utils.credentialsFilePath} is not exist.\n'
        'Please run `dart pub login` first');
    return null;
  }

  final fileContent = await credentialFile.readAsString();

  return oauth2.Credentials.fromJson(fileContent);
}
