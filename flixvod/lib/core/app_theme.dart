import 'package:flutter/material.dart';

/// Centralized theming constants for consistent design across the app
class AppTheme {
  AppTheme._();

  // =================== SPACING ===================
  
  /// Vertical spacing constants
  static const Widget tinyVerticalSpacer = SizedBox(height: 4);
  static const Widget smallVerticalSpacer = SizedBox(height: 8);
  static const Widget mediumVerticalSpacer = SizedBox(height: 16);
  static const Widget largeVerticalSpacer = SizedBox(height: 24);
  static const Widget extraLargeVerticalSpacer = SizedBox(height: 32);

  /// Horizontal spacing constants
  static const Widget tinyHorizontalSpacer = SizedBox(width: 2);
  static const Widget smallHorizontalSpacer = SizedBox(width: 4);
  static const Widget mediumHorizontalSpacer = SizedBox(width: 8);
  static const Widget largeHorizontalSpacer = SizedBox(width: 12);
  static const Widget extraLargeHorizontalSpacer = SizedBox(width: 16);

  /// Special spacing constants
  static const Widget specialVerticalSpacer = SizedBox(height: 12);

  /// Height constants for use in EdgeInsets and measurements
  static const double smallVerticalSpacerHeight = 8;
  static const double mediumVerticalSpacerHeight = 16;
  static const double largeVerticalSpacerHeight = 24;
  static const double extraLargeVerticalSpacerHeight = 32;

  /// Width constants for use in EdgeInsets and measurements
  static const double tinyHorizontalSpacerWidth = 2;
  static const double smallHorizontalSpacerWidth = 4;
  static const double mediumHorizontalSpacerWidth = 8;
  static const double largeHorizontalSpacerWidth = 12;
  static const double extraLargeHorizontalSpacerWidth = 16;

  // =================== COLORS ===================
  
  /// Background colors - Dark theme with blue accents
  static const Color primaryBackgroundColor = Color(0xFF1A1A1A);
  static const Color secondaryBackgroundColor = Color(0xFF2A2A2A);
  static const Color overlayBackgroundColor = Color(0xFF0D47A1);
  static const Color cardBackgroundColor = Color(0xFF333333);
  static const Color errorBackgroundColor = Color(0xFF4A1A1A);

  /// Foreground colors - White-based
  static const Color primaryForegroundColor = Colors.white;
  static const Color secondaryForegroundColor = Colors.white;
  static Color mutedForegroundColor = Colors.white.withOpacity(0.7);
  static Color lightForegroundColor = Colors.white.withOpacity(0.5);
  static const Color whiteForegroundColor = Colors.white;
  static const Color white70ForegroundColor = Colors.white70;

  /// Border colors
  static Color errorBorderColor = Colors.red.withOpacity(0.3);
  static Color primaryBorderColor = Colors.white.withOpacity(0.3);

  /// Status colors
  static const Color errorColor = Colors.red;
  static Color errorTextColor = Colors.red[300]!;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static Color infoColor = Colors.blue.withOpacity(0.8);

  /// Rating and interaction colors
  static const Color ratingColor = Colors.amber;
  static Color inactiveRatingColor = Colors.white.withOpacity(0.3);
  static const Color starColor = Colors.amber;

  /// Media type colors
  static Color movieTypeColor = Colors.blue.withOpacity(0.8);
  static Color seriesTypeColor = Colors.orange.withOpacity(0.8);

  /// Player colors
  static Color playerBackgroundColor = Colors.blue.withOpacity(0.9);
  static const Color playerControlsColor = Colors.white;
  static Color playerBufferedColor = Colors.white.withOpacity(0.3);
  static Color playerControlBackgroundColor = Colors.blue.withOpacity(0.6);

  /// Badge colors
  static Color ratingBadgeColor = Colors.blue.withOpacity(0.8);

  // =================== TEXT STYLES ===================
  
  /// Common text styles with consistent colors and alignment
  static const TextStyle primaryTextStyle = TextStyle(
    color: Colors.white,
  );

  static const TextStyle whiteTextStyle = TextStyle(
    color: Colors.white,
  );

  static TextStyle mutedTextStyle = TextStyle(
    color: Colors.white.withOpacity(0.7),
  );

  static const TextStyle white70TextStyle = TextStyle(
    color: Colors.white70,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
  );

