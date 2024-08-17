# DERMDX: Skin Lesion Diagnosis App

**DERMDX** is an iOS app designed to help users diagnose skin lesions by taking a photo of the lesion and processing it to determine whether it is benign or malignant. The app utilizes deep learning models trained on over 44,000 images of real skin lesions to provide accurate results at the touch of a button.

Try it here! https://appetize.io/app/b_yw7vurhc57tvnhp4nxzy2et2wu

## Features
- **Select or Capture an Image**: Users can either take a photo of their skin lesion using the phone's camera or select one from their photo library.
- **Crop for Accuracy**: The app provides an intuitive cropping tool, allowing users to zoom in and focus on the lesion for more precise analysis.
- **Diagnosis Prediction**: After the image is uploaded, the app runs it through a trained machine learning model to predict:
    - The **diagnosis** (e.g., nevus, melanoma, or other).
    - Whether the lesion is **benign** or **malignant**, with associated confidence scores.
- **Results Page**: After processing, the app displays the predicted diagnosis, along with the confidence score for each classification (diagnosis and benign/malignant).

## App Workflow
1. **Home Screen**: The user is welcomed with an option to select or capture an image of their skin lesion.
2. **Photo Library**: The user can select an image of their lesion from their device's photo library.
3. **Image Instructions**: The app provides instructions on how to crop the image to ensure the lesion is centered for accurate analysis.
4. **Cropping Tool**: The user crops the image to focus on the lesion.
5. **Image Upload**: Once the image is cropped, it is uploaded for analysis.
6. **Processing**: The app processes the image, analyzing it through the machine learning model to predict both the diagnosis and malignancy of the lesion.
7. **Results**: The results are displayed, providing the user with the predicted diagnosis (e.g., nevus, melanoma) and whether the lesion is benign or malignant. Confidence scores for both predictions are also shown.

## Technologies Used
- **Flutter**: The app’s frontend is developed using Flutter for a smooth cross-platform experience on both Android and iOS.
- **TensorFlow Lite**: The machine learning models for skin lesion diagnosis and malignancy classification are optimized for mobile using TensorFlow Lite.

## Conclusion
DERMdx empowers users by providing fast, reliable, and accurate insights into their skin health. With a simple user interface and powerful deep learning models running in the background, the app offers a convenient way to perform a preliminary diagnosis of skin lesions.
