module grpc.GrpcService;

import grpc.GrpcStream;
import grpc.Status;

import hunt.http.HttpFields;
import hunt.http.HttpMetaData;
import hunt.http.HttpScheme;
import hunt.http.HttpVersion;

import hunt.http.codec.http.frame;
import hunt.http.codec.http.stream;
import hunt.http.codec.http.model;
import hunt.util.Common;

import std.conv : to;

HeadersFrame endHeaderFrame(Status status , int streamId)
{
    HttpFields end_fileds = new HttpFields();
    int code = status.errorCode().to!int;
    end_fileds.put("grpc-status" , code.to!string);
    end_fileds.put("grpc-message" , status.errorMessage());
    return  new HeadersFrame(streamId, new HttpMetaData(HttpVersion.HTTP_2, end_fileds), null , true);
}

interface  GrpcService
{
    string getModule();
    Status process(string method ,  GrpcStream stream, ubyte[] complete);
    // Status process(string method ,  GrpcStream stream);
}
