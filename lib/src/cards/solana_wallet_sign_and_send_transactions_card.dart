/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:solana_web3/exceptions.dart';
import 'package:solana_web3/solana_web3.dart';
import '../themes/solana_wallet_theme_extension.dart';
import '../views/solana_wallet_modal_banner_view.dart';
import '../widgets/sign_transactions_mixin.dart';
import '../widgets/adapter_widget.dart';


/// Solana Wallet Sign And Send Transactions Card
/// ------------------------------------------------------------------------------------------------

/// The [SolanaWalletSignAndSendTransactionsCard] widget's state.
typedef SignAndSendAdapterState 
  = AdapterState<SignAndSendTransactionsResult, SolanaWalletSignAndSendTransactionsCard>;

/// The sign and send transaction method's progress states.
enum _ProgressState {
  signing,
  confirming,
}

/// A modal card for `signAndSendTransactions` method calls.
class SolanaWalletSignAndSendTransactionsCard 
  extends AdapterWidget<SignAndSendTransactionsResult> 
  with SignTransactionsWidget 
{
  /// Creates a `signAndSendTransactions` card.
  const SolanaWalletSignAndSendTransactionsCard({
    super.key,
    required super.adapter,
    required this.connection,
    required this.transactions,
    required this.config,
    required this.commitment,
    required this.eagerError,
    required super.completer,
    required super.dismissState,
  });

  @override
  final Connection connection;

  @override
  final List<Transaction> transactions;

  /// Transaction configurations.
  final SignAndSendTransactionsConfig? config;

  /// The [transactions] confirmation commitment level (default: [Connection.commitment]).
  final Commitment? commitment;

  /// If true, the request will complete immediately with the first error encountered.
  final bool eagerError;

  @override
  SignAndSendAdapterState createState() => _SolanaWalletSignAndSendTransactionsCardState();
}


/// Solana Wallet Sign And Send Transactions Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletSignAndSendTransactionsCardState 
  extends SignAndSendAdapterState 
  with SignTransactionsState
{
  /// The `in progress` state of the sign and send method call.
  _ProgressState _progressState = _ProgressState.signing;

  /// Returns an empty string if the method is being invoked for 1 transaction or 's' otherwise.
  String get _pluralSuffix => widget.transactions.length == 1 ? '' : 's';

  /// Sets [_progressState] to [state] and marks the widget for rebuild.
  void _setProgressState(final _ProgressState state) {
    if (mounted && _progressState != state) {
      setState(() => _progressState = state);
    }
  }

  /// Creates a Solana explorer uri for a transaction [signature].
  Uri _uri(final String signature) => Uri(
    scheme: 'https',
    host: 'explorer.solana.com',
    path: 'tx/$signature',
    queryParameters: { 'cluster': widget.connection.httpCluster.name },
  );

  /// Opens a tab for each of the transaction [signatures].
  void _onTapViewTransactions(final List<String?> signatures) {
    for (final String? signature in signatures) {
      if (signature != null) {
        final String b58Signature = base58To64Decode(signature);
        widget.adapter.openUri(_uri(b58Signature), '_blank');
      }
    }
  }

  @override
  Future<SignAndSendTransactionsResult> invokeMethod() async {

    // Sign transactions with the wallet account. 
    final SignTransactionsResult result = await signTransactions();
    
    // Broadcast the signed transactions on the network.
    final Connection connection = widget.connection;
    final SignAndSendTransactionsConfig? config = widget.config;
    final Commitment? commitment = widget.commitment ?? connection.commitment;
    final bool eagerError = widget.eagerError;
    final List<String?> b58Signatures = await connection.sendSignedTransactions(
      result.signedPayloads,
      eagerError: eagerError,
      config: SendTransactionConfig(
        minContextSlot: config?.minContextSlot,
        preflightCommitment: commitment,
      ),
    );

    // If a [commitment] level has been provided, update the UI and wait for confirmations.
    if (commitment != null) {
      _setProgressState(_ProgressState.confirming);
      final List<Future<SignatureNotification>> futures = [];
      for (final String? b58Signature in b58Signatures) {
        futures.add(b58Signature != null
          ? connection.confirmTransaction(
              b58Signature,
              config: CommitmentConfig(
                commitment: commitment,
              ),
            )
          : Future.error(const SignatureNotification(
              err: TransactionException('Transaction confirmation failed.'),
            )
          )
        );
      }
      await Future.wait(futures, eagerError: eagerError);
    }

    // Return the result.
    return SignAndSendTransactionsResult(
      signatures: b58Signatures.map(
        (signature) => signature != null ? base58To64Encode(signature) : null
      ).toList(growable: false),
    );
  }

  @override
  Widget? builder(
    final BuildContext context, 
    final AsyncSnapshot<SignAndSendTransactionsResult> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.active:
        return null; // Apply defaults.
      case ConnectionState.waiting:
        if (_progressState == _ProgressState.confirming) {
          final String suffix = _pluralSuffix;
          final String verb = suffix.isEmpty ? 'is' : 'are';
          return SolanaWalletModalBannerView.opening(
            key: const ValueKey('confirming'),
            title: const Text('Sending Transaction'),
            message: Text('Your transaction$suffix $verb being processed.'),
          );
        } else {
          return SolanaWalletModalBannerView.opening();
        }
      case ConnectionState.done:        
        final Object? error = snapshot.error;
        if (error != null) {
          return SolanaWalletModalBannerView.error(
            error: error,
            message: const Text('Transaction error.'),
          );
        } else {
          final List<String?> signatures = snapshot.data!.signatures;
          final String suffix = _pluralSuffix;
          final String verb = suffix.isEmpty ? 'has' : 'have';
          return SolanaWalletModalBannerView.success(
            title: const Text('Transaction Complete'),
            message: Text('Your transaction$suffix $verb been processed.'),
            body: TextButton(
              style: SolanaWalletThemeExtension.of(context)?.secondaryButtonStyle,
              onPressed: () => _onTapViewTransactions(signatures), 
              child: Text('View Transaction$suffix'),
            ),
          );
        }
    }
  }
}