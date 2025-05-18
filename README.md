## Tech Stack

- **Frontend Framework**: Flutter (SDK ^3.7.2)
- **State Management**: Provider (^6.1.5)
- **Backend/Database**: Firebase
  - Firebase Core (^3.13.0)
  - Cloud Firestore (^5.6.7)
  - Firebase Authentication (^5.5.3)
- **Additional Dependencies**:
  - Flutter DateTime Picker Plus (^2.2.0)
  - Shared Preferences (^2.5.3)
  - Mailer (^6.4.1)
  - Cupertino Icons (^1.0.8)
  
  **screenshots** 
![Alt text](screenshots/screenshot-1.jpeg?raw=true "login")
![Alt text](screenshots/screenshot-2.jpeg?raw=true "register")
![Alt text](screenshots/screenshot-3.jpeg?raw=true "dashbaord")
![Alt text](screenshots/screenshot-4.jpeg?raw=true "selecting date and time")
![Alt text]( screenshots/screenshot-5.jpeg?raw=true "booked an appointment")
![Alt text](screenshots/email-sample.jpeg?raw=true "confirmation mail sample")
![Alt text](screenshots/screenshot-6.jpeg?raw=true "confirmed appointment")
![Alt text](screenshots/screenshot-7.jpeg?raw=true "dashbaord2")


## Setup Instructions

### Prerequisites

1. Install [Flutter](https://flutter.dev/docs/get-started/install) (SDK version ^3.7.2)
2. Install [Git](https://git-scm.com/downloads)
3. Set up your preferred IDE (VS Code or Android Studio recommended)
4. Set up a Firebase project (for backend services)
5. Gmail account for email service (with App Password enabled)

### Installation Steps

1. Clone the repository:
   
   git clone [repository-url]
   cd auto_services

2. Install dependencies:
   
   flutter pub get

3. Configure Firebase:
   - Create a new project in Firebase Console
   - Add your Android/iOS app to Firebase project
   - Download and place the configuration files:
     - For Android: `google-services.json` in `android/app/`
     - For iOS: `GoogleService-Info.plist` in `ios/Runner/`

4. Configure Email Service:
   - Go to your Google Account settings
   - Enable 2-Step Verification if not already enabled
   - Generate an App Password:
     1. Go to Security settings
     2. Select 'App Passwords' under 2-Step Verification
     3. Generate a new app password for 'Mail'
   - Create a `.env` file in the project root with:
     
     EMAIL_USERNAME=your.email@gmail.com
     EMAIL_PASSWORD=your-16-digit-app-password
     

5. Run the app:
    flutter run
   

## Development

- Use `flutter run` for development
- Use `flutter build` for production builds

## Features

- User authentication
- Automotive service management
- Date and time scheduling
- Email notifications
- Local data persistence


For support, please contact the Me, if raise an issue in the repository.

