import 'package:flutter/material.dart';
import 'package:solana_wallet_provider/solana_wallet_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: ExampleApp()),
  );
}

class ExampleApp extends StatefulWidget {

  const ExampleApp({
    super.key,
  });

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {

  /// Request status.
  String? _status;

  @override
  Widget build(final BuildContext context) {
    // 1. Wrap application with SolanaWalletProvider.
    return SolanaWalletProvider.create(      
      httpCluster: Cluster.devnet,                     
      identity: AppIdentity(
        uri: Uri.parse('https://my_dapp.com'),
        icon: Uri.parse('favicon.png'),
        name: 'My Dapp'
      ),
      child: MaterialApp(
        home: Scaffold(
          body: FutureBuilder(
            // 2. Initialize SolanaWalletProvider before use.
            future: SolanaWalletProvider.initialize(),            
            builder: ((context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const CircularProgressIndicator();
              }
              // 3. Access SolanaWalletProvider.
              final provider = SolanaWalletProvider.of(context);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Wallet Button'),
                  SolanaWalletButton(),

                  const Divider(),

                  const Text('Wallet Methods'),
                  Wrap(
                    spacing: 24.0,
                    children: [
                      _textButton(
                        'Connect', 
                        enabled: !provider.adapter.isAuthorized, 
                        onPressed: () => _connect(context, provider),
                      ),
                      _textButton(
                        'Disconnect', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _disconnect(context, provider),
                      ),

                      _textButton(
                        'Sign Transactions (1)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signTransactions(context, provider, 1),
                      ),
                      _textButton(
                        'Sign Transactions (3)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signTransactions(context, provider, 3),
                      ),

                      _textButton(
                        'Sign And Send Transactions (1)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signAndSendTransactions(context, provider, 1),
                      ),
                      _textButton(
                        'Sign And Send Transactions (3)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signAndSendTransactions(context, provider, 3),
                      ),

                      _textButton(
                        'Sign Messages (1)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signMessages(context, provider, 1),
                      ),
                      _textButton(
                        'Sign Messages (3)', 
                        enabled: provider.adapter.isAuthorized, 
                        onPressed: () => _signMessages(context, provider, 3),
                      ),
                    ],
                  ),

                  const Divider(),

                  const Text('Output'),
                  Text(_status ?? '-'),
                ],
              ); 
            }),
          ),
        ),
      ),
    );
  }

  /// Connects the application to a wallet running on the device.
  Future<void> _connect(
    final BuildContext context, 
    final SolanaWalletProvider provider,
  ) async {
    if (!provider.adapter.isAuthorized) {
      await provider.connect(context);
      setState(() {});
    }
  }

  /// Disconnects the application from a wallet running on the device.
  Future<void> _disconnect(
    final BuildContext context, 
    final SolanaWalletProvider provider,
  ) async {
    if (provider.adapter.isAuthorized) {
      await provider.disconnect(context);
      setState(() {});
    }
  }

  /// Signs [count] number of transactions (then sends them to the network for processing and 
  /// confirms the transaction results).
  void _signTransactions(
    final BuildContext context, 
    final SolanaWalletProvider provider, 
    final int count,
  ) async {
    final String description = "Sign Transactions ($count)";
    try {
      setState(() => _status = "Create $description...");
      final List<TransferData> transfers = await _createTransfers(
        provider.connection, provider.adapter, count: count,
      );

      setState(() => _status = "$description...");
      final SignTransactionsResult result = await provider.signTransactions(
        context,
        transactions: transfers.map((transfer) => transfer.transaction).toList(),
      );

      setState(() => _status = "Broadcast $description...");
      final List<String?> signatures = await provider.connection.sendSignedTransactions(
        result.signedPayloads,
        eagerError: true,
      );

      setState(() => _status = "Confirm $description...");
      await _confirmTransfers(
        provider.connection, 
        signatures: signatures.map((e) => base58To64Encode(e!)).toList(), 
        transfers: transfers, 
      );

    } catch (error, stack) {
      print('$description Error: $error');
      print('$description Stack: $stack');
      setState(() => _status = error.toString());
    }
  }

  /// Signs and send [count] number of transactions to the network (then confirms the transaction 
  /// results).
  void _signAndSendTransactions(
    final BuildContext context, 
    final SolanaWalletProvider provider, 
    final int count,
  ) async {
    final String description = "Sign And Send Transactions ($count)";
    try {
      setState(() => _status = "Create $description...");
      final List<TransferData> transfers = await _createTransfers(
        provider.connection, provider.adapter, count: count,
      );

      setState(() => _status = "$description...");
      final SignAndSendTransactionsResult result = await provider.signAndSendTransactions(
        context,
        transactions: transfers.map((transfer) => transfer.transaction).toList(),
      );

      setState(() => _status = "Confirm $description...");
      await _confirmTransfers(
        provider.connection, 
        signatures: result.signatures, 
        transfers: transfers, 
      );

    } catch (error, stack) {
      print('$description Error: $error');
      print('$description Stack: $stack');
      setState(() => _status = error.toString());
    }
  }

  void _signMessages(
    final BuildContext context, 
    final SolanaWalletProvider provider, 
    final int count, 
  ) async {
    final String description = "Sign Messages ($count)";
    try {
      setState(() => _status = "Create $description...");
      final List<String> messages = List.generate(
        count, 
        (index) => 'Sign message $index'
      );

      setState(() => _status = "$description...");
      final SignMessagesResult result = await provider.signMessages(
        context,
        messages: messages,
        addresses: [provider.adapter.encodeAccount(provider.adapter.connectedAccount!)],
      );

      setState(() => _status = "Signed Messages ${result.signedPayloads.join('\n')}");
      
    } catch (error, stack) {
      print('$description Error: $error');
      print('$description Stack: $stack');
      setState(() => _status = error.toString());
    }
  }

  /// Requests an airdrop of 2 SOL for [wallet].
  Future<void> _airdrop(final Connection connection, final Pubkey wallet) async {
    if (connection.httpCluster != Cluster.mainnet) {
      setState(() => _status = "Requesting airdrop...");
      await connection.requestAndConfirmAirdrop(wallet, solToLamports(2).toInt());
    }
  }

  /// Creates [count] number of SOL transfer transactions.
  Future<List<TransferData>> _createTransfers(
    final Connection connection, 
    final SolanaWalletAdapter adapter, {
    required final int count,
  }) async {
  
    // Check connected wallet.
    setState(() => _status = "Pending...");
    final Pubkey? wallet = Pubkey.tryFromBase64(adapter.connectedAccount?.address);
    if (wallet == null) {
      throw 'Wallet not connected';
    }

    // Airdrop some SOL to the wallet account if required.
    setState(() => _status = "Checking balance...");
    final int balance = await connection.getBalance(wallet);
    if (balance < lamportsPerSol) await _airdrop(connection, wallet);

    // Create a SystemProgram instruction to transfer some SOL.
    setState(() => _status = "Creating transaction...");
    final latestBlockhash = await connection.getLatestBlockhash();
    final List<TransferData> txs = [];
    for (int i = 0; i < count; ++i) {
      final Keypair receiver = Keypair.generateSync();
      final BigInt lamports = solToLamports(0.1);
      final Transaction transaction = Transaction.v0(
        payer: wallet,
        recentBlockhash: latestBlockhash.blockhash,
        instructions: [
          SystemProgram.transfer(
            fromPubkey: wallet, 
            toPubkey: receiver.pubkey, 
            lamports: lamports,
          )
        ]
      );
      txs.add(TransferData(
        transaction: transaction, 
        receiver: receiver,
        lamports: lamports,
      ));
    }
    return txs;
  }

  /// Checks the results of [transfers].
  Future<void> _confirmTransfers(
    final Connection connection, {
    required final List<String?> signatures,
    required final List<TransferData> transfers, 
  }) async {

      // Wait for confirmations (**You need to convert the base-64 signatures to base-58!**).
      setState(() => _status = "Confirming transaction signature...");
      await Future.wait(
        [for (final sig in signatures) connection.confirmTransaction(base58To64Decode(sig!))], 
        eagerError: true,
      );

      // Get the receiver balances.
      setState(() => _status = "Checking balance...");
      final List<int> receiverBalances = await Future.wait(
        [for (final transfer in transfers) connection.getBalance(transfer.receiver.pubkey)],
        eagerError: true,
      );

      // Check the updated balances.
      final List<String> results = [];
      for (int i = 0; i < receiverBalances.length; ++i) {
        final TransferData transfer = transfers[i];
        final Pubkey pubkey = transfer.receiver.pubkey;
        final BigInt balance = receiverBalances[i].toBigInt();
        if (balance != transfer.lamports) throw Exception('Post transaction balance mismatch.');
        results.add("Transfer: Address $pubkey received $balance SOL");
      }

      // Output the result.
      setState(() => _status = "Success!\n\n"
        "Signatures: $signatures\n\n"
        "${results.join('\n')}"
        "\n"
      );
  }
  
  TextButton _textButton(
    final String text, {
    required final bool enabled,
    required final void Function() onPressed,
  }) => TextButton(
    onPressed: enabled ? onPressed : null, 
    child: Text(text), 
  );
}

class TransferData {
  const TransferData({
    required this.transaction,
    required this.receiver,
    required this.lamports,
  });
  final Transaction transaction;
  final Keypair receiver;
  final BigInt lamports;
}