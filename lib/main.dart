import 'dart:ffi';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'generator_page.dart';
import 'favorites_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: MyHomePage(
          storage: FavoriteStorage(),
        ),
      ),
    );
  }
}

class FavoriteStorage {
  static final FavoriteStorage _instance = FavoriteStorage._internal();
  factory FavoriteStorage() {
    return _instance;
  }
  FavoriteStorage._internal();
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/favorites.txt');
  }

  Future<File> writeFavorites(List<WordPair> favorites) async {
    final file = await _localFile;
    final str = favorites.map((e) => "${e.first} ${e.second}").join("\n");
    return file.writeAsString(str);
  }

  Future<List<WordPair>> readFavorites() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      var favorites = contents
          .split("\n")
          .map((e) => WordPair(e.split(" ")[0], e.split(" ")[1]))
          .toList();
      return favorites;
    } catch (e) {
      // If encountering an error, return 0
      print(e);
      return <WordPair>[];
    }
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  Future<File> toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();

    return FavoriteStorage._instance.writeFavorites(favorites);
  }

  Future<File> removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
    return FavoriteStorage._instance.writeFavorites(favorites);
  }

  void setFavorites(List<WordPair> favs) {
    favorites = favs;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.storage});
  final FavoriteStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      widget.storage
          .readFavorites()
          .then((value) => appState.setFavorites(value));
    }
    var theme = Theme.of(context);
    Widget page;
    switch (currentPageIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("No widget for $currentPageIndex");
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            color: theme.colorScheme.primaryContainer,
            child: page,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
        ],
        currentIndex: currentPageIndex,
        selectedItemColor: theme.colorScheme.primary,
        onTap: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
      ),
    );
  }
}
