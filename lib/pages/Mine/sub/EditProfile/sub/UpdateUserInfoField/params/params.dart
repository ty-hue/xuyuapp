class UpdateUserInfoFieldParams {
  final String title;
  final String tip;
  final String? initialValue;
  final int maxLength;

  const UpdateUserInfoFieldParams({
    required this.title,
    required this.tip,
    this.initialValue,
    required this.maxLength,
  });
}