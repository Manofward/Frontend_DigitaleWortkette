class LocalUserData{
  static String username = "Gast";
}

String getUsername() {
  return LocalUserData.username; // needs to be edited to get the username from the backend.
}

void setUsername(String inputUsername) {
  LocalUserData.username = inputUsername;
}