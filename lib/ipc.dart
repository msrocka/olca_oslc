import 'dart:convert';
import 'olca.dart';
import 'package:http/http.dart' as http;

class Client {
  late String _host;
  int _id = 0;

  Client(int port) {
    _host = "localhost:$port";
  }

  int _nextId() {
    _id++;
    return _id;
  }

  Future<Ref> getDescriptor(RefType type, String id) async {
    var r = await _call("data/get/descriptor", {"@type": type.type, "@id": id});
    return Ref.of(r as Map);
  }

  Future<List<Ref>> getDescriptors(RefType type) async {
    return _each<Ref>("data/get/descriptors", Ref.of,
        params: {"@type": type.type});
  }

  Future<List<T>> _each<T>(String method, T Function(Map) fn,
      {Map<String, Object?>? params}) async {
    var r = await _call(method, params);
    var ts = <T>[];
    for (var x in r as List) {
      if (x is Map) {
        ts.add(fn(x));
      }
    }
    return ts;
  }

  Future<Object> _call(String method, [Map<String, Object?>? params]) async {
    var uri = Uri.http(_host);
    var body = {
      "jsonrpc": "2.0",
      "id": _nextId(),
      "method": method,
    };
    if (params != null) {
      body["params"] = params;
    }
    var resp = await http.post(uri, body: json.encode(body));
    var map = json.decode(resp.body) as Map;
    var err = map["error"];
    if (err != null) {
      throw Exception("$method failed: $err");
    }
    return map["result"];
  }
}
