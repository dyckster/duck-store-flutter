class DuckUiModel {
  final String url;
  final bool isRare;

  const DuckUiModel({required this.url, required this.isRare});

  factory DuckUiModel.empty() {
    return const DuckUiModel(
        url: "https://i.imgur.com/H7dRYc8.png", isRare: false);
  }
}
