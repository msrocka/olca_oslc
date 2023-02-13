class Prefix {
  String prefix;
  String base;
  Prefix(this.prefix, this.base);

  bool matches(String uri) {
    return uri.startsWith(base);
  }

  String apply(String uri) {
    if (!matches(uri)) {
      return uri;
    }
    return uri.replaceFirst(base, "$prefix:");
  }

  @override
  String toString() {
    return "@prefix $prefix: <$base>.";
  }
}

class Document {
  final List<Prefix> _prefixes = [];
}
