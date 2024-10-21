import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'models/verse.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BibleChapterScreen(),
    );
  }
}

class BibleChapterScreen extends StatefulWidget {
  @override
  _BibleChapterScreenState createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends State<BibleChapterScreen> {
  final TextEditingController _controller = TextEditingController();
  Future<Verse>? _futureVerse;
  List<Verse>? _searchResults;
  String version = "kjv"; // Versi default Alkitab
  String book = "gn"; // Default Kitab (Genesis)
  int chapter = 1;

  // Daftar kitab lengkap dan jumlah pasal yang tersedia
  final Map<String, int> availableBooks = {
    "Genesis": 50,
    "Exodus": 40,
    "Leviticus": 27,
    "Numbers": 36,
    "Deuteronomy": 34,
    "Joshua": 24,
    "Judges": 21,
    "Ruth": 4,
    "1 Samuel": 31,
    "2 Samuel": 24,
    "1 Kings": 22,
    "2 Kings": 25,
    "1 Chronicles": 29,
    "2 Chronicles": 36,
    "Ezra": 10,
    "Nehemiah": 13,
    "Esther": 10,
    "Job": 42,
    "Psalms": 150,
    "Proverbs": 31,
    "Ecclesiastes": 12,
    "Song of Songs": 8,
    "Isaiah": 66,
    "Jeremiah": 52,
    "Lamentations": 5,
    "Ezekiel": 48,
    "Daniel": 12,
    "Hosea": 14,
    "Joel": 3,
    "Amos": 9,
    "Obadiah": 1,
    "Jonah": 4,
    "Micah": 7,
    "Nahum": 3,
    "Habakkuk": 3,
    "Zephaniah": 3,
    "Haggai": 2,
    "Zechariah": 14,
    "Malachi": 4
  };

  final Map<String, String> bookCodes = {
    "Genesis": "gn",
    "Exodus": "ex",
    "Leviticus": "lv",
    "Numbers": "nm",
    "Deuteronomy": "dt",
    "Joshua": "js",
    "Judges": "jg",
    "Ruth": "rt",
    "1 Samuel": "1sm",
    "2 Samuel": "2sm",
    "1 Kings": "1kg",
    "2 Kings": "2kg",
    "1 Chronicles": "1ch",
    "2 Chronicles": "2ch",
    "Ezra": "ez",
    "Nehemiah": "ne",
    "Esther": "es",
    "Job": "jb",
    "Psalms": "ps",
    "Proverbs": "pr",
    "Ecclesiastes": "ec",
    "Song of Songs": "ss",
    "Isaiah": "is",
    "Jeremiah": "jr",
    "Lamentations": "lm",
    "Ezekiel": "ez",
    "Daniel": "dn",
    "Hosea": "hs",
    "Joel": "jl",
    "Amos": "am",
    "Obadiah": "ob",
    "Jonah": "jh",
    "Micah": "mc",
    "Nahum": "nh",
    "Habakkuk": "hk",
    "Zephaniah": "zp",
    "Haggai": "hg",
    "Zechariah": "zc",
    "Malachi": "ml"
  };

  String getBookName(String bookCode) {
    return availableBooks.entries
        .firstWhere((entry) => bookCodes[entry.key] == bookCode,
            orElse: () => MapEntry("Unknown", 0))
        .key;
  }

  void _searchVerse() {
    setState(() {
      _futureVerse = ApiService().fetchVerse(version, book, chapter);
    });
  }

  // Fungsi untuk mencari ayat berdasarkan kata kunci
  void _searchByKeyword(String keyword) async {
    try {
      final searchResult = await ApiService().searchVerses(keyword);
      setState(() {
        _searchResults = searchResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching verses: $e'),
        ),
      );
    }
  }

  // Tampilkan dialog pencarian
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Bible Verse'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter keyword or phrase (e.g. Shepherd)',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Search'),
              onPressed: () {
                Navigator.of(context).pop();
                _searchByKeyword(_controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  // Metode untuk menampilkan modal daftar kitab
  void _showBookSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Book and Chapter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: availableBooks.entries.map((entry) {
                    String bookName = entry.key;
                    int totalChapters = entry.value;
                    return ListTile(
                      title: Text(bookName),
                      onTap: () {
                        _showChapterSelectionModal(
                            context, bookName, totalChapters);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Metode untuk menampilkan modal daftar pasal dari kitab yang dipilih
  void _showChapterSelectionModal(
      BuildContext context, String selectedBook, int totalChapters) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Select Chapter in $selectedBook',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: totalChapters,
                  itemBuilder: (context, index) {
                    int chapterNumber = index + 1;
                    return ListTile(
                      title: Text('Chapter $chapterNumber'),
                      onTap: () {
                        Navigator.of(context).pop(); // Tutup pemilihan pasal
                        Navigator.of(context).pop(); // Tutup pemilihan kitab
                        setState(() {
                          book = bookCodes[selectedBook]!;
                          chapter = chapterNumber;
                          _futureVerse =
                              ApiService().fetchVerse(version, book, chapter);
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Fetch initial chapter based on book and chapter
    _searchVerse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${getBookName(book)} $chapter'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    getBookName(book),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$chapter',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Chapter $chapter',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: _searchResults != null && _searchResults!.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults!.length,
                      itemBuilder: (context, index) {
                        Verse verse = _searchResults![index];
                        return ListTile(
                          title: Text(verse.reference,
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(verse.verses.join("\n"),
                              style: TextStyle(color: Colors.white)),
                        );
                      },
                    )
                  : FutureBuilder<Verse>(
                      future: _futureVerse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white));
                        } else if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.verses.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '$chapter:${index + 1} ${snapshot.data!.verses[index]}',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              );
                            },
                          );
                        } else {
                          return Text('No data',
                              style: TextStyle(color: Colors.white));
                        }
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    if (chapter > 1) {
                      setState(() {
                        chapter--;
                        _futureVerse =
                            ApiService().fetchVerse(version, book, chapter);
                      });
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => _showBookSelectionModal(context),
                  child: Text('${getBookName(book)} $chapter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      chapter++;
                      _futureVerse =
                          ApiService().fetchVerse(version, book, chapter);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
