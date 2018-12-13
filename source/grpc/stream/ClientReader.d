module grpc.stream.ClientReader;

import grpc.Status;
import grpc.GrpcStream;

class ClientReader(R)
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

    Status finish()
    {
       return stream.finish();
    }

    GrpcStream stream;
}