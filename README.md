# 🎯 GPMS Performance Management System

A comprehensive Flutter-based Performance Management System designed for modern organizations. Built with Flutter for cross-platform compatibility, featuring a robust employee appraisal workflow with KPI reviews, behavioral assessments, and goal tracking.

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey)

## 📑 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Getting Started](#getting-started)
- [User Roles](#user-roles)
- [Performance Appraisal Workflow](#performance-appraisal-workflow)
- [Technical Stack](#technical-stack)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage Guide](#usage-guide)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

GPMS (Goal Performance Management System) is a modern, mobile-first performance management solution that streamlines the entire employee appraisal process. From goal setting to final performance reviews, GPMS provides a comprehensive platform for both employees and managers to track, assess, and improve performance.

### Key Highlights

- **📱 Mobile-First Design**: Native mobile experience with responsive web support
- **🔐 Secure Authentication**: Employee number-based login with forced password change
- **📊 70/30 Performance Model**: KPI Performance (70%) + Behavioral Standards (30%)
- **🎯 Smart Weight Calculation**: Priority-based deliverable weight distribution
- **👥 HR Admin Panel**: Comprehensive employee management and bulk import
- **💾 Offline Support**: Local data persistence with Hive database
- **🔄 Real-time Sync**: Automatic data synchronization across devices

---

## ✨ Features

### 🎯 Core Performance Management

#### **1. Goal Setting & KPI Review**
- Create and manage up to 3 organizational goals
- Add unlimited deliverables per goal with priority levels (1-3)
- Automatic weight calculation (70% total for all deliverables)
- Threshold performance targets and key results tracking
- Self-assessment and manager scoring (1-5 scale)
- Read-only mode after submission with edit capability
- Comprehensive validation before saving

#### **2. Behavioral Assessment**
- 9 standard behavioral competencies
- Self and manager scoring (1-5 scale)
- 30% contribution to overall performance rating
- Clear behavioral indicators for each competency
- Automatic score calculation and display

#### **3. Continuous Feedback**
- Ongoing feedback throughout the performance cycle
- Track feedback by quarter
- Employee and manager feedback sections
- Historical feedback archive

#### **4. Final Appraisal**
- Consolidated view of KPI performance (70%)
- Behavioral standards summary (30%)
- Overall performance rating calculation
- Professional development planning
- Manager comments and recommendations

### 👨‍💼 HR Admin Features

#### **Developer Admin Panel**
Access via hidden gesture: Tap GPMS logo 7 times on login screen

**Features:**
- 📊 Employee registry overview with statistics
- ➕ Add single employees with auto-generated passwords
- 📥 Bulk import from CSV/Excel files
- 🔍 Advanced search (name, employee number, role, department)
- 🔒 View and copy initial passwords
- 📋 Track password change status
- 💾 Export employee data to CSV
- ✏️ Edit and delete employee records
- 📱 Mobile-optimized interface

**Admin Credentials:**
- Password: `gpmsadmin2024`
- Access: Tap logo 7 times on login screen

### 🔐 Security & Authentication

#### **Password Management**
- **Auto-generated Passwords**: 12-character secure passwords (letters + numbers)
- **Forced Password Change**: First-time login requires password update
- **Strength Validation**: Minimum 8 characters, uppercase, lowercase, and numbers
- **Password Tracking**: System tracks password change status
- **Secure Storage**: Passwords stored locally with Hive encryption

#### **Authentication Flow**
1. Employee logs in with employee number and initial password
2. System forces password change on first login
3. Direct access to portal after password change
4. No additional registration required

### 📊 Data Management

#### **Organizational Structure**
- **Departments**: HR & Admin, QHSSE, Operations & Maintenance, Finance
- **Job Grades**: M1 through M7
- **Line Manager Assignment**: Hierarchical reporting structure
- **Employee Registry**: Centralized employee data management

#### **Import/Export**
- **Bulk CSV Import**: Upload multiple employees at once
- **Excel Support**: Import from Excel spreadsheets
- **CSV Export**: Download employee data with timestamps
- **Data Validation**: Automatic duplicate detection

---

## 🏗️ System Architecture

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (UI)                                     │
│  ├── Login Screen                                            │
│  ├── Home Screen (Dashboard)                                 │
│  ├── Goal Setting Screen                                     │
│  ├── KPI Review Screen                                       │
│  ├── Behavioral Assessment Screen                            │
│  ├── Feedback Screen                                         │
│  ├── Final Appraisal Screen                                  │
│  └── Developer Admin Panel                                   │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer                                        │
│  ├── AppProvider (State Management)                          │
│  ├── AuthService (Authentication)                            │
│  ├── EmployeeRegistryService                                 │
│  └── PasswordService                                         │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│  ├── Models (Employee, Goal, Feedback, etc.)                 │
│  └── Hive Local Database                                     │
│     ├── employees_box                                        │
│     ├── auth_box                                             │
│     ├── goals_box                                            │
│     └── registry_box                                         │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Input → UI Components → Provider → Service Layer → Hive DB
                                 ↓
                          State Updates
                                 ↓
                          UI Re-renders
```

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.35.4 or higher
- **Dart SDK**: 3.9.2 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### Quick Start

```bash
# Clone the repository
git clone https://github.com/Roskobby/GPMS-Performance-Management-System.git

# Navigate to project directory
cd GPMS-Performance-Management-System

# Install dependencies
flutter pub get

# Run on web (for quick preview)
flutter run -d chrome

# Run on Android device/emulator
flutter run

# Build release APK
flutter build apk --release
```

---

## 👥 User Roles

### 1. **Employee**
- Set personal performance goals
- Track deliverables and key results
- Complete self-assessments (KPI + Behavioral)
- Provide continuous feedback
- View performance history
- Change password

### 2. **Line Manager**
- All employee capabilities
- Rate subordinate's KPI deliverables (1-5 scale)
- Complete behavioral assessments for team members
- Provide manager feedback
- View team performance overview

### 3. **HR Administrator**
- Access Developer Admin Panel
- Manage employee registry
- Add/edit/delete employees
- Bulk import from CSV/Excel
- Generate and distribute initial passwords
- Export employee data
- Monitor password change status
- System configuration

---

## 🔄 Performance Appraisal Workflow

### Annual Performance Cycle

```
┌──────────────────────────────────────────────────────────────┐
│                     Q1: Goal Setting                         │
│  • Set 3 organizational goals                                │
│  • Define deliverables with priorities (1-3)                 │
│  • Set threshold performance targets                         │
│  • Submit for manager approval                               │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│              Q2-Q4: Continuous Monitoring                    │
│  • Track progress on deliverables                            │
│  • Provide/receive ongoing feedback                          │
│  • Update key results achieved                               │
│  • Quarterly feedback sessions                               │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│              Q4: Mid-Year/End-Year Review                    │
│  • Employee self-scoring (1-5) on deliverables               │
│  • Document key results achieved                             │
│  • Complete behavioral self-assessment                       │
│  • Submit for manager review                                 │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│              Manager Assessment                              │
│  • Manager scores each deliverable (1-5)                     │
│  • Manager completes behavioral assessment                   │
│  • Add manager feedback and comments                         │
│  • Submit final assessment                                   │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│              Final Appraisal                                 │
│  • KPI Performance: 70% (weighted deliverables)              │
│  • Behavioral Standards: 30%                                 │
│  • Overall Performance Rating                                │
│  • Professional development planning                         │
│  • Next cycle goal setting                                   │
└──────────────────────────────────────────────────────────────┘
```

### Performance Rating Scale

| Score | Rating | Description |
|-------|--------|-------------|
| **5** | Excellent | Threshold far exceeded with exceptional results |
| **4** | Above Average | Threshold clearly exceeded, exceeds expectations |
| **3** | Average/Good | Threshold target achieved, meets expectations |
| **2** | Below Average | Performance partially meets expectations |
| **1** | Needs Improvement | Performance significantly below expectations |

### Performance Calculation

**Overall Performance = (KPI Score × 70%) + (Behavioral Score × 30%)**

#### KPI Performance (70%)
- Each deliverable has a weight based on priority
- Formula: `Weight = 70% × Priority ÷ Sum(All Priorities)`
- Score = Σ(Deliverable Score × Weight)
- Maximum: 70%

#### Behavioral Assessment (30%)
- 9 competencies scored 1-5
- Average score calculated
- Normalized to 30% of overall rating
- Maximum: 30%

---

## 🛠️ Technical Stack

### Frontend Framework
- **Flutter**: 3.35.4 - Cross-platform UI framework
- **Dart**: 3.9.2 - Programming language
- **Material Design 3**: Modern UI components

### State Management
- **Provider**: 6.1.5+1 - State management solution
- **ChangeNotifier**: Reactive state updates

### Local Storage
- **Hive**: 2.2.3 - Fast, lightweight NoSQL database
- **Hive Flutter**: 1.1.0 - Flutter integration
- **Shared Preferences**: 2.5.3 - Key-value storage

### Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: 6.1.5+1
  
  # Local Storage
  hive: 2.2.3
  hive_flutter: 1.1.0
  shared_preferences: 2.5.3
  
  # Networking
  http: 1.5.0
  
  # UI Components
  cupertino_icons: ^1.0.8
  
  # CSV Processing (for import/export)
  csv: ^6.0.0
```

### Platform Support
- ✅ **Android**: Native Android apps (API 21+)
- ✅ **iOS**: Native iOS apps (iOS 12+)
- ✅ **Web**: Progressive web app
- ✅ **Windows**: Desktop application
- ✅ **macOS**: Desktop application
- ✅ **Linux**: Desktop application

---

## 📱 Screenshots

### Employee Experience

#### Login Screen
- Employee number-based authentication
- Secure password entry
- Hidden admin panel access (tap logo 7 times)

#### Home Dashboard
- Performance cycle overview
- Quick access to all appraisal sections
- Current year selection

#### Goal Setting
- Create up to 3 goals
- Add/delete deliverables dynamically
- Priority selection (1-3)
- Automatic weight calculation
- Validation before saving

#### KPI Review
- View all goals and deliverables
- Enter key results achieved
- Self-scoring (1-5 scale)
- Manager scoring section
- Real-time score calculation
- Read-only mode after save
- Edit button to unlock

#### Behavioral Assessment
- 9 standard competencies
- Self and manager scoring
- Clear behavioral indicators
- 30% weight display

### HR Admin Experience

#### Admin Panel
- Employee statistics dashboard
- Search functionality (name, number, role, dept)
- Initial password display
- Password change status tracking
- Bulk import interface
- CSV export functionality

---

## 📥 Installation

### For End Users (APK Installation)

1. **Download APK**
   - Get the latest APK from releases
   - Or build from source (see Development section)

2. **Enable Unknown Sources**
   - Go to Settings → Security
   - Enable "Install from Unknown Sources"

3. **Install APK**
   - Open the downloaded APK file
   - Follow installation prompts
   - Launch GPMS

### For Developers

See [Development](#development) section below.

---

## ⚙️ Configuration

### Initial Setup

1. **Admin Panel Setup**
   - Launch application
   - On login screen, tap GPMS logo 7 times
   - Enter admin password: `gpmsadmin2024`
   - Load sample employees or import your data

2. **Employee Data Import**
   
   **CSV Format:**
   ```csv
   Employee Number,Name,Designation,Job Grade,Department,Line Manager,Email
   GPMS0001,John Doe,Manager,M5,HR & Admin,GPMS0000,john.doe@company.com
   GPMS0002,Jane Smith,Executive,M3,Finance,GPMS0001,jane.smith@company.com
   ```

3. **Department Configuration**
   - HR & Admin
   - QHSSE
   - Operations & Maintenance
   - Finance

4. **Job Grade Structure**
   - M1: Entry Level
   - M2: Junior Level (Manager eligible)
   - M3: Mid Level
   - M4: Senior Level
   - M5: Management Level (Manager eligible)
   - M6: Senior Management
   - M7: Executive Level

### Environment Variables

No external environment variables required. All configuration is managed internally through the application.

---

## 📖 Usage Guide

### For Employees

#### First Login
1. Receive employee number and initial password from HR
2. Login with credentials
3. System will force password change
4. Set a strong password (8+ chars, uppercase, lowercase, numbers)
5. Access portal directly after password change

#### Setting Goals
1. Navigate to **Goal Setting** from home screen
2. Fill in goal descriptions
3. Add deliverables for each goal
4. Set priority (1-3) for each deliverable
5. Define threshold performance
6. Weights are calculated automatically
7. Save goals

#### KPI Review (End of Year)
1. Navigate to **KPI Review**
2. For each deliverable:
   - Enter **Key Results Achieved**
   - Score yourself (1-5)
3. Review scoring guidelines (help icon)
4. Save KPI Review
5. Review becomes read-only (can edit if needed)

#### Behavioral Assessment
1. Navigate to **Behavioral Assessment**
2. Read each competency description
3. Score yourself (1-5) for each
4. Save assessment

### For Managers

#### Rating Subordinates
1. Navigate to KPI Review or Behavioral Assessment
2. View employee's self-assessment
3. Review key results and evidence
4. Provide manager scores (1-5)
5. Add feedback and comments
6. Submit assessment

### For HR Administrators

#### Adding Single Employee
1. Access Developer Admin Panel
2. Tap "Add Employee" (+ button)
3. Fill in employee details
4. System generates initial password
5. Copy password and share with employee

#### Bulk Import
1. Access Developer Admin Panel
2. Tap "Bulk Import" icon
3. Select CSV or Excel file
4. Review import preview
5. Confirm import
6. System generates passwords for all employees

#### Exporting Data
1. Access Developer Admin Panel
2. Tap "Export Data" icon (download)
3. CSV file downloads automatically
4. File includes all employee data and passwords

---

## 👨‍💻 Development

### Development Environment Setup

```bash
# Install Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor -v

# Clone repository
git clone https://github.com/Roskobby/GPMS-Performance-Management-System.git
cd GPMS-Performance-Management-System

# Install dependencies
flutter pub get

# Run on web (hot reload enabled)
flutter run -d chrome

# Run on Android emulator
flutter emulators --launch <emulator_id>
flutter run

# Run on physical device
flutter devices
flutter run -d <device_id>
```

### Project Structure

```
lib/
├── main.dart                      # Application entry point
├── models/                        # Data models
│   ├── employee.dart
│   ├── employee_registry.dart
│   ├── goal.dart
│   ├── feedback.dart
│   ├── behavioral_standard.dart
│   ├── appraisal.dart
│   └── professional_development.dart
├── screens/                       # UI screens
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── goal_setting_screen.dart
│   ├── kpi_review_screen.dart
│   ├── behavioral_assessment_screen.dart
│   ├── feedback_screen.dart
│   ├── final_appraisal_screen.dart
│   ├── change_password_screen.dart
│   ├── help_screen.dart
│   ├── developer_admin_panel.dart
│   └── bulk_import_dialog.dart
├── services/                      # Business logic
│   ├── auth_service.dart
│   ├── employee_registry_service.dart
│   └── password_service.dart
├── providers/                     # State management
│   └── app_provider.dart
└── utils/                         # Utilities
    ├── hive_setup.dart
    └── gpms_org_structure.dart
```

### Code Quality

```bash
# Run code analysis
flutter analyze

# Format code
dart format .

# Fix auto-fixable issues
dart fix --apply

# Run tests
flutter test
```

### Building for Production

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS app (requires macOS)
flutter build ios --release

# Build Web app
flutter build web --release
```

### Debugging Tips

1. **Enable Debug Mode**
   ```dart
   // In main.dart
   debugShowCheckedModeBanner: true,
   ```

2. **Hot Reload**
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart

3. **Flutter DevTools**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

4. **Logging**
   ```dart
   import 'package:flutter/foundation.dart';
   
   if (kDebugMode) {
     debugPrint('Debug message');
   }
   ```

---

## 🤝 Contributing

We welcome contributions to GPMS! Here's how you can help:

### Reporting Issues

1. Check existing issues first
2. Use issue templates
3. Provide detailed information:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots if applicable
   - Device/platform information

### Pull Requests

1. Fork the repository
2. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Follow code style guidelines
5. Test thoroughly
6. Commit with clear messages
   ```bash
   git commit -m "Add feature: description"
   ```
7. Push to your fork
8. Create a Pull Request

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write unit tests for new features

---

## 📋 Roadmap

### Version 1.1 (Planned)
- [ ] Professional Development section implementation
- [ ] Manager dashboard for team overview
- [ ] Export to PDF functionality
- [ ] Email notifications
- [ ] Multi-language support

### Version 1.2 (Future)
- [ ] Firebase integration for cloud sync
- [ ] Advanced analytics and reporting
- [ ] Mobile push notifications
- [ ] Calendar integration
- [ ] Training module integration

### Version 2.0 (Vision)
- [ ] AI-powered performance insights
- [ ] Automated goal suggestions
- [ ] Skill gap analysis
- [ ] Career path recommendations
- [ ] 360-degree feedback

---

## 🐛 Known Issues

1. **Web Platform**: dart:html warnings for Wasm builds (non-critical)
2. **Android**: Requires API level 21+ (Android 5.0+)
3. **CSV Export**: Large datasets (1000+ employees) may take time

See [Issues](https://github.com/Roskobby/GPMS-Performance-Management-System/issues) for complete list.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 GPMS Performance Management System

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions...
```

---

## 📞 Support

### Documentation
- 📚 [User Guide](docs/USER_GUIDE.md)
- 🔧 [Admin Guide](docs/ADMIN_GUIDE.md)
- 💻 [Developer Guide](docs/DEVELOPER_GUIDE.md)

### Contact
- 📧 Email: support@gpms.com
- 🐛 Issues: [GitHub Issues](https://github.com/Roskobby/GPMS-Performance-Management-System/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/Roskobby/GPMS-Performance-Management-System/discussions)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for UI guidelines
- Hive team for the excellent local database
- All contributors to this project

---

## 📊 Project Stats

![GitHub repo size](https://img.shields.io/github/repo-size/Roskobby/GPMS-Performance-Management-System)
![GitHub last commit](https://img.shields.io/github/last-commit/Roskobby/GPMS-Performance-Management-System)
![GitHub issues](https://img.shields.io/github/issues/Roskobby/GPMS-Performance-Management-System)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Roskobby/GPMS-Performance-Management-System)

---

<div align="center">

**Built with ❤️ using Flutter**

[Report Bug](https://github.com/Roskobby/GPMS-Performance-Management-System/issues) • [Request Feature](https://github.com/Roskobby/GPMS-Performance-Management-System/issues) • [Documentation](docs/)

</div>
