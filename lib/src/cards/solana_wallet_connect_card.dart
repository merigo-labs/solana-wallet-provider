/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import '../views/solana_wallet_progress_view.dart';
import '../../solana_wallet_provider.dart';
import '../../src/views/solana_wallet_authorized_view.dart';


/// Solana Wallet Connect Card
/// ------------------------------------------------------------------------------------------------

/// A card that facilitates connecting an application to a wallet app.
class SolanaWalletConnectCard extends StatefulWidget {
  
  /// Creates a card that facilitates connecting an application to a wallet app.
  const SolanaWalletConnectCard({
    super.key,
    this.options = const [],
    this.downloadOptions = const [],
    required this.adapter,
    this.hostAuthority,
    this.dismissState,
    required this.onComplete,
    required this.onCompleteError,
  });

  /// The applications presented as options to connect with.
  final List<AppInfo> options;

  /// The applications presented as options to download.
  final List<AppInfo> downloadOptions;

  /// The wallet adapter to connect with.
  final SolanaWalletAdapter adapter;

  /// The remote connection uri.
  final String? hostAuthority;

  /// The [SolanaWalletMethodState] in which the [SolanaWalletProvider] modal should be 
  /// automatically closed.
  final DismissState? dismissState;

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

  /// The selected application.
  AppInfo? _appInfo;

  /// The type of association being attempted.
  AssociationType _associationType = AssociationType.local;

  /// The wallet adapter.
  SolanaWalletAdapter get _adapter => widget.adapter;

  /// The remote connection uri.
  String? get _hostAuthority => widget.hostAuthority ?? _adapter.hostAuthority;

  /// The remote connection timeout.
  final Duration _hostTimeout = const Duration(minutes: 2);

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
    
  /// Returns true if [error] is a [SolanaWalletAdapterException] with error code 
  /// [SolanaWalletAdapterExceptionCode.walletNotFound].
  bool _isWalletNotFoundException(final Object? error) {
    return error is SolanaWalletAdapterException 
      && error.code == SolanaWalletAdapterExceptionCode.walletNotFound;
  }

  /// Sets [_associationType] and marks the widget to be rebuilt.
  void _setAssociationType(final AssociationType associationType) {
    if (mounted && _associationType != associationType) {
      setState(() => _associationType = associationType);
    }
  }

  /// Creates an app selection callback method.
  void Function(AppInfo info) _onTapSelection(
    final SolanaWalletMethodController controller,
  ) => (final AppInfo appInfo) {
    _appInfo = appInfo;
    // Set provider for desktop web browsers **(N/A for mobile)**.
    SolanaWalletAdapterPlatform.instance.setProvider(appInfo);
    if (SolanaWalletAdapterPlatform.instance.isDesktop
      && !SolanaWalletAdapterPlatform.instance.hasProvider) {
        _onTapInstall(appInfo);
    } else {
      controller.call();
    }
  };

  /// Opens [app]'s store and closes [SolanaWalletProvider]'s modal bottom sheet.
  void _onTapInstall(final AppInfo app) {
    SolanaWalletAdapterPlatform.instance.openStore(app).ignore();
    SolanaWalletProvider.close(context);
  }

  /// [SolanaWalletMethodBuilder.method].
  Future<AuthorizeResult> _method([
    final dynamic value,
  ]) async {
    try {
      // 1. Local Association - attempt a local association request to connect the application with 
      // a wallet running on the device.
      _setAssociationType(AssociationType.local);
      return await _adapter.localAssociation(
        _adapter.authorizeHandler, 
        walletUriBase: _appInfo?.walletUriBase,
        scheme: _appInfo?.scheme,
      );
    } on SolanaWalletAdapterException catch (error) {
      // 2. Remote Association - attempt a remote association request to connect the application 
      // with a wallet running on different device.
      final String? hostAuthority = _hostAuthority;
      if (_isWalletNotFoundException(error) && _hostAuthority != null) {
        _setAssociationType(AssociationType.remote);
        return _adapter.remoteAssociation(
          hostAuthority, 
          _adapter.authorizeHandler, 
          timeout: _hostTimeout,
        );
      }
      rethrow;
    }
  }

  /// Builds a widget for the current [SolanaWalletMethodController.state].
  Widget _builder(
    final BuildContext context, 
    final AsyncSnapshot<AuthorizeResult> snapshot,
    final SolanaWalletMethodController controller,
  ) {    
    switch(controller.state) {
      case SolanaWalletMethodState.none:
        return _noneBuilder(context, controller);
      case SolanaWalletMethodState.progress:
        return _progressBuilder(context, snapshot);
      case SolanaWalletMethodState.success:
        return _successBuilder(context, snapshot.data!);
      case SolanaWalletMethodState.error:
        return _errorBuilder(context, snapshot.error);
    }
  }

  /// Builds a widget for [SolanaWalletMethodState.none].
  Widget _noneBuilder(
    final BuildContext context, 
    final SolanaWalletMethodController controller,
  ) {
    return SolanaWalletCard(
      body: SolanaWalletAppListView(
        title: const Text('Connect Wallet'),
        message: const Text('Select a wallet provider.'),
        onPressed: _onTapSelection(controller),
        apps: widget.options,
      ),
    );
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
          body: SolanaWalletProgressView.opening(
            app: _appInfo,
          ),
        );
      case AssociationType.remote:
        return SolanaWalletCard(
          key: ValueKey(_associationType),
          body: SolanaWalletRemoteConnectView(
            app: _appInfo,
            hostAuthority: _hostAuthority!,
            timeout: _hostTimeout,
          ),
        );
    }
  }

  /// Builds a widget for [SolanaWalletMethodState.success].
  Widget _successBuilder(
    final BuildContext context, 
    final AuthorizeResult result,
  ) {
    return SolanaWalletCard(
      body: SolanaWalletAuthorizedView(
        result: result,
        app: _appInfo,
      ),
    );
  }

  /// Builds a widget for [SolanaWalletMethodState.error].
  Widget _errorBuilder(
    final BuildContext context, 
    final Object? error,
  ) {
    if (_isWalletNotFoundException(error)) {
      final AppInfo? appInfo = _appInfo; 
      if (appInfo != null) {
        return SolanaWalletCard(
          body: SolanaWalletAppDownloadView(
            app: appInfo,
            onPressed: _onTapInstall,
          ),
        );
      }
      if (widget.downloadOptions.isNotEmpty) {
        return SolanaWalletCard(
          body: SolanaWalletAppListView(
            title: const Text('Download Wallet'), 
            message: Text(SolanaWalletAppDownloadView.description), 
            apps: widget.downloadOptions, 
            onPressed: _onTapInstall,
          ),
        );
      }
    }
    return SolanaWalletCard(
      body: SolanaWalletStateView.error(
        error: error,
        message: 'Failed to connect.'
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return SolanaWalletMethodBuilder(
      value: null, 
      method: _method, 
      builder: _builder,
      dismissState: widget.dismissState,
      auto: widget.options.isEmpty,
      onComplete: widget.onComplete,
      onCompleteError: widget.onCompleteError,
    );
  }
}