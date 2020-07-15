module GreeterImpl;

import helloworld.helloworld;
import helloworld.helloworldrpc;
import grpc;

import hunt.logging.ConsoleLogger;

/**
 * 
 */
class GreeterImpl : GreeterBase {
    override Status SayHello(HelloRequest request, ref HelloReply reply) {
        reply.message = "Hello " ~ request.name;
        tracef("request: %s, reply: %s", request.name, reply.message);
        return Status.OK;
    }

    override Status SayGoodBye(HelloRequest request, ref HelloReply reply) {
        reply.message = "Bye " ~ request.name;
        tracef("request: %s, reply: %s", request.name, reply.message);
        return Status.OK;
    }
}
