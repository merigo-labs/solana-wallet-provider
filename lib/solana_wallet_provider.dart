/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:solana_web3/rpc_config/confirm_transaction_config.dart';
import 'package:solana_web3/rpc_config/send_transaction_config.dart';
import 'package:solana_web3/rpc_models/blockhash_cache.dart';
import 'package:solana_web3/rpc_models/blockhash_with_expiry_block_height.dart';
import 'package:solana_web3/rpc_models/signature_notification.dart';
import 'package:solana_web3/solana_web3.dart';
import 'package:solana_web3/types/commitment.dart';
import 'src/cards/solana_wallet_connect_card.dart';
import 'src/cards/solana_wallet_disconnect_card.dart';
import 'src/exceptions/solana_wallet_provider_exception.dart';
import 'src/exceptions/solana_wallet_provider_exception_code.dart';
import 'src/models/dismiss_mode.dart';
import 'src/models/messages_and_addresses.dart';
import 'src/models/solana_wallet_app_info.dart';
import 'src/models/solana_wallet_method_state.dart';
import 'src/models/transaction_with_signers.dart';
import 'src/models/transactions_and_signers.dart';
import 'src/views/solana_wallet_method_view.dart';
import 'src/cards/solana_wallet_card.dart';
import 'src/solana_wallet_constants.dart';
import 'src/themes/solana_wallet_theme_extension.dart';
import 'src/views/solana_wallet_list_view.dart';
import 'src/widgets/solana_wallet_method_builder.dart';
import 'src/widgets/solana_wallet_sign_and_send_transactions_result_view.dart';


/// Exports
/// ------------------------------------------------------------------------------------------------

// solana_wallet_adapter
export 'package:solana_wallet_adapter/solana_wallet_adapter.dart';

// solana_web3
export 'package:solana_web3/exceptions/index.dart';
export 'package:solana_web3/programs/index.dart';
export 'package:solana_web3/rpc_config/index.dart';
export 'package:solana_web3/rpc_models/index.dart';
export 'package:solana_web3/types/index.dart';
export 'package:solana_web3/solana_web3.dart';

// src/cards/
export 'src/cards/solana_wallet_disconnect_card.dart';
export 'src/cards/solana_wallet_card.dart';
export 'src/cards/solana_wallet_connect_card.dart';

// src/exceptions/
export 'src/exceptions/solana_wallet_provider_exception_code.dart';
export 'src/exceptions/solana_wallet_provider_exception.dart';

// src/extensions/
export 'src/extensions/account.dart';

// src/models/
export 'src/models/dismiss_mode.dart';
export 'src/models/messages_and_addresses.dart';
export 'src/models/solana_wallet_app_info.dart';
export 'src/models/solana_wallet_method_state.dart';
export 'src/models/transaction_with_signers.dart';
export 'src/models/transactions_and_signers.dart';

// src/themes/
export 'src/themes/solana_wallet_card_theme.dart';
export 'src/themes/solana_wallet_qr_code_theme.dart';
export 'src/themes/solana_wallet_method_view_theme.dart';
export 'src/themes/solana_wallet_theme_extension.dart';

// src/views/
export 'src/views/solana_wallet_download_list_view.dart';
export 'src/views/solana_wallet_list_view.dart';
export 'src/views/solana_wallet_method_view.dart';
export 'src/views/solana_wallet_remote_connect_view.dart';

// src/widgets/
export 'src/widgets/solana_wallet_button.dart';
export 'src/widgets/solana_wallet_method_builder.dart';


/// Inherited Solana Wallet Provider
/// ------------------------------------------------------------------------------------------------

class _InheritedSolanaWalletProvider extends InheritedWidget {

  /// Rebuilds the widget each time [adapterState] changes.
  const _InheritedSolanaWalletProvider({
    required this.providerState,
    required this.adapterState,
    required super.child,
  });

  /// The authorization state.
  final WalletAdapterState? adapterState;

  /// The [SolanaWalletProvider] widget's state.
  final SolanaWalletProviderState providerState;

  /// The [SolanaWalletProvider] widget.
  SolanaWalletProvider get provider => providerState.widget;

  @override
  bool updateShouldNotify(covariant _InheritedSolanaWalletProvider oldWidget) 
    => oldWidget.adapterState != adapterState;
}


/// Solana Wallet Provider
/// ------------------------------------------------------------------------------------------------

class SolanaWalletProvider extends StatefulWidget with SolanaWalletProviderMixin {

  /// Creates a UI wrapper around the `solana_web3` and `solana_wallet_adapter` packages.
  /// 
  /// The widget must be initialized with [SolanaWalletProvider.initialize] and accessed by calling 
  /// [SolanaWalletProvider.of] from a descendent widget.
  SolanaWalletProvider({
    super.key,
    required this.child,
    required this.connection,
    required this.adapter,
  }): assert(
    connection.cluster == adapter.cluster                                 // given values
    || connection.cluster == Cluster.mainnet && adapter.cluster == null,  // default values
    '[SolanaWalletProvider] - [connection] and [adapter] are using different cluster.'
  );

