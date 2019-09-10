module grpc.stream.ServerWriter;



import grpc.Status;
import grpc.GrpcStream;

class ServerWriter(W)
{
    this(GrpcStream stream)
    {
        this.stream = stream;
    }

    bool write(W w , bool option = false)
    {
        stream.write(w , option);
        return true;
    }
    GrpcStream stream;
}