import "lib/streams" =~ [
    => flow :DeepFrozen, => fuse :DeepFrozen, => alterSink :DeepFrozen]
import "src/messages" =~ [=> makeParserPump :DeepFrozen]
exports (makePSQLEndpoint)


def makePSQLEndpoint(endpoint) as DeepFrozen:
    return object PSQLEndpoint:
        to listen(processor):
            def responder(source, sink):
                def message := makeParserPump()
                flow(source, alterSink.fusePump(message, sink))
            endpoint.listenStream(responder)
