# An openLCA - OSLC Bridge

This is a small experimental project to explore a mapping of the
[openLCA IPC protocol](https://greendelta.github.io/openLCA-ApiDoc/ipc/) to
[OSLC](https://open-services.net/). Currently, this is just a small bridge
server that consumes an openLCA IPC endpoint of the openLCA JSON-RPC protocol
and maps this to an OSLC ServiceProvider endpoint. 

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
* `-port`: this is the port of the bridge server, defaults to `8000`.


## Endpoints

### `/`

Returns the information about the service provider

```turtle
@prefix oslc: <http://open-service.net/ns/core#>.

<http://localhost:8010>
  a oslc:ServiceProvider;
  oslc:queryBase <http://localhost:8010>.
```