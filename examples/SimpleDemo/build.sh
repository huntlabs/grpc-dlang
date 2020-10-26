
# cd proto
# ./generate.sh
# cd ..

dub build --compiler=dmd -a=x86_64 -b=debug -c=client
dub build --compiler=dmd -a=x86_64 -b=debug -c=server


// ghz --proto=./proto/helloworld.proto --call=helloworld.Greeter.SayHello --insecure --duration 1s -d "{\"name\":\"it's not as performant as we expected\"}" 127.0.0.1:30051
