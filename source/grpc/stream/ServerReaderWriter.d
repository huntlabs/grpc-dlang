module grpc.stream.ServerReaderWriter;

import grpc.Status;
import grpc.GrpcStream;

class ServerReaderWriter(R , W)
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


    bool write(W w , bool option = false)
    {
        if(stream.end)
            return false;
        stream.write(w , option);
        return true;
    }



    GrpcStream stream;
}