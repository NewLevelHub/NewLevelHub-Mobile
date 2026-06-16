/// Centralized UI copy for the auth feature.
///
/// Isolated here (Rule 8 — no hardcoded strings scattered through widgets)
/// so wiring real localization later is a mechanical extraction, not a
/// rewrite.
abstract final class AuthStrings {
  static const loginTitle = 'Вход';
  static const loginSubtitle = 'Войдите, чтобы продолжить';
  static const emailLabel = 'Email';
  static const emailHint = 'you@example.com';
  static const emailRequired = 'Введите email';
  static const emailInvalid = 'Введите корректный email';
  static const passwordLabel = 'Пароль';
  static const passwordRequired = 'Введите пароль';
  static const rememberMe = 'Запомнить меня';
  static const forgotPassword = 'Забыли пароль?';
  static const noAccount = 'Регистрация';
  static const signIn = 'Войти';
  static const signInLoading = 'Вход…';

  // Verify email (MOB-110)
  static const verifyEmailTitle = 'Подтверждение email';
  static const verifyEmailInstructions =
      'Мы отправили письмо со ссылкой для подтверждения на адрес ниже. '
      'Перейдите по ссылке из письма, чтобы продолжить.';
  static const verifyEmailInviteInstructions =
      'Проверьте почту — мы отправили письмо со ссылкой для подтверждения.';
  static const resendEmail = 'Отправить письмо повторно';
  static const resendEmailLoading = 'Отправляем…';
  static const resendEmailSent = 'Письмо отправлено повторно';
  static const resendEmailAlreadyVerified = 'Email уже подтверждён';
  static String resendCooldown(int seconds) =>
      'Попробуйте позже (через $seconds с)';
  static const backToLogin = 'Вернуться ко входу';
}
