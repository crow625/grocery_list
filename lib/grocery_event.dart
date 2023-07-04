// Possible events that can be triggered by the app.
abstract class GroceryEvent {}

// triggered when the app is rendered
class LoadAppEvent extends GroceryEvent {}

// triggered when an error occurs
class ThrowErrorEvent extends GroceryEvent {}

// triggered when an item is added to the grocery list
class GroceryAddEvent extends GroceryEvent {
  String name;

  GroceryAddEvent({required this.name});
}

// triggered when an item's name is changed
class GroceryEditEvent extends GroceryEvent {
  String newName;
  int id;

  GroceryEditEvent({required this.newName, required this.id});
}

// triggered when an item is deleted from the grocery list
class GroceryDeleteEvent extends GroceryEvent {
  int id;

  GroceryDeleteEvent({required this.id});
}