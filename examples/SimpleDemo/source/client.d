module client;

import helloworld.helloworld;
import helloworld.helloworldrpc;

import grpc;
import hunt.logging;
import std.stdio;

void main() {
    string host = "127.0.0.1";
    ushort port = 30051;

    auto channel = new Channel(host, port);
    GreeterClient client = new GreeterClient(channel);
    HelloRequest request = new HelloRequest();
    request.name = "Hunt";

    try {

        HelloReply replyHello = client.SayHello(request);
        tracef("++++++++++++++++%s", replyHello.message);

        HelloReply replyBye = client.SayGoodBye(request);
        tracef("++++++++++++++++%s", replyBye.message);

        client.SayHello(request, (Status status, HelloReply response) {
            tracef("response: %s", response.message);
        });

        client.SayGoodBye(request, (Status status, HelloReply response) {
            tracef("response: %s", response.message);
        });
    } catch (GrpcTimeoutException e) {
        channel.destroy();
        // reConnect;
    } catch (Exception e) {
        //connection error
        error(e);
    }

    getchar();

}
