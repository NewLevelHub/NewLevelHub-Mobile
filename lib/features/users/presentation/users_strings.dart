/// Centralized UI copy for the users feature.
///
/// Isolated here (Rule 8 — no hardcoded strings scattered through widgets)
/// so wiring real localization later is a mechanical extraction, not a
/// rewrite.
abstract final class UsersStrings {
  static const profileTitle = 'Профиль';
  static const profilePlaceholderMessage = 'Экран профиля в разработке';

  // Logout
  static const logout = 'Выйти';
  static const logoutLoading = 'Выходим…';
  static const logoutConfirmTitle = 'Выйти из аккаунта?';
  static const logoutConfirmMessage =
      'Вы уверены, что хотите выйти из аккаунта?';
  static const logoutConfirmCancel = 'Отмена';
}
