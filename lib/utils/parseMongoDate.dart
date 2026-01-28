DateTime? parseMongoDate(dynamic value) {
  if (value == null) return null;

  // если уже строка ISO
  if (value is String) {
    return DateTime.parse(value);
  }

  // если Mongo Extended JSON
  if (value is Map && value['\$date'] != null) {
    final date = value['\$date'];

    if (date is String) {
      return DateTime.parse(date);
    }

    if (date is int) {
      return DateTime.fromMillisecondsSinceEpoch(date);
    }
  }

  return null;
}
