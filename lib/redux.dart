// One simple action: Increment
enum Actions { Connected }

// The reducer, which takes the previous count and increments it in response
// to an Increment action.
bool connectionReducer(bool state, dynamic action) {
  if (action == Actions.Connected) {
    if (state)
      return false;
    else
      return true;
  }
  return state;
}