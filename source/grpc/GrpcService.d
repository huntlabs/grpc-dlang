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

import std.conv;

HeadersFrame endHeaderFrame(Status status , int streamId)
{
    HttpFields end_fileds = new HttpFields();
    int code = to!int(status.errorCode());
    end_fileds.put("grpc-status" , to!string(code));
    end_fileds.put("grpc-message" , status.errorMessage());
    return  new HeadersFrame(streamId, new HttpMetaData(HttpVersion.HTTP_2, end_fileds), null , true);
}


void serviceTask(string method, GrpcService service , GrpcStream stream , ubyte[] complete)
{
    if (!stream.isClosed()){
        service.process(method , stream ,complete);
    }
}

void taskCallBack(GrpcStream stream , ubyte[] complete)
{
    if (stream !is null)
    {
        stream.onCallBack(complete);
    }
}

interface  GrpcService
{ 
    string getModule();
    Status process(string method ,  GrpcStream stream, ubyte[] complete);
}
