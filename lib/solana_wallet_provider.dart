/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
import 'package:solana_web3/rpc_config/confirm_transaction_config.dart';
import 'package:solana_web3/rpc_config/send_transaction_config.dart';
import 'package:solana_web3/rpc_models/signature_notification.dart';
import 'package:solana_web3/solana_web3.dart';
import 'package:solana_web3/types/commitment.dart';
import 'src/models/solana_wallet_action.dart';
import 'src/models/solana_wallet_app_store.dart';
import 'src/solana_wallet_constants.dart';
import 'src/views/solana_wallet_account_view.dart';
import 'src/views/solana_wallet_authorize_view.dart';
import 'src/views/solana_wallet_connect_remotely_view.dart';
import 'src/views/solana_wallet_download_view.dart';
import 'src/views/solana_wallet_error_view.dart';
import 'src/views/solana_wallet_progress_indicator_view.dart';
import 'src/views/solana_wallet_success_view.dart';


/// Exports
/// ------------------------------------------------------------------------------------------------

// TODO: Export the entire solana_web3 and solana_wallet_adapter packages

export 'package:solana_wallet_adapter/solana_wallet_adapter.dart';
export 'package:solana_web3/solana_web3.dart';
export 'package:solana_web3/programs/system.dart';
export 'package:solana_web3/programs/stake_pool.dart';
export 'package:solana_web3/types/account_encoding.dart';
export 'package:solana_web3/types/commitment.dart';
export 'package:solana_web3/rpc_config/get_account_info_config.dart';
export 'package:solana_web3/rpc_config/get_balance_config.dart';
export 'package:solana_web3/rpc_config/commitment_config.dart';
export 'package:solana_web3/rpc_config/send_transaction_config.dart';
export 'src/views/solana_wallet_account_view.dart';
export 'src/views/solana_wallet_authorize_view.dart';
export 'src/views/solana_wallet_connect_remotely_view.dart';
export 'src/views/solana_wallet_download_view.dart';
export 'src/views/solana_wallet_error_view.dart';
export 'src/views/solana_wallet_progress_indicator_view.dart';
export 'src/views/solana_wallet_success_view.dart';


/// Inherited Solana Wallet Provider
/// ------------------------------------------------------------------------------------------------

class _InheritedSolanaWalletProvider extends InheritedWidget {

  /// Rebuilds the widget each time [state] changes.
  const _InheritedSolanaWalletProvider({
    required this.provider,
    required this.state,
    required super.child,
  });

  /// The authorization state.
  final WalletAdapterState? state;

  /// The [SolanaWalletProvider] widget's state.
  final SolanaWalletProviderState provider;

  @override
  bool updateShouldNotify(covariant _InheritedSolanaWalletProvider oldWidget) 
    => oldWidget.state != state;
}


/// Solana Wallet Provider
/// ------------------------------------------------------------------------------------------------

class SolanaWalletProvider extends StatefulWidget {

  /// Creates a UI wrapper around the packages `solana_web3` and `solana_wallet_adapter`.
  /// 
  /// The widget can be be accessed by calling [SolanaWalletProvider.of] from a descendent widget.
  SolanaWalletProvider({
    super.key,
    required this.child,
    required this.connection,
    required this.adapter,
  }): assert(
      connection.cluster == adapter.cluster
      || connection.cluster == Cluster.mainnet && adapter.cluster == null,
      'The [connection] and [adapter] are using different cluster.'
    );

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child; 

  /// {@macro solana_web3.Connection}
  final Connection connection;

  /// {@macro solana_wallet_adapter.SolanaWalletAdapter}
  final SolanaWalletAdapter adapter;

  /// A helper constructor that applies default values when creating the [connection] and [adapter].
  factory SolanaWalletProvider.create({
    required Widget child,
    required AppIdentity? identity,
    Cluster? cluster,
    Commitment? commitment,
    String? hostAuthority,
  }) {
    final defaultCluster = cluster ?? Cluster.mainnet;
    return SolanaWalletProvider(
      connection: Connection(
        defaultCluster, 
        commitment: commitment,
      ), 
      adapter: SolanaWalletAdapter(
        identity ?? const AppIdentity(),
        cluster: defaultCluster,
        hostAuthority: hostAuthority,
      ),
      child: child,
    );
  }

