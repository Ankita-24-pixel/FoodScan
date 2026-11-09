## FoodScan: A Comprehensive Food Quality Assessment Mobile App for Android and iOS

![FoodScan logo](packages/smooth_app/assets/app/foodscan_logo.png)

![GitHub language count](https://img.shields.io/github/languages/count/Ankita-24-pixel/ShuddhScore_01)
![GitHub top language](https://img.shields.io/github/languages/top/Ankita-24-pixel/ShuddhScore_01)
![GitHub last commit](https://img.shields.io/github/last-commit/Ankita-24-pixel/ShuddhScore_01)
![Github Repo Size](https://img.shields.io/github/repo-size/Ankita-24-pixel/ShuddhScore_01)

## Presentation

- FoodScan is a comprehensive mobile application designed to help users assess food quality and purity through an intuitive user experience and sleek user interface. It is a <b>Flutter application</b>.
- FoodScan aims to empower users with knowledge about food products, enabling them to make informed decisions about their food purchases and consumption.

### Stable version

- Install it on **Android** ([Google Play](https://play.google.com/store)) or **iPhone/iPad** ([App Store](https://apps.apple.com/app)).

### Beta version

- Join the Beta version through Google Play to test the latest features before official release.

### Testing version

- An internal development build is available for active testing and feature validation.

<img alt="app showcase" height='175' src="https://user-images.githubusercontent.com/1689815/168430524-3adc923a-1ce3-4233-9af5-02e9d49a76ca.png">

- FoodScan is built as a modular Flutter application with reusable components and plugins.
- The app supports desktop platforms (Linux, macOS, and Windows), but **only for development**.

## Weekly meetings

- Regular community meetings to discuss development progress, features, and roadmap.
- Meeting schedule and notes are available to team members.

## Current Release

- For latest releases and version information, please check the [Releases](https://github.com/Ankita-24-pixel/ShuddhScore_01/releases) page.

## 📚 Code documentation

- [Code documentation on GitHub pages](https://ankita-24-pixel.github.io/ShuddhScore_01/).

## 🎨 Design & User interface

- FoodScan prioritizes thoughtful design for every feature before implementation, ensuring a consistent and user-friendly interface.
- We maintain high standards for visual design and user experience.
- Are you a designer? [Join the design team](https://github.com/Ankita-24-pixel/ShuddhScore_01)

<details><summary><h2>Features of the app</h2></summary>

## ✨ Features

- A comprehensive food quality assessment system that helps users evaluate products based on their specific criteria
- A detailed product information page with nutritional data, ingredients, and quality metrics
- An intuitive scoring system that provides clear feedback on product quality

### You can

- Scan and assess food products in seconds
- Compare products based on multiple quality criteria
- Set your personal preferences for food quality assessment
- Track your food consumption patterns

### Criteria you can evaluate

- Nutritional Content: Macronutrients, Vitamins, Minerals
- Health Factors: Additives, Sugar Content, Salt, Allergens
- Quality Metrics: Certifications, Freshness Indicators
- Environmental Impact: Sustainability Indicators

</details>

## 🚀 How to run the project

- Make sure you have installed Flutter and all the requirements
    - [Official Flutter installation guide](https://docs.flutter.dev/get-started/install)
- Currently, the app uses the following version of Flutter: **3.44.8**.
- **Setting Up Your Environment with FVM**
    - To manage Flutter versions easily, download and install **FVM (Flutter Version Management)**:
        - Install FVM by following the [official FVM installation guide](https://fvm.app/documentation/getting-started/installation).
        - Once FVM is installed, run the following commands to set Flutter to version 3.44.8:
          ```bash
          fvm install 3.44.8
          fvm use 3.44.8
          ```
        - Verify the Flutter version with:
          ```bash
          fvm flutter --version
          ```

We have predefined run configurations for Android Studio and Visual Studio Code.
In order to run the application, make sure you are in the `packages/smooth_app` directory and run these commands:

- `fvm flutter pub get .`
- On Android 🤖: `fvm flutter run -t lib/entrypoints/android/main_google_play.dart`
- On iOS/macOS 🍎: `fvm flutter run -t lib/entrypoints/ios/main_ios.dart`
- Troubleshooting: If you encounter dependency resolution errors, try:
    - `fvm flutter pub cache clean`
    - Delete the pub cache directory: `C:\Users\~\AppData\Local\Pub\Cache` (Windows) or `~/.pub-cache` (macOS/Linux)
    - Redo the above procedure to run the app.

- [Contributing Guidelines](https://github.com/Ankita-24-pixel/ShuddhScore_01/blob/develop/CONTRIBUTING.md)

<br>

<details><summary><h3>About FoodScan</h3></summary>

FoodScan is a community-driven project aimed at helping users make informed food choices through comprehensive quality assessment. The project is built with contributions from developers, designers, and food science enthusiasts.

</details>
<br>

## Contributors

<a href="https://github.com/Ankita-24-pixel/ShuddhScore_01/graphs/contributors">
  <img alt="List of contributors to this repository" src="https://contrib.rocks/image?repo=Ankita-24-pixel/ShuddhScore_01" />
</a>
