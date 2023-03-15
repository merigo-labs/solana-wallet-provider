/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:solana_common/web_socket/web_socket_subscription_manager.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:solana_web3/exceptions/transaction_exception.dart';
import 'package:solana_web3/rpc_config/commitment_subscribe_config.dart';
import 'package:solana_web3/rpc_config/get_signature_statuses_config.dart';
import 'package:solana_web3/rpc_config/send_transaction_config.dart';
import 'package:solana_web3/rpc_models/blockhash_cache.dart';
import 'package:solana_web3/rpc_models/blockhash_with_expiry_block_height.dart';
import 'package:solana_web3/rpc_models/signature_notification.dart';
import 'package:solana_web3/rpc_models/signature_status.dart';
import 'package:solana_web3/solana_web3.dart';
import 'package:solana_web3/types/commitment.dart';
import 'src/cards/solana_wallet_card.dart';
import 'src/cards/solana_wallet_connect_card.dart';
import 'src/cards/solana_wallet_disconnect_card.dart';
import 'src/exceptions/solana_wallet_provider_exception.dart';
import 'src/models/dismiss_state.dart';
import 'src/models/messages_and_addresses.dart';
import 'src/models/sign_in_message.dart';
import 'src/models/solana_wallet_method_state.dart';
import 'src/models/transaction_with_signers.dart';
import 'src/models/transactions_and_signers.dart';
import 'src/utils/constants.dart';
import 'src/themes/solana_wallet_theme_extension.dart';
import 'src/views/solana_wallet_content_view.dart';
import 'src/views/solana_wallet_state_view.dart';
import 'src/views/solana_wallet_progress_view.dart';
import 'src/widgets/solana_wallet_method_builder.dart';
import 'src/views/solana_wallet_sign_and_send_transactions_result_view.dart';


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
export 'src/exceptions/solana_wallet_provider_exception.dart';

// src/extensions/
export 'src/extensions/account.dart';

// src/models/
export 'src/models/dismiss_state.dart';
export 'src/models/messages_and_addresses.dart';
export 'src/models/sign_in_message.dart';
export 'src/models/solana_wallet_method_state.dart';
export 'src/models/transaction_with_signers.dart';
export 'src/models/transactions_and_signers.dart';

// src/themes/
export 'src/themes/solana_wallet_card_theme.dart';
export 'src/themes/solana_wallet_qr_code_theme.dart';
export 'src/themes/solana_wallet_state_theme.dart';
export 'src/themes/solana_wallet_theme_extension.dart';

