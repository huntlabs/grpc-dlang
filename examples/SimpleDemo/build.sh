
# cd proto
# ./generate.sh
# cd ..

dub build --compiler=dmd -a=x86_64 -b=debug -c=client
dub build --compiler=dmd -a=x86_64 -b=debug -c=server
