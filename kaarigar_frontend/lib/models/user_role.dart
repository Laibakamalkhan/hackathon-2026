enum UserRole { seeker, provider }

enum AppLanguage { romanUrdu, urdu, english }

class UserProfile {
  const UserProfile({
    this.name = 'Ayesha Khan',
    this.city = 'Islamabad',
    this.area = 'G-13',
    this.streetAddress = '',
    this.phone = '+92 300 1234567',
    this.language = AppLanguage.romanUrdu,
  });

  final String name;
  final String city;
  final String area;
  final String streetAddress;
  final String phone;
  final AppLanguage language;

  UserProfile copyWith({
    String? name,
    String? city,
    String? area,
    String? streetAddress,
    String? phone,
    AppLanguage? language,
  }) {
    return UserProfile(
      name: name ?? this.name,
      city: city ?? this.city,
      area: area ?? this.area,
      streetAddress: streetAddress ?? this.streetAddress,
      phone: phone ?? this.phone,
      language: language ?? this.language,
    );
  }
}

enum ChatFlowPhase { processing, intentSummary, followUp, complete }
