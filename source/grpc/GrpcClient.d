module grpc.GrpcClient;

import hunt.concurrent.Promise;
import hunt.concurrent.CompletableFuture;

import hunt.logging;

import std.stdio;
import std.datetime;
import std.conv;
import std.format;

import hunt.http.client.ClientHttp2SessionListener;
import hunt.http.client.HttpClient;
import hunt.http.client.Http2ClientConnection;
import hunt.http.client.HttpClientConnection;

import hunt.http.codec.http.frame;
import hunt.http.codec.http.model;
import hunt.http.codec.http.stream;


import hunt.util.functional;
import hunt.concurrent.FuturePromise;

import hunt.container;
import hunt.net;

import grpc.GrpcException;
import grpc.GrpcStream;

alias Channel = GrpcClient;
class GrpcClient
{
    this(string host , ushort port)
    {
        this();
        connect(host , port);
    }


    this()
    {
        _http2Configuration = new Http2Configuration();
        _http2Configuration.setSecureConnectionEnabled(false);
        _http2Configuration.setFlowControlStrategy("simple");
        _http2Configuration.getTcpConfiguration().setTimeout(60 * 1000);
        _http2Configuration.setProtocol(HttpVersion.HTTP_2.asString());

        _promise = new FuturePromise!(HttpClientConnection)();
        _client = new HttpClient(_http2Configuration);
    }


    void connect(string host , ushort port)
    {
        _host = host;
        _port = port;
        _client.connect(host , port , _promise, new class ClientHttp2SessionListener {

            override
            Map!(int, int) onPreface(Session session) {
                Map!(int, int) settings = new HashMap!(int, int)();
                settings.put(SettingsFrame.HEADER_TABLE_SIZE, _http2Configuration.getMaxDynamicTableSize());
                settings.put(SettingsFrame.INITIAL_WINDOW_SIZE, _http2Configuration.getInitialStreamSendWindow());
                return settings;
            }

            override
            StreamListener onNewStream(Stream stream, HeadersFrame frame) {
                return null;
            }

            override
            void onSettings(Session session, SettingsFrame frame) {
            }

            override
            void onPing(Session session, PingFrame frame) {
            }

            override
            void onReset(Session session, ResetFrame frame) {
                logInfo("onReset");
            }

            override
            void onClose(Session session, GoAwayFrame frame) {
                logInfo("onClose");
            }

            override
            void onFailure(Session session, Exception failure) {
                logInfo("onFailure");
            }

            override
            bool onIdleTimeout(Session session) {
                return false;
            }
        });
    }

    
    GrpcStream createStream(string path)
    {
        HttpFields fields = new HttpFields();
        fields.put("te", "trailers");
        fields.put("content-type" ,"application/grpc+proto");
        fields.put("grpc-accept-encoding" , "identity");
        fields.put("accept-encoding" , "identity");

        MetaData.Request metaData = new MetaData.Request("POST", HttpScheme.HTTP,
            new HostPortHttpField(format("%s:%d", _host, _port)), 
            path, HttpVersion.HTTP_2, fields);

        auto conn = _promise.get();
        auto client = cast(Http2ClientConnection)conn;
        auto streampromise = new FuturePromise!(Stream)();
        auto http2session = client.getHttp2Session();
        auto grpcstream = new GrpcStream();

        http2session.newStream(new HeadersFrame(metaData , null , false), streampromise , new class StreamListener {

            StreamListener onPush(Stream stream,
                    PushPromiseFrame frame) {
                logInfo("onPush");
                return null;
            }
            /// unused
            override
            void onReset(Stream stream, ResetFrame frame, Callback callback) {
                logInfo("onReset");
                try {
                    onReset(stream, frame);
                    callback.succeeded();
                } catch (Exception x) {
                    callback.failed(x);
                }
            }
            /// unused
            override
            void onReset(Stream stream, ResetFrame frame) {
                logInfo("onReset2");
            }
            /// unused
            override
            bool onIdleTimeout(Stream stream, Exception x) {
                logInfo("timeout");
                return true;
            }
            /// unused
            override string toString()
            {
                return super.toString();
            }   

            override void onHeaders(Stream stream, HeadersFrame frame) {
                grpcstream.onHeaders(stream , frame);
            }

            override void onData(Stream stream, DataFrame frame, Callback callback) {
                grpcstream.onData(stream , frame);
            }
        });

        grpcstream.attachStream(streampromise.get());
        return grpcstream;
    }


    protected
    {
        string _host;
        ushort _port;
        HttpClient _client;
        FuturePromise!(HttpClientConnection) _promise;
        Http2Configuration  _http2Configuration;
    }
}
