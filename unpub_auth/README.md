# unpub_auth

Only for Dart 2.15 and later.

Since Dart 2.15:

1. The `accessToken` is only sent to https://pub.dev and https://pub.dartlang.org. See [dart-lang/pub #3007](https://github.com/dart-lang/pub/pull/3007) for details.
2. Since Dart 2.15, the third-party pub's token is stored at `/Users/username/Library/Application Support/dart/pub-tokens.json` (macOS)

unpub_auth has its own auth flow with Google OAuth2.

## Usage

```
An auth tool for unpub.

Usage: unpub_auth <command> [arguments]

Available commands:
  get             Refresh and get accessToken. Must login first.
  login           Login unpub_auth on Google APIs.
  logout          Delete local credentials file.
  migrate <path>  Migrate existed credentials file from path.
```

### Install and run

``` bash
dart pub global activate unpub_auth # activate the cli app
```

### Uninstall

``` bash
dart pub global deactivate unpub_auth # deactivate the cli app
```

### Get a token and export to Dart Client

``` bash
unpub_auth get | dart pub token add <self-hosted-pub-server>
```

**Please call `unpub_auth login` first before you run the `unpub_auth get` if you never login in 'terminal'.**

## Develop and debug locally

``` bash
dart pub global activate --source path ./  # activate the cli app
unpub_auth  # run it
```
