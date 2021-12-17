# unpub_auth

Only for Dart 2.15 and later.

Since Dart 2.15:

1. The `accessToken` is only sent to https://pub.dev and https://pub.dartlang.org [dart-lang/pub #3007](https://github.com/dart-lang/pub/pull/3007)
2. Since Dart 2.15, the third-party pub's token is stored at `/Users/username/Library/Application Support/dart/pub-tokens.json` (macOS)

This cli app reads the token from the new path of official pub credential. Then refresh and save it.
So Dart can continue to read the `accessToken` from `pub-tokens.json`

## Usage

Please call `dart pub login` first before you run the `unpub_auth` if you never login in 'terminal'.

``` bash
dart pub global activate unpub_auth
unpub_auth | dart pub token add <self-hosted-pub-server>
```

## Develop and debug locally

``` bash
dart pub global activate --source path ./
unpub_auth | dart pub token add <self-hosted-pub-server>
```
