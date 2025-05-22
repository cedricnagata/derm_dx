# DermDx - Skin Lesion Analyzer

An iOS application that analyzes skin lesions using machine learning to detect potential malignant conditions.

## Features

- Take photos of skin lesions using your device camera
- Get instant analysis with cloud-based API
- Fallback to on-device analysis when offline
- Receive benign/malignant classification with confidence score

## Requirements

- iOS 15.0+
- Xcode 13.0+
- CocoaPods

## Installation

1. Clone the repository
2. Install dependencies with CocoaPods:
   ```
   cd derm_dx
   pod install
   ```
3. Open `derm_dx.xcworkspace` in Xcode
4. Build and run the application

## Camera Permission

This app requires camera permission to function. You'll need to add the following to your `Info.plist` file (you mentioned you'll handle this in the Xcode UI):

```
<key>NSCameraUsageDescription</key>
<string>DermDx needs camera access to capture images of skin lesions for analysis.</string>
```

## Models

The app uses two machine learning models:
1. Cloud API using a Keras model (primary)
2. Local TFLite model (fallback when offline)

Both models were trained on 384x384 skin lesion images.

## Important Note

This application is for educational purposes only and is not a substitute for professional medical advice. Always consult a healthcare professional for proper diagnosis of skin conditions. 