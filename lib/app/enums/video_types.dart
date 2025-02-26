enum VideoTypes {
  movie,
  series,
  music,
  porns;
}

VideoTypes getType(String name) {
  for (final type in VideoTypes.values) {
    if (type.name == name) {
      return type;
    }
  }
  return VideoTypes.movie;
}
