
module helloworld.raw_example;


import helloworld.helloworld;
import google.protobuf;
import grpc;
import std.stdio;
import std.array:array;




import hunt.logging;

class MyService : GrpcService
{
    string getModule()
    {
        return "helloworld.Greeter";
    }

    Status process(string method , GrpcStream stream)
    {
        HelloRequest request = new HelloRequest();
        logInfo(method , " " , " process ");
        while(stream.read(request))
        {
            HelloReply reply = new HelloReply();
            reply.message = "hello " ~ request.name;
            logInfo(reply.message);
            stream.write(reply);
        }
        return Status.OK;
    }
}




void main() {

    string host = "0.0.0.0";
    ushort port = 30051;

    GrpcServer server = new GrpcServer();
    server.listen(host , port);
    server.register( new MyService());
    server.start();

    GrpcClient client = new GrpcClient();

    client.connect("127.0.0.1" , port);
    HelloRequest request = new HelloRequest();
    request.name = "world";
    
    for(size_t i = 0 ; i < 10 ; i++)
    {
        auto stream =  client.createStream("/helloworld.Greeter/SayHello");
        stream.write(request, true);

        HelloReply reply;
        while(stream.read(reply))
        {
            logInfo(reply.message);
        }
        auto status = stream.finish();
        logInfo(status.errorCode , " " , status.errorMessage);
    }

    

    getchar();

}
