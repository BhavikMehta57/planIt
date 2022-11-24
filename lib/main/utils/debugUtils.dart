void printInYellow(String message) {
  print('\x1B[33m$message\x1B[0m');
}

void printError(String message) {
  print('\x1B[31m$message\x1B[0m');
}