import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import "package:olca_oslc/ipc.dart" as ipc;
import "package:olca_oslc/olca.dart" as o;
import "package:olca_oslc/turtle.dart";

class _Args {
  int olcaPort = 8080;
  int port = 8000;

  _Args.of(List<String> cliArgs) {
    String? flag;
    for (var cliArg in cliArgs) {
      if (cliArg.startsWith("-")) {
        flag = cliArg;
        continue;
      }
      if (flag == null) {
        continue;
      }
      switch (flag) {
        case "-olca":
          olcaPort = int.parse(cliArg);
          break;
        case "-port":
          port = int.parse(cliArg);
          break;
      }
      flag = null;
    }
  }
}

main(List<String> args) async {
  var appArgs = _Args.of(args);
  var base = "http://localhost:${appArgs.port}";
  print("bridge openLCA service @${appArgs.olcaPort} to $base");

  try {
    var client = ipc.Client(appArgs.olcaPort);

    final router = Router();

    router.get("/", (Request req) async {
      var about = QName.uri(base);
      var doc = Document()
        ..addPrefix(Vocab.oslci)
        ..add(about, QName.a, Vocab.oslci.nameOf("ServiceProvider"))
        ..add(about, Vocab.oslci.nameOf("queryBase"), about);

      return Response.ok(doc.toString(),
          headers: {"Content-Type": "text/turtle; charset=utf-8"});
    });

    router.get("/processes", (Request req) async {
      var refs = await client.getDescriptors(o.RefType.process);

      var text = """

""";

      return Response.ok("${refs.length} processes");
    });

    await shelf_io.serve(router, "localhost", appArgs.port);
  } catch (e) {
    print("ERROR: failed to start service: $e");
  }
}
