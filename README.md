The flutter_frontend Folder has the main FIles for the Project of the [Digitale Wortkette](https://github.com/metar00t/Digitale-Wortkette).  
flutter_demo is a minimal demo of flutter and flask. (Is not important for the Digitale Wortkette Project.)

Most Things in this documentation is made out of the [Flutter documentation](https://docs.flutter.dev/get-started/quick).
___

## Creating a Development Enviroment for flutter and flask:
### Installing and Running Flutter in Visual Studio Code

This guide walks you through installing Flutter in Visual Studio Code (VS Code), setting up your first Flutter project, and exploring essential Flutter tools.

---

### Table of Contents

- [Creating a Development Enviroment for flutter and flask:](#creating-a-development-enviroment-for-flutter-and-flask)
  - [Installing and Running Flutter in Visual Studio Code](#installing-and-running-flutter-in-visual-studio-code)
  - [Table of Contents](#table-of-contents)
- [1. Install the Flutter Extension in VS Code](#1-install-the-flutter-extension-in-vs-code)
- [2. Install Flutter with VS Code](#2-install-flutter-with-vs-code)
  - [Make Flutter available everywhere](#make-flutter-available-everywhere)
- [3. Validate Your Setup](#3-validate-your-setup)
- [4. Running Flutter for the First Time](#4-running-flutter-for-the-first-time)
  - [Create a New Flutter App](#create-a-new-flutter-app)
  - [Run Your App on the Web](#run-your-app-on-the-web)
  - [Try Hot Reload](#try-hot-reload)
- [5. Testing it for mobile](#5-testing-it-for-mobile)
  - [Setting Up Android Studio for Flutter Development](#setting-up-android-studio-for-flutter-development)
  - [Install and Set Up Android Studio](#install-and-set-up-android-studio)
    - [1. Install Prerequisite Libraries](#1-install-prerequisite-libraries)
    - [2. Install Android Studio](#2-install-android-studio)
  - [Install Android SDK and Tools](#install-android-sdk-and-tools)
  - [Agree to Android Licenses](#agree-to-android-licenses)
  - [Create a New Emulator](#create-a-new-emulator)

---

## 1. Install the Flutter Extension in VS Code

1. Open the [Flutter extension page on the VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).  
2. Click **Install**.  
3. If prompted, allow your browser to open VS Code.  

> 💡 The **Dart** extension is automatically installed alongside Flutter.

---

## 2. Install Flutter with VS Code

1. Open the **Command Palette** in VS Code:  
   - Go to **View > Command Palette**, or  
   - Press **Ctrl + Shift + P**.
2. Type `flutter` and select **Flutter: New Project**.
3. When prompted for the SDK location, choose **Download SDK**.
4. In the “Select Folder for Flutter SDK” dialog, choose where to install Flutter.
5. Click **Clone Flutter**.  
   VS Code will begin downloading Flutter — this may take a few minutes.

> ⏳ **Tip:** If the download appears stuck, click *Cancel* and restart the installation.

6. When prompted, click **Add SDK to PATH**.  
   You should see this confirmation:  
   > *The Flutter SDK was added to your PATH.*

7. You may also see a **Google Analytics** notice — click **OK** if you agree.

### Make Flutter available everywhere

- Close and reopen all terminal windows.  
- Restart VS Code.

---

## 3. Validate Your Setup

Run the following command in your terminal to confirm Flutter is installed correctly:

```bash
flutter doctor -v
```
## 4. Running Flutter for the First Time

Now that Flutter and VS Code are set up, let’s create and run your first Flutter app!

---
### Create a New Flutter App

1. Open the **Command Palette** (`Ctrl + Shift + P`).
2. Type **flutter** and select **Flutter: New Project**.
3. Choose the **Application** template.
4. When asked, pick or create a folder to save your project.
5. Enter a project name (e.g. `trying_flutter`).  
   > Use only lowercase letters and underscores.
6. Wait for project initialization to complete.  
   Progress appears in the bottom-right corner or in the **Output** panel.
7. Open the `lib/main.dart` file to explore your new Flutter app.

---

### Run Your App on the Web

1. Open the **Command Palette** again.
2. Select **Flutter: Select Device**.
3. From the list, choose **Chrome**.  
   > 💡 If you have an Android emulator set up in Android Studio, it will also appear here.
4. Start debugging your app:
   - Go to **Run > Start Debugging**, or  
   - Press **F5**.

VS Code will run `flutter run`, then open Chrome to display your new app.

---

### Try Hot Reload

Flutter’s **hot reload** feature lets you instantly see code changes without restarting your app.

1. In your running app, tap the **+** button a few times.
2. Open `lib/main.dart`, find the `_incrementCounter()` method, and modify it like this:

```dart
setState(() {
  _counter--;
});
```

## 5. Testing it for mobile
This Part will now go more into detail with what you need to debug, build, emulate for a mobile phone. This will for now only be for Android devices but will most likely be the same for all other devices.  
This part of the documentation will also be mostly taken out from the [flutter Android docu](https://docs.flutter.dev/platform-integration/android/setup) and the [Android Studio documentary](https://developer.android.com/studio/install?hl=de).

### Setting Up Android Studio for Flutter Development

With **Android Studio**, you can run Flutter apps on either a **physical Android device** or an **Android Emulator**.

---

### Install and Set Up Android Studio

If you haven't already, install and set up the **latest stable version** of Android Studio.

#### 1. Install Prerequisite Libraries
Make sure all necessary libraries and dependencies are installed on your system (these vary by OS).

#### 2. Install Android Studio

- If you haven’t installed Android Studio, download the **latest stable release** from the [official Android Studio website](https://developer.android.com/studio).
- If you already have Android Studio installed, ensure that it’s **up to date**.

---

### Install Android SDK and Tools

1. **Launch Android Studio.**
2. Open the **SDK Manager** settings dialog:
   - If you’re on the **Welcome to Android Studio** screen, click **More Actions ▾ > SDK Manager**.
   - If you already have a project open, go to **Tools > SDK Manager**.
3. In the **SDK Platforms** tab:
   - Verify that the first entry with an **API Level of 36** is selected.
   - If the **Status** column shows *Update available* or *Not installed*:
     1. Check the box for that entry.
     2. Click **Apply**.
     3. In the **Confirm Change** dialog, click **OK**.
     4. Wait for the **SDK Component Installer** to finish, then click **Finish**.
4. Switch to the **SDK Tools** tab.
5. Ensure the following tools are selected:
   - **Android SDK Build-Tools**  
   - **Android SDK Command-line Tools**  
   - **Android Emulator**  
   - **Android SDK Platform-Tools**
6. If any of these tools show *Update available* or *Not installed*:
   1. Check their boxes.  
   2. Click **Apply**.  
   3. Confirm and install updates.  
   4. Once installation completes, click **Finish**.

---

### Agree to Android Licenses

Before you can use Flutter with Android, you must accept the Android SDK licenses.

1. Open your preferred terminal.
2. Run the following command:
    ```bash
    flutter doctor --android-licenses
    ```
### Create a New Emulator

Follow these steps to create a new Android emulator in **Android Studio**:

1. **Start Android Studio.**
2. **Open the Device Manager:**
   - If you’re on the **Welcome to Android Studio** screen, click  
     **More Actions ▾ > Virtual Device Manager**.
   - If you already have a project open, go to  
     **Tools > Device Manager**.
3. Click the **Create Virtual Device** (**+**) button.
4. In the **Virtual Device Configuration** dialog:
   - Under **Form Factor**, select **Phone** or **Tablet**.
   - Choose a device definition (you can browse or search for one).
   - Click **Next**.
5. **Choose a System Image:**
   - Select a system image for the Android version you want to emulate.
   - If the image has a **Download** icon next to it, click it to install.
   - Wait for the download to complete, then click **Finish**.
6. Click **Additional Settings** in the top tab bar and scroll to **Emulated Performance**.
7. Under **Graphics Acceleration**, select an option that includes **Hardware**  
   (this enables hardware acceleration for better rendering performance).
8. Review your virtual device configuration.
9. Click **Finish** to create the emulator.

> 💡 To learn more about creating and managing virtual devices, see the [Android Studio documentation](https://developer.android.com/studio/run/managing-avds).
