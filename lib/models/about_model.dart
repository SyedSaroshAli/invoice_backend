class AboutModel {
  final int entityId;
  final String entityDesc;
  final String contact1;
  final String address1;
  final String address2;
  final String contact2;
  final String aboutDesc1;
  final String aboutDesc2;
  final String aboutDesc3;
  final String aboutDesc4;
  final String entityLogo;

  AboutModel({
    required this.entityId,
    required this.entityDesc,
    required this.contact1,
    required this.address1,
    required this.address2,
    required this.contact2,
    required this.aboutDesc1,
    required this.aboutDesc2,
    required this.aboutDesc3,
    required this.aboutDesc4,
    required this.entityLogo,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      entityId: json['entityId'],
      entityDesc: json['entityDesc'],
      contact1: json['contact1'],
      address1: json['address1'],
      address2: json['address2'],
      contact2: json['contact2'],
      aboutDesc1: json['aboutDesc1'],
      aboutDesc2: json['aboutDesc2'],
      aboutDesc3: json['aboutDesc3'],
      aboutDesc4: json['aboutDesc4'],
      entityLogo: json['entityLogo'],
    );
  }
}