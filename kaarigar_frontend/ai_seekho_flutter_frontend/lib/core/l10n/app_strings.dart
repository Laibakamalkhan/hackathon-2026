import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_role.dart';
import '../providers/app_providers.dart';

/// Localized copy for KARIGAR — driven by selected [AppLanguage].
class S {
  S(this.lang);

  final AppLanguage lang;

  String get appName => 'KARIGAR';

  String get taglineUrdu => switch (lang) {
        AppLanguage.urdu => 'اپنی زندگی آسان کرو',
        _ => 'اپنی زندگی آسان کرو',
      };

  String get taglineRoman => switch (lang) {
        AppLanguage.english => 'Make life easier',
        AppLanguage.urdu => 'اپنی زندگی آسان بنائیں',
        _ => 'Apni Zindagi Asaan Karo',
      };

  String get chooseLanguage => switch (lang) {
        AppLanguage.english => 'Choose language',
        AppLanguage.urdu => 'زبان منتخب کریں',
        _ => 'Zubaan chunein',
      };

  String get continueLabel => switch (lang) {
        AppLanguage.english => 'Continue',
        AppLanguage.urdu => 'آگے بڑھیں',
        _ => 'Aage Barho',
      };

  String get skip => switch (lang) {
        AppLanguage.english => 'Skip',
        AppLanguage.urdu => 'چھوڑیں',
        _ => 'Skip',
      };

  String get onboarding => switch (lang) {
        AppLanguage.english => 'Onboarding',
        AppLanguage.urdu => 'تعارف',
        _ => 'Tutorial',
      };

  String get phoneNumber => switch (lang) {
        AppLanguage.english => 'Phone number',
        AppLanguage.urdu => 'فون نمبر',
        _ => 'Phone number',
      };

  String get phoneHint => switch (lang) {
        AppLanguage.english => 'We will send you an OTP',
        AppLanguage.urdu => 'ہم آپ کو OTP بھیجیں گے',
        _ => 'Hum aapko OTP bhejenge',
      };

  String get sendOtp => switch (lang) {
        AppLanguage.english => 'Send OTP',
        AppLanguage.urdu => 'OTP بھیجیں',
        _ => 'OTP Bhejein',
      };

  String get verifyOtp => switch (lang) {
        AppLanguage.english => 'Verify OTP',
        AppLanguage.urdu => 'OTP تصدیق کریں',
        _ => 'OTP enter karein',
      };

  String get profileSetup => switch (lang) {
        AppLanguage.english => 'Profile setup',
        AppLanguage.urdu => 'پروفائل سیٹ اپ',
        _ => 'Profile setup',
      };

  String get fullName => switch (lang) {
        AppLanguage.english => 'Full name',
        AppLanguage.urdu => 'پورا نام',
        _ => 'Pura naam',
      };

  String get city => switch (lang) {
        AppLanguage.english => 'City',
        AppLanguage.urdu => 'شہر',
        _ => 'Shehar',
      };

  String get area => switch (lang) {
        AppLanguage.english => 'Area / Location',
        AppLanguage.urdu => 'علاقہ',
        _ => 'Area / Location',
      };

  String get streetAddress => switch (lang) {
        AppLanguage.english => 'Full street address',
        AppLanguage.urdu => 'مکمل پتہ',
        _ => 'Pura street address',
      };

  String get salamGreeting => switch (lang) {
        AppLanguage.english => 'Hello',
        AppLanguage.urdu => 'سلام',
        _ => 'Salam',
      };

  String get needHelp => switch (lang) {
        AppLanguage.english => 'What do you need help with?',
        AppLanguage.urdu => 'آپ کو کیا مدد چاہیے؟',
        _ => 'Kya madad chahiye?',
      };

  String get chatHint => switch (lang) {
        AppLanguage.english => 'Describe your service need...',
        AppLanguage.urdu => 'اپنی سروس بتائیں...',
        _ => 'Apni service batayein...',
      };

  String get myBookings => switch (lang) {
        AppLanguage.english => 'My Bookings',
        AppLanguage.urdu => 'میری بکنگز',
        _ => 'Meri Bookings',
      };

  String get tabAll => switch (lang) {
        AppLanguage.english => 'All',
        AppLanguage.urdu => 'سب',
        _ => 'All',
      };

  String get tabActive => switch (lang) {
        AppLanguage.english => 'Active',
        AppLanguage.urdu => 'فعال',
        _ => 'Active',
      };

  String get tabCompleted => switch (lang) {
        AppLanguage.english => 'Completed',
        AppLanguage.urdu => 'مکمل',
        _ => 'Completed',
      };

  String get tabCancelled => switch (lang) {
        AppLanguage.english => 'Cancelled',
        AppLanguage.urdu => 'منسوخ',
        _ => 'Cancelled',
      };

  String get viewProfile => switch (lang) {
        AppLanguage.english => 'View Profile',
        AppLanguage.urdu => 'پروفائل دیکھیں',
        _ => 'View Profile',
      };

  String get whyAiChose => switch (lang) {
        AppLanguage.english => 'Why AI Chose This',
        AppLanguage.urdu => 'AI نے کیوں چنا؟',
        _ => 'Why AI Chose This',
      };

  String get bookNow => switch (lang) {
        AppLanguage.english => 'Book Now',
        AppLanguage.urdu => 'اب بک کریں',
        _ => 'Book Now',
      };

  String get intentUnderstood => switch (lang) {
        AppLanguage.english => 'I understood your request:',
        AppLanguage.urdu => 'میں نے آپ کی درخواست سمجھ لی:',
        _ => 'Main ne aap ki request samjhi:',
      };

  String get urgencyQuestion => switch (lang) {
        AppLanguage.english => 'When do you need this service? Is it urgent?',
        AppLanguage.urdu => 'آپ کو یہ سروس کب چاہیے؟ کیا فوری ہے؟',
        _ => 'Kab chahiye? Kya urgent hai?',
      };

  String get confirmAndMatch => switch (lang) {
        AppLanguage.english => 'Find best providers',
        AppLanguage.urdu => 'بہترین فراہم کنندہ تلاش کریں',
        _ => 'Best providers dhundhein',
      };

  String get whoAreYou => switch (lang) {
        AppLanguage.english => 'Who are you?',
        AppLanguage.urdu => 'آپ کون ہیں؟',
        _ => 'Aap kaun hain?',
      };

  String get seekerTitle => switch (lang) {
        AppLanguage.english => 'Need a service',
        AppLanguage.urdu => 'کام کروانا ہے',
        _ => 'Kaam Karwana Hai',
      };

  String get providerTitle => switch (lang) {
        AppLanguage.english => 'Offer services',
        AppLanguage.urdu => 'کام کرنا ہے',
        _ => 'Kaam Karna Hai',
      };
}

final stringsProvider = Provider<S>((ref) {
  final lang = ref.watch(userProfileProvider).language;
  return S(lang);
});
