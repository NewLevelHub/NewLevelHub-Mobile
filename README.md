# NewLevelHub — Mobile

Мобильное приложение платформы управления коворкинг-пространством **New Level Hub** на Flutter.

При локальной разработке приложение обращается к **production-бэкенду** (тот же API, что и веб-фронтенд). Локальный Django поднимать не нужно.

---

## Технологический стек

| Инструмент | Назначение |
|---|---|
| Flutter | UI-фреймворк (iOS + Android) |
| Dart | Язык приложения |

> Сетевой слой (Dio), авторизация и экраны — в следующих тикетах.

---

## Требования

- **Flutter SDK** — stable-канал, версия **3.24+** (рекомендуется последняя stable)
- **Xcode** — для iOS Simulator (macOS, iOS **15+**)
- **Android Studio** или Android SDK — для Android Emulator (API **24+**, Android 7.0)

Проверить установку:

```bash
flutter --version
flutter doctor
```

### Установка Flutter

1. Скачайте SDK: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Добавьте `flutter` в `PATH`
3. Выполните `flutter doctor` и установите недостающие компоненты (Xcode, Android SDK)

---

## API

| Параметр | Значение |
|---|---|
| Base URL (production) | `https://newlevelhub.kz/api/v1/` |
| Авторизация | JWT Bearer Token |
| Формат данных | JSON |

Константа в коде: `lib/core/config/app_config.dart` → `AppConfig.apiBaseUrl`.

Документация API: репозиторий бэкенда, каталог `mobile-api-docs/` (`mobile_api.md` и `mobile_api_*.md`).

---

## Установка и запуск

### 1. Клонирование

```bash
git clone https://github.com/NewLevelHub/NewLevelHub-Mobile.git
cd NewLevelHub-Mobile
```

### 2. Зависимости

```bash
flutter pub get
```

Если платформенные файлы отсутствуют или устарели:

```bash
chmod +x tool/bootstrap.sh
./tool/bootstrap.sh
```

### 3. Запуск

```bash
# Список доступных устройств
flutter devices

# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android
```

При первом запуске на iOS может потребоваться:

```bash
cd ios && pod install && cd ..
```

### 4. Проверка качества

```bash
flutter analyze
flutter test
```

### UI Kit Demo

В debug-сборке на главном экране доступна кнопка **UI Kit Demo** (`/ui-kit-demo`) — демонстрирует все компоненты дизайн-системы: кнопки, поля ввода, ошибки, загрузку и пустые состояния.

---

## Структура проекта

```
lib/
  main.dart                 # Точка входа
  app.dart                  # MaterialApp, тема
  core/
    config/                 # AppConfig, base URL
    network/                # HTTP-клиент (следующий тикет)
    auth/                   # JWT, сессия (следующий тикет)
    router/                 # Навигация (следующий тикет)
    theme/                  # AppTheme, AppColors, AppTextStyles
    widgets/                # UI-kit: AppButton, AppTextField, AppLoader, …
  features/
    auth/                   # Экраны авторизации (следующий тикет)
    users/                  # Профиль пользователя (следующий тикет)
```

---

## Идентификаторы

| Платформа | Значение |
|---|---|
| Package name | `newlevelhub_mobile` |
| Android applicationId | `kz.newlevelhub.newlevelhub_mobile` |
| iOS Bundle ID | `kz.newlevelhub.newlevelhub_mobile` |
| Min iOS | 15.0 |
| Min Android SDK | 24 |

---

## Секреты

Не коммитьте файлы с ключами и токенами (`.env`, `*.jks`, `*.keystore`, `google-services.json` и т.п.). См. `.gitignore`.
