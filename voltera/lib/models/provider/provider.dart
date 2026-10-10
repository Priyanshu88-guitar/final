class ServiceProviderModel {
  final String id;
  final String userId;
  final String businessName;
  final String status;
  final double rating;

  const ServiceProviderModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.status,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'businessName': businessName,
        'status': status,
        'rating': rating,
      };

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
