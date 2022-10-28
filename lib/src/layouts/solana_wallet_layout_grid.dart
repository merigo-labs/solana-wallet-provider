/// Solana Wallet Layout Grid
/// ------------------------------------------------------------------------------------------------

class SolanaWalletLayoutGrid {

  /// The UI grid system.
  const SolanaWalletLayoutGrid._();

  /// The smallest unit of measurement used to define a widget's size or spacing.
  static const double x1 = 8.0;

  /// 2 times the smallest unit of measurement [x1].
  static const double x2 = x1 * 2.0;

  /// 3 times the smallest unit of measurement [x1].
  static const double x3 = x1 * 3.0;

  /// Returns the smallest unit of measurement [x1] multiplied by [value].
  static double multiply(final double value) => x1 * value;
}