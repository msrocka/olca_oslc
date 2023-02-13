import "dart:convert";

enum RefType {
  actor("Actor"),
  currency("Currency"),
  dqSystem("DQSystem"),
  epd("Epd"),
  flow("Flow"),
  flowProperty("FlowProperty"),
  impactCategory("ImpactCategory"),
  impactMethod("ImpactMethod"),
  location("Location"),
  parameter("Parameter"),
  process("Process"),
  productSystem("ProductSystem"),
  project("Project"),
  result("Result"),
  socialIndicator("SocialIndicator"),
  source("Source"),
  unitGroup("UnitGroup");

  final String type;
  const RefType(this.type);

  static RefType? of(String type) {
    for (var t in RefType.values) {
      if (t.type == type) {
        return t;
      }
    }
    return null;
  }
}

class Ref {
  String? id;
  String? name;

  Ref();

  Ref.of(Map<dynamic, dynamic> map) {
    withValuesOf(map);
  }

  Ref.fromJson(String s) {
    var map = json.decode(s);
    if (map is Map) {
      withValuesOf(map);
    }
  }

  Ref withValuesOf(Map<dynamic, dynamic> dict) {
    var id = dict["@id"];
    if (id is String) {
      this.id = id;
    }
    var name = dict["name"];
    if (name is String) {
      this.name = name;
    }
    return this;
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{};
    if (id != null) {
      map["@id"] = id;
    }
    if (name != null) {
      map["name"] = name;
    }
    return map;
  }

  String toJson() {
    return json.encode(toMap());
  }
}
