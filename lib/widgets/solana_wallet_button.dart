/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../solana_wallet_constants.dart';
import '../layouts/solana_wallet_layout_grid.dart';


/// Solana Wallet Button Style
/// ------------------------------------------------------------------------------------------------

@immutable
class SolanaWalletButtonStyle with Diagnosticable {

  /// The style applied to a [SolanaWalletButton].
  const SolanaWalletButtonStyle({
    this.color,
    this.shape,
    this.padding,
    this.textStyle,
  });

  /// The background colour.
  final Color? color;

  /// The shape.
  final ShapeBorder? shape;

  /// The content padding.
  final EdgeInsets? padding;

  /// The text style.
  final TextStyle? textStyle;

  /// Creates a [SolanaWalletButtonStyle] from the provided values.
  static SolanaWalletButtonStyle styleFrom({
    final Color? color,
    final ShapeBorder? shape,
    final EdgeInsets? padding,
    final TextStyle? textStyle,
  }) => SolanaWalletButtonStyle(
      color: color,
      shape: shape,
      padding: padding ?? const EdgeInsets.symmetric(
        vertical: SolanaWalletLayoutGrid.x2,
        horizontal: SolanaWalletLayoutGrid.x3,
      ),
      textStyle: textStyle,
    );

  /// Linearly interpolate between two [SolanaWalletButtonStyle].
  static SolanaWalletButtonStyle lerp(
    final SolanaWalletButtonStyle? a, 
    final SolanaWalletButtonStyle? b, 
    final double t,
  ) => SolanaWalletButtonStyle(
      color: Color.lerp(a?.color, b?.color, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
    );
}


/// Solana Wallet Button
/// ------------------------------------------------------------------------------------------------

class SolanaWalletButton extends StatelessWidget {
  
  /// Creates a button.
  const SolanaWalletButton({
    super.key,
    this.child,
    this.style,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.statesController,
  });

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The button's style.
  final SolanaWalletButtonStyle? style;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback? onTapDown;

  /// Called when the user releases a tap that was started on this part of the material. [onTap] is 
  /// called immediately after.
  final GestureTapUpCallback? onTapUp;

  /// Called when the user cancels a tap that was started on this part of the material.
  final GestureTapCallback? onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  /// Called when this part of the material either becomes highlighted or stops being highlighted.
  ///
  /// The value passed to the callback is true if this part of the material has become highlighted 
  /// and false if this part of the material has stopped being highlighted.
  ///
  /// If all of [onTap], [onDoubleTap], and [onLongPress] become null while a gesture is ongoing, 
  /// then [onTapCancel] will be fired and [onHighlightChanged] will be fired with the value false 
  /// _during the build_. This means, for instance, that in that scenario [State.setState] cannot be 
  /// called.
  final ValueChanged<bool>? onHighlightChanged;

  /// Called when a pointer enters or exits the ink response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this part of the material 
  /// and false if a pointer has exited this part of the material.
  final ValueChanged<bool>? onHover;

  /// The cursor for a mouse pointer when it enters or is hovering over the widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>], [MaterialStateProperty.resolve] is 
  /// used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// The color of the ink response when the parent widget is focused. If this property is null then 
  /// the focus color of the theme, [ThemeData.focusColor], will be used.
  final Color? focusColor;

  /// The color of the ink response when a pointer is hovering over it. If this property is null 
  /// then the hover color of the theme, [ThemeData.hoverColor], will be used.
  final Color? hoverColor;

  /// The highlight color of the ink response when pressed. If this property is null then the 
  /// highlight color of the theme, [ThemeData.highlightColor], will be used.
  final Color? highlightColor;

  /// Defines the ink response focus, hover, and splash colors.
  ///
  /// This default null property can be used as an alternative to [focusColor], [hoverColor], 
  /// [highlightColor], and [splashColor]. If non-null, it is resolved against one of 
  /// [MaterialState.focused], [MaterialState.hovered], and [MaterialState.pressed]. It's convenient 
  /// to use when the parent widget can pass along its own MaterialStateProperty value for the 
  /// overlay color.
  ///
  /// [MaterialState.pressed] triggers a ripple (an ink splash), per the current Material Design 
  /// spec. The [overlayColor] doesn't map a state to [highlightColor] because a separate highlight 
  /// is not used by the current design guidelines.  See 
  /// https://material.io/design/interaction/states.html#pressed
  ///
  /// If the overlay color is null or resolves to null, then [focusColor], [hoverColor], 
  /// [splashColor] and their defaults are used instead.
  final MaterialStateProperty<Color?>? overlayColor;

  /// The splash color of the ink response. If this property is null then the splash color of the 
  /// theme, [ThemeData.splashColor], will be used.
  final Color? splashColor;

  /// Defines the appearance of the splash.
  ///
  /// Defaults to the value of the theme's splash factory: [ThemeData.splashFactory].
  final InteractiveInkFeatureFactory? splashFactory;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a long-press will produce a 
  /// short vibration, when feedback is enabled.
  final bool enableFeedback;

  /// Whether to exclude the gestures introduced by this widget from the semantics tree.
  ///
  /// For example, a long-press gesture for showing a tooltip is usually excluded because the 
  /// tooltip itself is included in the semantics tree directly and so having a gesture to show it 
  /// would result in duplication of information.
  final bool excludeFromSemantics;

  /// {@macro flutter.material.inkresponse.onFocusChanged}
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.material.inkwell.statesController}
  final MaterialStatesController? statesController;
  
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final SolanaWalletButtonStyle buttonStyle = style ?? SolanaWalletButtonStyle.styleFrom();
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: Material(
        color: buttonStyle.color,
        clipBehavior: Clip.hardEdge,
        shape: buttonStyle.shape ?? const StadiumBorder(),
        child: InkResponse(
          onTap: onTap,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTapCancel: onTapCancel,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onHighlightChanged: onHighlightChanged,
          onHover: onHover,
          mouseCursor: mouseCursor ?? SystemMouseCursors.click,
          containedInkWell: true, 
          highlightShape: BoxShape.rectangle, 
          focusColor: focusColor ?? theme.focusColor,
          hoverColor: hoverColor ?? theme.hoverColor,
          highlightColor: highlightColor ?? theme.highlightColor,
          overlayColor: overlayColor,
          splashColor: splashColor ?? theme.splashColor,
          splashFactory: splashFactory ?? theme.splashFactory,
          enableFeedback: enableFeedback, 
          excludeFromSemantics: excludeFromSemantics,
          focusNode: focusNode,
          canRequestFocus: onTap != null, 
          onFocusChange: onFocusChange,
          autofocus: autofocus, 
          statesController: statesController,
          child: DefaultTextStyle(
            style: buttonStyle.textStyle ?? DefaultTextStyle.of(context).style.copyWith(
              fontWeight: FontWeight.w500,
            ),
            child: Padding(
              padding: buttonStyle.padding!,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}