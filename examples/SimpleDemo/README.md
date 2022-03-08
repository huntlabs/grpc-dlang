# D and Python Client/Server

Test D client with Python server:

```console
$ pip3 install grpcio-tools
```

```console
$ make pyproto
```

then test the Python server:

```console
$ make run_python_server
$ make run_python_client  # in another terminal
message: "hi, Hunt"
```

Now test D client

```console
$ make run_d_client
```
