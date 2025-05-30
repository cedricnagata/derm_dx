# DermDx - Skin Lesion Analysis App

DermDx is an iOS application that allows users to take photos of skin lesions and receive an instant preliminary analysis using a machine learning model to classify lesions as benign or malignant.

## Features

- Camera integration to capture skin lesion images
- Image processing to prepare photos for analysis
- API integration with a .keras model for classification
- Clear visualization of diagnosis results
- User-friendly interface with step-by-step guidance

## Technical Details

- Built with SwiftUI for modern, responsive UI
- Implements UIKit integration for camera functionality
- Processes images to 384x384 square format as required by the model
- Communicates with API using multipart/form-data for image upload
- Handles errors gracefully with user feedback

## Setup

1. Clone the repository
2. Open `derm_dx.xcodeproj` in Xcode
3. Update the API endpoint in `DiagnosisService.swift` with your actual API URL
4. Build and run on a physical iOS device (camera access required)

## API Integration

The app is designed to work with an API that:
- Accepts POST requests with multipart/form-data
- Expects a square JPG image (384x384 pixels)
- Returns a JSON response with prediction, class, and confidence values

## Disclaimer

This application provides a preliminary assessment only and is not a substitute for professional medical advice. Always consult a healthcare provider for diagnosis and treatment.