import 'dart:io';

import 'package:args/args.dart';
import 'package:unpub_auth/unpub_auth.dart' as unpub_auth;

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addFlag('verbose', abbr: 'v');
  parser.addFlag('silence', abbr: 's');
  final result = parser.parse(arguments);

  await unpub_auth.run(verbose: result['verbose']);
  exit(0);
}
