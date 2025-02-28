enum VideoFileInfoTypes {
  info,
  realData,
  link,
}

VideoFileInfoTypes getType(String name) {
  for (final type in VideoFileInfoTypes.values) {
    if (type.name == name) {
      return type;
    }
  }
  return VideoFileInfoTypes.info;
}
