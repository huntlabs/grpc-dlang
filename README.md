[![Build Status](https://travis-ci.org/huntlabs/grpc-dlang.svg?branch=master)](https://travis-ci.org/huntlabs/grpc-dlang)

# grpc-dlang
gRPC implementation for D.

### Building

### Building the protocol buffer compiler for D
```sh
$ dub build :protoc-gen-d
$ sudo cp build/protoc-gen-d /usr/local/bin
```

### Building the gRPC plugin for D

```sh
$ git submodule update --init --recursive
# Update Git submodule to latest commit on origin
# git submodule update --remote --merge
$ cd compiler
$ mkdir build
$ cd build
$ cmake ..
$ make -j4
$ sudo cp deps/protobuf/protoc* /usr/local/bin
$ sudo cp grpc_dlang_plugin /usr/local/bin
```

### Building the core library
```sh
cd grpc-dlang
dub build
```

### Generating protobuf code
```sh
protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./examples -I ./examples ./examples/helloworld.proto
```

### Generating grpc client and server code
```sh
protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./examples --grpc_out=./examples ./examples/helloworld.proto
```

### Building the examples

1. A simple demo
```shell
dub build -c=example
```

2. Demo for streaming
```sh 
dub build -c=streamexample
./streamexample -f ./examples/route_guide_db.json
```


## Samples
 
### The server
 
```D
import grpc;

import helloworld.helloworld;
import helloworld.helloworldrpc;

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

auto server = new Server();
server.listen(host , port);
server.register( new GreeterImpl());
server.start();
```

### The client
```D
import helloworld.helloworld;
import helloworld.helloworldrpc;
import grpc;
import std.stdio;

auto channel = new Channel("127.0.0.1" , 50051);
GreeterClient client = new GreeterClient(channel);

auto request = new HelloRequest();
request.name = "test";

HelloReply reply = client.SayHello(request);
 
if(reply !is null)
{
   writeln(reply.message);
}
```

### The streaming
We implemented the offical example [RouteGuide](https://github.com/huntlabs/hunt-grpc/tree/master/examples/routeguide) 

## Resources
- [cpp tutorial](https://github.com/grpc/grpc/blob/master/examples/cpp/cpptutorial.md).

