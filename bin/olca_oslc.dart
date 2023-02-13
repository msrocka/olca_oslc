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

class Provider {
  o.RefType type;
  String name;

  Provider(this.type, this.name);

  static List<Provider> all() {
    return [
      Provider(o.RefType.actor, "actors"),
      Provider(o.RefType.currency, "currencies"),
      Provider(o.RefType.dqSystem, "dq-systems"),
      Provider(o.RefType.epd, "epds"),
      Provider(o.RefType.flow, "flows"),
      Provider(o.RefType.flowProperty, "flow-properties"),
      Provider(o.RefType.impactCategory, "impact-categories"),
      Provider(o.RefType.impactMethod, "impact-methods"),
      Provider(o.RefType.location, "locations"),
      Provider(o.RefType.parameter, "parameters"),
      Provider(o.RefType.process, "processes"),
      Provider(o.RefType.productSystem, "product-systems"),
      Provider(o.RefType.project, "projects"),
      Provider(o.RefType.result, "results"),
      Provider(o.RefType.socialIndicator, "social-indicators"),
      Provider(o.RefType.source, "sources"),
      Provider(o.RefType.unitGroup, "unit-groups"),
    ];
  }

  QName q(String base) {
    return QName.uri("$base/data/$name");
  }

  QName resource(String base, String? id) {
    return QName.uri("$base/data/$name/$id");
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
      var doc = Document()..addPrefix(Vocab.oslc);
      for (var provider in Provider.all()) {
        var q = provider.q(base);
        doc.add(q, QName.a, Vocab.oslc.nameOf("ServiceProvider"));
        doc.add(q, Vocab.oslc.nameOf("queryBase"), q);
        doc.add(q, Vocab.oslc.nameOf("creation"), q);
      }
      return Response.ok(doc.toString(),
          headers: {"Content-Type": "text/turtle; charset=utf-8"});
    });

    for (var provider in Provider.all()) {
      router.get("/data/${provider.name}", (Request req) async {
        var doc = Document()..addPrefix(Vocab.rdfs);
        var refs = await client.getDescriptors(provider.type);
        for (var ref in refs) {
          doc.add(provider.q(base), Vocab.rdfs.nameOf("member"),
              provider.resource(base, ref.id));
        }
        return Response.ok(doc.toString(),
            headers: {"Content-Type": "text/turtle; charset=utf-8"});
      });
    }

    for (var provider in Provider.all()) {
      router.get("/data/${provider.name}/<id>", (Request req, String id) async {
        var ref = await client.getDescriptor(provider.type, id);
        var doc = Document()..addPrefix(Vocab.dcterms);
        var about = provider.resource(base, ref.id);
        doc.add(
            about,
            QName.a,
            QName.uri(
                "https://greendelta.github.io/olca-schema/classes/${provider.type.type}.html"));
        doc.add(about, Vocab.dcterms.nameOf("identifier"), ref.id);
        doc.add(about, Vocab.dcterms.nameOf("title"), ref.name);
        doc.add(about, Vocab.dcterms.nameOf("hasVersion"), ref.version);
        return Response.ok(doc.toString(),
            headers: {"Content-Type": "text/turtle; charset=utf-8"});
      });
    }

    await shelf_io.serve(router, "localhost", appArgs.port);
  } catch (e) {
    print("ERROR: failed to start service: $e");
  }
}
