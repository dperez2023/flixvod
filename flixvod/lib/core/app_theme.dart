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
  
  /// Background colors
  static const Color primaryBackgroundColor = Colors.white;
  static const Color secondaryBackgroundColor = Color(0xFFF5F5F5);
  static Color overlayBackgroundColor = Colors.black.withOpacity(0.7);
  static Color cardBackgroundColor = Colors.grey[300]!;
  static Color errorBackgroundColor = Colors.red[50]!;

  /// Foreground colors
  static const Color primaryForegroundColor = Colors.black;
  static const Color secondaryForegroundColor = Colors.white;
  static Color mutedForegroundColor = Colors.grey[600]!;
  static Color lightForegroundColor = Colors.grey[500]!;
  static const Color whiteForegroundColor = Colors.white;
  static const Color white70ForegroundColor = Colors.white70;

  /// Border colors
  static Color errorBorderColor = Colors.red[200]!;
  static const Color primaryBorderColor = Colors.grey;

  /// Status colors
  static const Color errorColor = Colors.red;
  static Color errorTextColor = Colors.red[700]!;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  /// Rating and interaction colors
  static const Color ratingColor = Colors.amber;
  static Color inactiveRatingColor = Colors.grey[300]!;
  static const Color starColor = Colors.amber;

  /// Media type colors
  static const Color movieTypeColor = Colors.blue;
  static const Color seriesTypeColor = Colors.orange;

  /// Player colors
  static const Color playerBackgroundColor = Colors.black;
  static const Color playerControlsColor = Colors.white;
  static Color playerBufferedColor = Colors.grey[300]!;
  static Color playerControlBackgroundColor = Colors.black54;

  /// Badge colors
  static const Color ratingBadgeColor = Colors.black87;

  // =================== TEXT STYLES ===================
  
  /// Common text styles with consistent colors and alignment
  static const TextStyle whiteTextStyle = TextStyle(
    color: Colors.white,
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
  static const TextStyle emptyStateTitleStyle = TextStyle(
    fontSize: 18,
    color: Colors.grey,
  );

  static const TextStyle emptyStateSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
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
    horizontal: 6,
    vertical: 2,
  );
  
  static const EdgeInsets largeBadgePadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );

  /// Container padding
  static const EdgeInsets containerPadding = EdgeInsets.all(12);

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16);

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
          overlayBackgroundColor,
        ],
      ),
    );
  }
}
