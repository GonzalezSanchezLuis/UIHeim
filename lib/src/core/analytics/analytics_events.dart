class AnalyticsEvents {
   // ============== CICLO DE VIDA DEL USUARIO ==============
  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
  static const String appClose = 'app_close';

    // ============== AUTENTICACIÓN ==============
  static const String userSignUp = 'user_sign_up';
  static const String userLogin = 'user_login';
  static const String userLogout = 'user_logout';
  static const String userPasswordReset = 'user_password_reset';
  static const String userEmailVerification = 'user_email_verification';

   // ============== NAVEGACIÓN ==============
  static const String screenView = 'screen_view';
  static const String tabSwitch = 'tab_switch';
  static const String deepLinkOpen = 'deep_link_open';
  static const String backButtonPress = 'back_button_press';

  // ============== INTERACCIÓN ==============
  static const String buttonClick = 'button_click';
  static const String linkClick = 'link_click';
  static const String formSubmit = 'form_submit';
  static const String formError = 'form_error';
  static const String searchQuery = 'search_query';
  static const String shareContent = 'share_content';
  static const String rateContent = 'rate_content';
  static const String favoriteAdd = 'favorite_add';
  static const String favoriteRemove = 'favorite_remove';

  // ============== CONTENIDO ==============
  static const String contentView = 'content_view';
  static const String contentRead = 'content_read';
  static const String contentLike = 'content_like';
  static const String contentComment = 'content_comment';
  static const String contentShare = 'content_share';

    // ============== NOTIFICACIONES ==============
  static const String notificationReceived = 'notification_received';
  static const String notificationOpen = 'notification_open';
  static const String notificationDismiss = 'notification_dismiss';

  // ============== ERRORES ==============
  static const String errorOccurred = 'error_occurred';
  static const String apiError = 'api_error';
  static const String networkError = 'network_error';
}