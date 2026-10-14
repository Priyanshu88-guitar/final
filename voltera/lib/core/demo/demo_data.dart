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
    'totalUsers': '15,480',
    'customers': '12,850',
    'providers': '2,420',
    'admins': '210',
    'activeUsers': '14,920',
    'suspendedUsers': '560',
    'verifiedProviders': '2,150',
    'pendingProviders': '210',
    'rejectedProviders': '60',
    'stations': '3,850',
    'chargers': '11,420',
    'activeChargers': '9,840',
    'maintenanceChargers': '1,120',
    'pendingChargers': '310',
    'reportedChargers': '150',
    'totalSessions': '148,920',
    'completedSessions': '132,450',
    'activeSessions': '1,240',
    'pendingSessions': '3,850',
    'failedSessions': '4,120',
    'cancelledSessions': '7,260',
    'totalTransactions': '162,400',
    'completedPayments': '151,200',
    'pendingPayments': '4,150',
    'failedPayments': '5,220',
    'refundedPayments': '1,830',
    'revenue': '₹4,82,90,500',
    'commissionEarned': '₹48,29,050',
    'providerPayouts': '₹4,03,81,000',
    'pendingPayouts': '₹30,80,450',
    'totalReports': '840',
    'openReports': '125',
    'resolvedReports': '715',
  };

  static final List<Map<String, dynamic>> _registeredUsers = [];
  static final List<Map<String, dynamic>> _registeredProviders = [];

  static int get registeredUsersCount => _registeredUsers.length;
  static int get registeredCustomersCount => _registeredUsers.where((u) => u['role'] == 'customer').length;
  static int get registeredProvidersCount => _registeredUsers.where((u) => u['role'] == 'provider').length;

  static List<Map<String, dynamic>> get adminUsers => [
        ..._registeredUsers,
        ...staticAdminUsers,
      ];

  static List<Map<String, dynamic>> get adminProviders => [
        ..._registeredProviders,
        ...staticAdminProviders,
      ];

  static void registerUser({
    required String name,
    required String email,
    required String phone,
    required UserRole role,
    String? businessName,
    String? city,
    String? address,
  }) {
    if (email.isEmpty && phone.isEmpty) return;

    final userId = 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final userCity = (city != null && city.trim().isNotEmpty) ? city.trim() : 'Ahmedabad, Gujarat';
    final userBusiness = (businessName != null && businessName.trim().isNotEmpty)
        ? businessName.trim()
        : (name.trim().isNotEmpty ? name.trim() : 'EV Charging Station');

    final newUser = {
      'id': userId,
      'name': name.trim().isNotEmpty ? name.trim() : (email.isNotEmpty ? email.split('@')[0] : 'Registered User'),
      'role': role.name.toLowerCase(),
      'status': 'ACTIVE',
      'email': email.trim().isNotEmpty ? email.trim() : 'user@voltera.demo',
      'phone': phone.trim().isNotEmpty ? phone.trim() : '+91 98765 43210',
      'location': userCity,
      'sessions': 0,
      'wallet': '₹ 500',
    };

    _registeredUsers.removeWhere((u) =>
        (phone.isNotEmpty && u['phone'] == phone) || (email.isNotEmpty && u['email'] == email));
    _registeredUsers.insert(0, newUser);

    if (role == UserRole.provider) {
      final newProvider = {
        'id': 'PRV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'name': name.trim().isNotEmpty ? name.trim() : 'Provider Partner',
        'business': userBusiness,
        'city': userCity,
        'status': 'PENDING',
        'chargers': 0,
        'earnings': '₹ 0',
        'rating': 5.0,
      };

      _registeredProviders.removeWhere((p) => p['name'] == name || p['business'] == userBusiness);
      _registeredProviders.insert(0, newProvider);
    }
  }

  static const List<Map<String, dynamic>> staticAdminUsers = [
    {'id': 'USR-1001', 'name': 'Rahul Sharma', 'role': 'customer', 'status': 'ACTIVE', 'email': 'rahul@voltera.demo', 'phone': '+91 98765 43210', 'location': 'Ahmedabad, Gujarat', 'sessions': 38, 'wallet': '₹ 1,850'},
    {'id': 'USR-1002', 'name': 'Amit Patel', 'role': 'provider', 'status': 'ACTIVE', 'email': 'amit@voltera.demo', 'phone': '+91 98765 43220', 'location': 'SG Highway, Ahmedabad', 'sessions': 142, 'wallet': '₹ 12,450'},
    {'id': 'USR-1003', 'name': 'Priya Shah', 'role': 'customer', 'status': 'ACTIVE', 'email': 'priya@voltera.demo', 'phone': '+91 98765 43231', 'location': 'Satellite, Ahmedabad', 'sessions': 24, 'wallet': '₹ 920'},
    {'id': 'USR-1004', 'name': 'Raj Mehta', 'role': 'provider', 'status': 'PENDING', 'email': 'raj@voltera.demo', 'phone': '+91 98765 43242', 'location': 'Surat, Gujarat', 'sessions': 0, 'wallet': '₹ 0'},
    {'id': 'USR-1005', 'name': 'Neha Patel', 'role': 'customer', 'status': 'SUSPENDED', 'email': 'neha@voltera.demo', 'phone': '+91 98765 43253', 'location': 'Vadodara, Gujarat', 'sessions': 5, 'wallet': '₹ 0'},
    {'id': 'USR-1006', 'name': 'Vikram Desai', 'role': 'provider', 'status': 'ACTIVE', 'email': 'vikram@voltera.demo', 'phone': '+91 98765 43264', 'location': 'Gandhinagar, Gujarat', 'sessions': 89, 'wallet': '₹ 8,300'},
    {'id': 'USR-1007', 'name': 'Sneha Gupta', 'role': 'customer', 'status': 'ACTIVE', 'email': 'sneha@voltera.demo', 'phone': '+91 98765 43275', 'location': 'Bopal, Ahmedabad', 'sessions': 19, 'wallet': '₹ 1,200'},
    {'id': 'USR-1008', 'name': 'Aniket Verma', 'role': 'customer', 'status': 'ACTIVE', 'email': 'aniket@voltera.demo', 'phone': '+91 98765 43286', 'location': 'Rajkot, Gujarat', 'sessions': 14, 'wallet': '₹ 650'},
    {'id': 'USR-1009', 'name': 'Riddhi Trivedi', 'role': 'admin', 'status': 'ACTIVE', 'email': 'riddhi.admin@voltera.demo', 'phone': '+91 98765 43297', 'location': 'Ahmedabad, HQ', 'sessions': 0, 'wallet': '₹ 0'},
    {'id': 'USR-1010', 'name': 'Karan Malhotra', 'role': 'customer', 'status': 'ACTIVE', 'email': 'karan@voltera.demo', 'phone': '+91 98765 43308', 'location': 'Mumbai, Maharashtra', 'sessions': 45, 'wallet': '₹ 3,400'},
    {'id': 'USR-1011', 'name': 'Pooja Joshi', 'role': 'provider', 'status': 'ACTIVE', 'email': 'pooja@voltera.demo', 'phone': '+91 98765 43319', 'location': 'Prahlad Nagar, Ahmedabad', 'sessions': 67, 'wallet': '₹ 6,100'},
    {'id': 'USR-1012', 'name': 'Manish Dave', 'role': 'customer', 'status': 'ACTIVE', 'email': 'manish@voltera.demo', 'phone': '+91 98765 43320', 'location': 'Jamnagar, Gujarat', 'sessions': 8, 'wallet': '₹ 420'},
    {'id': 'USR-1013', 'name': 'Sunita Rao', 'role': 'customer', 'status': 'SUSPENDED', 'email': 'sunita@voltera.demo', 'phone': '+91 98765 43331', 'location': 'Pune, Maharashtra', 'sessions': 2, 'wallet': '₹ 100'},
    {'id': 'USR-1014', 'name': 'Devang Parikh', 'role': 'provider', 'status': 'PENDING', 'email': 'devang@voltera.demo', 'phone': '+91 98765 43342', 'location': 'Anand, Gujarat', 'sessions': 0, 'wallet': '₹ 0'},
    {'id': 'USR-1015', 'name': 'Hetal Bhatt', 'role': 'customer', 'status': 'ACTIVE', 'email': 'hetal@voltera.demo', 'phone': '+91 98765 43353', 'location': 'Bhavnagar, Gujarat', 'sessions': 29, 'wallet': '₹ 2,150'},
    {'id': 'USR-1016', 'name': 'Siddharth Roy', 'role': 'admin', 'status': 'ACTIVE', 'email': 'siddharth@voltera.demo', 'phone': '+91 98765 43364', 'location': 'Bengaluru, Karnataka', 'sessions': 0, 'wallet': '₹ 0'},
    {'id': 'USR-1017', 'name': 'Hardik Solanki', 'role': 'customer', 'status': 'ACTIVE', 'email': 'hardik@voltera.demo', 'phone': '+91 98765 43375', 'location': 'Navsari, Gujarat', 'sessions': 11, 'wallet': '₹ 780'},
    {'id': 'USR-1018', 'name': 'Bhavin Kothari', 'role': 'provider', 'status': 'ACTIVE', 'email': 'bhavin@voltera.demo', 'phone': '+91 98765 43386', 'location': 'Mehsana, Gujarat', 'sessions': 52, 'wallet': '₹ 4,900'},
    {'id': 'USR-1019', 'name': 'Meera Nair', 'role': 'customer', 'status': 'ACTIVE', 'email': 'meera@voltera.demo', 'phone': '+91 98765 43397', 'location': 'Kochi, Kerala', 'sessions': 33, 'wallet': '₹ 1,540'},
    {'id': 'USR-1020', 'name': 'Deepak Kumar', 'role': 'customer', 'status': 'ACTIVE', 'email': 'deepak@voltera.demo', 'phone': '+91 98765 43408', 'location': 'Delhi, NCR', 'sessions': 62, 'wallet': '₹ 4,100'},
  ];

  static const List<Map<String, dynamic>> staticAdminProviders = [
    {'id': 'PRV-201', 'name': 'Amit Patel', 'business': 'Amit EV Hub', 'city': 'Ahmedabad', 'status': 'APPROVED', 'chargers': 8, 'earnings': '₹ 1,48,750', 'rating': 4.8},
    {'id': 'PRV-202', 'name': 'Raj Mehta', 'business': 'Raj Power Grid', 'city': 'Surat', 'status': 'PENDING', 'chargers': 4, 'earnings': '₹ 0', 'rating': 0.0},
    {'id': 'PRV-203', 'name': 'Vikram Shah', 'business': 'Shah Chargers', 'city': 'Gandhinagar', 'status': 'APPROVED', 'chargers': 6, 'earnings': '₹ 98,200', 'rating': 4.6},
    {'id': 'PRV-204', 'name': 'Neel Joshi', 'business': 'Joshi EV Solutions', 'city': 'Vadodara', 'status': 'REJECTED', 'chargers': 2, 'earnings': '₹ 0', 'rating': 0.0},
    {'id': 'PRV-205', 'name': 'Pooja Joshi', 'business': 'EcoCharge Gujarat', 'city': 'Ahmedabad', 'status': 'APPROVED', 'chargers': 12, 'earnings': '₹ 2,34,100', 'rating': 4.9},
    {'id': 'PRV-206', 'name': 'Bhavin Kothari', 'business': 'SparkVolt India', 'city': 'Mehsana', 'status': 'APPROVED', 'chargers': 5, 'earnings': '₹ 67,800', 'rating': 4.5},
    {'id': 'PRV-207', 'name': 'Devang Parikh', 'business': 'Highway Energy Station', 'city': 'Anand', 'status': 'PENDING', 'chargers': 6, 'earnings': '₹ 0', 'rating': 0.0},
    {'id': 'PRV-208', 'name': 'Sanjay Rathod', 'business': 'Urban Charge Hub', 'city': 'Rajkot', 'status': 'APPROVED', 'chargers': 10, 'earnings': '₹ 1,82,400', 'rating': 4.7},
    {'id': 'PRV-209', 'name': 'Chirag Vora', 'business': 'GreenMotion Power', 'city': 'Bhavnagar', 'status': 'APPROVED', 'chargers': 4, 'earnings': '₹ 54,300', 'rating': 4.4},
    {'id': 'PRV-2010', 'name': 'Alok Pandey', 'business': 'Metro Volt Station', 'city': 'Mumbai', 'status': 'APPROVED', 'chargers': 15, 'earnings': '₹ 3,92,000', 'rating': 4.8},
  ];

  static const List<Map<String, dynamic>> adminStations = [
    {'id': 'CHG-301', 'name': 'Voltera SG Highway', 'provider': 'Amit Patel', 'city': 'Ahmedabad', 'type': 'CCS2 DC Fast', 'power': '60 kW', 'price': '₹18/kWh', 'status': 'ACTIVE', 'sessions': 1420, 'revenue': '₹2,55,600', 'rating': 4.8},
    {'id': 'CHG-302', 'name': 'GreenSpark Station', 'provider': 'Vikram Shah', 'city': 'Gandhinagar', 'type': 'Type 2 AC', 'power': '22 kW', 'price': '₹15/kWh', 'status': 'ACTIVE', 'sessions': 890, 'revenue': '₹1,33,500', 'rating': 4.6},
    {'id': 'CHG-303', 'name': 'RapidVolt Hub', 'provider': 'Raj Mehta', 'city': 'Surat', 'type': 'CHAdeMO Fast', 'power': '50 kW', 'price': '₹19/kWh', 'status': 'MAINTENANCE', 'sessions': 640, 'revenue': '₹1,21,600', 'rating': 4.2},
    {'id': 'CHG-304', 'name': 'Volt Point Satellite', 'provider': 'Pooja Joshi', 'city': 'Ahmedabad', 'type': 'CCS2 Dual', 'power': '120 kW', 'price': '₹22/kWh', 'status': 'ACTIVE', 'sessions': 2150, 'revenue': '₹4,73,000', 'rating': 4.9},
    {'id': 'CHG-305', 'name': 'EcoCharge Bopal', 'provider': 'Amit Patel', 'city': 'Ahmedabad', 'type': 'Type 2 AC', 'power': '7.4 kW', 'price': '₹12/kWh', 'status': 'ACTIVE', 'sessions': 520, 'revenue': '₹62,400', 'rating': 4.5},
    {'id': 'CHG-306', 'name': 'SparkVolt Express', 'provider': 'Bhavin Kothari', 'city': 'Mehsana', 'type': 'CCS2 DC', 'power': '30 kW', 'price': '₹16/kWh', 'status': 'PENDING', 'sessions': 0, 'revenue': '₹0', 'rating': 0.0},
    {'id': 'CHG-307', 'name': 'Urban Charging Plaza', 'provider': 'Sanjay Rathod', 'city': 'Rajkot', 'type': 'CCS2 / Type 2', 'power': '60 kW', 'price': '₹18/kWh', 'status': 'ACTIVE', 'sessions': 1180, 'revenue': '₹2,12,400', 'rating': 4.7},
    {'id': 'CHG-308', 'name': 'Metro EV Station', 'provider': 'Alok Pandey', 'city': 'Mumbai', 'type': 'Ultra Fast 150kW', 'power': '150 kW', 'price': '₹25/kWh', 'status': 'REPORTED', 'sessions': 3100, 'revenue': '₹7,75,000', 'rating': 4.1},
  ];

  static const List<Map<String, dynamic>> adminBookings = [
    {'id': 'SES-5001', 'customer': 'Rahul Sharma', 'provider': 'Amit Patel', 'station': 'Voltera SG Highway', 'charger': 'CCS2-01', 'status': 'COMPLETED', 'energy': '18.4 kWh', 'duration': '42 min', 'cost': '₹ 331', 'date': 'Today, 2:15 PM'},
    {'id': 'SES-5002', 'customer': 'Sneha Gupta', 'provider': 'Pooja Joshi', 'station': 'Volt Point Satellite', 'charger': 'CCS2 Ultra-01', 'status': 'ACTIVE', 'energy': '12.1 kWh', 'duration': '22 min', 'cost': '₹ 266', 'date': 'Live Now'},
    {'id': 'SES-5003', 'customer': 'Priya Shah', 'provider': 'Vikram Shah', 'station': 'GreenSpark Station', 'charger': 'Type2-02', 'status': 'PENDING', 'energy': '0.0 kWh', 'duration': '0 min', 'cost': '₹ 220', 'date': 'Today, 5:00 PM'},
    {'id': 'SES-5004', 'customer': 'Karan Malhotra', 'provider': 'Alok Pandey', 'station': 'Metro EV Station', 'charger': 'CCS2-150', 'status': 'FAILED', 'energy': '2.1 kWh', 'duration': '4 min', 'cost': '₹ 0 (Refunded)', 'date': 'Yesterday, 8:40 PM'},
    {'id': 'SES-5005', 'customer': 'Aniket Verma', 'provider': 'Sanjay Rathod', 'station': 'Urban Charging Plaza', 'charger': 'CCS2-03', 'status': 'CANCELLED', 'energy': '0.0 kWh', 'duration': '0 min', 'cost': '₹ 0', 'date': 'Yesterday, 11:10 AM'},
    {'id': 'SES-5006', 'customer': 'Deepak Kumar', 'provider': 'Amit Patel', 'station': 'Voltera SG Highway', 'charger': 'CCS2-02', 'status': 'COMPLETED', 'energy': '28.6 kWh', 'duration': '55 min', 'cost': '₹ 515', 'date': '2 days ago'},
    {'id': 'SES-5007', 'customer': 'Meera Nair', 'provider': 'Pooja Joshi', 'station': 'Volt Point Satellite', 'charger': 'CCS2 Ultra-02', 'status': 'COMPLETED', 'energy': '35.0 kWh', 'duration': '38 min', 'cost': '₹ 770', 'date': '2 days ago'},
    {'id': 'SES-5008', 'customer': 'Manish Dave', 'provider': 'Chirag Vora', 'station': 'GreenMotion Power', 'charger': 'Type2-01', 'status': 'FAILED', 'energy': '0.5 kWh', 'duration': '2 min', 'cost': '₹ 0', 'date': '3 days ago'},
  ];

  static const List<Map<String, dynamic>> adminTransactions = [
    {'id': 'TXN-9001', 'user': 'Rahul Sharma', 'station': 'Voltera SG Highway', 'type': 'CHARGING_SESSION', 'method': 'UPI (Google Pay)', 'status': 'COMPLETED', 'amount': '₹ 331', 'date': 'Today, 2:15 PM', 'ref': 'UPI-901824101'},
    {'id': 'TXN-9002', 'user': 'Karan Malhotra', 'station': 'Wallet Top-up', 'type': 'WALLET_RECHARGE', 'method': 'Credit Card', 'status': 'COMPLETED', 'amount': '₹ 2,000', 'date': 'Today, 1:00 PM', 'ref': 'CC-78901234'},
    {'id': 'TXN-9003', 'user': 'Amit Patel (Provider)', 'station': 'Weekly Payout', 'type': 'PROVIDER_PAYOUT', 'method': 'Bank Transfer (NEFT)', 'status': 'COMPLETED', 'amount': '₹ 18,450', 'date': 'Yesterday, 6:00 PM', 'ref': 'NEFT-88391024'},
    {'id': 'TXN-9004', 'user': 'Priya Shah', 'station': 'GreenSpark Station', 'type': 'CHARGING_SESSION', 'method': 'Voltera Wallet', 'status': 'PENDING', 'amount': '₹ 220', 'date': 'Today, 3:30 PM', 'ref': 'WAL-1029384'},
    {'id': 'TXN-9005', 'user': 'Neha Patel', 'station': 'Metro EV Station', 'type': 'CHARGING_SESSION', 'method': 'Debit Card', 'status': 'FAILED', 'amount': '₹ 450', 'date': 'Yesterday, 9:20 PM', 'ref': 'DC-44210982'},
    {'id': 'TXN-9006', 'user': 'Karan Malhotra', 'station': 'Metro EV Station', 'type': 'REFUND', 'method': 'UPI Direct', 'status': 'REFUNDED', 'amount': '₹ 450', 'date': 'Yesterday, 9:45 PM', 'ref': 'REF-5591023'},
    {'id': 'TXN-9007', 'user': 'Sneha Gupta', 'station': 'Volt Point Satellite', 'type': 'CHARGING_SESSION', 'method': 'UPI (PhonePe)', 'status': 'COMPLETED', 'amount': '₹ 266', 'date': 'Live Session', 'ref': 'UPI-99102381'},
    {'id': 'TXN-9008', 'user': 'Devang Parikh (Provider)', 'station': 'Pending Payout', 'type': 'PROVIDER_PAYOUT', 'method': 'Bank Transfer', 'status': 'PENDING', 'amount': '₹ 12,800', 'date': 'Scheduled', 'ref': 'PAY-882103'},
  ];

  static const List<Map<String, dynamic>> adminReports = [
    {'id': 'REP-701', 'user': 'Karan Malhotra', 'email': 'karan@voltera.demo', 'category': 'CHARGER_ISSUE', 'subject': 'Connector not releasing cable', 'description': 'Gun cable was locked in Metro EV Station connector 150kW.', 'priority': 'HIGH', 'status': 'OPEN', 'date': 'Today, 11:30 AM'},
    {'id': 'REP-702', 'user': 'Neha Patel', 'email': 'neha@voltera.demo', 'category': 'PAYMENT_DISPUTE', 'subject': 'Double deduction on card payment', 'description': 'Debited ₹450 twice for session SES-5004.', 'priority': 'HIGH', 'status': 'IN_PROGRESS', 'date': 'Yesterday, 10:00 PM'},
    {'id': 'REP-703', 'user': 'Manish Dave', 'email': 'manish@voltera.demo', 'category': 'CHARGER_ISSUE', 'subject': 'Screen display turned off', 'description': 'GreenMotion Power charger display was blank.', 'priority': 'MEDIUM', 'status': 'OPEN', 'date': '2 days ago'},
    {'id': 'REP-704', 'user': 'Rahul Sharma', 'email': 'rahul@voltera.demo', 'category': 'USER_REPORT', 'subject': 'Incorrect billing rate shown', 'description': 'App displayed ₹16/kWh but receipt charged ₹18/kWh.', 'priority': 'LOW', 'status': 'RESOLVED', 'date': '3 days ago'},
    {'id': 'REP-705', 'user': 'Priya Shah', 'email': 'priya@voltera.demo', 'category': 'APP_BUG', 'subject': 'QR Code scanner delay', 'description': 'Scanning QR code took more than 30 seconds to connect.', 'priority': 'LOW', 'status': 'RESOLVED', 'date': '4 days ago'},
  ];
}

