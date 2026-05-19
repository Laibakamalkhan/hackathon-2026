import '../models/booking_model.dart';
import '../models/provider_model.dart';

abstract final class MockDataService {
  static const categories = [
    ('🌬️', 'AC Repair'),
    ('🔧', 'Plumber'),
    ('⚡', 'Electrical'),
    ('📚', 'Tutor'),
    ('💆', 'Beauty'),
    ('🔩', 'Mechanic'),
  ];

  static const quickActions = [
    ('🔧', 'Plumber', 'rgba(186, 200, 224, 0.25)'),
    ('🌬️', 'AC Repair', 'rgba(168, 213, 181, 0.25)'),
    ('⚡', 'Electrician', 'rgba(245, 201, 122, 0.25)'),
    ('💬', 'Kuch aur?', 'rgba(208, 190, 163, 0.25)'),
  ];

  static final providers = [
    const ServiceProvider(
      id: 'p1',
      name: 'Ali AC Services',
      service: 'AC Repair & Maintenance',
      rating: 4.9,
      reviews: 234,
      distance: '1.2 km',
      price: 'PKR 800–1,200',
      matchScore: 96,
      eta: '45 min',
      badges: ['Verified', 'Top Rated'],
    ),
    const ServiceProvider(
      id: 'p2',
      name: 'Hassan Cool Tech',
      service: 'AC Installation',
      rating: 4.7,
      reviews: 156,
      distance: '2.1 km',
      price: 'PKR 700–1,000',
      matchScore: 89,
      eta: '1 hr',
      badges: ['Verified'],
    ),
    const ServiceProvider(
      id: 'p3',
      name: 'Cool Breeze Experts',
      service: 'AC Gas Refill',
      rating: 4.6,
      reviews: 98,
      distance: '3.4 km',
      price: 'PKR 650–900',
      matchScore: 82,
      eta: '1.5 hr',
    ),
  ];

  static final bookings = [
    const Booking(
      id: 'BSK-2024-1821',
      providerName: 'Hassan Electrical',
      providerInitials: 'HE',
      providerRating: 4.6,
      service: 'Wiring Check',
      date: 'Today',
      time: '2:00 PM',
      timePill: 'Aaj 2:00 PM',
      location: 'Model Town, Lahore',
      price: 'PKR 880',
      status: BookingStatus.active,
      canTrack: true,
    ),
    const Booking(
      id: 'BSK-001',
      providerName: 'Ali AC Services',
      providerInitials: 'Al',
      providerRating: 4.8,
      service: 'AC Repair',
      date: 'May 17',
      shortDate: 'May 17',
      time: '11:30 AM',
      location: 'G-13/3, Islamabad',
      price: 'PKR 880',
      status: BookingStatus.completed,
    ),
    const Booking(
      id: 'BSK-002',
      providerName: 'Saad Plumbing',
      providerInitials: 'SP',
      providerRating: 4.5,
      service: 'Pipe Fix',
      date: 'May 15',
      shortDate: 'May 15',
      time: '10:00 AM',
      location: 'F-10/4, Islamabad',
      price: 'PKR 650',
      status: BookingStatus.completed,
    ),
    const Booking(
      id: 'BSK-2024-1790',
      providerName: 'Quick Fix Plumbing',
      providerInitials: 'QF',
      providerRating: 4.2,
      service: 'Plumber',
      date: '1 May 2026',
      shortDate: '1 May',
      time: '4:00 PM',
      location: 'DHA Phase 5, Karachi',
      price: 'PKR 500',
      status: BookingStatus.cancelled,
    ),
  ];

  static const intentChips = [
    'AC Repair',
    'Urgency: HIGH',
    'G-13, Islamabad',
    'Tomorrow AM',
    'Budget: Moderate',
  ];

  static const priceBreakdown = [
    ('Service fee', 'PKR 600'),
    ('Travel', 'PKR 150'),
    ('Platform fee', 'PKR 80'),
    ('GST', 'PKR 50'),
  ];
}
