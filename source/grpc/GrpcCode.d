module grpc.GrpcCode;

alias GrpcReplyHandler(T) = void delegate(Status status, T response);

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

string CM(O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
    stream.write(request , false);
    auto response = new `~O.stringof ~ `();
    while(stream.read(response)){}
    auto status = stream.finish();
    return response;`;
    return code;
}

//auto response = new `~O.stringof ~ `();
/*
 while(stream.read(response)){}
    auto status = stream.finish();
*/

string CM1(O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
    stream.write(request , false);
    auto reader = new ClientReader!`~O.stringof~`(stream);
    return reader;`;
    return code;
}


string CM2(O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
    
    auto writer = new ClientWriter!`~O.stringof~`(stream ,response);
    return writer;`;
    return code;
}


string CM3(I , O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
    auto readerwriter = new ClientReaderWriter!(`~I.stringof~`,`~O.stringof~`)(stream);
    return readerwriter;`;
    return code;
}




string CMA(O , string service , string funcs = __FUNCTION__)()
{
    string func = GetFunc(funcs);
    string code = 
    `auto stream = _channel.createStream("/`~ service ~`/`~func~`");
     stream.setCallBack((data) {
         auto response = new `~O.stringof~`();
         if(dele !is null) {
            fromProtobuf!`~O.stringof~`(data, response);
            dele(stream.finish() , response);
         }
     });
     stream.write(request , false);`;
    return code;
}

string SM(I , O , string method)()
{
    string code = `case "`~method~`":
                auto request = new `~I.stringof~`();
                auto response = new `~O.stringof~`();
                complete.fromProtobuf! `~I.stringof~`(request);
                auto status = `~method~`(request,response);
                stream.write(response,false);
                return status;`;
    return code;
}


/// server stream
string SM1(I , O , string method)()
{
    string code = `case "`~method~`":
                auto request = new `~I.stringof~`();
                auto writer = new ServerWriter!`~O.stringof~`(stream);
                complete.fromProtobuf! `~I.stringof~`(request);
                auto status = `~method~`(request,writer);
                return status;`;
    return code;
}

/// client stream
string SM2(I , O , string method)()
{
    string code = `case "`~method~`":
                auto reader = new ServerReader!`~I.stringof~`(stream);
                auto response = new `~O.stringof~`();               
                auto status = `~method~`(reader,response);
                stream.write(response);
                return status;`;
    return code;
}

/// client stream & server stream
string SM3(I , O , string method)()
{
    string code = `case "`~method~`":
                auto readerwriter = new ServerReaderWriter!(`~I.stringof~`,`~O.stringof~`)(stream);                            
                auto status = `~method~`(readerwriter);
                return status;`;
    return code;
}

string NONE()
{
    string code = `default:
                  return new Status(StatusCode.NOT_FOUND , "The method '" ~ method ~ "' is not found in " ~ SERVICE);`;
    return code;
}
