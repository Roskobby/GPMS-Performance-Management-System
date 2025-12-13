# Security Policy

## Overview

This document outlines the security considerations, known vulnerabilities, and recommendations for the GPMS Performance Management System.

## Current Security Status

⚠️ **Development Stage**: This application is currently in development and contains several security vulnerabilities that **MUST** be addressed before production deployment.

---

## Known Security Issues

### 🔴 Critical Issues (Must Fix Before Production)

#### 1. Plain Text Password Storage
**Status**: Known Issue  
**Severity**: CRITICAL  
**Location**: `lib/services/auth_service.dart`, `lib/models/employee.dart`

**Issue**: User passwords are stored in plain text in the local Hive database without any encryption or hashing.

**Risk**: 
- If the device is compromised, all user passwords are exposed
- Passwords can be read directly from the local storage
- No protection against data breaches

**Mitigation Plan**:
```dart
// Use a secure hashing library
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Hash passwords before storage
String hashPassword(String password, String salt) {
  final bytes = utf8.encode(password + salt);
  return sha256.convert(bytes).toString();
}

// Store only the hash
employee.passwordHash = hashPassword(password, salt);
```

**Recommended Packages**:
- `crypto` for SHA-256 hashing (minimum)
- `bcrypt` for more secure password hashing (recommended)
- `pointycastle` for encryption (if needed)

---

#### 2. Hardcoded Admin Credentials
**Status**: Known Issue  
**Severity**: HIGH  
**Location**: `lib/screens/login_screen.dart:296`

**Issue**: Developer admin panel password is hardcoded in source code.

```dart
final _devPassword = 'gpmsadmin2024'; // Hardcoded - INSECURE!
```

**Risk**:
- Anyone with access to the source code or decompiled APK can access admin panel
- Cannot change password without rebuilding the app
- No audit trail for admin access

**Recommended Solutions**:

**Option 1: Use Employee Registry for Admin Access**
```dart
// Check if employee has admin role
Future<bool> isAdmin() async {
  final currentUser = await getCurrentUser();
  if (currentUser == null) return false;
  
  // Check against admin employee numbers or roles
  return currentUser.designation.contains('General Manager') ||
         currentUser.designation.contains('HR & Admin Manager');
}
```

**Option 2: Environment Variables (Recommended for Production)**
```dart
// Use flutter_dotenv for environment variables
import 'package:flutter_dotenv/flutter_dotenv.dart';

final adminPassword = dotenv.env['ADMIN_PASSWORD'];
```

**Option 3: Remove Admin Panel from Production Builds**
```dart
// Only include admin panel in debug builds
if (kDebugMode) {
  // Show admin panel access
}
```

---

### 🟡 Medium Priority Issues

#### 3. Insufficient Password Complexity
**Status**: Partially Addressed  
**Severity**: MEDIUM

**Current Requirements**:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number

**Recommendations**:
- Increase minimum length to 12 characters
- Require special characters
- Check against common password lists
- Implement password strength meter
- Enforce password history (prevent reuse)

---

#### 4. No Session Timeout
**Status**: Open  
**Severity**: MEDIUM

**Issue**: User sessions do not expire, allowing indefinite access if device is left unlocked.

**Recommendation**:
```dart
// Implement session timeout
class SessionManager {
  static const Duration sessionTimeout = Duration(minutes: 30);
  DateTime? _lastActivity;
  
  bool isSessionValid() {
    if (_lastActivity == null) return false;
    return DateTime.now().difference(_lastActivity!) < sessionTimeout;
  }
  
  void updateActivity() {
    _lastActivity = DateTime.now();
  }
}
```

---

#### 5. No Rate Limiting on Login Attempts
**Status**: Open  
**Severity**: MEDIUM

**Issue**: No protection against brute force login attempts.

**Recommendation**:
```dart
// Implement login attempt limiting
class LoginAttemptTracker {
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  final Map<String, LoginAttempts> _attempts = {};
  
  bool canAttemptLogin(String employeeNumber) {
    final attempts = _attempts[employeeNumber];
    if (attempts == null) return true;
    
    if (attempts.isLockedOut) {
      if (DateTime.now().difference(attempts.lockoutTime!) > lockoutDuration) {
        _attempts.remove(employeeNumber);
        return true;
      }
      return false;
    }
    
    return attempts.count < maxAttempts;
  }
}
```

---

### 🔵 Low Priority Issues

#### 6. No Input Sanitization
**Status**: Open  
**Severity**: LOW to MEDIUM

**Issue**: User inputs are not sanitized, which could lead to injection vulnerabilities or data corruption.

**Recommendation**:
- Sanitize all text inputs
- Validate input formats (email, employee number, etc.)
- Use Flutter's built-in validators
- Implement length limits

```dart
String sanitizeInput(String input) {
  // Remove leading/trailing whitespace
  input = input.trim();
  
  // Remove any HTML/script tags (if applicable)
  input = input.replaceAll(RegExp(r'<[^>]*>'), '');
  
  // Limit length
  if (input.length > 500) {
    input = input.substring(0, 500);
  }
  
  return input;
}
```

---

## Data Security

### Local Storage

**Current Implementation**: Hive database (unencrypted)

**Risks**:
- Data can be accessed if device is rooted/jailbroken
- No encryption at rest
- Passwords stored in plain text

**Recommendations**:

1. **Enable Hive Encryption**:
```dart
import 'package:hive/hive.dart';

// Generate encryption key (store securely)
final encryptionKey = Hive.generateSecureKey();

// Open encrypted box
await Hive.openBox('employees', encryptionCipher: HiveAesCipher(encryptionKey));
```