  /// Loads the wallet adapter's stored state.
  /// 
  /// This must be called when the application is first loaded. Methods an properties of the 
  /// [SolanaWalletProviderState] must not be called until the future completes.
  static Future<void> initialize() => SolanaWalletAdapter.initialize();
  
  /// Returns the widget state of the closest [SolanaWalletProvider] instance that encloses the 
  /// provided context.
  static SolanaWalletProviderState of(final BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedSolanaWalletProvider>();
    return inherited?.provider ?? (throw FlutterError(
      'Failed to find an instance of [SolanaWalletProvider] in the widget tree.'
    ));
  }

  @override
  State<SolanaWalletProvider> createState() => _SolanaWalletProviderState();
}


/// Solana Wallet Provider State (Interface)
/// ------------------------------------------------------------------------------------------------

abstract class SolanaWalletProviderState extends State<SolanaWalletProvider> {

  /// The modal view's route settings.
  static const RouteSettings _routeSettings = RouteSettings(name: '$packageName/dialog');

  /// The Solana JSON-RPC API.
  Connection get connection => widget.connection;

  /// The Solana Mobile Wallet Specification API.
  SolanaWalletAdapter get adapter => widget.adapter;

  /// {@macro solana_wallet_adapter.hostAuthority}
  String? get hostAuthority => widget.adapter.hostAuthority;

  /// {@macro solana_wallet_adapter.authorizeResult}
  AuthorizeResult? get authorizeResult => widget.adapter.authorizeResult;

  /// {@macro solana_wallet_adapter.feePayerAccount}
  Account? get feePayerAccount => widget.adapter.feePayerAccount;

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

  Future<List<Transaction>> _applyDefaults(final List<Transaction> transactions) async {
    final latestBlockhash = await connection.getLatestBlockhash();
    final defaultFeePayerAddress = PublicKey.tryFromBase64(feePayerAccount?.address);
    return transactions.map((final Transaction transaction) => transaction.copyWith(
      recentBlockhash: latestBlockhash.blockhash,
      lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
      feePayer: transaction.feePayer ?? defaultFeePayerAddress,
    )).toList(growable: false);
  }

  /// Serializes [transactions] into a list of base-64 encoded strings.
  Future<List<String>> _serialize(final List<Transaction> transactions, 
    final List<Signer> signers,
  ) async {
    final latestBlockhash = await connection.getLatestBlockhash();
    final defaultFeePayerAddress = PublicKey.tryFromBase64(feePayerAccount?.address);
    const config = SerializeConfig(
      requireAllSignatures: false, 
      verifySignatures: false,
    );
    return transactions.map(
      (final Transaction transaction) {
        final copy = transaction.copyWith(
          recentBlockhash: latestBlockhash.blockhash,
          lastValidBlockHeight: latestBlockhash.lastValidBlockHeight,
          feePayer: transaction.feePayer ?? defaultFeePayerAddress,
        );
        if (signers.isNotEmpty) {
          copy.sign(signers);
        }
        return copy
          .serialize(config)
          .getString(BufferEncoding.base64);
      }
    ).toList(growable: false);
  }

  /// Serializes [messages] into a list of base-64 encoded strings.
  Future<List<String>> _serializeMessages(final List<Message> messages) async {
    return messages.map(
      (final Message message) 
        => message.serialize()
        .getString(BufferEncoding.base64),
    ).toList(growable: false);
  }

