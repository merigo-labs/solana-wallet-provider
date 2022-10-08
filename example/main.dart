/// Imports
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

void main(final List<String> arguments) async {
  runApp(MaterialApp(
    home: Scaffold(
      body: SolanaWalletProvider.create(
        identity: Identity(),
        child: const Center(
          child: Text('APP'),
        ),
      ),
    ),
  ));
}