// src/views/
export 'src/views/solana_wallet_app_list_view.dart';
export 'src/views/solana_wallet_app_download_view.dart';
export 'src/views/solana_wallet_column_view.dart';
export 'src/views/solana_wallet_state_view.dart';
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
    final Cluster? wsCluster,
    final Commitment? commitment = Commitment.confirmed,
    final String? hostAuthority,
    required Widget child,
  }) {
    final Cluster defaultCluster = cluster ?? Cluster.mainnet;
    return SolanaWalletProvider(
      connection: Connection(
        defaultCluster, 
        wsCluster: wsCluster,
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
  /// {@template solana_wallet_provider.dismissed_exception}
  /// Throws a [SolanaWalletProviderException] with code 
  /// [SolanaWalletProviderExceptionCode.dismissed] if the modal closes before completing the task.
  /// {@endtemplate}
  Future<T> open<T>({
    required final BuildContext context, 
    required final Widget Function(BuildContext, Completer<T>) builder,
  }) {
    final Completer<T> completer = Completer();
    showModalBottomSheet(
      context: context, 
      builder: (final BuildContext context) => builder(context, completer),
      isScrollControlled: true,
      routeSettings: modalRouteSettings,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ).whenComplete(_onMethodCancelledHandler(completer))
     .ignore();
    return completer.future;
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
    SolanaWalletAdapter.disconnect().ignore();
    return _onMethodCancelled(completer);
  };

  /// Creates a [Widget] by invoking the corresponding builder method of 
  /// [SolanaWalletMethodController.state].
  Widget stateWidget<T>(
    final BuildContext context, 
    final AsyncSnapshot<T> snapshot, 
    final SolanaWalletMethodController controller, {
    required final Widget Function(BuildContext)? noneBuilder,
    required final Widget Function(BuildContext) progressBuilder,
    required final Widget Function(BuildContext, T?)? successBuilder,
    required final Widget Function(BuildContext, Object? error) errorBuilder,
  }) {
    switch (controller.state) {
      case SolanaWalletMethodState.none:
        return noneBuilder?.call(context) 
          ?? progressBuilder.call(context);
      case SolanaWalletMethodState.progress:
        return progressBuilder.call(context);
      case SolanaWalletMethodState.success:
        return successBuilder?.call(context, snapshot.data)
          ?? SolanaWalletStateView.success();
      case SolanaWalletMethodState.error:
        return errorBuilder.call(context, snapshot.error);
    }
  }

  /// Creates a builder method that calls [stateWidget].
  MethodBuilder<T> stateWidgetBuilder<T>({
    final Widget Function(BuildContext)? noneBuilder,
    required final Widget Function(BuildContext) progressBuilder,
    final Widget Function(BuildContext, T?)? successBuilder,
    required final Widget Function(BuildContext, Object? error) errorBuilder,
  }) => (
    final BuildContext context, 
    final AsyncSnapshot<T> snapshot, 
    final SolanaWalletMethodController controller,
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
  /// Provide [options] to display a list of wallet applications prior to establishing a connection.
  /// 
  /// The [downloadOptions] are presented if a Solana wallet cannot be found on the device.
  Future <AuthorizeResult> connect(
    final BuildContext context, {
    final List<AppInfo> options = const [],
    final List<AppInfo> downloadOptions = const [],
    final String? hostAuthority,
    final DismissState? dismissState,
  }) => open(
    context: context, 
    builder: (
      final BuildContext context, 
      final Completer<AuthorizeResult> completer,
    ) => SolanaWalletConnectCard(
      options: options, 
      downloadOptions: downloadOptions,
      adapter: adapter,
      hostAuthority: hostAuthority,
      dismissState: dismissState,
      onComplete: _onMethodCompleteHandler(completer),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );
  
  /// Presents a modal bottom sheet with a [SolanaWalletDisconnectCard].
  Future<DeauthorizeResult> disconnect(
    final BuildContext context, {
    final DismissState? dismissState,
  }) => open(
    context: context, 
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
  Future<T> nonPrivilegedMethod<T>(
    final BuildContext context, {
    required final Future<T> Function() method,
    required final MethodBuilder<T> builder,
    final DismissState? dismissState,
  }) => open(
    context: context, 
    builder: (
      final BuildContext context, 
      final Completer<T> completer,
    ) => SolanaWalletMethodBuilder<T, dynamic>(
      value: null,
      method: (_) => method(), 
      builder: builder,
      dismissState: dismissState,
      onComplete: _onMethodCompleteHandler(completer),
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );

  // /// Presents a modal bottom sheet for an [SolanaWalletAdapter.authorize] method call.
  // ///
  // /// {@macro solana_wallet_adapter_platform_interface.authorize}
  // ///
  // /// {@macro solana_wallet_provider.dismissed_exception}
  // Future<AuthorizeResult> authorize(
  //   final BuildContext context, {
  //   final MethodBuilder<AuthorizeResult>? builder,
  //   final Widget? header,
  //   final DismissState? dismissState,
  // }) => nonPrivilegedMethod(
  //   context, 
  //   dismissState: dismissState,
  //   method: adapter.authorize,
  //   builder: builder ?? stateWidgetBuilder(
  //     progressBuilder: (_) => SolanaWalletCard(
  //       header: header,
  //       body: const SolanaWalletOpeningWalletView(),
  //     ),
  //     successBuilder: (_, result) => SolanaWalletCard(
  //       body: SolanaWalletAuthorizedView(
  //         result: result,
  //       ),
  //     ),
  //     errorBuilder: (_, error) => SolanaWalletCard(
  //       body: SolanaWalletStateView.error(
  //         error: error,
  //         message: 'Failed to connect.',
  //       ),
  //     ),
  //   ),
  // );
  
  // /// Presents a modal bottom sheet for an [SolanaWalletAdapter.deauthorize] method call.
  // ///
  // /// {@macro solana_wallet_adapter_platform_interface.deauthorize}
  // ///
  // /// {@macro solana_wallet_provider.dismissed_exception}
  // Future<DeauthorizeResult> deauthorize(
  //   final BuildContext context, {
  //   final MethodBuilder<DeauthorizeResult>? builder,
  //   final Widget? header,
  //   final DismissState? dismissState,
  // }) => nonPrivilegedMethod(
  //   context, 
  //   dismissState: dismissState,
  //   method: adapter.deauthorize,
  //   builder: builder ?? stateWidgetBuilder(
  //     progressBuilder: (_) => SolanaWalletCard(
  //       header: header,
  //       body: const SolanaWalletOpeningWalletView(),
  //     ),
  //     successBuilder: (_, __) => SolanaWalletCard(
  //       body: SolanaWalletStateView.success(
  //         title: 'Wallet Disconnected',
  //       ),
  //     ),
  //     errorBuilder: (_, error) => SolanaWalletCard(
  //       body: SolanaWalletStateView.error(
  //         error: error,
  //         message: 'Failed to disconnect.',
  //       ),
  //     ),
  //   ),
  // );

  // /// Presents a modal bottom sheet for an [SolanaWalletAdapter.reauthorize] method call.
  // /// 
  // /// {@macro solana_wallet_adapter_platform_interface.reauthorize}
  // ///
  // /// {@macro solana_wallet_provider.dismissed_exception}
  // Future<ReauthorizeResult> reauthorize(
  //   final BuildContext context, {
  //   final MethodBuilder<ReauthorizeResult>? builder,
  //   final Widget? header,
  //   final DismissState? dismissState,
  // }) => nonPrivilegedMethod(
  //   context, 
  //   dismissState: dismissState,
  //   method: adapter.reauthorize,
  //   builder: builder ?? stateWidgetBuilder(
  //     progressBuilder: (_) => SolanaWalletCard(
  //       header: header,
  //       body: const SolanaWalletOpeningWalletView(),
  //     ),
  //     successBuilder: (_, __) => SolanaWalletCard(
  //       body: SolanaWalletStateView.success(
  //         title: 'Wallet Connected',
  //       ),
  //     ),
  //     errorBuilder: (_, error) => SolanaWalletCard(
  //       body: SolanaWalletStateView.error(
  //         error: error,
  //         message: 'Failed to connect.',
  //       ),
  //     ),
  //   ),
  // );

  // /// Presents a modal bottom sheet for an [SolanaWalletAdapter.reauthorizeOrAuthorize] method call.
  // ///
  // /// {@macro solana_wallet_adapter_platform_interface.reauthorizeOrAuthorize}
  // ///
  // /// {@macro solana_wallet_provider.dismissed_exception}
  // Future<AuthorizeResult> reauthorizeOrAuthorize(
  //   final BuildContext context, {
  //   final MethodBuilder<AuthorizeResult>? builder,
  //   final Widget? header,
  //   final DismissState? dismissState,
  // }) => nonPrivilegedMethod(
  //   context, 
  //   dismissState: dismissState,
  //   method: adapter.reauthorizeOrAuthorize,
  //   builder: builder ?? stateWidgetBuilder(
  //     progressBuilder: (_) => SolanaWalletCard(
  //       header: header,
  //       body: const SolanaWalletOpeningWalletView(),
  //     ),
  //     successBuilder: (_, __) => SolanaWalletCard(
  //       body: SolanaWalletStateView.success(
  //         title: 'Wallet Connected',
  //       ),
  //     ),
  //     errorBuilder: (_, error) => SolanaWalletCard(
  //       body: SolanaWalletStateView.error(
  //         error: error,
  //         message: 'Failed to connect.',
  //       ),
  //     ),
  //   ),
  // );

  // /// Presents a modal bottom sheet for an [SolanaWalletAdapter.getCapabilities] method call.
  // ///
  // /// {@macro solana_wallet_adapter_platform_interface.getCapabilities}
  // ///
  // /// {@macro solana_wallet_provider.dismissed_exception}
  // Future<GetCapabilitiesResult> getCapabilities(
  //   final BuildContext context, {
  //   final MethodBuilder<GetCapabilitiesResult>? builder,
  //   final Widget? header,
  //   final DismissState? dismissState,
  // }) => nonPrivilegedMethod(
  //   context, 
  //   dismissState: dismissState,
  //   method: adapter.getCapabilities,
  //   builder: builder ?? stateWidgetBuilder(
  //     progressBuilder: (_) => SolanaWalletCard(
  //       header: header,
  //       body: const SolanaWalletOpeningWalletView(),
  //     ),
  //     errorBuilder: (_, error) => SolanaWalletCard(
  //       body: SolanaWalletStateView.error(
  //         error: error,
  //       ),
  //     ),
  //   ),
  // );

  /// Creates a builder method that generates a widget for each [SolanaWalletMethodState]s.
  MethodBuilder<U> _privilegedBuilder<T, U>({
    required final Completer<T> completer,
    required final Future<T> Function(U value) method,
    required final MethodBuilder<U> valueBuilder,
    required final MethodBuilder<T> methodBuilder,
    required final MethodBuilder<T>? reviewBuilder,
  }) {
    return (
      final BuildContext context, 
      final AsyncSnapshot<U> snapshot, 
      final SolanaWalletMethodController controller,
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
  MethodBuilder<T> _privilegedInnerBuilder<T>({
    required final MethodBuilder<T>? reviewBuilder,
    required final MethodBuilder<T> methodBuilder,
  }) {
    return (
      final BuildContext context, 
      final AsyncSnapshot<T> snapshot, 
      final SolanaWalletMethodController controller,
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
      final SolanaWalletMethodController controller,
  ) {
    final SolanaWalletThemeExtension? themeExt = SolanaWalletThemeExtension.of(context);
    return SolanaWalletCard(
      body: SolanaWalletContentView(
        title: const Text('Review Order'),
        message: const Text('Would you like to proceed with your order?'),
        body: Row(
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
        ),
      ),
    );
  }

  /// Presents a modal bottom sheet that displays the state of a privileged [method] call.
  Future<T> privilegedMethod<T, U>(
    final BuildContext context, {
    required final Future<U> value,
    required final Future<T> Function(U value) method,
    required final MethodBuilder<U> valueBuilder,
    required final MethodBuilder<T>? reviewBuilder,
    required final MethodBuilder<T> methodBuilder,
    final DismissState? dismissState,
  }) => open(
    context: context, 
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
      dismissState: dismissState,
      onCompleteError: _onMethodCompleteErrorHandler(completer),
    ),
  );

  /// Presents a modal bottom sheet for an [SolanaWalletAdapter.signTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignTransactionsResult> signTransactions(
    final BuildContext context,
    final Future<List<Transaction>> transactions, {
    final MethodBuilder<List<Transaction>>? valueBuilder,
    final MethodBuilder<SignTransactionsResult>? reviewBuilder,
    final MethodBuilder<SignTransactionsResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: transactions, 
    method: _signTransactionsHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Transaction',
          message: 'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.transaction(),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletStateView.success(
          title: 'Transactions Signed',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to sign transactions.',
        ),
      ),
    ),
  );
  
  /// Presents a modal bottom sheet for an [SolanaWalletAdapter.signTransactions] method call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignTransactionsResult> signTransactionsWithSigners(
    final BuildContext context,
    final Future<List<TransactionWithSigners>> transactions, {
    final MethodBuilder<List<TransactionWithSigners>>? valueBuilder,
    final MethodBuilder<SignTransactionsResult>? reviewBuilder,
    final MethodBuilder<SignTransactionsResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: transactions, 
    method: _signTransactionsWithSignersHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Transaction',
          message: 'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.transaction(),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletStateView.success(
          title: 'Transactions Signed',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to sign transactions.',
        ),
      ),
    ),
  );

  /// Builds a widget for a successful sign and send transactions result.
  Widget _signAndSendTransactionsResultBuilder(
    final BuildContext context,
    final SignAndSendTransactionsResult? data,
  ) {
    return SolanaWalletCard(
      body: SolanaWalletSignAndSendTransactionsResultView(
        result: data, 
        cluster: connection.cluster, 
      ),
    );
  }

  /// Presents a modal bottom sheet for an [SolanaWalletAdapter.signAndSendTransactions] method 
  /// call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignAndSendTransactionsResult> signAndSendTransactions(
    final BuildContext context,
    final Future<List<Transaction>> transactions, {
    final Commitment? commitment = Commitment.confirmed,
    final SignAndSendTransactionsConfig? config,
    final bool skipErrorResponse = false,
    final MethodBuilder<List<Transaction>>? valueBuilder,
    final MethodBuilder<SignAndSendTransactionsResult>? reviewBuilder,
    final MethodBuilder<SignAndSendTransactionsResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: transactions, 
    method: (final List<Transaction> transactions) => _signAndSendTransactionsPolyfill(
      transactions,
      commitment: commitment, 
      config: config,
      skipErrorResponse: skipErrorResponse,
    ), 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Transaction',
          message: 'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.transaction(),
      ),
      successBuilder: _signAndSendTransactionsResultBuilder,
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [SolanaWalletAdapter.signAndSendTransactions] method 
  /// call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactions}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignAndSendTransactionsResult> signAndSendTransactionsWithSigners(
    final BuildContext context,
    final Future<List<TransactionWithSigners>> transactions, {
    final Commitment? commitment = Commitment.confirmed,
    final SignAndSendTransactionsConfig? config,
    final bool skipErrorResponse = false,
    final MethodBuilder<List<TransactionWithSigners>>? valueBuilder,
    final MethodBuilder<SignAndSendTransactionsResult>? reviewBuilder,
    final MethodBuilder<SignAndSendTransactionsResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: transactions, 
    method: (final List<TransactionWithSigners> transactions) 
      => _signAndSendTransactionsWithSignersHandler(
        transactions,
        commitment: commitment, 
        config: config,
        skipErrorResponse: skipErrorResponse,
      ), valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Transaction',
          message: 'Processing transactions.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.transaction(),
      ),
      successBuilder: _signAndSendTransactionsResultBuilder,
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process transactions.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for an [SolanaWalletAdapter.signMessages] method call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signMessages}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignMessagesResult> signMessages(
    final BuildContext context,
    final Future<MessagesAndAddresses> messages, {
    final MethodBuilder<MessagesAndAddresses>? valueBuilder,
    final MethodBuilder<SignMessagesResult>? reviewBuilder,
    final MethodBuilder<SignMessagesResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: messages, 
    method: _signMessagesHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Message',
          message: 'Processing messages.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process messages.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.message(),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletStateView.success(
          title: 'Messages Signed',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to sign messages.',
        ),
      ),
    ),
  );

  /// Presents a modal bottom sheet for a `sign in` message method call.
  /// 
  /// {@macro solana_wallet_adapter_platform_interface.signMessages}
  ///
  /// {@macro solana_wallet_provider.dismissed_exception}
  Future<SignMessagesResult> signInMessage(
    final BuildContext context,
    final Future<SignInMessage> message, {
    final MethodBuilder<SignInMessage>? valueBuilder,
    final MethodBuilder<SignMessagesResult>? reviewBuilder,
    final MethodBuilder<SignMessagesResult>? methodBuilder,
    final DismissState? dismissState,
  }) => privilegedMethod(
    context, 
    dismissState: dismissState,
    value: message, 
    method: _signInMessageHandler, 
    valueBuilder: valueBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletStateView.progress(
          title: 'Sign In',
          message: 'Processing sign in message.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to process sign in message.',
        ),
      ),
    ),
    reviewBuilder: reviewBuilder,
    methodBuilder: methodBuilder ?? stateWidgetBuilder(
      progressBuilder: (_) => SolanaWalletCard(
        body: SolanaWalletProgressView.signIn(),
      ),
      successBuilder: (_, __) => SolanaWalletCard(
        body: SolanaWalletStateView.success(
          message: 'Sign in complete.',
        ),
      ),
      errorBuilder: (_, error) => SolanaWalletCard(
        body: SolanaWalletStateView.error(
          error: error,
          message: 'Failed to sign in.',
        ),
      ),
    ),
  );

  /// Formats [address].
  String _signInMessageAddress(final PublicKey? address) {
    final String? messageAddress = address?.toBase58() ?? connectedAccount?.addressBase58;
    if (messageAddress != null) {
      return messageAddress;
    }
    final List<Account>? accounts = authorizeResult?.accounts;
    if (accounts != null && accounts.isNotEmpty) {
      return accounts.first.addressBase58;
    }
    throw const SolanaWalletProviderException(
      'Sign in message requires an address.',
      code: SolanaWalletProviderExceptionCode.format,
    );
  }

  /// Formats chain [id].
  String _signInMessageChainId(final String? id) {
    final String? chainId = id ?? adapter.cluster?.id ?? Cluster.mainnet.id;
    return chainId ?? (throw const SolanaWalletProviderException(
      'Sign in message requires a chain id.',
      code: SolanaWalletProviderExceptionCode.format,
    ));
  }

  /// Creates a random string if [nonce] is omitted.
  String _signInMessageNonce(final String? nonce) {
    return nonce ?? Random.secure().nextInt(0xFFFFFFFF).toString();
  }

  /// Formats [resources].
  String? _signInMessageResources(final List<String>? resources) {
    if (resources != null && resources.isNotEmpty) {
      const String separator = '\n- ';
      return '$separator${resources.join(separator)}';
    }
    return null;
  }

  /// Creates a sign in message.
  String _signInMessage(
    final SignInMessage message,
  ) {
    final String domain = message.domain;
    final String address = _signInMessageAddress(message.address);
    final String? statement = message.statement;
    final Uri uri = message.uri ?? Uri.https(domain);
    final int version = message.version ?? 1;
    final String chainId = _signInMessageChainId(message.chainId);
    final String nonce = _signInMessageNonce(message.nonce);
    final DateTime issuedAt = message.issuedAt ?? DateTime.now();
    final DateTime? expirationTime = message.expirationTime;
    final DateTime? notBefore = message.notBefore;
    final String? requestId = message.requestId;
    final String? resources = _signInMessageResources(message.resources);
    final List<String> signInMessage = [
      '$domain wants you to sign in with your Solana account:',
      'solana:$chainId:$address\n',
      if (statement != null)
        '$statement\n',
      'URI: $uri',
      'Version: $version',
      'Nonce: $nonce',
      'Issued At: ${issuedAt.toUtc().toIso8601String()}',
      if (expirationTime != null)
        'Expiration Time: ${expirationTime.toUtc().toIso8601String()}',
      if (notBefore != null)
        'Not Before: ${notBefore.toUtc().toIso8601String()}',
      if (requestId != null)
        'Request ID: $requestId',
      'Chain ID: solana:$chainId',
      if (resources != null)
        'Resources: $resources',
    ];
    return _serializeMessages([signInMessage.join('\n')]).first;
  }

  /// Runs [callback] for a local wallet endpoint. If a local wallet cannot be found, attempt a 
  /// remote connection with [SolanaWalletAdapter.hostAuthority].
  Future<T> _association<T>(
    final Future<T> Function(SolanaWalletAdapterConnection connection) callback,
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

  /// {@macro solana_wallet_adapter_platform_interface.signTransactions}
  Future<SignTransactionsResult> _signTransactionsHandler(
    final List<Transaction> transactions,
  ) => _association((final SolanaWalletAdapterConnection connection) async {
    await adapter.reauthorizeOrAuthorizeHandler(connection);
    final List<String> encodedTransactions = await _serializeTransactions(transactions);
    return adapter.signTransactionsHandler(
      connection, 
      transactions: encodedTransactions,
      skipReauthorize: true,
    );
  });

  /// {@macro solana_wallet_adapter_platform_interface.signTransactions}
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

  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactions}
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
      skipReauthorize: true,
    );
  });

  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactions}
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
      await _confirmTransactions(
        transactions: _splitTransactionsWithSigners(transactions).transactions,
        signatures: sendResult.signatures, 
        commitment: commitment,
      );
    }

    /// Return the transaction signatures.
    return sendResult;
  }

  /// {@macro solana_wallet_adapter_platform_interface.signAndSendTransactions}
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
      await _confirmTransactions(
        transactions: transactions,
        signatures: result.signatures, 
        commitment: commitment,
      );
    }
    
    /// Return the transaction signatures.
    return result;
  }

  /// {@macro solana_wallet_adapter_platform_interface.signMessages}
  Future<SignMessagesResult> _signMessagesHandler(
    final MessagesAndAddresses data,
  ) {
    return _association((connection) async {
      await adapter.reauthorizeOrAuthorizeHandler(connection);
      return adapter.signMessagesHandler(
        connection, 
        messages: _serializeMessages(data.messages), 
        addresses: _serializeAddresses(data.addresses),
        skipReauthorize: true,
      );
    });
  }

  /// {@macro solana_wallet_adapter_platform_interface.signMessages}
  Future<SignMessagesResult> _signInMessageHandler(
    final SignInMessage data,
  ) => _association((connection) async {
    await adapter.reauthorizeOrAuthorizeHandler(connection);
    return adapter.signMessagesHandler(
      connection, 
      messages: [_signInMessage(data)], 
      addresses: const [],
      skipReauthorize: true,
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
  /// 
  /// Throws a [TransactionException] if any of the [transactions] cannot be confirmed.
  Future<List<SignatureNotification>> _confirmTransactions({
    required final List<Transaction> transactions,
    required final List<String?> signatures, 
    required final Commitment commitment,
  }) async {
    assert(transactions.length == signatures.length);

    // Check for failed transactions and convert signatures from base-64 to base-58.
    final List<String> txSignatures = [];
    for (final String? signature in signatures) {
      if (signature != null) { 
        txSignatures.add(base64ToBase58(signature));
      } else {
        throw const TransactionException('Transaction not submitted to network,');
      }
    }

    // Subscribe to `confirm transaction` notifications.
    final List<Future<WebSocketSubscription<SignatureNotification>>> requests = [];
    for (final String txSignature in txSignatures) {
      requests.add(
        connection.signatureSubscribe(
          txSignature,
          config: CommitmentSubscribeConfig(
            commitment: commitment,
          ),
        ),
      );
    }

    // Wait for all subscriptions to be registered.
    List<WebSocketSubscription<SignatureNotification>> subscriptions = await Future.wait(
      requests, 
      eagerError: true,
    );

    // Get the current transaction signature statuses.
    final List<SignatureStatus?> statuses = await connection.getSignatureStatuses(
      txSignatures,
      config: const GetSignatureStatusesConfig(
        searchTransactionHistory: true,
      ),
    );

    // Resolve confirmed transactions.
    final List<Future<SignatureNotification>> notifications = [];
    for (int i = 0; i < transactions.length; ++i) {
      final SignatureStatus? status = statuses[i];
      final WebSocketSubscription<SignatureNotification> subscription = subscriptions[i];
      if (status != null) {
        connection.signatureUnsubscribe(subscription).ignore();
        if (status.err != null) {
          throw const TransactionException('Transaction status error.');
        } else {
          notifications.add(Future.value(const SignatureNotification(err: null)));
        }
      } else {
        notifications.add(connection.confirmSignatureSubscription(
          txSignatures[i], 
          subscription,
          blockhash: transactions[i].blockhash,
        ));
      }
    }
    
    // Check that [notifications] contains all transactions.
    assert(notifications.length == signatures.length);

    // Wait for the remaining confirmations.
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

  /// Serializes [transactions] into a list of encoded strings.
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
      if (SolanaWalletAdapterPlatform.instance.isDesktop) {
        encodedTransactions.add(tx.serializeMessage().getString(BufferEncoding.base58));
      } else {
        encodedTransactions.add(tx.serialize(config).getString(BufferEncoding.base64));
      }
    }
    return encodedTransactions;
  }

  /// Serializes [messages] into a list of encoded strings.
  List<String> _serializeMessages(final Iterable<String> messages) {
    if (SolanaWalletAdapterPlatform.instance.isDesktop) {
      return messages.toList(growable: false);
    } else {
      return messages.map((message) => base64UrlEncode(message.codeUnits)).toList(growable: false);
    }
  }

  /// Serializes [addresses] into a list of encoded strings.
  List<String> _serializeAddresses(final Iterable<PublicKey> addresses) {
    if (SolanaWalletAdapterPlatform.instance.isDesktop) {
      return addresses.map((address) => address.toBase58()).toList(growable: false);
    } else if (addresses.isEmpty) {
      final String? address = connectedAccount?.address;
      if (address != null) {
        return [address];
      } else {
        throw const SolanaWalletAdapterException('No addresses found.');
      }
    }
    return addresses.map((address) => address.toBase64()).toList(growable: false);
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
  void _onStateChanged() { 
    if (mounted) setState(() {}); 
  }

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

  /// {@macro solana_wallet_adapter_platform_interface.authorizeResult}
  AuthorizeResult? get authorizeResult;

  /// {@macro solana_wallet_adapter_platform_interface.connectedAccount}
  Account? get connectedAccount;
}