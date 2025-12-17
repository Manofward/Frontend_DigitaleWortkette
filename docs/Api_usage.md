# API Levels for Android studio and flutter for emulating and compiling 

If you want to test a Flutter Program on a emulator/real device you need the right API Compilation.

That is because if your device has **Android 13(API Level 33)** you cant compile for **API Level 36** and expect it to work with **API Level 33**.  
If you instead compile for **API Level 33** and want to use it with **API Level 36** thats possible.

To compile it with a release build you do:
```bash
flutter build
```

If you compiled for Android the Apk will be in the following folder:
> *build/app/outputs/flutter-apk*

