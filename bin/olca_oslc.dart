import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import "package:olca_oslc/ipc.dart" as ipc;
import "package:olca_oslc/olca.dart" as o;

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
  print("bridge openLCA service @${appArgs.olcaPort}"
      " to http://localhost:${appArgs.port}");

  try {
    var client = ipc.Client(appArgs.olcaPort);

    final router = Router();

    router.get("/", (Request req) async {
      return Response.ok("root");
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