2. **Encrypt Sensitive Fields**:
```dart
// Encrypt passwords before storage
import 'package:encrypt/encrypt.dart';

final key = Key.fromSecureRandom(32);
final iv = IV.fromSecureRandom(16);
final encrypter = Encrypter(AES(key));

final encrypted = encrypter.encrypt(password, iv: iv);
employee.password = encrypted.base64;
```

3. **Use Secure Storage for Keys**:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'encryption_key', value: encryptionKey);
```

---

## Network Security

**Current Status**: No network communication (local-only app)

**Future Considerations** (if adding backend):
- Use HTTPS/TLS for all communications
- Implement certificate pinning
- Validate SSL certificates
- Use secure API authentication (JWT, OAuth)
- Implement request signing
- Add CSRF protection

---

## Access Control

### Current Implementation
- Employee number + password authentication
- Role-based access (implicit through job titles)
- Admin panel with separate password

### Recommendations

1. **Implement Proper RBAC**:
```dart
enum UserRole {
  employee,
  manager,
  hrAdmin,
  systemAdmin,
}

class Permission {
  static const viewOwnData = 'view_own_data';
  static const editOwnGoals = 'edit_own_goals';
  static const viewTeamData = 'view_team_data';
  static const manageEmployees = 'manage_employees';
  static const systemSettings = 'system_settings';
}

class RolePermissions {
  static final Map<UserRole, Set<String>> permissions = {
    UserRole.employee: {
      Permission.viewOwnData,
      Permission.editOwnGoals,
    },
    UserRole.manager: {
      Permission.viewOwnData,
      Permission.editOwnGoals,
      Permission.viewTeamData,
    },
    UserRole.hrAdmin: {
      Permission.manageEmployees,
    },
  };
}
```

2. **Audit Logging**:
```dart
// Log all security-relevant actions
class AuditLog {
  static Future<void> logAction({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'action': action,
      'metadata': metadata,
    };
    
    // Store in separate audit box
    final auditBox = await Hive.openBox('audit_logs');
    await auditBox.add(log);
  }
}
```

---

## Data Privacy

### Personal Information Handling

**Current Data Stored**:
- Employee number
- Full name
- Email address
- Department
- Job title
- Performance data
- Feedback

**Recommendations**:

1. **Data Minimization**: Only collect necessary information
2. **Data Retention**: Implement data retention policies
3. **Right to Deletion**: Allow users to request data deletion
4. **Data Export**: Provide data export functionality (already partially implemented)

---

## Secure Development Practices

### Code Review Checklist

Before deploying to production, ensure:

- [ ] All passwords are hashed (bcrypt/argon2)
- [ ] Hardcoded credentials removed
- [ ] Input validation on all user inputs
- [ ] Output encoding to prevent XSS (if web)
- [ ] Proper error handling (no sensitive info in errors)
- [ ] Audit logging for security events
- [ ] Session management implemented
- [ ] Rate limiting on authentication
- [ ] Encryption enabled on Hive boxes
- [ ] Sensitive data encrypted at rest
- [ ] Code obfuscation enabled for releases
- [ ] Debug mode disabled in production builds

---

## Build Security

### Release Configuration

```bash
# Build with code obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Build with ProGuard (Android)
flutter build apk --release --shrink

# Verify debug mode is disabled
grep -r "kDebugMode" lib/
```

### ProGuard Rules (Android)
```proguard
# Keep Hive classes
-keep class * extends hive.** { *; }
-keepclassmembers class * extends hive.HiveObject { *; }

# Keep model classes
-keep class com.yourcompany.gpms.models.** { *; }
```

---

## Incident Response

### Security Incident Reporting

If you discover a security vulnerability:

1. **Do NOT** create a public GitHub issue
2. Email security concerns to: [security@gpms.com]
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Expected Response Time
- Critical: 24 hours
- High: 72 hours
- Medium: 1 week
- Low: 2 weeks

---

## Security Updates

### Current Version
**Version**: 1.0.0  
**Last Security Review**: 2025-12-13  
**Status**: Development - NOT PRODUCTION READY

### Known Vulnerabilities
See "Known Security Issues" section above.

### Update Policy
- Security patches will be released as soon as available
- Critical vulnerabilities will be addressed immediately
- All security updates will be documented in CHANGELOG.md

---

## Compliance Considerations

### Data Protection
- Consider GDPR compliance if handling EU citizen data
- Implement data protection by design
- Maintain data processing records
- Implement breach notification procedures

### Employment Law
- Ensure performance data handling complies with employment laws
- Implement fair access controls
- Maintain audit trails for performance reviews
- Provide transparency in data usage

---

## Security Testing

### Recommended Tests

1. **Authentication Tests**:
   - Brute force protection
   - Session management
   - Password policy enforcement

2. **Authorization Tests**:
   - Role-based access control
   - Privilege escalation attempts
   - Direct object reference

3. **Data Security Tests**:
   - Encryption verification
   - Data leakage checks
   - Secure storage validation

4. **Code Security Tests**:
   - Static code analysis
   - Dependency vulnerability scanning
   - Secrets detection in code

### Recommended Tools

- `flutter analyze` - Code analysis
- `dart analyze` - Dart static analysis
- OWASP Mobile Security Testing Guide
- MobSF - Mobile Security Framework

---

## References

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [Dart Security](https://dart.dev/guides/security)
- [NIST Password Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html)

---

## Changelog

### 2025-12-13
- Initial security policy created
- Documented known vulnerabilities
- Added security recommendations
- Created incident response process

---

**Last Updated**: 2025-12-13  
**Version**: 1.0  
**Status**: Active
