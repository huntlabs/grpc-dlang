import grpc
import helloworld_pb2
import helloworld_pb2_grpc

host = '127.0.0.1'
PORT = 30051;


if __name__ == "__main__":
  channel = grpc.insecure_channel(host + ':' + str(PORT))
  client = helloworld_pb2_grpc.GreeterStub(channel)
  resp = client.SayHello(helloworld_pb2.HelloRequest(name='Hunt'))
  print(resp)
