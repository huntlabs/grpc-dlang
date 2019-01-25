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
        logInfo(reply.message);
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

    auto channel = new Channel("127.0.0.1" , port);
    GreeterClient client = new GreeterClient(channel);
    
    string[] test_name = ["1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" , "0"];
    
    trace("444444");
    foreach(name ; test_name)    
    {
        HelloRequest request = new HelloRequest();
        request.name = name;
        HelloReply reply = client.SayHello(request );
        logInfo(  reply.message);
    }

    trace("xxxxxxxxx");
    getchar();
    trace("5555555555");

}