# Android module

Open this directory in Android Studio. Java-only app, no third-party runtime dependencies.
Build requirements: JDK 17, Gradle 8.13, Android SDK Platform 35 / Build Tools 35.0.0.
Output: `app/build/outputs/apk/debug/app-debug.apk`.
The app only dispatches commands through Termux's `RUN_COMMAND` service after the user grants Android permission and enables `allow-external-apps=true` inside Termux.
