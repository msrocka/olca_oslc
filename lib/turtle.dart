class Vocab {
  static final oslc = Prefix("oslc", "http://open-service.net/ns/core#");
}

class Uri {
  String value;
  Uri(this.value);
}

class QName {
  late final Prefix? prefix;
  late final String name;

  static final QName a = QName.of(Prefix("", ""), "a");

  QName.uri(String uri) {
    name = uri;
    prefix = null;
  }

  QName.of(this.prefix, this.name);

  @override
  String toString() {
    if (prefix != null) {
      return prefix!.isEmpty ? name : "${prefix!.name}:$name";
    }
    return "<$name>";
  }

  String full() {
    return prefix != null ? "${prefix!.uri}$name" : name;
  }

  @override
  bool operator ==(Object? other) {
    if (other is QName) {
      return full() == other.full();
    }
    return false;
  }

  @override
  int get hashCode => full().hashCode;
}

class Prefix {
  String name;
  String uri;
  Prefix(this.name, this.uri);

  bool get isEmpty => name == "" && uri == "";

  QName nameOf(String name) {
    return QName.of(this, name);
  }

  bool matches(QName qname) {
    return qname.prefix != null
        ? name == qname.prefix!.name
        : qname.name.startsWith(uri);
  }

  QName apply(QName qname) {
    if (matches(qname)) {
      if (qname.prefix != null) {
        return qname;
      }
      return QName.of(this, qname.name.substring(name.length));
    }
    return qname;
  }

  @override
  String toString() {
    return "@prefix $name: <$uri>.";
  }

  @override
  bool operator ==(Object? other) {
    if (other is Prefix) {
      return toString() == other.toString();
    }
    return false;
  }

  @override
  int get hashCode => toString().hashCode;
}

class Document {
  final List<Prefix> _prefixes = [];
  final Map<QName, List<_Val>> _triples = {};

  addPrefix(Prefix prefix) {
    _prefixes.add(prefix);
  }

  add(QName subject, QName predicate, Object value) {
    var list = _triples.putIfAbsent(_adapt(subject), () => []);
    var str = value is String ? '"$value"' : value.toString();
    list.add(_Val(predicate, str));
  }

  QName _adapt(QName qname) {
    for (var p in _prefixes) {
      if (p.matches(qname)) {
        return p.apply(qname);
      }
    }
    return qname;
  }

  @override
  String toString() {
    var str = "";
    for (var p in _prefixes) {
      str += "$p\n";
    }
    str += "\n";

    for (var e in _triples.entries) {
      str += e.key.toString();
      for (int i = 0; i < e.value.length; i++) {
        if (i > 0) {
          str += ";";
        }
        str += "\n";
        var val = e.value[i];
        str += "  ${val.predicate} ${val.value}";
      }
      str += ".\n\n";
    }
    return str;
  }
}

class _Val {
  QName predicate;
  String value;

  _Val(this.predicate, this.value);
}
