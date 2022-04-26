class DuckDTO {
  final String url;

  const DuckDTO({required this.url});

  factory DuckDTO.fromJson(Map<String, dynamic> json) {
    return DuckDTO(url: json['url']);
  }
}
