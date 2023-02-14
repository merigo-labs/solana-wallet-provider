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
      identity: AppIdentity(
        uri: Uri.parse('https://my_dapp.com'),
        icon: Uri.parse('favicon.png'),
        name: 'My Dapp'
      ),
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