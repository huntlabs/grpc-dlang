module grpc.GrpcService;

import grpc.GrpcStream;
import grpc.Status;

import hunt.http.codec.http.frame;
import hunt.http.codec.http.stream;
import hunt.http.codec.http.model;
import hunt.util.functional;

import std.conv;


HeadersFrame endHeaderFrame(Status status , int streamId)
{
    HttpFields end_fileds = new HttpFields();
    int code = to!int(status.errorCode());
    end_fileds.put("grpc-status" , to!string(code));
    end_fileds.put("grpc-message" , status.errorMessage());
    return  new HeadersFrame(streamId,
    new MetaData(HttpVersion.HTTP_2, end_fileds), null , true);
}


void serviceTask(string method, GrpcService service , GrpcStream stream)
{
    auto status = service.process(method , stream);
    auto res_end_header = endHeaderFrame(status , stream.stream.getId);
    stream.stream.headers(res_end_header , Callback.NOOP);

} 

interface  GrpcService
{ 
    string getModule();
    Status process(string method , GrpcStream stream);
}
