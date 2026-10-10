import '../../models/user_role.dart';

class DemoUserAccount {
  final String name;
  final String phone;
  final String email;
  final String password;
  final UserRole role;

  const DemoUserAccount({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.role,
  });
}

class DemoData {
  static const List<DemoUserAccount> demoAccounts = [
    DemoUserAccount(
      name: 'Rahul Sharma',
      phone: '9876543210',
      email: 'rahul@voltera.demo',
      password: 'Password123',
      role: UserRole.customer,
    ),
    DemoUserAccount(
      name: 'Amit Patel',
      phone: '9876543220',
      email: 'amit@voltera.demo',
      password: 'Password123',
      role: UserRole.provider,
    ),
    DemoUserAccount(
      name: 'Voltera Admin',
      phone: '9876543230',
      email: 'admin@voltera.demo',
      password: 'Password123',
      role: UserRole.admin,
    ),
  ];

  // Customer Home & Search
  static const Map<String, dynamic> customerProfile = {
    'name': 'Rahul Sharma',
    'email': 'rahul@voltera.demo',
    'phone': '9876543210',
    'customerSince': 'January 2026',
    'batteryPercent': 72,
    'rangeKm': 286,
    'walletBalance': 1850.0,
    'totalSessions': 24,
    'totalEnergyKwh': 412.0,
  };

  static const List<Map<String, dynamic>> nearbyChargers = [
    {
      'id': 'chg-1',
      'name': 'GreenCharge Hub',
      'address': 'SG Highway, Ahmedabad',
      'distance': '1.2 km',
      'connector': 'CCS2',
      'type': 'Fast Charger',
      'power': '60 kW',
      'price': '₹18/kWh',
      'status': 'Available',
      'rating': 4.7,
      'operating': '24 Hours',
      'amenities': ['Parking', 'Restroom', 'Cafe', 'Wi-Fi'],
    },
    {
      'id': 'chg-2',
      'name': 'Volt Point',
      'address': 'Prahlad Nagar, Ahmedabad',
      'distance': '1.8 km',
      'connector': 'CCS2',
      'type': 'Fast Charger',
      'power': '30 kW',
      'price': '₹16/kWh',
      'status': 'Available',
      'rating': 4.5,
      'operating': '24 Hours',
      'amenities': ['Parking', 'Restroom'],
    },
    {
      'id': 'chg-3',
      'name': 'EV Power Station',
      'address': 'Satellite, Ahmedabad',
      'distance': '2.4 km',
      'connector': 'Type 2',
      'type': 'Normal Charger',
      'power': '7.4 kW',
      'price': '₹12/kWh',
      'status': 'Available',
      'rating': 4.3,
      'operating': '6 AM - 11 PM',
      'amenities': ['Parking'],
    },
    {
      'id': 'chg-4',
      'name': 'ChargeMax Hub',
      'address': 'Vastrapur, Ahmedabad',
      'distance': '3.1 km',
      'connector': 'CCS2',
      'type': 'Ultra Fast',
      'power': '120 kW',
      'price': '₹22/kWh',
      'status': 'Busy',
      'rating': 4.8,
      'operating': '24 Hours',
      'amenities': ['Parking', 'Restroom', 'Lounge', 'Cafe', 'Wi-Fi'],
    },
    {
      'id': 'chg-5',
      'name': 'GreenVolt Station',
      'address': 'Drive In Road, Ahmedabad',
      'distance': '3.8 km',
      'connector': 'CHAdeMO',
      'type': 'Fast Charger',
      'power': '50 kW',
      'price': '₹19/kWh',
      'status': 'Available',
      'rating': 4.6,
      'operating': '24 Hours',
      'amenities': ['Parking', 'Restroom'],
    },
  ];

  static const List<Map<String, dynamic>> demoBookings = [
    {
      'id': 'BK-101',
      'station': 'GreenCharge Hub',
      'charger': 'CCS2 Charger',
      'time': 'Today, 6:30 PM – 7:30 PM',
      'cost': '₹320',
      'status': 'CONFIRMED',
    },
    {
      'id': 'BK-102',
      'station': 'Volt Point',
      'charger': 'Type-2 AC',
      'time': 'Tomorrow, 10:00 AM – 11:00 AM',
      'cost': '₹150',
      'status': 'UPCOMING',
    },
    {
      'id': 'BK-103',
      'station': 'EV Power Station',
      'charger': 'Type-2 AC',
      'time': 'Yesterday, 4:00 PM – 5:00 PM',
      'cost': '₹188',
      'status': 'COMPLETED',
    },
    {
      'id': 'BK-104',
      'station': 'ChargeMax Hub',
      'charger': 'CCS2 Ultra',
      'time': '3 days ago',
      'cost': '₹450',
      'status': 'CANCELLED',
    },
  ];

