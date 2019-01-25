module grpc.GrpcServer;

import std.stdio;
import std.string;

import hunt.http.codec.http.frame;
import hunt.http.codec.http.model;
import hunt.http.codec.http.stream;

import hunt.http.server.HttpServer;
import hunt.http.server.ServerHttpHandler;
import hunt.http.server.ServerSessionListener;

import hunt.util.Common;
import hunt.collection;
import hunt.logging;

import grpc.GrpcService;
import grpc.GrpcStream;
import grpc.Status;
import grpc.StatusCode;

alias Server = GrpcServer;
class GrpcServer
{
    this()
    {
            _HttpConfiguration = new HttpConfiguration();
            _HttpConfiguration.setSecureConnectionEnabled(false);
            _HttpConfiguration.setFlowControlStrategy("simple");
            _HttpConfiguration.getTcpConfiguration().setTimeout(60 * 1000);
            _HttpConfiguration.setProtocol(HttpVersion.HTTP_2.asString());

            _settings = new HashMap!(int, int)();
            _settings.put(SettingsFrame.HEADER_TABLE_SIZE, _HttpConfiguration.getMaxDynamicTableSize());
            _settings.put(SettingsFrame.INITIAL_WINDOW_SIZE, _HttpConfiguration.getInitialStreamSendWindow());
    }

    void listen(string address , ushort port)
    {
        _server = new HttpServer(address, port, _HttpConfiguration, 
        new class ServerSessionListener {

            override
            Map!(int, int) onPreface(Session session) {
                infof("server received preface: %s", session);
                return _settings;
            }

            override
            StreamListener onNewStream(Stream stream, HeadersFrame frame) {
                infof("server created new stream: %d", stream.getId());
                infof("server created new stream headers: %s", frame.getMetaData().toString());
                auto request = cast(MetaData.Request)frame.getMetaData();

                string path = request.getURI().getPath();
                auto arr = path.split("/");
                auto mod = arr[1];
                auto method = arr[2];

                auto service =  mod in _router ;
            

                HttpFields fields = new HttpFields();
                fields.put("content-type" ,"application/grpc+proto");
                fields.put("grpc-accept-encoding" , "identity");
                fields.put("accept-encoding" , "identity");

                auto response = new MetaData.Response(HttpVersion.HTTP_2 , 200 , fields);
                auto res_header = new HeadersFrame(stream.getId(),response , null , false);
                stream.headers(res_header , Callback.NOOP);

                if(service == null)
                {
                    Status status = new Status(StatusCode.NOT_FOUND , "not found this module:" ~ mod);
                    stream.headers(endHeaderFrame(status ,stream.getId()), Callback.NOOP);
                    return null;
                }


                auto grpcstream = new GrpcStream();
                grpcstream.attachStream(stream);


                auto listener =  new class StreamListener {

                    override
                    void onHeaders(Stream stream, HeadersFrame frame) {
                        grpcstream.onHeaders(stream , frame);
                    }

                    override
                    StreamListener onPush(Stream stream, PushPromiseFrame frame) {
                        return null;
                    }

                    override
                    void onData(Stream stream, DataFrame frame, Callback callback) {
                        grpcstream.onData(stream , frame);
                        callback.succeeded();
                    }

                    void onReset(Stream stream, ResetFrame frame, Callback callback) {
                        try {
                            onReset(stream, frame);
                            callback.succeeded();
                        } catch (Exception x) {
                            callback.failed(x);
                        }
                    }

                    override
                    void onReset(Stream stream, ResetFrame frame) {
                    }

                    override
                    bool onIdleTimeout(Stream stream, Exception x) {
                        return true;
                    }

                    override string toString() {
                        return super.toString();
                    }

                };
                import std.parallelism;
                auto t = task!(serviceTask , string , GrpcService , GrpcStream )(method , *service , grpcstream);
                taskPool.put(t);

                return listener;

            }

            override
            void onSettings(Session session, SettingsFrame frame) {
                
            }

            override
            void onPing(Session session, PingFrame frame) {
            }

            override
            void onReset(Session session, ResetFrame frame) {
                
            }

            override
            void onClose(Session session, GoAwayFrame frame) {
            }

            override
            void onFailure(Session session, Exception failure) {
            }

            void onClose(Session session, GoAwayFrame frame, Callback callback)
            {
                try
                {
                    onClose(session, frame);
                    callback.succeeded();
                }
                catch (Exception x)
                {
                    callback.failed(x);
                }
            }

            void onFailure(Session session, Exception failure, Callback callback)
            {
                try
                {
                    onFailure(session, failure);
                    callback.succeeded();
                }
                catch (Exception x)
                {
                    callback.failed(x);
                }
            }

            override
            void onAccept(Session session) {
            }

            override
            bool onIdleTimeout(Session session) {
                return false;
            }
        }, new ServerHttpHandlerAdapter(), null);
    }

    void register(GrpcService service)
    {
        _router[service.getModule()] = service;
    }

    void start()
    {
        _server.start();
    }

    void stop()
    {
        _server.stop();
    }

    protected
    {
        HttpConfiguration      _HttpConfiguration;
        Map!(int, int)          _settings;
        HttpServer             _server;
        GrpcService[string]     _router;
    }

}
