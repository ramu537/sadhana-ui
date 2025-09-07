# Sadhana App 🕉️

A beautiful Flutter mobile application designed to help ISKCON devotees track their daily spiritual practices (sadhana). This app provides an intuitive interface to monitor japa meditation, scriptural reading, lecture hearing, and devotee association.

## Features ✨

### 🌟 Splash Screen
- **Beautiful app branding** with orange-to-red gradient
- **Animated logo** with scaling and rotation effects
- **Sanskrit greeting** with "Hare Krishna" mantra
- **Progressive loading** with dynamic status messages
- **Service initialization** for auth and data loading
- **Smooth transitions** to main app

### 🏠 Home Dashboard
- **Personal greeting** based on time of day and user profile
- **Today's Inspiration** - Daily spiritual quotes from Srila Prabhupada and scriptures
- **Streak tracking** with fire icon to maintain motivation
- **Daily sadhana overview** with rounds progress and visual indicators
- **Quick actions** for easy navigation (Log Sadhana, Events)
- **Profile picture display** with initials fallback

### 📝 Sadhana Logging
- Track **rounds chanted** (japa meditation) with time-of-day breakdown
- Record **reading time** (Bhagavatam, Bhagavad Gita, etc.)
- Log **hearing time** (spiritual discourses and lectures)
- Track **service hours** and temple programs
- **Time-based japa tracking** (morning, afternoon, evening, night)
- **Notes and reflections** for each entry

### 📊 Progress & Analytics
- **Monthly analytics dashboard** with comprehensive insights
- **Chanting time analysis** - Distribution across morning, afternoon, evening, night
- **Reading vs Hearing balance** with progress toward monthly goals (600 min targets)
- **Consistency tracking** showing active days percentage and streak analysis
- **Study insights** and recommendations based on practice patterns
- **Historical data** with visual calendar and recent activity view
- **Goal achievement tracking** with progress indicators

### 🎉 Community Events & RSVP
- **Event listings** with dates, locations, and descriptions
- **RSVP with attendee count** - Specify how many family members attending
- **Real-time capacity tracking** with visual progress indicators
- **Admin dashboard** for congregation leaders:
  - View all confirmed families and total attendee counts
  - Export attendee lists for planning purposes
  - Monitor event capacity and prevent over-booking
- **Dynamic RSVP management** with confirmation messages
- **Event types**: Sunday Feast, Study Circles, Festivals, Special Programs

### 👤 User Profile & Admin
- **Profile picture upload** with camera/gallery selection and initials fallback
- **Personal information** management (name, temple, location)
- **Admin privileges toggle** for congregation management access
- **Google Sign-In integration** with demo mode fallback
- **Comprehensive statistics** overview and achievements
- **App settings** and preferences management
- **Secure logout** with confirmation dialog

## Screenshots 📱

The app features a modern, clean design with:
- Orange primary theme color (#FF6B35)
- Card-based layout with subtle shadows
- Progress indicators and visual feedback
- Intuitive navigation with bottom tabs

## Installation & Setup 🚀

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Chrome (for web development)

### Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sadhana_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For iOS:**
   ```bash
   flutter run -d ios
   ```
   
   **For Android:**
   ```bash
   flutter run -d android
   ```

4. **Build for production**
   
   **Web:**
   ```bash
   flutter build web
   ```
   
   **iOS:**
   ```bash
   flutter build ios
   ```
   
   **Android:**
   ```bash
   flutter build apk
   ```

## Dependencies 📦

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  provider: ^6.1.2          # State management
  shared_preferences: ^2.2.3 # Local data storage
  intl: ^0.19.0             # Date formatting
```

## App Architecture 🏗️

### State Management
- **Provider pattern** for reactive state management
- **SadhanaModel** as the main data model
- **Persistent storage** using SharedPreferences

### Project Structure
```
lib/
  ├── main.dart              # App entry point
  ├── models/
  │   └── sadhana_model.dart # Data models and state management
  └── screens/
      ├── home_screen.dart    # Main dashboard
      ├── log_screen.dart     # Sadhana logging
      ├── events_screen.dart  # Community events
      ├── progress_screen.dart # Statistics and progress
      └── profile_screen.dart # User profile and settings
```

### Data Models

**SadhanaData**
- `rounds`: Number of japa rounds chanted
- `readingMinutes`: Time spent in scriptural reading
- `lectureMinutes`: Time spent hearing lectures
- `devoteesMet`: Number of devotees associated with
- `date`: Date of the sadhana entry

**UserProfile**
- `name`: User's spiritual name
- `temple`: ISKCON temple affiliation
- `location`: Geographic location

## Key Features Implementation 🔧

### Streak Tracking
- Automatic calculation based on consecutive days
- Visual streak display with gradient background
- Motivation through gamification

### Data Persistence
- Local storage using SharedPreferences
- Automatic daily reset functionality
- Historical data preservation

### Progress Visualization
- Linear progress indicators for goals
- Color-coded categories for different practices
- Statistical calculations and averages

### Responsive Design
- Material Design 3 components
- Adaptive layouts for different screen sizes
- Smooth animations and transitions

## Spiritual Practices Tracked 🙏

1. **Japa Meditation (Rounds Chanted)**
   - Target: 16 rounds daily
   - Progress indicator shows completion percentage
   - Color: Orange

2. **Scriptural Reading**
   - Track minutes spent reading sacred texts
   - Includes Bhagavatam, Bhagavad Gita, etc.
   - Color: Blue

3. **Lecture Hearing**
   - Time spent listening to spiritual discourses
   - Helps in philosophical understanding
   - Color: Green

4. **Devotee Association**
   - Number of devotees met for satsang
   - Encourages community participation
   - Color: Purple

## Customization 🎨

### Theme Colors
The app uses a warm orange theme (#FF6B35) representing:
- Spiritual energy and devotion
- Warmth of the devotee community
- Vibrant spiritual life

### Localization
Ready for internationalization with:
- Date formatting using `intl` package
- Flexible text structures
- Cultural considerations for ISKCON practices

## Future Enhancements 🚀

- **Push notifications** for sadhana reminders
- **Cloud sync** for data backup across devices
- **Community features** for connecting with other devotees
- **Advanced analytics** with charts and trends
- **Goal setting** with customizable targets
- **Offline mode** for areas with poor connectivity

## Contributing 🤝

This app is built for the ISKCON devotee community. Contributions are welcome from developers who understand the spiritual context and requirements.

### Development Guidelines
- Follow Flutter best practices
- Maintain the spiritual theme and context
- Test on multiple devices and platforms
- Consider the needs of devotees worldwide

## Support 💬

For support, feature requests, or spiritual guidance integration:
- Create an issue in the repository
- Contact the ISKCON technology team
- Join our developer community discussions

## About ISKCON 🌺

The International Society for Krishna Consciousness (ISKCON) is a worldwide spiritual movement based on the ancient Vedic scriptures of India. This app supports the daily spiritual practices taught by ISKCON's founder, Srila Prabhupada.

---

**Made with ❤️ for the devotee community**

*Version 1.0.0*

Hare Krishna! 🙏
