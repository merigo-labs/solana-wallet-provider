/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import '../../solana_wallet_provider.dart' show SolanaWalletProvider;
import '../models/dismiss_state.dart';
import '../views/solana_wallet_apps_view.dart';
import '../views/solana_wallet_download_view.dart';
import '../views/solana_wallet_modal_banner_view.dart';
import '../views/solana_wallet_modal_view.dart';
import '../views/solana_wallet_qr_code_view.dart';
import '../widgets/solana_wallet_method_builder.dart';
import 'solana_wallet_modal_card.dart';


/// Solana Wallet Connect Card
/// ------------------------------------------------------------------------------------------------

/// A card that facilitates connecting a dApp to a wallet application.
class SolanaWalletConnectCard extends StatefulWidget {
  
  /// Creates a card that facilitates connecting a dApp to a wallet application.
  const SolanaWalletConnectCard({
    super.key,
    required this.adapter,
    this.options,
    this.hostAuthority,
    this.completer,
    this.dismissState,
  });

  /// The wallet adapter interface.
  final SolanaWalletAdapter adapter;

  /// The applications presented as `connect options` (defaults to the adapter platform's 
  /// [StoreInfo.options] if omitted, pass an empty list to display no options).
  final List<AppInfo>? options;

  /// {@macro solana_wallet_adapter.hostAuthority}
  final String? hostAuthority;

  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.completer}
  final Completer<AuthorizeResult>? completer;

  /// {@macro solana_wallet_provider.SolanaWalletMethodBuilder.dismissState}
  final DismissState? dismissState;

  @override
  State<SolanaWalletConnectCard> createState() => _SolanaWalletConnectCardState();
}


/// Solana Wallet Connect Card State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletConnectCardState extends State<SolanaWalletConnectCard> {

  /// The local authorization request.
  Future<AuthorizeResult>? _localFuture;

  /// The remote authorization request.
  Future<AuthorizeResult>? _remoteFuture;

  /// The selected application.
  AppInfo? _app;

  /// The wallet adapter interface.
  SolanaWalletAdapter get _adapter => widget.adapter;

  /// The applications presented to the user for selection.
  List<AppInfo> get _options => widget.options ?? _adapter.store.options;

  /// The remote connection uri.
  String? get _hostAuthority => widget.hostAuthority ?? _adapter.hostAuthority;

  /// The remote connection timeout duration.
  final Duration _hostTimeLimit = const Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    if (_options.isEmpty) {
      _initLocalFuture();
    }
  }

  // /// Simulates a connect request that results in a [SolanaWalletAdapterException] with error code 
  // /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  // Future<AuthorizeResult> _simulateErrorRequest() {
  //   return Future.delayed(
  //     const Duration(seconds: 1),
  //     () => Future.error(const SolanaWalletAdapterException(
  //       'Simulated request exception - wallet not found.',
  //       code: SolanaWalletAdapterExceptionCode.walletNotFound,
  //     )),
  //   );
  // }

  /// Sets [_localFuture] and invokes a local authorization method call.
  void _initLocalFuture() {
    if (mounted && _localFuture == null) {
      // _localFuture = _simulateErrorRequest().catchError(_localFutureError);
      _localFuture = _adapter.authorize(
        type: AssociationType.local, 
        walletUriBase: _app?.walletUriBase,
      ).catchError(_localFutureError);
      setState(() {});
    }
  }

  /// Sets [_remoteFuture] and invokes a remote authorization method call if a `hostAuthority` url 
  /// is available.
  void _initRemoteFuture() {
    final String? hostAuthority = _hostAuthority;
    if (mounted && _remoteFuture == null && hostAuthority != null) {
      _remoteFuture = _adapter.authorize(
        type: AssociationType.remote, 
        hostAuthority: hostAuthority, 
        walletUriBase: _app?.walletUriBase,
      );
      setState(() {});
    }
  }

  /// Handles a local association error and invoke a remote association call for an [error] of type 
  /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  Future<AuthorizeResult> _localFutureError(
    final Object error, [
    final StackTrace? stackTrace, 
  ]) async {
    if (_isWalletNotFoundException(error)) {
      _initRemoteFuture();
    }
    return Future.error(error, stackTrace);
  }
    
  /// Returns true if [error] is a [SolanaWalletAdapterException] with error code 
  /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  bool _isWalletNotFoundException(final Object? error) {
    return error is SolanaWalletAdapterException 
      && error.code == SolanaWalletAdapterExceptionCode.walletNotFound;
  }

  /// Invokes a local association method call for [app].
  void _onTapConnect(final AppInfo app) {
    _app = app;
    _initLocalFuture();
  }

  /// Opens the application store for [app] and closes the modal.
  void _onTapDownload(final AppInfo? app) {
    _adapter.store.open(app);
    SolanaWalletProvider.close(context);
  }

  /// Builds an error view.
  Widget _errorBuilder(
    final Object error, [
    final StackTrace? stackTrace, 
  ]) => SolanaWalletModalBannerView.error(
      error: error,
      message: const Text('Connection failed.'),
    );
  
  /// Builds an success view.
  Widget _successBuilder(
    final AuthorizeResult data, 
  ) => SolanaWalletModalBannerView.success(
      message: const Text('Wallet connected.'),
    );

  /// Builds a view for the current local association state.
  Widget _localBuilder(
    final BuildContext context,
    final AsyncSnapshot<AuthorizeResult> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        final List<AppInfo> options = _options;
        return options.isEmpty 
          ? SolanaWalletModalBannerView.opening()
          : SolanaWalletModalView(
              title: const Text('Connect Wallet'),
              message: const Text('Select a wallet provider.'),
              body: SolanaWalletAppsView(
                apps: options,
                onPressed: _onTapConnect,
              ),
            );
      case ConnectionState.waiting:
      case ConnectionState.active:
        return SolanaWalletModalBannerView.opening();
      case ConnectionState.done:
        final Object? error = snapshot.error;
        if (error != null) {
          if (_remoteFuture != null) {
            return SolanaWalletMethodBuilder(
              future: _remoteFuture, 
              completer: widget.completer, 
              dismissState: widget.dismissState,
              builder: _remoteBuilder,
            );
          } else if (_isWalletNotFoundException(error)) {
            final AppInfo? app = _app;
            return SolanaWalletDownloadView(
              options: app != null ? [app] : _adapter.store.apps, 
              onPressed: _onTapDownload,
            );
          } else {
            return _errorBuilder(error, snapshot.stackTrace);
          }
        } else {
          return _successBuilder(snapshot.data!);
        }
    }
  }

  /// Builds a view for the current remote association state.
  Widget _remoteBuilder(
    final BuildContext context,
    final AsyncSnapshot<AuthorizeResult> snapshot,
  ) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
      case ConnectionState.active:
        return SolanaWalletQrCodeView(
          app: _app,
          hostAuthority: _hostAuthority!, 
          timeLimit: _hostTimeLimit, 
          onPressedDownload: _onTapDownload,
        );
      case ConnectionState.done:
        final Object? error = snapshot.error;
        return error != null
          ? _errorBuilder(error, snapshot.stackTrace)
          : _successBuilder(snapshot.data!);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletModalCard(
      child: SolanaWalletMethodBuilder(
        future: _localFuture, 
        completer: widget.completer, 
        dismissState: widget.dismissState,
        builder: _localBuilder,
      ),
    );
  }
}