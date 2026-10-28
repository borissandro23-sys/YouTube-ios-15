# RetroTube

RetroTube — лёгкий YouTube-клиент для iOS 15+, с полноэкранным интерфейсом и минималистичным дизайном.

> RetroTube — независимый веб-клиент, а не официальное приложение YouTube и не модификация его бинарного файла. Сайт, воспроизведение видео, вход в аккаунт и другие функции контролируются YouTube и могут изменяться.

## Возможности

- Мобильная версия YouTube внутри `WKWebView`
- Полноэкранный интерфейс без дополнительных панелей приложения
- Поддержка iPhone и iPad
- Генерация проекта Xcode с помощью XcodeGen
- Сборка unsigned IPA через GitHub Actions

## Структура проекта

- `Sources/RetroTubeApp.swift` — приложение SwiftUI и оболочка WKWebView
- `project.yml` — конфигурация проекта XcodeGen (Bundle ID и минимальная версия iOS)
- `.github/workflows/build.yml` — CI-сборка и упаковка IPA

## Локальная сборка

Требования: macOS, Xcode с iOS SDK и [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
xcodebuild \
  -project RetroTube.xcodeproj \
  -scheme RetroTube \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Чтобы упаковать unsigned-приложение после успешной сборки:

```sh
mkdir -p ipa/Payload
cp -R build/Build/Products/Release-iphoneos/RetroTube.app ipa/Payload/RetroTube.app
(cd ipa && zip -qry ../RetroTube-unsigned.ipa Payload)
```

## GitHub Actions

При отправке изменений в ветку `main` или ручном запуске через **Actions → Build RetroTube IPA → Run workflow** выполняется сборка приложения. Скачайте артефакт `RetroTube-unsigned-IPA` в разделе Artifacts соответствующего запуска.

Артефакт не подписан. Перед установкой на обычный iPhone или iPad его нужно подписать подходящим способом с использованием Apple Developer signing. Этот workflow не публикует приложение в App Store.

## Ограничения

- RetroTube — веб-оболочка: она не восстанавливает и не модифицирует официальное приложение YouTube 19.x.
- YouTube может менять сайт, требования к воспроизведению видео, авторизации и свои правила.
- App Store может отклонить приложение, которое является простой оболочкой сайта или не добавляет достаточно самостоятельной функциональности.
- Успешность сборки проверяется запуском GitHub Actions; если сборка завершится ошибкой, изучите логи workflow.
