// Model for streaming services available on Watchmode
class StreamingService {
  final int id;
  final String name;
  final String? logoUrl;

  StreamingService({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory StreamingService.fromJson(Map<String, dynamic> json) {
    return StreamingService(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      logoUrl: json['logo_url'],
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamingService &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Model for source details within a movie/season source
class Source {
  final int sourceId;
  final String sourceName;
  final String type; // "subscription", "purchase", "rent", etc.
  final bool isAndroid;
  final bool isIos;
  final bool isWeb;

  Source({
    required this.sourceId,
    required this.sourceName,
    required this.type,
    this.isAndroid = true,
    this.isIos = true,
    this.isWeb = true,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      sourceId: json['source_id'],
      sourceName: json['source_name'] ?? 'Unknown',
      type: json['type'] ?? 'subscription',
      isAndroid: json['android'] ?? true,
      isIos: json['ios'] ?? true,
      isWeb: json['web'] ?? true,
    );
  }
}
