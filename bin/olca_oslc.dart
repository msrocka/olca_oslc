import 'package:olca_oslc/olca_oslc.dart' as o;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import "package:olca_oslc/ipc.dart" as ipc;
import "package:olca_oslc/olca.dart" as o;

main(List<String> arguments) async {
  var client = ipc.Client(8080);
  print('Hello world: ${o.calculate()}!');
  final router = Router();

  router.get("/data/processes", (Request req) async {
    var refs = await client.getDescriptors(o.RefType.process);
    var text = """

""";

    return Response.ok("${refs.length} processes");
  });

  await shelf_io.serve(router, "localhost", 8001);
}