  /// True if [SolanaWalletProvider.initialize] has completed successfully.
  static bool _debugInitialized = false;

  /// Modal bottom sheet route settings.
  static const RouteSettings modalRouteSettings = RouteSettings(name: '$packageName/modal');

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child; 

  @override
  final Connection connection;

  @override
  final SolanaWalletAdapter adapter;

  @override
  AuthorizeResult? get authorizeResult => adapter.authorizeResult;

  @override
  Account? get connectedAccount => adapter.connectedAccount;

  /// The accounts of the connected wallet.
  List<Account> get walletAccounts => adapter.authorizeResult?.accounts ?? const [];

  /// The addresses of the connected accounts.
  List<PublicKey> get walletAddresses => walletAccounts.map((final Account account) 
    => PublicKey.fromBase64(account.address)).toList(growable: false);

  /// A helper constructor that applies default values to [connection] and [adapter].
  factory SolanaWalletProvider.create({
    required AppIdentity identity,
    final Cluster? cluster,
    final Commitment? commitment = Commitment.confirmed,
    final String? hostAuthority,
    required Widget child,
  }) {
    final Cluster defaultCluster = cluster ?? Cluster.mainnet;
    return SolanaWalletProvider(
      connection: Connection(
        defaultCluster, 
        commitment: commitment,
      ), 
      adapter: SolanaWalletAdapter(
        identity,
        cluster: defaultCluster,
        hostAuthority: hostAuthority,
      ),
      child: child,
    );
  }

  /// Loads the wallet adapter's stored state.
  /// 
  /// This must be called when the application is first loaded. Methods and properties of 
  /// [SolanaWalletProvider] must be called `after` the future completes.
  static Future<void> initialize()
    => SolanaWalletAdapter.initialize().then((_) => _debugInitialized = true);
  
  /// Returns the widget state of the closest [SolanaWalletProvider] instance that encloses the 
  /// provided context.
  static SolanaWalletProvider of(final BuildContext context) {
    assert(_debugInitialized, '[SolanaWalletProvider.of] has been called before initialize().');
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedSolanaWalletProvider>();
    return inherited?.provider ?? (throw FlutterError(
      'Failed to find an instance of [SolanaWalletProvider] in the widget tree.'
    ));
  }

  /// Closes the provider's modal bottom sheet.
  static void close<T>(final BuildContext context) 
    => Navigator.popUntil(context, (route) => route.settings != modalRouteSettings);

  /// Opens the provider's modal bottom sheet with the contents returned by [builder].
  /// 
  /// The modal will be dismissed in accordance with the provided [dismissMode].
  /// 
  /// {@template solana_wallet_provider.dismissed_exception}
  /// Throws a [SolanaWalletProviderException] with code 
  /// [SolanaWalletProviderExceptionCode.dismissed] if the modal closes before completing the task.
  /// {@endtemplate}
  Future<T> open<T>({
    required final BuildContext context, 
    required final Widget Function(BuildContext, Completer<T>) builder,
    final DismissMode? dismissMode,
  }) {
    final Completer<T> completer = Completer();
    _dismissModal(
      context, 
      future: completer.future, 
      mode: dismissMode,
    );
    showModalBottomSheet(
      context: context, 
      builder: (final BuildContext context) => builder(context, completer),
      isScrollControlled: true,
      routeSettings: modalRouteSettings,
      backgroundColor: Colors.transparent,
    ).whenComplete(_onMethodCancelledHandler(completer))
     .ignore();
    return completer.future;
  }

  /// Dismiss the modal bottom sheet created for [future] in accordance with [mode].
  void _dismissModal<T>(
    final BuildContext context, {
    required final Future<T> future,
    required final DismissMode? mode,
  }) {
    switch(mode) {
      case null:
      case DismissMode.none:
        break;
      case DismissMode.success:
        future.then((_) { close(context); });
        break;
      case DismissMode.error:
        future.catchError((_) { close(context); });
        break;
      case DismissMode.done:
        future.whenComplete(() { close(context); });
        break;
    }
  }

  /// Resolves [completer] with [value].
  void _onMethodComplete<T>(
    final Completer<T> completer, 
    final T? value, 
  ) {
    if (!completer.isCompleted) {
      completer.complete(value);
    }
  }

  /// Creates a callback function for [_onMethodComplete].
  void Function(T? value) _onMethodCompleteHandler<T>(
    final Completer<T> completer,
  ) => (final T? value) {
    return _onMethodComplete(completer, value);
  };

