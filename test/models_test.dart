import 'package:flutter_test/flutter_test.dart';
import 'package:stint/models/app_user.dart';
import 'package:stint/models/opportunity.dart';
import 'package:stint/models/startup.dart';
import 'package:stint/providers/auth_provider.dart';

void main() {
  group('Opportunity.matchCount', () {
    final opportunity = Opportunity(
      id: 'o1',
      startupId: 's1',
      startupName: 'Kigali Grocers',
      title: 'Flutter Developer Intern',
      description: 'Build our mobile app.',
      category: 'Software Development',
      requiredSkills: const ['Flutter', 'UI/UX Design', 'Data Analysis'],
      commitment: 'Part-time',
      deadline: DateTime(2030),
      createdAt: DateTime(2026),
    );

    test('counts overlapping skills case-insensitively', () {
      expect(opportunity.matchCount(['flutter', 'Data Analysis']), 2);
    });

    test('returns zero when nothing overlaps', () {
      expect(opportunity.matchCount(['Photography']), 0);
    });

    test('returns zero for a student with no skills', () {
      expect(opportunity.matchCount([]), 0);
    });
  });

  group('Email validation by role', () {
    test('accepts an @alustudent.com address for students', () {
      expect(
        AuthProvider.validateEmailForRole(
            'm.ihozo@alustudent.com', UserRole.student),
        isNull,
      );
    });

    test('rejects other domains for students', () {
      expect(
        AuthProvider.validateEmailForRole(
            'someone@gmail.com', UserRole.student),
        isNotNull,
      );
    });

    test('accepts any valid email for founders', () {
      expect(
        AuthProvider.validateEmailForRole(
            'founder@venture.rw', UserRole.founder),
        isNull,
      );
    });

    test('rejects malformed emails for founders', () {
      expect(
        AuthProvider.validateEmailForRole('not-an-email', UserRole.founder),
        isNotNull,
      );
    });

    test('rejects empty input', () {
      expect(
        AuthProvider.validateEmailForRole('  ', UserRole.student),
        isNotNull,
      );
    });
  });

  group('Startup initials', () {
    Startup startup(String name) => Startup(
          id: 's1',
          ownerUid: 'u1',
          name: name,
          sector: 'EdTech',
          stage: 'MVP',
          description: 'desc',
          createdAt: DateTime(2026),
        );

    test('two-word name gives two letters', () {
      expect(startup('Kigali Grocers').initials, 'KG');
    });

    test('single-word name gives one letter', () {
      expect(startup('Zando').initials, 'Z');
    });
  });

  test('new startups start unverified', () {
    final startup = Startup(
      id: 's1',
      ownerUid: 'u1',
      name: 'Test',
      sector: 'Other',
      stage: 'Idea',
      description: 'desc',
      createdAt: DateTime(2026),
    );
    expect(startup.verificationStatus, VerificationStatus.pending);
    expect(startup.isVerified, isFalse);
  });
}
