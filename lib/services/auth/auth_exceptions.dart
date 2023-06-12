// login Exceptions

class InvalidEmailAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

// register Exceptions

class EmailALreadyInUseAuthException implements Exception {}
class WeakPasswordAuthException implements Exception {}

// generic Exceptions

class GenericException implements Exception {}

// Unknown Exceptions

class UserNotLoggedInAuthException implements Exception {}