import 'package:olca_oslc/olca_oslc.dart' as o;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

main(List<String> arguments) async {
  print('Hello world: ${o.calculate()}!');
  final router = Router();

  router.get("/data/processes", (Request req) {
    return Response.ok("Works!");
  });

  await shelf_io.serve(router, "localhost", 8080);

}