  static const List<Map<String, dynamic>> chargingHistory = [
    {
      'station': 'GreenCharge Hub',
      'energy': '18.4 kWh',
      'amount': '₹331',
      'duration': '45 min',
      'date': 'Yesterday',
      'status': 'Completed',
    },
    {
      'station': 'Volt Point',
      'energy': '22.1 kWh',
      'amount': '₹354',
      'duration': '52 min',
      'date': '3 days ago',
      'status': 'Completed',
    },
    {
      'station': 'EV Power Station',
      'energy': '15.7 kWh',
      'amount': '₹188',
      'duration': '38 min',
      'date': '5 days ago',
      'status': 'Completed',
    },
  ];

  static const Map<String, dynamic> activeSession = {
    'station': 'GreenCharge Hub',
    'charger': 'CCS2-01',
    'batteryFrom': '72%',
    'batteryTo': '86%',
    'energyKwh': '8.6 kWh',
    'durationMin': '24 min',
    'currentCost': '₹155',
    'estimatedRemainingMin': '18 min',
  };

  static const List<Map<String, dynamic>> paymentsList = [
    {'id': 'TXN-901', 'station': 'GreenCharge Hub', 'amount': '₹331', 'status': 'Completed', 'method': 'UPI', 'date': 'Yesterday'},
    {'id': 'TXN-902', 'station': 'Volt Point', 'amount': '₹354', 'status': 'Completed', 'method': 'UPI', 'date': '3 days ago'},
    {'id': 'TXN-903', 'station': 'EV Power Station', 'amount': '₹188', 'status': 'Completed', 'method': 'Wallet', 'date': '5 days ago'},
    {'id': 'TXN-904', 'station': 'GreenCharge Hub', 'amount': '₹320', 'status': 'Pending', 'method': 'Card', 'date': 'Today'},
  ];

  static const List<Map<String, dynamic>> walletTransactions = [
    {'title': 'Wallet Recharge', 'amount': '+ ₹1,000', 'type': 'credit', 'date': 'Today'},
    {'title': 'Charging (GreenCharge Hub)', 'amount': '- ₹331', 'type': 'debit', 'date': 'Yesterday'},
    {'title': 'Charging (Volt Point)', 'amount': '- ₹188', 'type': 'debit', 'date': '3 days ago'},
    {'title': 'Wallet Recharge', 'amount': '+ ₹500', 'type': 'credit', 'date': '1 week ago'},
  ];

  static const List<Map<String, dynamic>> notificationsList = [
    {'title': 'Booking confirmed', 'subtitle': 'Your charging slot is reserved at GreenCharge Hub.', 'time': '10m ago', 'unread': true},
    {'title': 'Your charging session has started', 'subtitle': 'GreenCharge Hub CCS2-01 is now active.', 'time': '25m ago', 'unread': true},
    {'title': 'Payment successful', 'subtitle': '₹331 paid successfully via UPI.', 'time': '1d ago', 'unread': false},
    {'title': 'GreenCharge Hub is now available', 'subtitle': 'Your favorite station is clear for booking.', 'time': '2d ago', 'unread': false},
    {'title': '₹1,000 wallet recharge successful', 'subtitle': 'Your wallet balance is updated to ₹1,850.', 'time': '3d ago', 'unread': false},
    {'title': 'New bundle available', 'subtitle': 'Check out the new Fast Charge Pack (50 kWh).', 'time': '4d ago', 'unread': false},
  ];

  static const List<Map<String, dynamic>> demoBundles = [
    {'id': 'BND-1', 'name': 'EV Saver Pack', 'energy': '10 kWh', 'price': '₹150', 'validity': '15 Days', 'savings': 'Save 15%'},
    {'id': 'BND-2', 'name': 'Fast Charge Pack', 'energy': '50 kWh', 'price': '₹700', 'validity': '30 Days', 'savings': 'Save 22%'},
    {'id': 'BND-3', 'name': 'Monthly EV Pass', 'energy': '150 kWh', 'price': '₹1,999', 'validity': '30 Days', 'savings': 'Save 30%'},
  ];

  static const List<Map<String, dynamic>> emergencyServices = [
    {'name': 'Roadside Assistance', 'status': 'Available', 'phone': '+91 1800 123 456'},
    {'name': 'Battery Assistance', 'status': 'Available', 'phone': '+91 1800 123 457'},
    {'name': 'Towing Service', 'status': 'Available', 'phone': '+91 1800 123 458'},
  ];

  static const List<Map<String, dynamic>> supportTickets = [
    {'id': 'VT-1024', 'subject': 'Payment issue', 'status': 'Resolved', 'date': '2 days ago'},
    {'id': 'VT-1027', 'subject': 'Charging session question', 'status': 'Open', 'date': 'Today'},
    {'id': 'VT-1011', 'subject': 'App login help', 'status': 'Resolved', 'date': '1 week ago'},
    {'id': 'VT-1005', 'subject': 'Station accessibility', 'status': 'Resolved', 'date': '2 weeks ago'},
  ];

  // Provider Data
  static const Map<String, dynamic> providerDashboard = {
    'name': 'Amit Patel',
    'totalEarnings': '₹48,750',
    'thisMonth': '₹12,480',
    'activeChargers': 8,
    'totalChargers': 12,
    'todaysSessions': 14,
    'pendingRequests': 3,
  };

