module grpc.stream.ClientWriter;



import grpc.Status;
import grpc.GrpcStream;

class ClientWriter(W)
{
    this(GrpcStream stream , void delegate() dele)
    {
        this.stream = stream;
        this.dele = dele;
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

    Status finish()
    {
        dele();
        return stream.finish();
    }
    GrpcStream stream;
    void delegate() dele;
}

