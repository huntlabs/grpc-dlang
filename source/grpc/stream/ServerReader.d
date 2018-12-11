module grpc.stream.ServerReader;

import grpc.Status;
import grpc.GrpcStream;

class ServerReader(R)
{
    this(GrpcStream stream)
    {
        this.stream = stream;
    }

    bool read(R r)
    {
        if(stream.read(r)){
            return true;
        }
        return false;
    }

    GrpcStream stream;
}