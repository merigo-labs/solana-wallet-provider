/// Imports
/// ------------------------------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter/widgets.dart' show AssetImage, immutable;
import '../solana_wallet_constants.dart';


/// Solana Wallet App Info
/// ------------------------------------------------------------------------------------------------

/// App information.
@immutable
class SolanaWalletAppInfo {

  /// Defines a solana wallet application found in the play/app store.
  const SolanaWalletAppInfo({
    required this.name,
    required this.favicon,
    required this.androidId,
    required this.iosId,
  });

  /// The application name.
  final String name;

  /// The favicon image.
  final AssetImage favicon;

  /// The android application id (play store).
  final String androidId;

  /// The iOS application id (app store).
  final String iosId;

  /// The application id for the current platform (Android or iOS).
  String get id {
    if (Platform.isAndroid) {
      return androidId;
    } else if (Platform.isIOS) {
      return iosId;
    } else {
      throw UnsupportedError('SolanaWalletAppInfo "${Platform.operatingSystem}" not supported.');
    }
  }

  /// Creates an [AssetImage] for the favicon image [name].
  static _faviconAssetImage(final String name)
    => AssetImage('icons/$name.ico', package: packageName);

  /// Creates a [SolanaWalletAppInfo] for the `phantom` wallet.
  static SolanaWalletAppInfo get phantom => SolanaWalletAppInfo(
    name: 'Phantom', 
    favicon: _faviconAssetImage('phantom'), 
    androidId: 'app.phantom', 
    iosId: '1598432977',
  );

  /// Creates a [SolanaWalletAppInfo] for the `solflare` wallet.
  static SolanaWalletAppInfo get solflare => SolanaWalletAppInfo(
    name: 'Solflare', 
    favicon: _faviconAssetImage('solflare'), 
    androidId: 'com.solflare.mobile', 
    iosId: '1580902717',
  );
}