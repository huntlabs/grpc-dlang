
Test D client with Python server:

```
$ make pyproto
```

then test the Python server:

```
$ cd source
$ python3 server.py
$ python3 client.py  # in another terminal
message: "hi, Hunt"

```

Now test D client
```
$ ./client
```


# Python pyd client

First make sure you have pyd (>= version 0.14.1) installed
```
$ cd source
$ make pyd
$ make run
Hello client_pyd
```
