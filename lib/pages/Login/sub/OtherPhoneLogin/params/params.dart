class OtherPhoneLoginParams {
  final String code;
  final String short;
  final String name;
  final String en;
  final String groupEn;
  final String groupCn;
  const OtherPhoneLoginParams({
    required this.code,
    required this.short,
    required this.name,
    required this.en,
    required this.groupEn,
    required this.groupCn,
  });
  factory OtherPhoneLoginParams.fromJson(Map<String, String> json) => OtherPhoneLoginParams(
    code: json['code']??'',
    short: json['short']??'',
    name: json['name']??'',
    en: json['en']??'',
    groupEn: json['groupEn']??'',
    groupCn: json['groupCn']??'', 
  );
}