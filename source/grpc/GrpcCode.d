module grpc.GrpcCode;


string GetFunc(string funcstr)
{
    import std.string;
    string[] funcs = funcstr.split(".");
    string myFunc;
    if (funcs.length > 0)
        myFunc = funcs[$ - 1];
    else
        myFunc = funcstr;
    return myFunc;
}

string CM(string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
    stream.write(request , true);
    while(stream.read(response)){}
    return stream.finish();`;
    return code;
}

string CMA(O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
     stream.write(request , true);
     new Thread((){
         auto response = new `~O.stringof~`();
         while(stream.read(response)){}
         dele(stream.finish() , response);
     }).start();`;
    return code;
}

string SM(I , O , string method)()
{
    string code = `case "`~method~`":
                auto request = new `~I.stringof~`();
                auto response = new `~O.stringof~`();
                while(stream.read(request)){} 
                auto status = `~method~`(request,response);
                stream.write(response);
                return status;`;
    return code;
}

string NONE(string method)()
{
    string code = `default:
                  return new Status(StatusCode.NOT_FOUND , "not found this method:" ~ method ~ " in " ~ SERVICE);`;
    return code;
}
