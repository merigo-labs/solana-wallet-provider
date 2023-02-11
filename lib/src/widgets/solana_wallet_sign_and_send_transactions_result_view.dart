/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert' show base64;
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' 
  show Cluster, SignAndSendTransactionsResult, SolanaWalletAdapter, SolanaWalletAdapterPlatform;
import 'package:solana_wallet_provider/src/views/solana_wallet_list_view.dart';
import 'package:solana_web3/solana_web3.dart' show base58;
import '../themes/solana_wallet_theme_extension.dart';
import '../views/solana_wallet_method_view.dart';


/// Solana Wallet Sign and Send Transactions Result View
/// ------------------------------------------------------------------------------------------------

/// A view that displays the result of a [SolanaWalletAdapter.signAndSendTransactions] method call.
@immutable
class SolanaWalletSignAndSendTransactionsResultView extends StatefulWidget {
  
  /// Creates a [SolanaWalletMethodView] with a link to view the transaction [result].
  const SolanaWalletSignAndSendTransactionsResultView({
    super.key,
    required this.result,
    required this.cluster,
    this.message,
  });

  /// The sign and send transactions result.
  final SignAndSendTransactionsResult? result;

  /// The connected cluster.
  final Cluster cluster;

  /// The success message.
  final String? message;

  @override
  State<SolanaWalletSignAndSendTransactionsResultView> createState() 
    => _SolanaWalletSignAndSendTransactionsResultViewState();
}


/// Solana Wallet Sign and Send Transactions Result Tile State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletSignAndSendTransactionsResultViewState 
  extends State<SolanaWalletSignAndSendTransactionsResultView> {
  
  /// Creates a Solana explorer uri for a transaction [signature].
  String _uri(final String signature) {
    return 'https://explorer.solana.com/tx/$signature?cluster=${widget.cluster.name}';
  }

  /// Opens a tab for each of the transaction [signatures].
  void _onPressed(final List<String?> signatures) {
    for (final String? signature in signatures) {
      if (signature != null) {
        final String b58Signature = base58.encode(base64.decode(signature));
        SolanaWalletAdapterPlatform.instance.openUri(_uri(b58Signature));
      }
    }
  }

  /// Builds a view to display the result.
  Widget _build(final List<String?> signatures) {
    return SolanaWalletListView(
      children: [
        SolanaWalletMethodView.success(widget.message),
        TextButton(
          style: SolanaWalletThemeExtension.of(context)?.secondaryButtonStyle,
          onPressed: () => _onPressed(signatures), 
          child: const Text('View Transactions'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String?> signatures = widget.result?.signatures ?? const [];
    final bool isNotEmpty = signatures.isNotEmpty 
      && signatures.any((signature) => signature != null);
    return isNotEmpty
      ? _build(signatures)
      : const Text('No Transactions found.');
  }
}