class ReportTypeItem{
  String text;
  String code;
  int id;
  ReportTypeItem({
    required this.text,
    required this.code,
    required this.id,
  });
  factory ReportTypeItem.fromJson(Map<String, dynamic> json) {
    return ReportTypeItem(
      text: json['text'],
      code: json['code'],
      id: json['id'],
    );
  }
}