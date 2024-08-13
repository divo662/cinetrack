
# CineTrack

CineTrack is a modern and user-friendly movie tracking application built using Flutter. The app allows users to explore trending movies, add favorites to their watchlist, and generate color palettes from movie posters. This README covers the frontend implementation of the CineTrack app.

## Features

- **User Authentication**: Seamless sign-up and login with secure password storage.
- **Trending Movies**: Browse a list of trending movies fetched from the TMDB API.
- **Movie Details**: View detailed information about each movie, including cast, release date, and synopsis.
- **Watchlist Management**: Easily add or remove movies from your watchlist.
- **Color Palette Generation**: Create color palettes based on movie posters to inspire your design ideas.
- **Search Functionality**: Quickly search for movies by title.
- **Responsive UI**: Optimized for both Android and iOS devices with a clean and intuitive interface.

## Screenshots

![Screenshot 2024-08-14 002815](https://github.com/user-attachments/assets/f93c07fe-49b4-4b1b-9370-d3435a9b5d4d)
 ![Screenshot 2024-08-14 002904](https://github.com/user-attachments/assets/9d22e149-af36-475f-9342-89cf7cc26c60)
![Screenshot 2024-08-14 002919](https://github.com/user-attachments/assets/a10453b8-3b96-4dc6-a014-0100909f4cc7)
![Screenshot 2024-08-14 002939](https://github.com/user-attachments/assets/c0182fb4-066b-4150-860f-b6b96894a171)
![Screenshot 2024-08-14 002957](https://github.com/user-attachments/assets/7a0f668f-7384-4f29-b41f-489496ad9c6b)


## APK Download

You can download the latest version of the CineTrack app from the link below:

- [Download CineTrack APK](https://drive.google.com/file/d/1ZqcyVD-eWLq62DND2r0oNKHi2aZpD53q/view)

## Installation

To run the CineTrack app locally on your device, follow these steps:

### Prerequisites

- **Flutter SDK**: Ensure you have Flutter installed on your machine. You can download it from [Flutter's official website](https://flutter.dev).
- **Android Studio or Xcode**: For Android or iOS development.

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/divo662/cinetrack.git
   cd cinetrack
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   - Connect your device or start an emulator.
   - Use the following command to start the app:
     ```bash
     flutter run
     ```

4. **Build APK**:
   To build the APK for Android, use:
   ```bash
   flutter build apk --release
   ```

## Project Structure

The project is structured to maintain a clean and organized codebase:

```
CineTrack/
├── android/                       # Android-specific files
├── lib/
│   ├── models/                    # Data models (e.g., Movie, User)
│   ├── providers/                 # State management (e.g., MovieProvider)
│   ├── features/                   # UI screens (e.g., HomeScreen, DetailsScreen)
│   ├── services/                  # API services and data fetching logic
│   ├── cores/                      # Utility functions and helpers
│   └── main.dart                  # Entry point of the application
├── assets/                        # Images, fonts, etc.
│   ├── images/                    # Image assets (e.g., app icons, placeholders)
│   └── fonts/                     # Custom fonts
├── pubspec.yaml                   # Project dependencies and metadata
```

## Key Dependencies

- **provider**: For state management.
- **http**: For making HTTP requests to the TMDB API.
- **palette_generator**: For extracting prominent colors from images.

## Development and Contribution

Contributions are welcome! To contribute to this project:

1. **Fork the repository**: Click on the fork button at the top-right corner of this page.
2. **Create a branch**: 
   ```bash
   git checkout -b feature-name
   ```
3. **Make your changes**: Implement your feature or bug fix.
4. **Commit your changes**: 
   ```bash
   git commit -m "Description of changes"
   ```
5. **Push to the branch**: 
   ```bash
   git push origin feature-name
   ```
6. **Create a pull request**: Open a pull request from your branch to the `main` branch of the repository.

## Testing

To ensure the app runs smoothly and is bug-free, unit tests are implemented for key functionalities. To run the tests, use:

```bash
flutter test
```

This will run all the unit tests in the `test/` directory, covering the core functionalities like movie fetching, user authentication, and watchlist management.

## Issues and Support

If you encounter any issues or have any questions, please open an issue on GitHub. We value your feedback and are here to help you with any difficulties you might face.


