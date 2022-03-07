from concurrent import futures
import time

import grpc
import helloworld_pb2
import helloworld_pb2_grpc

PORT = 30051;

class GreeterHandler(helloworld_pb2_grpc.GreeterServicer):
    def SayHello(self, request, context):
      print('req=', request)
      return helloworld_pb2.HelloReply(message='hi, ' + request.name)


if __name__ == "__main__":
  handler = GreeterHandler()
  server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
  helloworld_pb2_grpc.add_GreeterServicer_to_server(handler, server)
  server.add_insecure_port('[::]:' + str(PORT))
  server.start()
  try:
      while True:
          time.sleep(100)
  except KeyboardInterrupt:
      server.stop(0)