  static const List<Map<String, dynamic>> providerStations = [
    {'name': 'Amit EV Hub', 'location': 'SG Highway', 'chargers': 6, 'status': 'Active', 'rating': 4.8},
    {'name': 'Patel Charging Point', 'location': 'Bopal', 'chargers': 4, 'status': 'Active', 'rating': 4.6},
    {'name': 'GreenVolt Station', 'location': 'Satellite', 'chargers': 5, 'status': 'Maintenance', 'rating': 4.5},
  ];

  static const List<Map<String, dynamic>> providerBookings = [
    {'customer': 'Rahul Sharma', 'station': 'Amit EV Hub', 'time': 'Today, 6:30 PM', 'amount': '₹320', 'status': 'Pending'},
    {'customer': 'Priya Patel', 'station': 'Patel Charging Point', 'time': 'Today, 8:00 PM', 'amount': '₹250', 'status': 'Pending'},
    {'customer': 'Arjun Mehta', 'station': 'Amit EV Hub', 'time': 'Tomorrow, 10:00 AM', 'amount': '₹180', 'status': 'Accepted'},
    {'customer': 'Neha Shah', 'station': 'GreenVolt Station', 'time': 'Completed yesterday', 'amount': '₹410', 'status': 'Completed'},
  ];

  static const Map<String, dynamic> providerEarningsSummary = {
    'today': '₹2,850',
    'thisWeek': '₹14,620',
    'thisMonth': '₹48,750',
    'lifetime': '₹3,82,400',
    'availablePayout': '₹18,450',
    'pendingPayout': '₹5,200',
    'lastPayout': '₹12,000 (Completed)',
  };

  static const Map<String, dynamic> providerBankAccount = {
    'bankName': 'HDFC Bank',
    'accountNumber': 'XXXX XXXX 4521',
    'ifsc': 'HDFC0001234',
    'holderName': 'Amit Patel',
  };

  // Admin Data
  static const Map<String, dynamic> adminDashboard = {
    'totalUsers': '1,284',
    'customers': '1,050',
    'providers': '220',
    'admins': '14',
    'stations': '186',
    'chargers': '542',
    'bookings': '8,420',
    'revenue': '₹24,85,600',
    'activeSessions': 42,
    'pendingApprovals': 7,
  };

  static const List<Map<String, dynamic>> adminUsers = [
    {'name': 'Rahul Sharma', 'role': 'Customer', 'status': 'Active', 'email': 'rahul@voltera.demo'},
    {'name': 'Amit Patel', 'role': 'Provider', 'status': 'Active', 'email': 'amit@voltera.demo'},
    {'name': 'Priya Shah', 'role': 'Customer', 'status': 'Active', 'email': 'priya@voltera.demo'},
    {'name': 'Raj Mehta', 'role': 'Provider', 'status': 'Pending Verification', 'email': 'raj@voltera.demo'},
    {'name': 'Neha Patel', 'role': 'Customer', 'status': 'Suspended', 'email': 'neha@voltera.demo'},
  ];

  static const List<Map<String, dynamic>> adminProviders = [
    {'name': 'Amit Patel', 'business': 'Amit EV Hub', 'status': 'Approved'},
    {'name': 'Raj Mehta', 'business': 'Raj Power Grid', 'status': 'Pending'},
    {'name': 'Vikram Shah', 'business': 'Shah Chargers', 'status': 'Approved'},
    {'name': 'Neel Joshi', 'business': 'Joshi EV Solutions', 'status': 'Rejected'},
  ];

  static const List<Map<String, dynamic>> adminStations = [
    {'name': 'Voltera SG Highway', 'provider': 'Amit Patel', 'city': 'Ahmedabad', 'chargers': 6, 'status': 'Active', 'revenue': '₹1,24,500', 'rating': 4.8},
    {'name': 'GreenSpark Gandhinagar', 'provider': 'Vikram Shah', 'city': 'Gandhinagar', 'chargers': 4, 'status': 'Active', 'revenue': '₹98,200', 'rating': 4.6},
    {'name': 'RapidVolt Surat', 'provider': 'Raj Mehta', 'city': 'Surat', 'chargers': 8, 'status': 'Maintenance', 'revenue': '₹1,45,000', 'rating': 4.7},
  ];

  static const List<Map<String, dynamic>> adminBookings = [
    {'customer': 'Rahul Sharma', 'provider': 'Amit Patel', 'station': 'Voltera SG Highway', 'charger': 'CCS2-01', 'date': 'Today', 'amount': '₹320', 'status': 'Confirmed'},
    {'customer': 'Priya Patel', 'provider': 'Vikram Shah', 'station': 'GreenSpark', 'charger': 'Type-2', 'date': 'Today', 'amount': '₹180', 'status': 'Completed'},
    {'customer': 'Arjun Mehta', 'provider': 'Raj Mehta', 'station': 'RapidVolt', 'charger': 'CHAdeMO', 'date': 'Yesterday', 'amount': '₹450', 'status': 'Cancelled'},
  ];
}