  /// Resolves [completer] with [error].
  void _onMethodCompleteError<T>(
    final Completer<T> completer, 
    final Object error, [
    final StackTrace? stackTrace, 
  ]) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }

  /// Creates a callback function for [_onMethodCompleteError].
  void Function(Object error, [StackTrace? stackTrace]) _onMethodCompleteErrorHandler<T>(
    final Completer<T> completer,
  ) => (final Object error, [final StackTrace? stackTrace]) {
    return _onMethodCompleteError(completer, error, stackTrace);
  };

  /// Resolves [completer] with a [SolanaWalletProviderExceptionCode.dismissed] exception.
  void _onMethodCancelled<T>(final Completer<T> completer) => _onMethodCompleteError(
    completer, 
    const SolanaWalletProviderException(
      'The modal has been closed before completing the method.', 
      code: SolanaWalletProviderExceptionCode.dismissed,
    ),
  );

  /// Creates a callback function for [_onMethodCancelled].
  VoidCallback _onMethodCancelledHandler<T>(
    final Completer<T> completer,
  ) => () {
    return _onMethodCancelled(completer);
  };

  /// Creates a [Widget] by invoking the corresponding builder method of [controller.state].
  Widget stateWidget<T, U>(
    final BuildContext context, 
    final AsyncSnapshot<T> snapshot, 
    final SolanaWalletMethodController<U> controller, {
    final Widget Function(BuildContext)? noneBuilder,
    final Widget Function(BuildContext)? progressBuilder,
    final Widget Function(BuildContext, T?)? successBuilder,
    final Widget Function(BuildContext, Object? error)? errorBuilder,
  }) {
    switch (controller.state) {
      case SolanaWalletMethodState.none:
        return noneBuilder?.call(context)
          ?? SolanaWalletCard(
              body: SolanaWalletMethodView.none(),
            );
      case SolanaWalletMethodState.progress:
        return progressBuilder?.call(context)
          ?? SolanaWalletCard(
              body: SolanaWalletMethodView.progress(
                'Waiting for wallet response.',
              ),
            );
      case SolanaWalletMethodState.success:
        return successBuilder?.call(context, snapshot.data)
          ?? SolanaWalletCard(
              body: SolanaWalletMethodView.success(
                'Success.',
              ),
            );
      case SolanaWalletMethodState.error:
        return errorBuilder?.call(context, snapshot.error)
          ?? SolanaWalletCard(
              body: SolanaWalletMethodView.error(
                snapshot.error,
              ),
            );
    }
  }

  /// Creates a builder method that calls [stateWidget].
  MethodBuilder<T, U> stateWidgetBuilder<T, U>({
    final Widget Function(BuildContext)? noneBuilder,
    final Widget Function(BuildContext)? progressBuilder,
    final Widget Function(BuildContext, T?)? successBuilder,
    final Widget Function(BuildContext, Object? error)? errorBuilder,
  }) => (
    final BuildContext context, 
    final AsyncSnapshot<T> snapshot, 
    final SolanaWalletMethodController<U> controller,
  ) => stateWidget(
    context, 
    snapshot, 
    controller,
    noneBuilder: noneBuilder,
    progressBuilder: progressBuilder,
    successBuilder: successBuilder,
    errorBuilder: errorBuilder,
  );

  /// Presents a modal bottom sheet with a [SolanaWalletConnectCard].
  /// 
  /// The [apps] are given as download options if a Solana wallet cannot be found on the device.
  Future <AuthorizeResult> connect(
    final BuildContext context, {
    final List<SolanaWalletAppInfo> apps = const [],
    final String? hostAuthority,
    final DismissMode? dismissMode,
  }) => open(
    context: context, 
    dismissMode: dismissMode,
    builder: (
      final BuildContext context, 
      final Completer<AuthorizeResult> completer,
    ) => SolanaWalletConnectCard(
      apps: apps, 
      adapter: adapter,
      hostAuthority: hostAuthority,
      onComplete: _onMethodCompleteHandler(completer),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );
  
  /// Presents a modal bottom sheet with a [SolanaWalletDisconnectCard].
  Future<DeauthorizeResult> disconnect(
    final BuildContext context, {
    final DismissMode? dismissMode,
  }) => open(
    context: context, 
    dismissMode: dismissMode,
    builder: (
      final BuildContext context, 
      final Completer<DeauthorizeResult> completer,
    ) => SolanaWalletDisconnectCard(
      accounts: walletAccounts,
      selectedAccount: connectedAccount,
      onComplete: _onMethodCompleteHandler(completer),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );

  /// Presents a modal bottom sheet with the contents returned by [builder] for a non-privileged 
  /// [method] call.
  Future<T> nonPrivilegedMethod<T, U>(
    final BuildContext context, {
    required final Future<T> Function() method,
    required final MethodBuilder<T, dynamic> builder,
    final DismissMode? dismissMode,
  }) => open(
    context: context, 
    dismissMode: dismissMode,
    builder: (
      final BuildContext context, 
      final Completer<T> completer,
    ) => SolanaWalletMethodBuilder<T, dynamic>(
      value: null,
      method: (_) => method(), 
      builder: builder,
      onComplete: _onMethodCompleteHandler(completer),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.authorize] method call.
  ///
  /// {@macro solana_wallet_adapter.authorize}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<AuthorizeResult> authorize(
    final BuildContext context, {
    final MethodBuilder<AuthorizeResult, dynamic>? builder,
    final Widget? title,
    final DismissMode? dismissMode,
  }) => nonPrivilegedMethod(
    context, 
    dismissMode: dismissMode,
    method: adapter.authorize,
    builder: builder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: title,
        body: SolanaWalletMethodView.progress(
          'Waiting for wallet to connect.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Wallet connected.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to connect.',
        ),
      ),
    ),
  );
  
  /// Presents a modal bottom sheet for an [adapter.deauthorize] method call.
  ///
  /// {@macro solana_wallet_adapter.deauthorize}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<DeauthorizeResult> deauthorize(
    final BuildContext context, {
    final MethodBuilder<DeauthorizeResult, dynamic>? builder,
    final Widget? title,
    final DismissMode? dismissMode,
  }) => nonPrivilegedMethod(
    context, 
    dismissMode: dismissMode,
    method: adapter.deauthorize,
    builder: builder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: title,
        body: SolanaWalletMethodView.progress(
          'Waiting for wallet to connect.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Wallet disconnected.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to disconnect.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.reauthorize] method call.
  /// 
  /// {@macro solana_wallet_adapter.reauthorize}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<ReauthorizeResult> reauthorize(
    final BuildContext context, {
    final MethodBuilder<ReauthorizeResult, dynamic>? builder,
    final Widget? title,
    final DismissMode? dismissMode,
  }) => nonPrivilegedMethod(
    context, 
    dismissMode: dismissMode,
    method: adapter.reauthorize,
    builder: builder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: title,
        body: SolanaWalletMethodView.progress(
          'Waiting for wallet to connect.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Wallet connected.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to connect.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.reauthorizeOrAuthorize] method call.
  ///
  /// {@macro solana_wallet_adapter.reauthorizeOrAuthorize}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<AuthorizeResult> reauthorizeOrAuthorize(
    final BuildContext context, {
    final MethodBuilder<AuthorizeResult, dynamic>? builder,
    final Widget? title,
    final DismissMode? dismissMode,
  }) => nonPrivilegedMethod(
    context, 
    dismissMode: dismissMode,
    method: adapter.reauthorize,
    builder: builder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: title,
        body: SolanaWalletMethodView.progress(
          'Waiting for wallet to connect.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Wallet connected.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to connect.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.getCapabilities] method call.
  ///
  /// {@macro solana_wallet_adapter.getCapabilities}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<GetCapabilitiesResult> getCapabilities(
    final BuildContext context, {
    final MethodBuilder<GetCapabilitiesResult, dynamic>? builder,
    final Widget? title,
    final DismissMode? dismissMode,
  }) => nonPrivilegedMethod(
    context, 
    dismissMode: dismissMode,
    method: adapter.getCapabilities,
    builder: builder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: title,
        body: SolanaWalletMethodView.progress(
          'Requesting wallet capabilities.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Success.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed.',
        ),
      ),
    ),
  );

  /// Creates a builder method that generates a widget for each [SolanaWalletMethodState]s.
  MethodBuilder<U, dynamic> _privilegedBuilder<T, U>({
    required final Completer<T> completer,
    required final Future<T> Function(U value) method,
    required final MethodBuilder<U, dynamic> valueBuilder,
    required final MethodBuilder<T, U> methodBuilder,
    required final MethodBuilder<T, U>? reviewBuilder,
  }) {
    return (
      final BuildContext context, 
      final AsyncSnapshot<U> snapshot, 
      final SolanaWalletMethodController<dynamic> controller,
    ) {
      SolanaWalletMethodState state = controller.state;
      if (state == SolanaWalletMethodState.success) {
        final U? value = snapshot.data;
        if (value != null) {
          return SolanaWalletMethodBuilder<T, U>(
            value: value,
            method: method, 
            builder: _privilegedInnerBuilder(
              reviewBuilder: reviewBuilder,
              methodBuilder: methodBuilder,
            ),
            onComplete: _onMethodCompleteHandler(completer),
            onCompleteError: _onMethodCompleteErrorHandler(completer),
            auto: reviewBuilder == null,
          );
        }
        throw Exception('[SolanaWalletProvider] privileged builder returned null value.');
      }

      return valueBuilder(context, snapshot, controller);
    };
  }

  /// Creates a builder method that generates a widget for a privileged method call.
  MethodBuilder<T, U> _privilegedInnerBuilder<T, U>({
    required final MethodBuilder<T, U>? reviewBuilder,
    required final MethodBuilder<T, U> methodBuilder,
  }) {
    return (
      final BuildContext context, 
      final AsyncSnapshot<T> snapshot, 
      final SolanaWalletMethodController<U> controller,
    ) {
      switch (controller.state) {
        case SolanaWalletMethodState.none:
          return reviewBuilder?.call(context, snapshot, controller)
            ?? _privilegedReviewBuilder(context, snapshot, controller);
        default:
          return methodBuilder(context, snapshot, controller);
      }
    };
  }
  
  /// Builds a 'review order' card.
  Widget _privilegedReviewBuilder<T, U>(
      final BuildContext context, 
      final AsyncSnapshot<T> snapshot, 
      final SolanaWalletMethodController<U> controller,
  ) {
    final SolanaWalletThemeExtension? themeExt = SolanaWalletThemeExtension.of(context);
    return SolanaWalletCard(
      body: SolanaWalletListView(
        children: [
          const Text('Would you like to proceed with your order?'),
          Row(
            children: [
              TextButton(
                onPressed: () => SolanaWalletProvider.close(context), 
                style: themeExt?.secondaryButtonStyle,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => controller.call(), 
                style: themeExt?.primaryButtonStyle,
                child: const Text('Continue'),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Presents a modal bottom sheet that displays the state of a privileged [method] call.
  Future<T> privilegedMethod<T, U>(
    final BuildContext context, {
    required final Future<U> value,
    required final Future<T> Function(U value) method,
    required final MethodBuilder<U, dynamic> valueBuilder,
    required final MethodBuilder<T, U>? reviewBuilder,
    required final MethodBuilder<T, U> methodBuilder,
    final DismissMode? dismissMode,
  }) => open(
    context: context, 
    dismissMode: dismissMode,
    builder: (
      final BuildContext context, 
      final Completer<T> completer,
    ) => SolanaWalletMethodBuilder<U, dynamic>(
      value: null,
      method: (_) => value,
      builder: _privilegedBuilder(
        completer: completer, 
        method: method, 
        valueBuilder: valueBuilder, 
        methodBuilder: methodBuilder,
        reviewBuilder: reviewBuilder,
      ),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.signTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignTransactionsResult> signTransactions(
    final BuildContext context,
    final Future<List<Transaction>> transactions, {
    final Widget? valueTitle,
    final Widget? methodTitle,
    final MethodBuilder<List<Transaction>, dynamic>? valueBuilder,
    final MethodBuilder<SignTransactionsResult, List<Transaction>>? reviewBuilder,
    final MethodBuilder<SignTransactionsResult, List<Transaction>>? methodBuilder,
    final DismissMode? dismissMode,
  }) => privilegedMethod(
    context, 
    dismissMode: dismissMode,
    value: transactions, 
    method: _signTransactionsHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: valueTitle,
        body: SolanaWalletMethodView.progress(
          'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: methodTitle,
        body: SolanaWalletMethodView.progress(
          'Signing transactions.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Signing complete.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to sign transactions.',
        ),
      ),
    ),
  );
  
  /// Presents a modal bottom sheet for an [adapter.signTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignTransactionsResult> signTransactionsWithSigners(
    final BuildContext context,
    final Future<List<TransactionWithSigners>> transactions, {
    final Widget? valueTitle,
    final Widget? methodTitle,
    final MethodBuilder<List<TransactionWithSigners>, dynamic>? valueBuilder,
    final MethodBuilder<SignTransactionsResult, List<TransactionWithSigners>>? reviewBuilder,
    final MethodBuilder<SignTransactionsResult, List<TransactionWithSigners>>? methodBuilder,
    final DismissMode? dismissMode,
  }) => privilegedMethod(
    context, 
    dismissMode: dismissMode,
    value: transactions, 
    method: _signTransactionsWithSignersHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: valueTitle,
        body: SolanaWalletMethodView.progress(
          'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: methodTitle,
        body: SolanaWalletMethodView.progress(
          'Signing transactions.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Signing complete.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to sign transactions.',
        ),
      ),
    ),
  );

  /// Builds a widget for a successful sign and send transactions result.
  Widget _signAndSendTransactionsResultBuilder(
    final BuildContext context,
    final SignAndSendTransactionsResult? data,
  ) {
    final int length = data != null ? data.signatures.length : 0;
    return SolanaWalletCard(
      body: SolanaWalletSignAndSendTransactionsResultView(
        result: data, 
        cluster: connection.cluster,
        message: 'Transaction${length != 1 ? 's' : ''} confirmed.',
      ),
    );
  }

  /// Presents a modal bottom sheet for an [adapter.signAndSendTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignAndSendTransactionsResult> signAndSendTransactions(
    final BuildContext context,
    final Future<List<Transaction>> transactions, {
    final Commitment? commitment = Commitment.confirmed,
    final SignAndSendTransactionsConfig? config,
    final bool skipErrorResponse = false,
    final Widget? valueTitle,
    final Widget? methodTitle,
    final MethodBuilder<List<Transaction>, dynamic>? valueBuilder,
    final MethodBuilder<SignAndSendTransactionsResult, List<Transaction>>? reviewBuilder,
    final MethodBuilder<SignAndSendTransactionsResult, List<Transaction>>? methodBuilder,
    final DismissMode? dismissMode,
  }) => privilegedMethod(
    context, 
    dismissMode: dismissMode,
    value: transactions, 
    method: (final List<Transaction> transactions) => _signAndSendTransactionsPolyfill(
      transactions,
      commitment: commitment, 
      config: config,
      skipErrorResponse: skipErrorResponse,
    ), 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: valueTitle,
        body: SolanaWalletMethodView.progress(
          'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: methodTitle,
        body: SolanaWalletMethodView.progress(
          'Signing transactions to the network.',
        ),
      ),
      successBuilder: _signAndSendTransactionsResultBuilder,
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to sign and send transactions.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.signAndSendTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignAndSendTransactionsResult> signAndSendTransactionsWithSigners(
    final BuildContext context,
    final Future<List<TransactionWithSigners>> transactions, {
    final Commitment? commitment = Commitment.confirmed,
    final SignAndSendTransactionsConfig? config,
    final bool skipErrorResponse = false,
    final Widget? valueTitle,
    final Widget? methodTitle,
    final MethodBuilder<List<TransactionWithSigners>, dynamic>? valueBuilder,
    final MethodBuilder<SignAndSendTransactionsResult, List<TransactionWithSigners>>? reviewBuilder,
    final MethodBuilder<SignAndSendTransactionsResult, List<TransactionWithSigners>>? methodBuilder,
    final DismissMode? dismissMode,
  }) => privilegedMethod(
    context, 
    dismissMode: dismissMode,
    value: transactions, 
    method: (final List<TransactionWithSigners> transactions) 
      => _signAndSendTransactionsWithSignersHandler(
        transactions,
        commitment: commitment, 
        config: config,
        skipErrorResponse: skipErrorResponse,
      ), 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: valueTitle,
        body: SolanaWalletMethodView.progress(
          'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: methodTitle,
        body: SolanaWalletMethodView.progress(
          'Signing transactions to the network.',
        ),
      ),
      successBuilder: _signAndSendTransactionsResultBuilder,
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to sign and send transactions.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [adapter.signMessages] method call.
  /// 
  /// {@macro solana_wallet_adapter.signMessages}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignMessagesResult> signMessages(
    final BuildContext context,
    final Future<MessagesAndAddresses> messages, {
    final Widget? valueTitle,
    final Widget? methodTitle,
    final MethodBuilder<MessagesAndAddresses, dynamic>? valueBuilder,
    final MethodBuilder<SignMessagesResult, MessagesAndAddresses>? reviewBuilder,
    final MethodBuilder<SignMessagesResult, MessagesAndAddresses>? methodBuilder,
    final DismissMode? dismissMode,
  }) => privilegedMethod(
    context, 
    dismissMode: dismissMode,
    value: messages, 
    method: _signMessagesHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: valueTitle,
        body: SolanaWalletMethodView.progress(
          'Processing messages.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to process messages.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        title: methodTitle,
        body: SolanaWalletMethodView.progress(
          'Signing messages.',
        ),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletMethodView.success(
          'Signing complete.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletMethodView.error(
          error,
          'Failed to sign messages.',
        ),
      ),
    ),
  );
    
  /// Runs [callback] for a local wallet endpoint. If a local wallet cannot be found, attempt a 
  /// remote connection with [adapter.hostAuthority].
  Future<T> _association<T>(
    final AssociationCallback<T> callback,
  ) async {
    try {
      return await adapter.localAssociation(callback);
    } on SolanaWalletAdapterException catch (error, stackTrace) {
      final String? hostAuthority = adapter.hostAuthority;
      return hostAuthority != null && error.code == SolanaWalletAdapterExceptionCode.walletNotFound
        ? adapter.remoteAssociation(hostAuthority, callback)
        : Future.error(error, stackTrace);
    }
  }

  /// {@macro solana_wallet_adapter.signTransactions}
  Future<SignTransactionsResult> _signTransactionsHandler(
    final List<Transaction> transactions,
  ) => _association((final WalletAdapterConnection connection) async {
    await adapter.reauthorizeOrAuthorizeHandler(connection);
    final List<String> encodedTransactions = await _serializeTransactions(transactions);
    return adapter.signTransactionsHandler(
      connection, 
      transactions: encodedTransactions,
    );
  });

  /// {@macro solana_wallet_adapter.signTransactions}
  Future<SignTransactionsResult> _signTransactionsWithSignersHandler(
    final List<TransactionWithSigners> transactions,
  ) async {
    final TransactionsAndSigners info = _splitTransactionsWithSigners(transactions);
    final SignTransactionsResult result = await _signTransactionsHandler(info.transactions); 
    final List<String> signedTransactions = _partialSign(
      result.signedPayloads, 
      signersList: info.signersList,
    );
    return SignTransactionsResult(
      signedPayloads: signedTransactions,
    ); 
  }

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> _signAndSendTransactionsHandler(
    final List<Transaction> transactions, {
    final SignAndSendTransactionsConfig? config,
  }) => _association((connection) async {
    await adapter.reauthorizeOrAuthorizeHandler(connection);
    final List<String> encodedTransactions = await _serializeTransactions(transactions);
    return adapter.signAndSendTransactionsHandler(
      connection,
      transactions: encodedTransactions,
      config: config,
    );
  });

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> _signAndSendTransactionsWithSignersHandler(
    final List<TransactionWithSigners> transactions, {
    final Commitment? commitment,
    final SignAndSendTransactionsConfig? config,
    required final bool skipErrorResponse,
  }) async {
    
    // Sign transactions with the wallet accounts and provided signers.
    final SignTransactionsResult signResult = await _signTransactionsWithSignersHandler(
      transactions,
    );

    // Send the signed transactions to the Solana network.
    final SignAndSendTransactionsResult sendResult = await _sendSignedTransactions(
      signResult.signedPayloads,
      config: config,
      skipErrorResponse: skipErrorResponse,
    );
    
    /// Wait for signature notifications.
    if (commitment != null) {
      await _confirmTransactions(sendResult.signatures, commitment: commitment);
    }

    /// Return the transaction signatures.
    return sendResult;
  }

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> _signAndSendTransactionsPolyfill(
    final List<Transaction> transactions, {
    final Commitment? commitment = Commitment.confirmed,
    final SignAndSendTransactionsConfig? config,
    required final bool skipErrorResponse,
  }) async {
    
    /// The sign and send method call result.
    late final SignAndSendTransactionsResult result;
    try {
      // throw JsonRpcException('', code: JsonRpcExceptionCode.methodNotFound);
      // Try calling the wallet API's implementation, which may not exist.
      result = await _signAndSendTransactionsHandler(
        transactions,
        config: config,
      );
    } on JsonRpcException catch (error, stackTrace) {
      // If the wallet does not implement the sign and send method, sign the transactions with the 
      // wallet and send the result to the Solana network separately.
      if (error.code == JsonRpcExceptionCode.methodNotFound) {
        final SignTransactionsResult signResult = await _signTransactionsHandler(transactions);
        result = await _sendSignedTransactions(
          signResult.signedPayloads, 
          config: config, 
          skipErrorResponse: skipErrorResponse,
        );
      } else {
        return Future.error(error, stackTrace);
      }
    }
    
    /// Wait for signature notifications.
    if (commitment != null) {
      await _confirmTransactions(result.signatures, commitment: commitment);
    }
    
    /// Return the transaction signatures.
    return result;
  }

  /// {@macro solana_wallet_adapter.signMessages}
  Future<SignMessagesResult> _signMessagesHandler(
    final MessagesAndAddresses data,
  ) => _association((connection) async {
    await adapter.reauthorizeOrAuthorizeHandler(connection);
    final List<String> encodedMessages = _serializeMessages(data.messages);
    return adapter.signMessagesHandler(
      connection, 
      messages: encodedMessages, 
      addresses: data.addresses.map((address) => address.toBase64()).toList(growable: false),
    );
  });

  /// Sends [signedTransactions] to the Solana network for processing.
  Future<SignAndSendTransactionsResult> _sendSignedTransactions(
    final List<String> signedTransactions, {
    required final SignAndSendTransactionsConfig? config,
    required final bool skipErrorResponse,
  }) async {

    // Send signed transactions to the Solana network for processing.
    final List<JsonRpcResponse> responses = await connection.sendSignedTransactionsRaw(
      signedTransactions,
      config: SendTransactionConfig(
        minContextSlot: config?.minContextSlot,
        preflightCommitment: connection.commitment,
      ),
    );

    // Convert each signature to base-64 as per the Mobile Wallet Adapter Specification.
    // 
    // Check for error responses and convert each signature to a base-64 string so that it's inline
    // with the Mobile Wallet Specification API.
    final List<String?> signatures = [];
    for (final JsonRpcResponse response in responses) {
      final JsonRpcException? error = response.error;
      if (!skipErrorResponse && error != null) {
        return Future.error(error);
      }
      final String? signature = response.result;
      signatures.add(
        signature != null
          ? base64.encode(base58.decode(signature))
          : null,
      );
    }
    return SignAndSendTransactionsResult(
      signatures: signatures,
    );
  }

  /// Confirms transaction [signatures] for the provided [commitment] level.
  Future<List<SignatureNotification>> _confirmTransactions(
    final List<String?> signatures, {
    required final Commitment commitment,
  }) {
    final List<Future<SignatureNotification>> notifications = [];
    for (final String? signature in signatures) {
      if (signature != null) {
        notifications.add(
          connection.confirmTransaction(
            base58.encode(base64.decode(signature)),
            config: ConfirmTransactionConfig(
              commitment: commitment,
            ),
          ),
        );
      }
    }
    return Future.wait(
      notifications, 
      eagerError: true,
    );
  }

  /// Separates transactions and signers.
  TransactionsAndSigners _splitTransactionsWithSigners<T>(
    final List<TransactionWithSigners> transactionWithSignersList,
  ) {
    final List<Transaction> transactions= [];
    final List<List<Signer>?> signersList = [];
    for (final TransactionWithSigners transactionWithSigners in transactionWithSignersList) {
      transactions.add(transactionWithSigners.transaction);
      signersList.add(transactionWithSigners.signers);
    }
    return TransactionsAndSigners(
      transactions: transactions, 
      signersList: signersList,
    );
  }

  /// Serializes [transactions] into a list of base-64 encoded strings.
  Future<List<String>> _serializeTransactions(
    final Iterable<Transaction> transactions,
  ) async {
    final List<String> encodedTransactions = [];
    final BlockhashCache blockhashCache = BlockhashCache();
    const SerializeConfig config = SerializeConfig(requireAllSignatures: false);
    for (final Transaction transaction in transactions) {
      final BlockhashWithExpiryBlockHeight blockhashInfo = transaction.blockhash 
        ?? (await blockhashCache.get(connection, disabled: false));
      final Transaction tx = transaction.copyWith(
        recentBlockhash: blockhashInfo.blockhash,
        lastValidBlockHeight: blockhashInfo.lastValidBlockHeight,
        feePayer: transaction.feePayer ?? PublicKey.tryFromBase64(connectedAccount?.address),
      );
      encodedTransactions.add(
        tx.serialize(config).getString(BufferEncoding.base64),
      );
    }
    return encodedTransactions;
  }

  /// Serializes [messages] into a list of base-64 encoded strings.
  List<String> _serializeMessages(final Iterable<Message> messages) {
    final List<String> encodedMessages = [];
    for (final Message message in messages) {
      encodedMessages.add(
        message.serialize().getString(BufferEncoding.base64),
      );
    }
    return encodedMessages;
  }

  /// Signs each of the [signedPayloads] with the corresponding `signers`.
  /// 
  /// ```
  /// _partialSign(
  ///   [
  ///     'signed payload 1', 
  ///     'signed payload 2', 
  ///     'signed payload 3',
  ///   ],
  ///   signersList: [
  ///     ['signer 1', 'signer 2'], // Additional signers for 'signed payload 1'.
  ///     null,                     // Additional signers for 'signed payload 2'.
  ///     ['signer 1'],             // Additional signers for 'signed payload 3'.
  ///   ], 
  /// );
  /// ```
  List<String> _partialSign(
    final List<String> signedPayloads, { 
    required final List<List<Signer>?> signersList
  }) {
    final List<String> signedTransactions = [];
    for (int i = 0; i < signedPayloads.length; ++i) {
      final String signedTransaction = signedPayloads[i];
      final List<Signer>? signers = signersList[i];
      if (signers != null && signers.isNotEmpty) {
        final Transaction tx = Transaction.fromBase64(signedTransaction)..partialSign(signers);
        signedTransactions.add(tx.serialize().getString(BufferEncoding.base64));
      } else {
        signedTransactions.add(signedTransaction);
      }
    }
    return signedTransactions;
  }

  @override
  SolanaWalletProviderState createState() => SolanaWalletProviderState();
}


/// Solana Wallet Provider State
/// ------------------------------------------------------------------------------------------------

class SolanaWalletProviderState extends State<SolanaWalletProvider> with SolanaWalletProviderMixin {
  
  @override
  Connection get connection => widget.connection;

  @override
  SolanaWalletAdapter get adapter => widget.adapter;

  @override
  AuthorizeResult? get authorizeResult => widget.adapter.authorizeResult;

  @override
  Account? get connectedAccount => widget.adapter.connectedAccount;

  @override
  void initState() {
    super.initState();
    adapter.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    adapter.removeListener(_onStateChanged);
    super.dispose();
  }

  /// Calls for the widget to be rebuilt.
  void _onStateChanged() => setState(() {});

  /// Returns the widget state of the closest [SolanaWalletProvider] instance that encloses the 
  /// provided context.
  static SolanaWalletProviderState of(final BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedSolanaWalletProvider>();
    return inherited?.providerState ?? (throw FlutterError(
      'Failed to find an instance of [SolanaWalletProviderState] in the widget tree.'
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSolanaWalletProvider(
      providerState: this,
      adapterState: widget.adapter.state,
      child: widget.child,
    );
  }
}


/// Solana Wallet Provider Mixin
/// ------------------------------------------------------------------------------------------------

mixin SolanaWalletProviderMixin {

  /// {@macro solana_web3.Connection}
  Connection get connection;

  /// {@macro solana_wallet_adapter.SolanaWalletAdapter}
  SolanaWalletAdapter get adapter;

  /// {@macro solana_wallet_adapter.authorizeResult}
  AuthorizeResult? get authorizeResult;

  /// {@macro solana_wallet_adapter.connectedAccount}
  Account? get connectedAccount;
}