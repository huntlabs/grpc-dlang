

protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./examples -I ./examples ./examples/route_guide.proto
protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./examples --grpc_out=./examples/routeguide ./examples/route_guide.proto