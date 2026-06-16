import 'package:flutter_test/flutter_test.dart';
import 'package:newlevelhub_mobile/core/auth/models/auth_tokens.dart';
import 'package:newlevelhub_mobile/core/auth/models/company_brief.dart';
import 'package:newlevelhub_mobile/core/auth/models/user.dart';
import 'package:newlevelhub_mobile/core/auth/models/user_role.dart';

void main() {
  group('User.fromJson', () {
    test('parses a full UserProfileSerializer payload', () {
      final user = User.fromJson({
        'id': 1,
        'email': 'user@example.com',
        'first_name': 'Анна',
        'last_name': 'Иванова',
        'full_name': 'Анна Иванова',
        'phone': '+77001234567',
        'position': 'Менеджер',
        'avatar': '/media/avatars/1.jpg',
        'role': 'company_admin',
        'company': {
          'id': 10,
          'name': 'Acme Coworking',
          'onboarding_completed': true,
        },
        'is_email_verified': true,
        'date_joined': '2024-01-01T00:00:00Z',
      });

      expect(user.id, 1);
      expect(user.email, 'user@example.com');
      expect(user.firstName, 'Анна');
      expect(user.lastName, 'Иванова');
      expect(user.fullName, 'Анна Иванова');
      expect(user.role, UserRole.companyAdmin);
      expect(
        user.company,
        const CompanyBrief(
          id: 10,
          name: 'Acme Coworking',
          onboardingCompleted: true,
        ),
      );
      expect(user.isEmailVerified, isTrue);
      expect(user.dateJoined, DateTime.parse('2024-01-01T00:00:00Z'));
    });

    test('parses an employee payload with a company, including onboarding_completed', () {
      final user = User.fromJson({
        'id': 3,
        'email': 'employee@example.com',
        'first_name': 'Пётр',
        'last_name': 'Сидоров',
        'full_name': 'Пётр Сидоров',
        'role': 'employee',
        'company': {
          'id': 5,
          'name': 'Beta Coworking',
          'onboarding_completed': false,
        },
        'is_email_verified': true,
        'date_joined': '2024-03-01T00:00:00Z',
      });

      expect(user.role, UserRole.employee);
      expect(user.company, isNotNull);
      expect(user.company!.id, 5);
      expect(user.company!.name, 'Beta Coworking');
      expect(user.company!.onboardingCompleted, isFalse);
    });

    test('parses a guest payload with null company and optional fields', () {
      final user = User.fromJson({
        'id': 2,
        'email': 'guest@example.com',
        'first_name': 'Guest',
        'last_name': 'User',
        'full_name': 'Guest User',
        'phone': null,
        'position': null,
        'avatar': null,
        'role': 'guest',
        'company': null,
        'is_email_verified': false,
        'date_joined': '2024-06-01T00:00:00Z',
      });

      expect(user.role, UserRole.guest);
      expect(user.company, isNull);
      expect(user.phone, isNull);
      expect(user.isEmailVerified, isFalse);
    });

    test('round-trips through toJson', () {
      final user = User(
        id: 1,
        email: 'user@example.com',
        firstName: 'Анна',
        lastName: 'Иванова',
        fullName: 'Анна Иванова',
        role: UserRole.employee,
        isEmailVerified: true,
        dateJoined: DateTime(2024, 1, 1),
      );

      final restored = User.fromJson(user.toJson());

      expect(restored, user);
    });
  });

  group('UserRole', () {
    test('maps every backend wire value', () {
      expect(User.fromJson(_userJson(role: 'superadmin')).role, UserRole.superadmin);
      expect(User.fromJson(_userJson(role: 'company_admin')).role, UserRole.companyAdmin);
      expect(User.fromJson(_userJson(role: 'employee')).role, UserRole.employee);
      expect(User.fromJson(_userJson(role: 'reception')).role, UserRole.reception);
      expect(User.fromJson(_userJson(role: 'service_manager')).role, UserRole.serviceManager);
      expect(User.fromJson(_userJson(role: 'guest')).role, UserRole.guest);
    });
  });

  group('AuthTokens', () {
    test('fromJson/toJson round-trip', () {
      final tokens = AuthTokens.fromJson({
        'access': 'access-jwt',
        'refresh': 'refresh-jwt',
      });

      expect(tokens.access, 'access-jwt');
      expect(tokens.refresh, 'refresh-jwt');
      expect(AuthTokens.fromJson(tokens.toJson()), tokens);
    });
  });
}

Map<String, dynamic> _userJson({required String role}) => {
      'id': 1,
      'email': 'user@example.com',
      'first_name': 'A',
      'last_name': 'B',
      'full_name': 'A B',
      'role': role,
      'company': null,
      'is_email_verified': true,
      'date_joined': '2024-01-01T00:00:00Z',
    };
