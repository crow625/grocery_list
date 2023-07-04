// Possible app states.
abstract class GroceryState {}

// initial state of the app
class GroceryInitial extends GroceryState {}

// while the app is loading or saving data
class GroceryLoading extends GroceryState {}

// if an error occurs
class GroceryError extends GroceryState {}

// if the list is empty
class GroceryEmpty extends GroceryState {}

// if the list is populated and ready for presentation
class GroceryLoaded extends GroceryState {}