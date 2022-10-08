/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/widgets.dart';
import '../solana_wallet_constants.dart';


/// Solana Wallet App Store
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletAppStore {

  /// Defines a solana wallet application found in the play/app store.
  SolanaWalletAppStore({
    required this.name,
    required final String favicon,
    required this.androidId,
    required this.iosId,
  }): favicon = AssetImage(
      'icons/$favicon.ico', 
      package: packageName,
    );

  /// The application name.
  final String name;

  /// The favicon asset image name (located in /icons).
  final AssetImage favicon;

  /// The android application id (play store).
  final String androidId;

  /// The iOS application id (app store).
  final String iosId;

  /// The application id for the current platform (Android or iOS).
  String get id => Platform.isAndroid ? androidId : iosId;

  /// Creates a [SolanaWalletAppStore] for the `phantom` wallet.
  factory SolanaWalletAppStore.phantom() => SolanaWalletAppStore(
    name: 'Phantom', 
    favicon: 'phantom', 
    androidId: 'app.phantom', 
    iosId: '1598432977',
  );

  /// Creates a [SolanaWalletAppStore] for the `solflare` wallet.
  factory SolanaWalletAppStore.solflare() => SolanaWalletAppStore(
    name: 'Solflare', 
    favicon: 'solflare', 
    androidId: 'com.solflare.mobile', 
    iosId: '1580902717',
  );
}