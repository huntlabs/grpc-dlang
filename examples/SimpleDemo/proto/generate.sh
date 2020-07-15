protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=../source -I ./ helloworld.proto
protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./ --grpc_out=../source/helloworld helloworld.proto
