module grpc.GrpcClient;

import hunt.concurrency.Promise;
import hunt.concurrency.CompletableFuture;

import hunt.logging.ConsoleLogger;

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

import hunt.util.Common;
import hunt.concurrency.FuturePromise;

import hunt.collection;
import hunt.net;

import grpc.GrpcException;
import grpc.GrpcStream;
import core.thread;

alias Channel = GrpcClient;
class GrpcClient {
    this(string host, ushort port) {
        this();
        connect(host, port);
    }

    this() {
        _HttpConfiguration = new HttpConfiguration();
        _HttpConfiguration.setSecureConnectionEnabled(false);
        _HttpConfiguration.setFlowControlStrategy("simple");
        _HttpConfiguration.getTcpConfiguration().setTimeout(60 * 1000);
        _HttpConfiguration.setProtocol(HttpVersion.HTTP_2.asString());

        _promise = new FuturePromise!(HttpClientConnection)();
        _client = new HttpClient(_HttpConfiguration);
    }

    void connect(string host, ushort port) {
        _host = host;
        _port = port;
        logInfo("host : ", host, " port :", port);
        _client.connect(host, port, _promise, new ClientHttp2SessionListenerEx(_HttpConfiguration));
    }

    GrpcStream createStream(string path) {
        HttpFields fields = new HttpFields();
        fields.put("te", "trailers");
        fields.put("content-type", "application/grpc+proto");
        fields.put("grpc-accept-encoding", "identity");
        fields.put("accept-encoding", "identity");

        MetaData.Request metaData = new MetaData.Request("POST", HttpScheme.HTTP,
                new HostPortHttpField(format("%s:%d", _host, _port)), path,
                HttpVersion.HTTP_2, fields);

        auto conn = _promise.get();
        auto client = cast(Http2ClientConnection) conn;
        auto streampromise = new FuturePromise!(Stream)();
        auto http2session = client.getHttp2Session();
        auto grpcstream = new GrpcStream();

        // dfmt off
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

        // dfmt on
        grpcstream.attachStream(streampromise.get());
        return grpcstream;
    }

    protected {
        string _host;
        ushort _port;
        HttpClient _client;
        FuturePromise!(HttpClientConnection) _promise;
        HttpConfiguration _HttpConfiguration;
    }
}

class ClientHttp2SessionListenerEx : ClientHttp2SessionListener {

    HttpConfiguration _HttpConfiguration;
    this(HttpConfiguration config) {
        this._HttpConfiguration = config;
    }

    override Map!(int, int) onPreface(Session session) {
        Map!(int, int) settings = new HashMap!(int, int)();

        settings.put(SettingsFrame.HEADER_TABLE_SIZE, _HttpConfiguration.getMaxDynamicTableSize());
        settings.put(SettingsFrame.INITIAL_WINDOW_SIZE,
                _HttpConfiguration.getInitialStreamSendWindow());
        return settings;
    }

    override StreamListener onNewStream(Stream stream, HeadersFrame frame) {
        return null;
    }

    override void onSettings(Session session, SettingsFrame frame) {
    }

    override void onPing(Session session, PingFrame frame) {
    }

    override void onReset(Session session, ResetFrame frame) {
        logInfo("onReset");
    }

    override void onClose(Session session, GoAwayFrame frame) {
        logInfo("onClose");
    }

    override void onFailure(Session session, Exception failure) {
        warning("onFailure");
    }

    override bool onIdleTimeout(Session session) {
        return false;
    }
}
