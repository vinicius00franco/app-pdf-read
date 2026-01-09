class SavedPdf {
  final String id;
  final String originalName;
  final String pdfUrl;
  final DateTime savedAt;
  final int lastPage;

  SavedPdf({
    required this.id,
    required this.originalName,
    required this.pdfUrl,
    required this.savedAt,
    this.lastPage = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalName': originalName,
    'pdfUrl': pdfUrl,
    'savedAt': savedAt.toIso8601String(),
    'lastPage': lastPage,
  };

  factory SavedPdf.fromJson(Map<String, dynamic> json) => SavedPdf(
    id: json['id'],
    originalName: json['originalName'],
    pdfUrl: json['pdfUrl'],
    savedAt: DateTime.parse(json['savedAt']),
    lastPage: json['lastPage'] ?? 1,
  );
}