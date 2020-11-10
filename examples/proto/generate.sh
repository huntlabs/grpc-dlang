# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=../source -I ./ helloworld.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./ --grpc_out=../source/helloworld helloworld.proto

# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./ -I ./app/grpc Common.proto
# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./ -I ./app/grpc AuthService.proto

# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./app/grpc --grpc_out=./app/grpc Common.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./app/grpc --grpc_out=./app/grpc AuthService.proto


# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=../source -I ./app/grpc Common.proto
# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=../source -I ./app/grpc AuthService.proto

# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./app/grpc --grpc_out=../source/app/grpc Common.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./app/grpc --grpc_out=../source/app/grpc AuthService.proto

# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./ -I ./ *.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./ --grpc_out=./app/grpc *.proto

mkdir -p gen

# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=../source -I ./ *.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin -I ./ --grpc_out=../source/app/grpc *.proto



# protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./gen --proto_path=./ app/grpc/message/*.proto


protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=./gen --proto_path=./ app/grpc/*.proto
protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin --proto_path=./ --grpc_out=./gen app/grpc/*.proto

# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin --proto_path=./app/grpc/message -I ./ --grpc_out=./gen app/grpc/*.proto
# protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin --proto_path=./app/grpc/message --proto_path=./ --grpc_out=./gen *.proto



# https://github.com/protocolbuffers/protobuf/issues/4176
# https://stackoverflow.com/questions/38390260/import-and-usage-of-different-package-files-in-protobuf