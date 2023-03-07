/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_common/config/cluster.dart';
import 'package:solana_common/utils/convert.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart' 
  show SignAndSendTransactionsResult, SolanaWalletAdapter, SolanaWalletAdapterPlatform;
import 'solana_wallet_content_view.dart';
import 'solana_wallet_state_view.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../widgets/solana_wallet_icon_paint.dart';
import '../../src/models/solana_wallet_method_state.dart';
import '../../src/widgets/solana_wallet_icon_painter.dart';


/// Solana Wallet Sign and Send Transactions Result View
/// ------------------------------------------------------------------------------------------------

/// A view that displays the result of a [SolanaWalletAdapter.signAndSendTransactions] method call.
@immutable
class SolanaWalletSignAndSendTransactionsResultView extends StatefulWidget {
  
  /// Creates a [SolanaWalletContentView] that links to the transaction [result].
  const SolanaWalletSignAndSendTransactionsResultView({
    super.key,
    required this.result,
    required this.cluster,
  });

  /// The sign and send transaction result.
  final SignAndSendTransactionsResult? result;

  /// The connected cluster.
  final Cluster cluster;

  @override
  State<SolanaWalletSignAndSendTransactionsResultView> createState() 
    => _SolanaWalletSignAndSendTransactionsResultViewState();
}


/// Solana Wallet Sign and Send Transactions Result Tile State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletSignAndSendTransactionsResultViewState 
  extends State<SolanaWalletSignAndSendTransactionsResultView> {
  
  /// Creates a Solana explorer uri for a transaction [signature].
  Uri _uri(final String signature) 
    => Uri(
      scheme: 'https',
      host: 'explorer.solana.com',
      path: 'tx/$signature',
      queryParameters: { 'cluster': widget.cluster.name },
    );

  /// Opens a tab for each of the transaction [signatures].
  void _onPressed(final List<String?> signatures) {
    for (final String? signature in signatures) {
      if (signature != null) {
        final String b58Signature = base64ToBase58(signature);
        SolanaWalletAdapterPlatform.instance.openUri(_uri(b58Signature), '_blank');
      }
    }
  }

  /// Builds a view that display the result.
  Widget _successBuilder(final List<String?> signatures) {
    return SolanaWalletStateView.success(
      message: 'Your transactions have been processed.',
      body: TextButton(
        style: SolanaWalletThemeExtension.of(context)?.secondaryButtonStyle,
        onPressed: () => _onPressed(signatures), 
        child: const Text('View Transactions'),
      ),
    );
  }

  /// Builds a view that display an error.
  Widget _errorBuilder() {
    return SolanaWalletStateView(
      iconBuilder: (_, __) => const SolanaWalletIconPaint(painter: SolanaWalletBangIcon.new),
      state: SolanaWalletMethodState.error,
      message: const Text('No Transactions found.'),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final List<String?> signatures = widget.result?.signatures ?? const [];
    final bool isNotEmpty = signatures.isNotEmpty 
      && signatures.any((signature) => signature != null);
    return isNotEmpty
      ? _successBuilder(signatures)
      : _errorBuilder();
  }
}