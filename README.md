# hunt-grpc
Grpc for D programming language, hunt-http library based.

# Generating protobuf code
https://github.com/dcarp/protobuf-d

protoc --plugin=protoc-gen-d --d_out=./example -I ./doc ./doc/helloworld.proto

# Generating grpc client and server code
https://github.com/huntlabs/google-grpc
 
protoc -I ./doc/ --grpc_out=./example --plugin=protoc-gen-grpc=grpc_dlang_plugin ./doc/protos/helloworld.proto
 
 # example-server
 
```D
  import helloworld.helloworld;
  import helloworld.helloworldrpc;
  import grpc;

  class GreeterImpl : GreeterBase
  {
      override Status SayHello(HelloRequest request , ref HelloReply reply)
      {
          reply.message = "hello " ~ request.name;
          return Status.OK;
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
```D
  import helloworld.helloworld;
  import helloworld.helloworldrpc;
  import grpc;
  import std.stdio;

  auto channel = new Channel("127.0.0.1" , 50051);
  GreeterClient client = new GreeterClient(channel);

  HelloRequest request = new HelloRequest();
  HelloReply reply = new HelloReply();
  request.name = "test";
  auto status = client.SayHello(request , reply);
  if(status.ok())
  {
     writeln(reply.message);
  }
  ```
  
 
  
  # example for streaming
  We implemented the offical example [RouteGuide](https://github.com/huntlabs/hunt-grpc/tree/master/examples/routeguide) 
  
  
  offical link:https://github.com/grpc/grpc/blob/master/examples/cpp/cpptutorial.md
 # build (dmd only , some bug in ldc)

for library:
```shell
dub build
 ```

 for example:
 ```shell
 dub build -c=example
 ```
 
 for streaming example:
 ```shell
 dub build -c=streamexample
 ```
