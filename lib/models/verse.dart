class Verse {
  final String reference;
  final List<String> verses;

  Verse({required this.reference, required this.verses});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      reference: json['book']['name'] ??
          'Unknown Reference', // Berikan nilai default jika null
      verses: List<String>.from(json['verses']?.map((verse) => verse['text']) ??
          []), // Berikan list kosong jika null
    );
  }
}
