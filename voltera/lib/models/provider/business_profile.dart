class BusinessProfile {
  final String providerId;
  final String businessName;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String taxId;

  const BusinessProfile({
    required this.providerId,
    required this.businessName,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.taxId,
  });

  Map<String, dynamic> toJson() => {
        'providerId': providerId,
        'businessName': businessName,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'address': address,
        'taxId': taxId,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      providerId: json['providerId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      taxId: json['taxId'] as String? ?? '',
    );
  }
}
