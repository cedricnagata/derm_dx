# DERMdx: Skin Lesion Diagnosis App

**DERMdx** is an iOS app designed to help users diagnose skin lesions by taking a photo of the lesion and processing it to determine whether it is benign or malignant. The app utilizes deep learning models trained on over 44,000 images of real skin lesions to provide accurate results at the touch of a button.

## Features
- Capture or select an image of a skin lesion from your photo library.
- Crop the image to ensure accurate analysis.
- Get a diagnosis (nevus, melanoma, or other) and benign/malignant classification with confidence scores.

## App Workflow
### 1. Home Screen
On the home screen, users can start by selecting an image from their library.

![Home Screen](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5040.PNG)

### 2. Photo Library
Users can choose images of skin lesions from their library for analysis.

![Photo Library](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5041.PNG)

### 3. Image Instructions
Instructions guide users on how to crop the image for the most accurate diagnosis.

![Image Instructions](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5042.PNG)

### 4. Crop Image
Users are prompted to crop the image to focus on the lesion.

![Crop Image](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5043.PNG)

### 5. Upload Image
After cropping, the image is uploaded for analysis.

![Upload Image](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5044.PNG)

### 6. Processing
The app analyzes the image and provides feedback on progress.

![Processing](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5045.PNG)

### 7. Results (Benign)
Here is an example of a diagnosis result showing a benign lesion with confidence scores.

![Benign Result](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5046.PNG)

### 8. Results (Malignant)
Here is an example of a diagnosis result showing a malignant lesion with confidence scores.

![Malignant Result](https://github.com/cedricnagata/derm_dx/blob/main/demo_images/IMG_5047.PNG)

## Conclusion
DERMdx provides an easy-to-use solution for preliminary skin lesion diagnosis using cutting-edge machine learning techniques. It is designed to empower users with fast, reliable insights into their skin health.

---

### Tech Stack
- **Flutter** for the mobile app frontend
- **TensorFlow Lite** for the machine learning models
- **Flask** for backend API (serving predictions)

---

Feel free to try out the app and explore the codebase!
