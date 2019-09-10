module grpc.stream.ServerReaderWriter;

import grpc.Status;
import grpc.GrpcStream;

class ServerReaderWriter(R , W)
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


    bool write(W w , bool option = false)
    {
        stream.write(w , option);
        return true;
    }



    GrpcStream stream;
}