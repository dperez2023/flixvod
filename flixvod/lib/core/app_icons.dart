import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centralized icon system with consistent styling across the app
/// Provides styled Icon widgets instead of just IconData references
class AppIcons {
  AppIcons._();

  // =================== NAVIGATION ICONS ===================
  
  /// Back/arrow back icon with consistent styling
  static const Icon back = Icon(
    Icons.arrow_back,
    color: AppTheme.playerControlsColor,
    size: AppTheme.largeIconSize,
  );

  /// Back icon for dark backgrounds
  static const Icon backDark = Icon(
    Icons.arrow_back,
    color: AppTheme.whiteForegroundColor,
    size: AppTheme.largeIconSize,
  );

  /// Back icon for light backgrounds
  static const Icon backLight = Icon(
    Icons.arrow_back,
    color: AppTheme.primaryForegroundColor,
    size: AppTheme.largeIconSize,
  );

  /// Arrow forward icon
  static const Icon arrowForward = Icon(
    Icons.arrow_forward_ios,
    color: AppTheme.primaryForegroundColor,
    size: AppTheme.mediumIconSize,
  );

  // =================== MEDIA ICONS ===================
  
  /// Movie icon for media type indicators
  static const Icon movie = Icon(
    Icons.movie,
    color: AppTheme.movieTypeColor,
    size: AppTheme.mediumIconSize,
  );

  /// TV series icon for media type indicators
  static const Icon series = Icon(
    Icons.tv,
    color: AppTheme.seriesTypeColor,
    size: AppTheme.mediumIconSize,
  );

  /// Video library icon
  static const Icon videoLibrary = Icon(
    Icons.video_library,
    size: AppTheme.heroIconSize,
  );

  /// Video library icon (medium size)
  static const Icon videoLibraryMedium = Icon(
    Icons.video_library,
    size: AppTheme.extraLargeIconSize,
  );

  // =================== PLAYER ICONS ===================
  
  /// Play button icon for video player
  static const Icon play = Icon(
    Icons.play_arrow,
    color: AppTheme.playerControlsColor,
    size: AppTheme.playButtonSize,
  );

  /// Play button icon (large)
  static const Icon playLarge = Icon(
    Icons.play_arrow,
    color: AppTheme.playerControlsColor,
    size: AppTheme.largePlayButtonSize,
  );

  /// Play button icon for cards/thumbnails
  static const Icon playCard = Icon(
    Icons.play_arrow,
    color: AppTheme.whiteForegroundColor,
    size: AppTheme.largeIconSize,
  );

  // =================== ACTION ICONS ===================
  
  /// Add/upload icon
  static const Icon add = Icon(
    Icons.add,
    size: AppTheme.mediumIconSize,
  );

  /// Delete icon
  static const Icon delete = Icon(
    Icons.delete,
    size: AppTheme.mediumIconSize,
  );

  /// Edit icon
  static const Icon edit = Icon(
    Icons.edit,
    size: AppTheme.mediumIconSize,
  );

  /// More options (vertical dots)
  static const Icon moreVert = Icon(
    Icons.more_vert,
    size: AppTheme.mediumIconSize,
  );

  /// Remove icon
  static const Icon remove = Icon(
    Icons.remove,
    size: AppTheme.mediumIconSize,
  );

  /// Refresh icon
  static const Icon refresh = Icon(
    Icons.refresh,
    size: AppTheme.mediumIconSize,
  );

  /// Image icon
  static const Icon image = Icon(
    Icons.image,
    size: AppTheme.mediumIconSize,
  );

  // =================== SEARCH ICONS ===================
  
  /// Search icon
  static const Icon search = Icon(
    Icons.search,
    size: AppTheme.mediumIconSize,
  );

  // =================== RATING ICONS ===================
  
  /// Star icon for ratings (filled)
  static const Icon starFilled = Icon(
    Icons.star,
    color: AppTheme.starColor,
    size: AppTheme.mediumIconSize,
  );

  /// Star icon for ratings (empty) - using helper method for non-const color
  static Icon get starEmpty => Icon(
    Icons.star,
    color: AppTheme.inactiveRatingColor,
    size: AppTheme.mediumIconSize,
  );

  /// Large star for rating input
  static const Icon starLarge = Icon(
    Icons.star,
    size: 32,
  );

  // =================== STATUS ICONS ===================
  
  /// Error icon
  static const Icon error = Icon(
    Icons.error,
    color: AppTheme.errorColor,
    size: AppTheme.extraLargeIconSize,
  );

  /// Error icon (large)
  static const Icon errorLarge = Icon(
    Icons.error,
    color: AppTheme.errorColor,
    size: 64,
  );

  /// Warning icon
  static const Icon warning = Icon(
    Icons.warning,
    color: AppTheme.warningColor,
    size: AppTheme.extraLargeIconSize,
  );

  /// Info icon
  static const Icon info = Icon(
    Icons.info,
    color: AppTheme.infoColor,
    size: AppTheme.extraLargeIconSize,
  );

  // =================== HELPER METHODS ===================
  
  /// Create a custom star icon with dynamic color based on selection state
  static Icon createStar({
    required bool isSelected,
    double? size,
  }) {
    return Icon(
      Icons.star,
      color: isSelected ? AppTheme.starColor : AppTheme.inactiveRatingColor,
      size: size ?? AppTheme.mediumIconSize,
    );
  }

  /// Create a media type icon with dynamic color based on type
  static Icon createMediaTypeIcon({
    required bool isMovie,
    double? size,
  }) {
    return Icon(
      isMovie ? Icons.movie : Icons.tv,
      color: isMovie ? AppTheme.movieTypeColor : AppTheme.seriesTypeColor,
      size: size ?? AppTheme.mediumIconSize,
    );
  }

  /// Create a back icon with custom color (for different backgrounds)
  static Icon createBackIcon({
    Color? color,
    double? size,
  }) {
    return Icon(
      Icons.arrow_back,
      color: color ?? AppTheme.primaryForegroundColor,
      size: size ?? AppTheme.largeIconSize,
    );
  }

  /// Create a play icon with custom styling
  static Icon createPlayIcon({
    Color? color,
    double? size,
  }) {
    return Icon(
      Icons.play_arrow,
      color: color ?? AppTheme.playerControlsColor,
      size: size ?? AppTheme.playButtonSize,
    );
  }
}
