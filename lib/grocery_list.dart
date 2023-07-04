import 'grocery_item.dart';

// An object that stores a list of GroceryItems and automatically assigns each new item a unique ID
class GroceryList {

  // fields
  List<GroceryItem> list = [];
  int nextID = 0;

  // constructors
  GroceryList();
  GroceryList.fromValues({
    required this.list,
    required this.nextID,
  });

  // methods
  void addItem(String name) {
    DateTime currentTime = DateTime.now();
    list.add(GroceryItem(
      name: name, 
      id: nextID, 
      added: '${currentTime.month}/${currentTime.day}'
    ));
    nextID++;
  }

  void editItem(int id, String newName) {
    GroceryItem item = list.firstWhere((element) => element.id == id);
    item.editName(newName);
  }

  void deleteItem(int id) {
    list.removeWhere((element) => element.id == id);
  }
}