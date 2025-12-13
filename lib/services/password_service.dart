import 'dart:math';

class PasswordService {
  /// Generate a random secure password
  /// Format: 3 uppercase + 3 lowercase + 2 digits = 8 characters
  /// Example: ABCdef12
  static String generateRandomPassword() {
    const uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Excluding I, O
    const lowercase = 'abcdefghjkmnpqrstuvwxyz'; // Excluding i, l, o
    const digits = '23456789'; // Excluding 0, 1
    
    final random = Random.secure();
    final buffer = StringBuffer();
    
    // 3 uppercase letters
    for (int i = 0; i < 3; i++) {
      buffer.write(uppercase[random.nextInt(uppercase.length)]);
    }
    
    // 3 lowercase letters
    for (int i = 0; i < 3; i++) {
      buffer.write(lowercase[random.nextInt(lowercase.length)]);
    }
    
    // 2 digits
    for (int i = 0; i < 2; i++) {
      buffer.write(digits[random.nextInt(digits.length)]);
    }
    
    // Shuffle the characters
    final chars = buffer.toString().split('');
    chars.shuffle(random);
    
    return chars.join();
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    
    return null; // Password is valid
  }

  /// Get password strength (1-5)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    
    // Maximum strength is 5
    return strength > 5 ? 5 : strength;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

  /// Get password strength color
  static String getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 1:
      case 2:
        return 'red';
      case 3:
        return 'orange';
      case 4:
      case 5:
        return 'green';
      default:
        return 'red';
    }
  }
}