  /// Opens a dialog box that displays the widget returned by [builder].
  Future<T?> showView<T>(final Widget Function(BuildContext) builder) {
    return Navigator.pushAndRemoveUntil(
      context, 
      DialogRoute(
        context: context,
        settings: _routeSettings, 
        builder: (final BuildContext context) {
          final Size screenSize = MediaQuery.of(context).size;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height,
                ),
                child: Dismissible(
                  key: const ValueKey('dialog_view'),
                  direction: DismissDirection.down,
                  onDismissed: (_) => closeView(),
                  child: builder(context),
                ),
              ),
            ],
          );
        }
      ), 
      (route) => route.settings != _routeSettings,
    );
  }

  /// Closes all dialog boxes opened by the provider.
  void closeView() 
    => Navigator.popUntil(
      context, 
      (route) => route.settings != _routeSettings,
    );
  
  /// Shows a modal that displays a list of app store links to download supported mobile wallets.
  Future<SolanaWalletAction?> showDownloadView<T>(
    final BuildContext context,
    final String? hostAuthority,
  ) => showView((final BuildContext context) 
      => SolanaWalletDownloadView(
        apps: [
          SolanaWalletAppStore.phantom(),
          SolanaWalletAppStore.solflare(),
        ],
        onTapApp: (SolanaWalletAppStore app) {
          Navigator.pop(context);
          SolanaWalletAdapterPlatform.instance.openStore(app.id);
        },
        onTapConnectRemotely: hostAuthority != null 
          ? () => Navigator.pop(context, ConnectRemotelyAction(hostAuthority))
          : null,
      ),
    );

  /// Shows a modal that displays a QR code connection link, which can be scanned by a wallet 
  /// running on another device to establish a remote connection with the dApp.
  Future<void> showConnectRemoteView<T>(
    final BuildContext context,
    final String? hostAuthority,
  ) {
    assert(hostAuthority != null, '[SolanaWalletProvider.adapter] must provide a `hostAuthority`');
    return showView((final BuildContext context) 
      => hostAuthority != null 
        ? SolanaWalletConnectRemotelyView(
            hostAuthority: hostAuthority,
          )
        : const SolanaWalletErrorView(
            title: 'Connect Remotely',
            message: 'Unable to connect the wallet.',
          ),
    );
  }

  /// Shows a modal that displays the user's authorized accounts.
  Future<SolanaWalletAction?> showAccountView<T>()
    => showView((final BuildContext context) => SolanaWalletAccountView(
        selectedAccount: feePayerAccount,
        accounts: authorizeResult?.accounts ?? [],
        onTapAccount: (account) => Navigator.pop(context, ChangeAccountAction(account)),
        onTapDisconnect: () => Navigator.pop(context, const DeauthorizeAction()),
      ),
    );

  /// Shows a modal that displays a prompt to begin authorisation.
  Future<SolanaWalletAction?> showAuthorizeView<T>()
    => showView((final BuildContext context) => SolanaWalletAuthorizeView(
      identity: adapter.identity,
      onTapAuthorize: () => Navigator.pop(context, const AuthorizeAction()),
    ));

  /// Shows a modal that displays a success [message].
  Future<void> showSuccessView<T>({
    final String? title,
    final String? message,
  }) => showView((final BuildContext context) => SolanaWalletSuccessView(
      title: title,
      message: message,
    ));

  /// Shows a modal that displays an error [message].
  Future<void> showErrorView<T>({
    final String? title,
    final String? message,
  }) => showView((final BuildContext context) => SolanaWalletErrorView(
      title: title,
      message: message,
    ));

  /// Shows a modal that displays a progress indicator.
  Future<void> showProgressIndicatorView<T>({
    required final String title,
  }) => showView(
      (final BuildContext context) => SolanaWalletProgressIndicatorView(title: title)
    );

  /// {@macro solana_wallet_adapter.authorize}
  Future<AuthorizeResult> authorize() => _association(adapter.authorizeHandler);

  /// {@macro solana_wallet_adapter.deauthorize}
  Future<DeauthorizeResult> deauthorize() {
    final AuthToken? authToken = adapter.authorizeResult?.authToken;
    return authToken != null
      ? _association((connection) => adapter.deauthorizeHandler(connection, authToken))
      : Future.value(const DeauthorizeResult());
  }

  /// {@macro solana_wallet_adapter.reauthorize}
  Future<ReauthorizeResult> reauthorize() {
    final AuthToken? authToken = authorizeResult?.authToken;
    return authToken != null
      ? _association((connection) => adapter.reauthorizeHandler(connection, authToken))
      : Future.error(adapter.reauthorizeException);
  }

  /// {@macro solana_wallet_adapter.reauthorizeOrAuthorize}
  Future<AuthorizeResult> reauthorizeOrAuthorize() 
    => _association(adapter.reauthorizeOrAuthorizeHandler);

  /// {@macro solana_wallet_adapter.getCapabilities}
  Future<GetCapabilitiesResult> getCapabilities() 
    => _association((connection) => connection.getCapabilities());

  /// Presents a progress indicator modal view while running [callback].
  /// 
  /// Throws a [SolanaWalletAdapterException] if the modal is closed before [callback] completes.
  Future<T> _signWithWalletProgressIndicatorView<T>(
    final String title, 
    final Future<T> Function() callback,
  ) async {
    try {
      final Future<void> future = showProgressIndicatorView(title: title);
      return await Future.any([
        callback(), 
        future.then((_) => Future.error(
          const SolanaWalletAdapterException(
            'The modal view has been closed',
            code: SolanaWalletAdapterExceptionCode.sessionClosed,
          ),
        ),
      )]);
    } finally {
      closeView();
    }
  }

  /// {@macro solana_wallet_adapter.signTransactions}
  Future<SignTransactionsResult> signTransactions({
    required final List<Transaction> transactions,
    // final List<Signer> signers = const [],
    final AssociationType? type,
  }) => _signWithWalletProgressIndicatorView(
      'Sign Transactions', 
      () => signTransactionsHandler(
        transactions: transactions, 
        // signers: signers,
        type: type,
      ),
    );

  /// {@macro solana_wallet_adapter.signTransactions}
  Future<SignTransactionsResult> signTransactionsHandler({
    required final List<Transaction> transactions,
    // final List<Signer> signers = const [],
    final AssociationType? type,
  }) => _association((connection) async {
      await adapter.reauthorizeOrAuthorizeHandler(connection);
      await _requestAirdropForFeePayerAccount();
      final txs = await _applyDefaults(transactions);
      return adapter.signTransactionsHandler(
        connection, 
        type: type,
        transactions: txs.map(
          (e) => e.serialize(
            const SerializeConfig(requireAllSignatures: false, verifySignatures: false)
          ).getString(BufferEncoding.base64)
        ).toList(growable: false),
      );
      
      // final t = Transaction.fromBase64(
      //   x.signedPayloads.first,
      // );
      
      // if (signers.isNotEmpty) {
      //   t.partialSign(signers);
      // }
      
      // return SignTransactionsResult(
      //   signedPayloads: [t.serialize().getString(BufferEncoding.base64)],
      // );
    });

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> signAndSendTransactions({
    required final List<Transaction> transactions,
    final SignAndSendTransactionsConfig? config,
    final Commitment? commitment = Commitment.confirmed,
    // final List<Signer> signers = const [],
  }) => _signWithWalletProgressIndicatorView(
      'Sign And Send Transactions', 
      () => signAndSendTransactionsHandler(
        transactions: transactions, 
        config: config,
        commitment: commitment,
        // signers: signers,
      ),
    );

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  /// 
  /// The transaction signatures will be returned once they have been confirmed for the provided 
  /// [commitment] level. To disable transaction confirmation, set [commitment] to `null`.
  Future<SignAndSendTransactionsResult> signAndSendTransactionsHandler({
    required final List<Transaction> transactions,
    final SignAndSendTransactionsConfig? config,
    final Commitment? commitment = Commitment.confirmed,
    // final List<Signer> signers = const [],
  }) async {

    /// Sign and send the transaction.
    late final SignAndSendTransactionsResult result;
    try {
      // throw JsonRpcException('', code: JsonRpcExceptionCode.methodNotFound);
      result = await _signAndSendTransactionsHandler(
        transactions: transactions,
        config: config,
        //// signers: signers,
      );
    } on JsonRpcException catch (error, stackTrace) {
      print('SIGN AND SEND ERROR (${error.code}) $error');
      if (error.code == JsonRpcExceptionCode.methodNotFound) {
        result = await _signAndSendTransactionsFallbackHandler(
          transactions: transactions,
          // signers: signers,
        );
      } else {
        return Future.error(error, stackTrace);
      }
    }

    // Submit the transaction signatures to be confirmed for the provided commitment level.
    final List<Future<SignatureNotification>> notifications = [];
    if (commitment != null) {
      for (final String? signature in result.signatures) {
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
    }
    
    /// Wait for signature notifications.
    await Future.wait(notifications, eagerError: true);

    /// Return the transaction signatures.
    return result;
  }
  
  /// Airdrops 1 SOL to the [feePayerAccount] if it has insufficient funds.
  Future<void> _requestAirdropForFeePayerAccount() async {
    if (connection.cluster != Cluster.mainnet) {
      final Account? feePayerAccount = this.feePayerAccount;
      if (feePayerAccount != null) {
        final PublicKey feePayer = PublicKey.fromBase64(feePayerAccount.address);
        final int lamportsBalance = await connection.getBalance(feePayer);
        if (solToLamports(1).compareTo(BigInt.from(lamportsBalance)) > 0) {
          final TransactionSignature txSignature = await connection.requestAirdrop(
            feePayer, 
            solToLamports(1).toInt(),
          );
          await connection.confirmTransaction(txSignature);
        }
      }
    }
  }

  /// {@macro solana_wallet_adapter.signAndSendTransactions}
  Future<SignAndSendTransactionsResult> _signAndSendTransactionsHandler({
    required final List<Transaction> transactions,
    final SignAndSendTransactionsConfig? config,
    //// final List<Signer> signers = const [],
  }) => _association((connection) async {
      await adapter.reauthorizeOrAuthorizeHandler(connection);
      await _requestAirdropForFeePayerAccount();
      return adapter.signAndSendTransactionsHandler(
        connection, 
        transactions: await _serialize(transactions, const []),
        config: config,
      );
    });

  /// Sign [transactions] using the wallet's [signTransactions] method, then send the signed 
  /// transactions signatures to the network using [connection.sendSignedTransactions].
  Future<SignAndSendTransactionsResult> _signAndSendTransactionsFallbackHandler({
    required final List<Transaction> transactions,
    final SignAndSendTransactionsConfig? config,
    // final List<Signer> signers = const [],
  }) async {
    /// Sign the transactions using the wallet.
    final SignTransactionsResult result = await signTransactionsHandler(
      transactions: transactions,
      // signers: signers,
    );

    /// Send the signed transactions to the network for processing.
    final List<JsonRpcResponse> responses = await connection.sendSignedTransactionsRaw(
      result.signedPayloads,
      config: SendTransactionConfig(
        skipPreflight: false,
        minContextSlot: config?.minContextSlot,
      ),
    );

    /// Convert the signature to base 64 so that it matched the mobile wallet adapter API.
    return SignAndSendTransactionsResult(
      signatures: List.from(
        responses.map(
          (response) => response.isSuccess 
            ? base64.encode(base58.decode(response.result))
            : null,
        ),
      ),
    );
  }

  /// {@macro solana_wallet_adapter.signMessages}
  Future<SignMessagesResult> signMessages({
    required final List<Message> messages,
    required final List<PublicKey> addresses,
    final AssociationType? type,
  }) => _signWithWalletProgressIndicatorView(
      'Sign Messages', 
      () => signMessagesHandler(
        messages: messages, 
        addresses: addresses,
        type: type,
      ),
    );

  /// {@macro solana_wallet_adapter.signMessages}
  Future<SignMessagesResult> signMessagesHandler({
    required final List<Message> messages,
    required final List<PublicKey> addresses,
    final AssociationType? type,
  }) => _association((connection) async {
      await adapter.reauthorizeOrAuthorizeHandler(connection);
      await _requestAirdropForFeePayerAccount();
      return adapter.signMessagesHandler(
        connection,
        messages: await _serializeMessages(messages), 
        addresses: addresses.map((address) => address.toBase64()).toList(growable: false),
      );
    });

  /// {@macro solana_wallet_adapter.cloneAuthorization}
  Future<CloneAuthorizationResult> cloneAuthorization() {
    final AuthToken? authToken = authorizeResult?.authToken;
    return authToken != null
      ? _association((connection) => adapter.cloneAuthorizationHandler(connection, authToken))
      : Future.error(adapter.cloneAuthorizationException);
  }

  /// Run [callback] for a local wallet endpoint. If a local wallet cannot be found, present the 
  /// option to connect to a remote wallet endpoint.
  Future<T> _association<T>(
    final Future<T> Function(WalletAdapterConnection connection) callback,
  ) async {
      try {
        return await adapter.localAssociation(callback);
      } on SolanaWalletAdapterException catch (error, stackTrace) {
        print('IS MOUNTED $mounted && ERROR CODE = ${error.code}');
        if (mounted && error.code == SolanaWalletAdapterExceptionCode.walletNotFound) {
          final SolanaWalletAction? action = await showDownloadView(context, hostAuthority);
          print('OPENING DOWNLOAD VIEW WITH RESULT... $action');
          if (mounted && action is ConnectRemotelyAction) {
            showConnectRemoteView(context, action.data);
            return adapter.remoteAssociation(action.data, callback);
          }
        }
        return Future.error(error, stackTrace);
      }
  }
}


/// Solana Wallet Provider State
/// ------------------------------------------------------------------------------------------------

class _SolanaWalletProviderState extends SolanaWalletProviderState {
  @override
  Widget build(BuildContext context) =>_InheritedSolanaWalletProvider(
    provider: this,
    state: widget.adapter.state,
    child: widget.child,
  );
}