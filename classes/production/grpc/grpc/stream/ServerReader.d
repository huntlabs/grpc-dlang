module grpc.stream.ServerReader;

import grpc.Status;
import grpc.GrpcStream;

class ServerReader(R)
{
    this(GrpcStream stream)
    {
        this.stream = stream;
    }

    bool read(out R r)
    {
        r = new R();
        if(stream.read(r)){
            return true;
        }
        return false;
    }

    GrpcStream stream;
}