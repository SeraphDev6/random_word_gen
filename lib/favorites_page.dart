import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: Center(
            child: Text('You have '
                '${appState.favorites.length} favorites:'),
          ),
        ),
        for (var pair in appState.favorites)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              elevation: 5,
              child: ListTile(
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                  color: Colors.red,
                  onPressed: () {
                    appState.removeFavorite(pair);
                  },
                ),
                title: Text(pair.asLowerCase),
                enableFeedback: true,
              ),
            ),
          ),
      ],
    );
  }
}
