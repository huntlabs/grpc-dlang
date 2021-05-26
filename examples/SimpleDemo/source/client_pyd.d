module client_pyd;

import pyd.pyd;

import helloworld.helloworld;
import helloworld.helloworldrpc;

import grpc;
import hunt.logging;
import std.stdio;


class PydGreeterClient {
  string host = "127.0.0.1";
  ushort port = 30051;
  GreeterClient client;

  this() {
    auto channel = new Channel(host, port);
    client = new GreeterClient(channel);
  }

  auto SayHello(string name) {
    HelloReply reply;
    HelloRequest request = new HelloRequest();
    request.name = name;
    try {
      reply = client.SayHello(request);
    } catch (Exception e) {  //connection error
      error(e);
    }
    return reply; //.message;
  }
}

// python3 setup.py build

extern(C) void PydMain() {
    module_init();

    wrap_class!(
        helloworld.helloworld.HelloReply,
	Member!("message", Mode!"rw")
    )();

    wrap_class!(
        PydGreeterClient,
        Init!(),
        Def!(PydGreeterClient.SayHello)
    )();
}
