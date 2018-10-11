# hunt-grpc
Grpc for D programming language, hunt-http library based.

# Generating protobuf code
https://github.com/dcarp/protobuf-d

protoc --plugin=protoc-gen-d --d_out=./example -I ./doc ./doc/helloworld.proto

# Generating grpc client and server code
https://github.com/huntlabs/google-grpc
 
protoc -I ./doc/ --grpc_out=./example --plugin=protoc-gen-grpc=grpc_dlang_plugin ./doc/protos/helloworld.proto
 
 # example-server
 
```
  import helloworld.helloworld;
  import helloworld.helloworldrpc;
  import grpc;

  class GreeterImpl : GreeterBase
  {
      override HelloReply SayHello(HelloRequest request)
      {
          HelloReply reply = new HelloReply();
          reply.message = "hello " ~ request.name;
          return reply;
      }
  }


  string host = "0.0.0.0";
  ushort port = 50051;

  Server server = new Server();
  server.listen(host , port);
  server.register( new GreeterImpl());
  server.start();
```

# example-client
```
  import helloworld.helloworld;
  import helloworld.helloworldrpc;
  import grpc;

  auto channel = new Channel("127.0.0.1" , 50051);
  GreeterClient client = new GreeterClient(channel);

  HelloRequest request = new HelloRequest();
  request.name = "test";
  HelloReply reply = client.SayHello(request);
  ```
 # build
 
 1 dub build ---  lib
 
 2 dub build -c=example --- example  
 
  
