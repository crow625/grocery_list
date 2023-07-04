import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'grocery_state.dart';
import 'grocery_event.dart';
import 'grocery_list.dart';
import 'grocery_item.dart';

// BLoC for controlling state management
class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {

  // stores all the grocery items
  late GroceryList list;

  GroceryBloc(): super(GroceryInitial()) {

    // fetches list from shared preferences on app load
    on<LoadAppEvent>((event, emit) async {
      emit(GroceryLoading());
      list = await _getGroceryList();
      if (list.list.isEmpty) {
        emit(GroceryEmpty());
      } else {
        emit(GroceryLoaded());
      }
    });

    // throws error
    on<ThrowErrorEvent>((event, emit) {
      emit(GroceryError());
    });

    // adds item to list
    on<GroceryAddEvent>((event, emit) {
      emit(GroceryLoading());
      list.addItem(event.name);
      _saveGroceryList(list);
      emit(GroceryLoaded());
    });

    // edits item on list
    on<GroceryEditEvent>((event, emit) {
      emit(GroceryLoading());
      list.editItem(event.id, event.newName);
      _saveGroceryList(list);
      emit(GroceryLoaded());
    });

    // removes item from list
    on<GroceryDeleteEvent>((event, emit) {
      emit(GroceryLoading());
      list.deleteItem(event.id);
      _saveGroceryList(list);
      if (list.list.isEmpty) {
        emit(GroceryEmpty());
      } else {
        emit(GroceryLoaded());
      }
    });
  }
  
}

// writes the current list to storage
// called whenever an item is added, edited, or deleted
void _saveGroceryList(GroceryList groceryList) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  List<String> listEncoded = groceryList.list.map((item) => jsonEncode(item.toJson())).toList();
  await sharedPreferences.setStringList('groceryList', listEncoded);
  await sharedPreferences.setInt('nextID', groceryList.nextID);
}

// fetches the list from storage
// called on app load
Future<GroceryList> _getGroceryList() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  final List<String> listEncoded = sharedPreferences.getStringList('groceryList') ?? [];
  final list = listEncoded.map((item) => GroceryItem.fromJson(jsonDecode(item))).toList();
  final nextID = sharedPreferences.getInt('nextID') ?? 0;
  return GroceryList.fromValues(nextID: nextID, list: list);
}
