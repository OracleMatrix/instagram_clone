# Instagram Clone 📸

An **Instagram Clone** project that mimics the core functionalities of Instagram. Built using Flutter, Firebase, and a range of other powerful tools, this app demonstrates scalable architecture and features for social media platforms.

---

## Features ✨

- User Authentication (Signup/Login/Logout)
- Create, edit, and delete posts
- Like and comment on posts
- Profile management
- Real-time data syncing with **Firebase**
- Responsive UI for various device sizes
- Dark and Light themes with `adaptive_theme`
- Image uploading using `firebase_storage` and `image_picker`

---

## Tech Stack 🛠

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage, Analytics)
- **State Management**: Provider
- **UI Components**: Google Fonts, Cached Network Images
- **Utilities**: Image Picker, Connectivity Plus, Timeago

---

## Installation Guide 🛠️

1. **Clone the repository**
   ```bash
   git clone https://github.com/your_username/instagram_clone.git
   cd instagram_clone
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Set up Firebase**
   - Create a new Firebase project.
   - Add your Android, iOS, and Web apps.
   - Download and place `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in the respective folders.
   - Enable Firebase services: Firestore, Authentication, and Storage.
4. **Run the app**
   ```bash
   flutter run
   ```

---

## Dependencies 📦

Here are the main dependencies used in the project:

- `flutter`: ^3.0.0
- `firebase_core`: ^3.4.1
- `firebase_auth`: ^5.2.1
- `cloud_firestore`: ^5.4.1
- `firebase_storage`: ^12.3.0
- `google_fonts`: ^6.2.1
- `cached_network_image`: ^3.4.1
- `image_picker`: ^1.1.2
- `provider`: ^6.1.2
- `adaptive_theme`: ^3.6.0
- `timeago`: ^3.7.0

For the full list of dependencies, check the [`pubspec.yaml`](pubspec.yaml).

---

## Assets 📂

Assets used in the project include:

- `assets/images/insta_logo.png`
- `assets/images/app_icon.png`
- `assets/images/instagram_text_logo.png`
- `assets/images/profile_pic.jpg`
- `assets/images/instagram-logo-white.png`

---

## Screenshots 📷

> Showcase screenshots of the app here.

---

## Contributions 🤝

Contributions are welcome! Follow these steps:

1. Fork the repository.
2. Create your feature branch:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Open a pull request.

---

## License 📜

This project is licensed under the MIT License. See the `LICENSE` file for details.
