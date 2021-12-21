import 'dart:io';

import 'package:args/args.dart';
import 'package:unpub_auth/unpub_auth.dart' as unpub_auth;

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addCommand('login');
  parser.addCommand('logout');
  parser.addCommand('migrate');
  parser.addCommand('get');

  final result = parser.parse(arguments);

  unpub_auth.Flow flow = unpub_auth.Flow.getToken;

  Object? subArgs;

  switch (result.command?.name) {
    case 'login':
      flow = unpub_auth.Flow.login;
      break;
    case 'logout':
      flow = unpub_auth.Flow.logout;
      break;
    case 'migrate':
      flow = unpub_auth.Flow.migrate;
      if (result.command?.arguments.length != 1) {
        throw "unpub_auth migrate need a path argument";
      }
      subArgs = result.command?.arguments.first;
      break;
    case 'get':
      flow = unpub_auth.Flow.getToken;
      break;
    default:
      stdout.write('''
An auth tool for unpub.

Usage: unpub_auth <command> [arguments]

Available commands:
  get             Refresh and get accessToken. Must login first.
  login           Login unpub_auth on Google APIs.
  logout          Delete local credentials file.
  migrate <path>  Migrate existed credentials file from path.
''');
      exit(0);
  }

  await unpub_auth.run(flow: flow, args: subArgs);
  exit(0);
}
