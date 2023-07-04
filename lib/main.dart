import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'grocery_bloc.dart';
import 'grocery_item.dart';
import 'grocery_state.dart';
import 'grocery_event.dart';

/*
 * Ethan Crow
 * 6/27/2023 - 7/1/2023
 * 
 * A single-screen Grocery List App using Flutter SDK.
 * Users can add, remove, and edit items on the grocery list.
 * Items on the list will persist after the app is closed.
 * 
 */

// Checks if provided text is just whitespace.
// Called when adding an item to the list to block items that are just whitespace.
bool isValidItem(String text) {
  return text.trim().isNotEmpty;
}

void main() {
  runApp(const GroceryApp());
}

// Provider and outermost shell of app
class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroceryBloc(),
      child: MaterialApp(
        key: const Key('groceryApp'),
        title: 'Grocery List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const GroceryScreen(),
        ),
    );
  }
}

// The primary screen of the app
class GroceryScreen extends StatelessWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Grocery List'),
        ),
        // determines what to render based on the app state
        body: BlocBuilder<GroceryBloc, GroceryState>(
          builder: (context, state) {
            if (state is GroceryInitial) {
              context.read<GroceryBloc>().add(LoadAppEvent());
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GroceryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GroceryLoaded) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputArea(),
                    const SizedBox(
                      height: 20,
                    ),
                    GroceryItems(list: context.select((GroceryBloc bloc) => bloc.list.list)),
                  ],
                ),
              );
            } else if (state is GroceryEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InputArea(),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'There\'s nothing here.',
                      style: TextStyle(
                        fontSize: 32,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Add something to your grocery list using the input bar.',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            // Default: error state
            } else {
              return const Center(
                child: Text(
                  'An error occurred.',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
              );
            }
          },
        )
      )
    );
  }
}

// the area for typing and adding a new item
class InputArea extends StatelessWidget {
  InputArea({super.key});

  final inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Theme.of(context).colorScheme.primary,
        ),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: inputController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add an item...',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textInputAction: TextInputAction.done,
                // user can submit by pressing '+ or by pressing enter on keyboard
                onSubmitted: (value) {
                  if (!isValidItem(inputController.text)) return;
                  context
                    .read<GroceryBloc>()
                    .add(GroceryAddEvent(name: inputController.text));
                  inputController.clear();
                },
                onTapOutside: ((event) {
                  FocusScope.of(context).unfocus();
                }),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (!isValidItem(inputController.text)) return;
              context
                .read<GroceryBloc>()
                .add(GroceryAddEvent(name: inputController.text));
              inputController.clear();
            },
            icon: const Icon(Icons.add),
          ),
        ]
      ),
    );
  }
}

// the list of all the grocery items
class GroceryItems extends StatelessWidget {
  const GroceryItems({super.key, required this.list});

  final List<GroceryItem> list;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return GroceryCard(
            item: list[index].name,
            added: list[index].added,
            id: list[index].id,
          );
        },
      ),
    );
  }
}

// a single item in the grocery list
class GroceryCard extends StatelessWidget {
  const GroceryCard(
    {super.key, required this.item, required this.added, required this.id}
  );

  final String item;
  final String added;
  final int id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(added),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => showEditDialog(context, item, id),
              icon: const Icon(Icons.edit)),
            IconButton(
              onPressed: () => showDeleteDialog(context, item, id),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

// a dialog for editing the contents of an item
Future<void> showEditDialog(BuildContext context, String name, int id) {
  // auto-fill the text input with the current item and highlight it
  final inputController = TextEditingController();
  inputController.text = name;
  inputController.selection = TextSelection(baseOffset: 0, extentOffset: inputController.value.text.length);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Item'),
        content: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              autofocus: true,
              controller: inputController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Editing $name',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              textInputAction: TextInputAction.done,
              // user can submit by pressing checkmark or by pressing enter on keyboard
              onSubmitted: (value) {
                if (!isValidItem(inputController.text)) return;
                context
                  .read<GroceryBloc>()
                  .add(GroceryEditEvent(newName: inputController.text, id: id));
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          IconButton(
            onPressed: () {
              if (!isValidItem(inputController.text)) return;
              context
                .read<GroceryBloc>()
                .add(GroceryEditEvent(newName: inputController.text, id: id));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      );
    },
  );
}

// a dialog for confirming deletion of an item
Future<void> showDeleteDialog(BuildContext context, String name, int id) {

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $name?'),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          IconButton(
            onPressed: () {
              context.read<GroceryBloc>().add(GroceryDeleteEvent(id: id));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check),
          ),
        ],
      );
    },
  );
}
