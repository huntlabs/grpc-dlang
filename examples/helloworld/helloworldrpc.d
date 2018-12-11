module helloworld.helloworldrpc;


// Generated by the gRPC dlang plugin.
// If you make any local change, they will be lost.


import helloworld.helloworld;
import std.array;
public import hunt.net.Result;
import grpc;
import google.protobuf;
import hunt.logging;
import core.thread;



class GreeterClient
{
    this(Channel channel)
    {
        _channel = channel;
    }

    Status SayHello( HelloRequest request ,ref HelloReply response)
    {
        mixin(CM!(GreeterBase.SERVICE));
    }

    void SayHello( HelloRequest request , void delegate(Status status , HelloReply response) dele)
    {
        mixin(CMA!(HelloReply , GreeterBase.SERVICE));
    }


    private:
    Channel _channel;
}

class GreeterBase: GrpcService
{
    enum SERVICE  = "helloworld.Greeter";
    string getModule()
    {
        return SERVICE;
    }

    Status SayHello( HelloRequest , ref HelloReply ){ return Status.OK; }

    Status process(string method , GrpcStream stream)
    {
        switch(method)
        {
            mixin(SM!(HelloRequest , HelloReply , "SayHello"));

            mixin(NONE());
        }
    }
}

