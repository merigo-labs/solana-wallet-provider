/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'solana_wallet_card.dart';
import '../models/solana_wallet_app_info.dart';
import '../models/solana_wallet_method_state.dart';
import '../views/solana_wallet_download_list_view.dart';
import '../views/solana_wallet_method_view.dart';
import '../widgets/solana_wallet_method_builder.dart';
import '../../src/views/solana_wallet_remote_connect_view.dart';


/// Solana Wallet Connect Card
/// ------------------------------------------------------------------------------------------------

/// A card that facilitates connecting an application to a wallet app.
class SolanaWalletConnectCard extends StatefulWidget {
  
  /// Creates a card that facilitates connecting an application to a wallet app.
  const SolanaWalletConnectCard({
    super.key,
    required this.apps,
    required this.adapter,
    this.hostAuthority,
    required this.onComplete,
    required this.onCompleteError,
  });

  /// The applications presented for download.
  final List<SolanaWalletAppInfo> apps;

  /// The wallet adapter to connect with.
  final SolanaWalletAdapter adapter;

  /// The remote connection uri.
  final String? hostAuthority;

  /// The callback function invoked when the connection completes successfully.
  final void Function(AuthorizeResult? value)? onComplete;

  /// The callback function invoked when the connection fails.
  final void Function(Object error, [StackTrace? stackTrace])? onCompleteError;

  @override
  State<SolanaWalletConnectCard> createState() => _SolanaWalletConnectCardState();
}


/// Solana Wallet Connect Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletConnectCardState extends State<SolanaWalletConnectCard> {

  /// The type of association being attempted.
  AssociationType? _associationType = AssociationType.local;

  /// The connection request.
  late final Future<AuthorizeResult?> _future;

  /// The wallet adapter.
  SolanaWalletAdapter get _adapter => widget.adapter;

  /// The remote connection uri.
  String? get _hostAuthority => widget.hostAuthority ?? _adapter.hostAuthority;

  @override
  void initState() {
    super.initState();
    _future = _localAssociation()       // Attempt local wallet connection.
      .catchError(_remoteAssociation)   // Attempt remote wallet connection.
      .catchError(_installApplication); // Complete future to present download options.
  }

  /// Simulate a connect request that results in a [SolanaWalletAdapterException] with error code 
  /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  // Future<AuthorizeResult?> _simulateErrorRequest() {
  //   return Future.delayed(
  //     const Duration(seconds: 1),
  //     () => Future.error(const SolanaWalletAdapterException(
  //       'Simulated request exception - wallet not found.',
  //       code: SolanaWalletAdapterExceptionCode.walletNotFound,
  //     )),
  //   );
  // }

  /// [SolanaWalletMethodBuilder.method].
  Future<AuthorizeResult?> _method([final dynamic value]) => _future;

  /// Returns true if [error] is a [SolanaWalletAdapterException] with error code 
  /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  bool _isWalletNotFoundException(final Object error) {
    return error is SolanaWalletAdapterException 
      && error.code == SolanaWalletAdapterExceptionCode.walletNotFound;
  }

  /// 1. Local Association.
  /// 
  /// Makes a local association request to connect to a wallet running on the current device.
  Future<AuthorizeResult?> _localAssociation() {
    _setAssociationType(AssociationType.local);
    return _adapter.localAssociation(_adapter.authorizeHandler);
  }

  /// 2. Remote Association.
  /// 
  /// Makes a remote association request to connect to a wallet running on a different device.
  Future<AuthorizeResult?> _remoteAssociation(
    final Object error, [
    final StackTrace? stackTrace,
  ]) {
    // Handler [error] returned by [_localAssociation].
    final String? hostAuthority = _hostAuthority;
    if (!_isWalletNotFoundException(error) || hostAuthority == null) {
      return Future.error(error, stackTrace);
    }
    // Make remote association request.
    _setAssociationType(AssociationType.remote);
    return _adapter.remoteAssociation(hostAuthority, _adapter.authorizeHandler);
  }

  /// 3. Download Wallet.
  /// 
  /// Completes with a `null` result.
  Future<AuthorizeResult?> _installApplication(
    final Object error, [
    final StackTrace? stackTrace,
  ]) {
    // Handler [error] returned by [_remoteAssociation].
    if (!_isWalletNotFoundException(error)) {
      return Future.error(error, stackTrace);
    }
    // Complete with no result.
    _setAssociationType(null);
    return Future.value(null);
  }

  void _setAssociationType(final AssociationType? associationType) {
    if (mounted) setState(() => _associationType = associationType);
  }

  /// Builds a widget for [controller.state].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<AuthorizeResult?> snapshot,
    final SolanaWalletMethodController<dynamic> controller,
  ) {    
    switch(controller.state) {
      case SolanaWalletMethodState.none:
      case SolanaWalletMethodState.progress:
        return _progressBuilder(context, snapshot);
      case SolanaWalletMethodState.success:
        return _successBuilder(context, snapshot.data);
      case SolanaWalletMethodState.error:
        return _errorBuilder(context, snapshot.error);
    }
  }

  /// Builds a widget for [SolanaWalletMethodState.progress].
  Widget _progressBuilder(
    final BuildContext context, 
    final AsyncSnapshot<AuthorizeResult?> snapshot,
  ) {
    switch(_associationType) {
      case AssociationType.local:
        return SolanaWalletCard(
          key: ValueKey(_associationType),
          body: SolanaWalletMethodView.progress(
            'Opening wallet application.'
          ),
        );
      case AssociationType.remote:
        return SolanaWalletCard(
          key: ValueKey(_associationType),
          body: SolanaWalletRemoteConnectView(
            hostAuthority: _hostAuthority!,
            timeout: AssociationType.remote.timeout,
          ),
        );
      case null:
        return SolanaWalletCard(
          key: ValueKey(_associationType),
          body: SolanaWalletMethodView.error(
            snapshot.error,
            'Invalid connection state.'
          ),
        );
    }
  }

  /// Builds a widget for [SolanaWalletMethodState.success].
  Widget _successBuilder(
    final BuildContext context, 
    final AuthorizeResult? result,
  ) {
    switch(_associationType) {
      case AssociationType.local:
      case AssociationType.remote:
        return SolanaWalletCard(
          body: SolanaWalletMethodView.success(
            'Wallet connected.'
          ),
        );
      case null:
        return SolanaWalletCard(
          title: const Text('Download Wallet'),
          body: SolanaWalletDownloadListView(
            apps: widget.apps,
          ),
        );
    }
  }

  /// Builds a widget for [SolanaWalletMethodState.error].
  Widget _errorBuilder(
    final BuildContext context, 
    final Object? error,
  ) => SolanaWalletCard(
    body: SolanaWalletMethodView.error(
      error,
      'Failed to connect.'
    ),
  );

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletMethodBuilder(
      value: null, 
      method: _method, 
      builder: _builder,
      onComplete: widget.onComplete,
      onCompleteError: widget.onCompleteError,
    );
  }
}