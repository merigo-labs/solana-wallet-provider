Provides access to [solana_web3](https://pub.dev/packages/solana_web3) and [solana_wallet_adapter](https://pub.dev/packages/solana_wallet_adapter) in the widget tree. The package creates UI wrappers around each [Mobile Wallet Adapter Specification](https://solana-mobile.github.io/mobile-wallet-adapter/spec/spec.html) method.

<br>

<img src="https://github.com/merigo-labs/example-apps/blob/master/docs/images/solana_wallet_provider.gif?raw=true" alt="Sign and Send Transaction" height="400"/>
<br>

*[Solana Wallet Provider Example App](https://github.com/merigo-labs/example-apps/tree/master/solana_wallet_provider_example)*

<br>

## [Dapp Identity Verification](https://solana-mobile.github.io/mobile-wallet-adapter/spec/spec.html#dapp-identity-verification)

Wallet endpoints will use your AppIdentity information to decide whether to extend trust to your dapp.

```dart
AppIdentity(
    uri: Uri.parse('https://<YOUR_DOMAIN>'),
    icon: Uri.parse('favicon.png'),
    name: '<APP_NAME>'
)
```

### Android Setup

1. Get your application id.

```gradle
// FILE: /android/app/build.gradle
defaultConfig {
    applicationId "<APPLICATION_ID>"
}
```

2. Generate your application's sha256 fingerprint.
```console
$ cd android
$ ./gradlew app:signingReport

// Output:
//  ...
//  SHA-256: <SHA256_FINGERPRINT>
//  ...
```

3. Host a Digital Asset Links file with the following contents:

```json
// GET: https:://<YOUR_DOMAIN>/.well-known/assetlinks.json
[{
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": { 
        "namespace": "android_app", 
        "package_name": "<AAPLICATION_ID>",
        "sha256_cert_fingerprints": ["<SHA256_FINGERPRINT>"]
    }
}]
```

<br>

## Theme

Add `SolanaWalletThemeExtension` as a `ThemeData` extension to set the provider's appearance.

```dart
ThemeData(
    extensions: const [
        SolanaWalletThemeExtension(
            cardTheme: SolanaWalletCardTheme(
                color: Colors.indigo,
            ),
        ),
    ],
);
```

<br>

## Convenience Methods and Widgets

- `SolanaWalletButton` - <em>A button widget that toggles authorization of the application with a wallet.</em>
- `connect` - <em>authorizes the application with an available wallet or present a list of download options.</em>
- `disconnect` - <em>presents the authorized accounts and a disconnect button to deauthorize the application.</em>

<br>

## Example: Authorize

Uses the provider to authorize the application with a Solana wallet.

```dart
import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    // 1. Wrap application with SolanaWalletProvider.
    return SolanaWalletProvider.create(                           
      identity: const AppIdentity(),
      child: MaterialApp(
        home: Scaffold(
          body: FutureBuilder(
            // 2. Initialize SolanaWalletProvider before use.
            future: SolanaWalletProvider.initialize(),            
            builder: ((context, snapshot) {
              // 3. Access SolanaWalletProvider.
              final provider = SolanaWalletProvider.of(context);
              return TextButton(
                onPressed: () => provider.authorize(context),
                child: const Center(
                  child: Text('Example App'),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
```

<br>

## Bugs
Report a bug by opening an [issue](https://github.com/merigo-labs/solana-wallet-provider/issues/new?template=bug_report.md).

## Feature Requests
Request a feature by raising a [ticket](https://github.com/merigo-labs/solana-wallet-provider/issues/new?template=feature_request.md).