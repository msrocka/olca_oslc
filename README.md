# An openLCA - OSLC Bridge

This is a small experimental project to explore a mapping of the
[openLCA IPC protocol](https://greendelta.github.io/openLCA-ApiDoc/ipc/) to
[OSLC](https://open-services.net/). Currently, this is just a small bridge
server that consumes an openLCA IPC endpoint of the openLCA JSON-RPC protocol
and maps this to a set of OSLC service providers. 

## Usage

Make sure that an openLCA IPC server is running with the standard JSON-RPC
protocol. You can start such an IPC server from the openLCA user interface:
`Tools > Developer tools > IPC Server`. The bridge server can be then started
from the command line like this:

```
olca_oslc -olca [port of the openLCA server] -port [port of the bridge server]
```

It takes two arguments which are both optional:

* `-olca`: The port where the openLCA IPC server is running, defaults to `8080`.
* `-port`: The port of the bridge server; defaults to `8000`.


## Routes

The resource URIs of the bridge server all start with the base URL of that
server. In the example below, the serve runs on `http://localhost:8010`, so the
URIs are relative to that.

### `GET /`

Returns the available service providers. For each openLCA root entity type, a
separate service provider is mounted.

```turtle
# example response of GET http://localhost:8010

@prefix oslc: <http://open-service.net/ns/core#>.

# ...

<http://localhost:8010/data/flows>
  a oslc:ServiceProvider;
  oslc:queryBase <http://localhost:8010/data/flows>;
  oslc:creation <http://localhost:8010/data/flows>.

<http://localhost:8010/data/processes>
  a oslc:ServiceProvider;
  oslc:queryBase <http://localhost:8010/data/processes>;
  oslc:creation <http://localhost:8010/data/processes>.

# ...
```

### `GET /{provider}`

Returns the available resources of the respective provider:

```turtle
# example response of GET http://localhost:8010/processes

@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.

<http://localhost:8010/data/processes>
  rdfs:member <http://localhost:8010/data/processes/2d1b0c1f-dd8f-3aea-bc50-bbd10acbd86d>;
  rdfs:member <http://localhost:8010/data/processes/887bc2f7-9c3b-388c-ac9a-3bd578af1cf6>;
  rdfs:member <http://localhost:8010/data/processes/cd28b192-66ac-38d2-ab3b-82a97b845d59>;
  rdfs:member <http://localhost:8010/data/processes/7ff672e3-a296-30e8-b1bb-a3173711a28b>;
  rdfs:member <http://localhost:8010/data/processes/8d502e2e-456b-3c2a-a678-ba4c651cb8b1>;
# ...

```

### `GET /{provider}/{id}`

Returns some meta-data of a resource:

```turtle
# example response of GET http://localhost:8010/data/processes/7ff672e3-a296-30e8-b1bb-a3173711a28b

@prefix dcterms: <http://purl.org/dc/terms/>.

<http://localhost:8010/data/processes/7ff672e3-a296-30e8-b1bb-a3173711a28b>
  a <https://greendelta.github.io/olca-schema/classes/Process.html>;
  dcterms:identifier "7ff672e3-a296-30e8-b1bb-a3173711a28b";
  dcterms:title "compost plant, open".
```