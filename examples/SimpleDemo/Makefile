.PHONY: clean

pyproto:
	python3 -m grpc_tools.protoc -I ./proto --python_out=python --grpc_python_out=python ./proto/helloworld.proto

gen_d_proto:
	$(PWD)/../../compiler/build/deps/protobuf/protoc --plugin=/usr/local/bin/protoc-gen-d --d_out=$(PWD)/source --proto_path=$(PWD)/proto helloworld.proto
	$(PWD)/../../compiler/build/deps/protobuf/protoc --plugin=protoc-gen-grpc=/usr/local/bin/grpc_dlang_plugin --grpc_out=./source/helloworld --proto_path=./proto helloworld.proto

build_d_client: gen_d_proto
	dub build -c=client

run_d_client: build_d_client
	./client

build_d_server: gen_d_proto
	dub build -c=server

run_d_server: build_d_server
	./server

run_python_client: pyproto
	python3 python/client.py

run_python_server: pyproto
	python3 python/server.py

clean:
	$(MAKE) -C source clean
	$(MAKE) -C python clean
	rm client
	rm server
	dub clean
