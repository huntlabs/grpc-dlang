module helloworld.example;

import helloworld.helloworld;

import helloworld.helloworldrpc;
import grpc;
import hunt.logging;
import std.stdio;


class GreeterImpl : GreeterBase
{
    override Status SayHello( HelloRequest request , ref HelloReply reply)
    {
        reply.message = "hello " ~ request.name;
        return Status.OK;
    }

    override Status SayGoodBye( HelloRequest request , ref HelloReply reply)
    {
        reply.message = "bye " ~ request.name;
        return Status.OK;
    }
}



void main()
{
    string host = "0.0.0.0";
    ushort port = 30051;

    Server server = new Server();
    server.listen(host , port);
    server.register( new GreeterImpl());
    server.start();


    auto channel = new Channel(host , port);
    GreeterClient client = new GreeterClient(channel);
    HelloRequest request = new HelloRequest();
    request.name = "abcdefg";

    try {

        HelloReply replyHello = client.SayHello(request);
        tracef("++++++++++++++++%s" ,replyHello.message);

        HelloReply replyBye = client.SayGoodBye(request);
        tracef("++++++++++++++++%s" ,replyBye.message);


        client.SayHello(request,&client.onDataSayHello);

        client.SayGoodBye(request,&client.onDataSayGoodBye);
    }  catch (GrpcTimeoutException e) {
        channel.destroy();
        // reConnect;
    }  catch (Exception e)
    {
        //connection error
    }


    getchar();

}
