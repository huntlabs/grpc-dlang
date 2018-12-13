module grpc.stream.ClientReaderWriter;

import grpc.Status;
import grpc.GrpcStream;

class ClientReaderWriter(R , W)
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

    bool write(W w , bool option = false)
    {
        if(stream.end)
            return false;
        stream.write(w , option);
        return true;
    }

    bool writesDone()
    {
        if(stream.end)
            return false;
        stream.writesdone();
        return true;
    }

    GrpcStream stream;
}