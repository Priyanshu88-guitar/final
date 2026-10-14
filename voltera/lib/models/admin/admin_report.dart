class AdminReportRecord {
  final String id;
  final String userName;
  final String userEmail;
  final String category; // CHARGER_ISSUE, PAYMENT_DISPUTE, USER_REPORT, APP_BUG
  final String subject;
  final String description;
  final String priority; // HIGH, MEDIUM, LOW
  final String status; // OPEN, IN_PROGRESS, RESOLVED
  final DateTime timestamp;
  final String resolutionNotes;

  const AdminReportRecord({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.category,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.timestamp,
    this.resolutionNotes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userEmail': userEmail,
        'category': category,
        'subject': subject,
        'description': description,
        'priority': priority,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'resolutionNotes': resolutionNotes,
      };

  factory AdminReportRecord.fromJson(Map<String, dynamic> json) {
    return AdminReportRecord(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? 'User',
      userEmail: json['userEmail'] as String? ?? 'user@voltera.demo',
      category: json['category'] as String? ?? 'CHARGER_ISSUE',
      subject: json['subject'] as String? ?? 'Support Request',
      description: json['description'] as String? ?? 'No details provided.',
      priority: json['priority'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'OPEN',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      resolutionNotes: json['resolutionNotes'] as String? ?? '',
    );
  }
}
