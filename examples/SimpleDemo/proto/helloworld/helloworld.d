// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: helloworld.proto

module helloworld.helloworld;

import google.protobuf;

enum protocVersion = 3012004;

class HelloRequest
{
    @Proto(1) string name = protoDefaultValue!string;
}

class HelloReply
{
    @Proto(1) string message = protoDefaultValue!string;
}
