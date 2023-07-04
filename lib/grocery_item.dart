// an object that represents an item on a grocery list
// has fields for name, date added, and unique ID

class GroceryItem {

  // fields
  late String name;
  late String added;
  final int id;

  // constructor
  GroceryItem({
    required this.name,
    required this.id,
    required this.added,
  });

  // edit method
  void editName(String newName) {
    name = newName;
  }

  // encoding/decoding methods for storage via sharedpreferences
  factory GroceryItem.fromJson(Map<String, dynamic> parsedJson) {
    return GroceryItem(
      name: parsedJson['name'] ?? "",
      id: parsedJson['id'] ?? "",
      added: parsedJson['added'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
      "added": added,
    };
  }
}