  /// Player text styles
  static const TextStyle playerTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle playerSubtitleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  static const TextStyle playerInfoStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  /// Badge text styles
  static const TextStyle badgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 8,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle ratingBadgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle episodeBadgeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  /// Error display styles
  static const TextStyle errorDisplayStyle = TextStyle(
    fontSize: 12,
  );

  /// Empty state styles
  static TextStyle emptyStateTitleStyle = TextStyle(
    fontSize: 18,
    color: Colors.white.withOpacity(0.8),
  );

  static TextStyle emptyStateSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.6),
  );

  /// Media type badge style
  static const TextStyle mediaTypeBadgeStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // =================== COMMON WIDGET STYLES ===================
  
  /// Standard padding
  static const EdgeInsets standardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);
  static const EdgeInsets extraLargePadding = EdgeInsets.all(32.0);
  
  /// Badge padding
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  );
  
  static const EdgeInsets largeBadgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Container padding
  static const EdgeInsets containerPadding = EdgeInsets.all(12);

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16);

  /// Form field padding
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets searchBarPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  /// Border radius
  static const double smallBorderRadius = 6.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;

  /// Icon sizes
  static const double smallIconSize = 12.0;
  static const double mediumIconSize = 20.0;
  static const double largeIconSize = 28.0;
  static const double extraLargeIconSize = 40.0;
  static const double heroIconSize = 80.0;

  /// Play button sizes
  static const double playButtonSize = 50.0;
  static const double largePlayButtonSize = 80.0;
  static const double loadingIndicatorSize = 20.0;

  // =================== BUTTON STYLES ===================
  
  /// Primary elevated button style (blue background)
  static ButtonStyle primaryElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: overlayBackgroundColor,
    foregroundColor: primaryForegroundColor,
    padding: buttonPadding,
  );

  /// Error elevated button style (red background)
  static ButtonStyle errorElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: whiteForegroundColor,
    padding: buttonPadding,
  );

  /// Secondary elevated button style (for disabled states)
  static ButtonStyle secondaryElevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: overlayBackgroundColor,
    foregroundColor: primaryForegroundColor,
    disabledBackgroundColor: mutedForegroundColor,
    disabledForegroundColor: lightForegroundColor,
    padding: buttonPadding,
  );

  /// Basic elevated button style (theme default with padding)
  static ButtonStyle basicElevatedButtonStyle = ElevatedButton.styleFrom(
    padding: buttonPadding,
  );

  /// Primary text button style (muted foreground)
  static ButtonStyle primaryTextButtonStyle = TextButton.styleFrom(
    foregroundColor: mutedForegroundColor,
  );

  /// Error text button style (red foreground)
  static ButtonStyle errorTextButtonStyle = TextButton.styleFrom(
    foregroundColor: errorColor,
  );

  // =================== HELPER METHODS ===================
  
  /// Get media type color based on boolean
  static Color getMediaTypeColor(bool isMovie) {
    return isMovie ? movieTypeColor : seriesTypeColor;
  }

  /// Get star color based on rating state
  static Color getStarColor(bool isSelected) {
    return isSelected ? ratingColor : inactiveRatingColor;
  }

  /// Create a themed BoxDecoration for badges
  static BoxDecoration createBadgeDecoration(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(smallBorderRadius),
    );
  }

  /// Create a themed BoxDecoration for large badges
  static BoxDecoration createLargeBadgeDecoration(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(largeBorderRadius),
    );
  }

  /// Create a themed BoxDecoration for error containers
  static BoxDecoration createErrorContainerDecoration() {
    return BoxDecoration(
      color: errorBackgroundColor,
      borderRadius: BorderRadius.circular(mediumBorderRadius),
      border: Border.all(color: errorBorderColor),
    );
  }

  /// Create a themed BoxDecoration for cards
  static BoxDecoration createCardDecoration() {
    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(mediumBorderRadius),
    );
  }

  /// Create a themed BoxDecoration for play buttons
  static BoxDecoration createPlayButtonDecoration() {
    return BoxDecoration(
      color: overlayBackgroundColor,
      shape: BoxShape.circle,
    );
  }

  /// Create a themed BoxDecoration with gradient overlay
  static BoxDecoration createGradientOverlayDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.blue.withOpacity(0.8),
        ],
      ),
    );
  }
}
