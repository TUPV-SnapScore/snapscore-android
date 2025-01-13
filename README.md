# SnapScore

SnapScore is a mobile application designed to streamline the grading of handwritten assessments using advanced Optical Character Recognition (OCR) and Artificial Intelligence (AI) technologies. This app aims to automate grading, improve efficiency, and provide educators with real-time insights into student performance.

## Features

- **OCR and AI Integration**: Converts handwritten text and mathematical equations into digital formats.
- **Automated Grading**: Scores assessments based on customizable rubrics.
- **Plagiarism Detection**: Identifies potential similarities and provides detailed reports.
- **Dashboards**:
  - Educators can manage classes, assessments, and grading tasks.
  - Students can view their scores and feedback.
- **Cross-Platform Compatibility**: Mobile app for Android and web platform for data storage and management.

## Getting Started

### Prerequisites

Before running the app, ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install): Follow the installation guide for your platform.
- [Android Studio](https://developer.android.com/studio): For Android development and emulation.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/snapscore.git
   cd snapscore
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Add your `google-services.json` file for Firebase configuration in the `android/app` directory.
   - Ensure Firebase Authentication and Firestore are configured for the project.

4. Run the app:
   ```bash
   flutter run
   ```

### Development Tips

- Use the Flutter DevTools for debugging and performance monitoring.
- Ensure your Android device/emulator has camera permissions enabled to test OCR functionalities.

## Contribution

We welcome contributions to enhance SnapScore! Feel free to submit issues, pull requests, or suggest new features.
