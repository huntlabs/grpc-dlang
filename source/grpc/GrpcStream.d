module grpc.GrpcStream;

import grpc.Status;
import grpc.EvBuffer;

import hunt.http.codec.http.stream;
import hunt.http.codec.http.frame;
import hunt.http.codec.http.model;

import hunt.collection;
import hunt.util.Common;

import hunt.logging;

import google.protobuf;

import core.thread;
import core.sync.condition;
import core.sync.mutex;

import std.array;
import std.container : DList;
import std.bitmanip;
import std.conv;
import std.stdint;

import grpc.StatusCode;
import std.concurrency;
import hunt.Exceptions;
import grpc.GrpcService;


alias StreamHandler = void delegate(ubyte[] data);

class GrpcStream
{
    alias void delegate(ubyte[] complete) Callback;

    private StreamHandler _dataHandler;

    const ulong DataHeadLen = 5;

    this(bool asyn = false)
    {
        // _stream = stream;
       _status = Status.OK;
       _end = false;
       _asyn = asyn;
       _mutex = new Mutex();
       _condition = new Condition(_mutex);
       _read_buffer = new EvBuffer!ubyte;
       _dele = null;
       _write_mutex = new Mutex();
    }

    GrpcStream onDataReceived(StreamHandler handler) {
        _dataHandler = handler;
        return this;
    }

    void attachStream(  Stream stream)
    {
        this._stream = stream;
    }

    bool isClosed()
    {
        return this._stream.isClosed();
    }

   /// client status.
   void onHeaders(Stream stream, HeadersFrame frame)
   {
   }


   private ubyte[] parse( DataFrame frame)
   {
       ubyte[] bodyDetail = null;

       if (frame !is null)
       {
           try {
               ubyte[] bytes;
               bytes = cast(ubyte[])BufferUtils.toString(frame.getData());
               _read_buffer.mergeBuffer(bytes);

               ulong uBufLen = 0;
               while ( (uBufLen = _read_buffer.getBufferLength()) >= DataHeadLen )
               {
                   auto head = new ubyte [DataHeadLen];
                   if (!_read_buffer.copyOutFromHead(head ,DataHeadLen)) { break;}
                   ulong bodyLength = bigEndianToNative!int32_t(head[1 .. 5]);
                   if (bodyLength > 2147483647 || bodyLength < 0)
                   {
                       _read_buffer.reset();
                       break;
                   }
                   if (uBufLen >=  bodyLength + DataHeadLen)
                   {
                       if (!_read_buffer.drainBufferFromHead(DataHeadLen)) { break;}
                       if (bodyLength)
                       {
                           bodyDetail = new ubyte [bodyLength];
                           if (!_read_buffer.removeBufferFromHead(bodyDetail,bodyLength))  {break;}
                       }
                   } else
                   {
                      break;
                   }
               }
           } catch(Exception e){
               _read_buffer.reset();
               warning(e);
               return null;
           }
       }
       return bodyDetail;
   }

   void  onDataTransitQueue(Stream stream, DataFrame frame)
   {
       if(frame.isEndStream())
       {
           _end = true;
       }

       auto bodyDetail = parse(frame);
       if (bodyDetail !is null)
       {
           push(bodyDetail);
       }
   }

   void onData(Stream stream, DataFrame frame) {
       if(frame.isEndStream()) {
           _end = true;
       }

        ubyte[] _incomingData = parse(frame);
        if(_incomingData.length > 0) {
            version(HUNT_DEBUG) tracef("%(%02X %)", _incomingData);
            
            if(_dataHandler !is null) {
                _dataHandler(_incomingData);
            }
        } else {
            warning("The data is not ready yet.");
        }
   }

//    private ubyte[] _incomingData;

    ubyte[] onDataTransitTask(Stream stream, DataFrame frame)
   {
       if(frame.isEndStream())
       {
           _end = true;
       }

       ubyte[] incomingData = parse(frame);

        version(HUNT_DEBUG) tracef("%(%02X %)", incomingData);

       return incomingData;
   }


    void write(IN)(IN obj , bool option = false)
   {
        ubyte compress = 0;
        ubyte[] data = obj.toProtobuf.array;

        if (data.length > 2147483647 || data.length < 0 )
        {
            return;
        }
        ubyte[4] len = nativeToBigEndian(cast(int)data.length);
        ubyte[] grpc_data;
        grpc_data.reserve(1 + len.length + data.length);
        grpc_data ~= compress;
        grpc_data ~= len;
        grpc_data ~= data;
        try {
            synchronized(this)
            {
                auto dataFrame = new DataFrame( _stream.getId(),BufferUtils.toBuffer( cast(byte[])grpc_data), option);
                if (!_stream.isClosed())
                {
                    _stream.data( dataFrame , new NoopCallback());
                }
            }
        }

        catch (IndexOutOfBoundsException e)
        {
            _status.setStatusCode(StatusCode.OUT_OF_RANGE);
        } catch (Exception e)
        {
            _status.setStatusCode(StatusCode.INTERNAL);
        }
   }

   void writesdone()
   {
       auto dataFrame = new DataFrame(_stream.getId() ,
       BufferUtils.toBuffer(cast(byte[])[]) , true);
       _stream.data(dataFrame , new NoopCallback());
   }


   bool read(OUT)(ref OUT obj)
   {
       bool isTimeout = false;
       while(true)
       {
           auto bytes = pop();
           if(bytes == null || bytes.length == 0)
           {
               _condition.mutex().lock();
               scope (exit)
                    _condition.mutex().unlock();
               if (!_condition.wait(dur!"seconds"(5)))
               {
                    import grpc.GrpcException : GrpcTimeoutException;
                    throw new GrpcTimeoutException("Timedout after 5 seconds.");
               }
           }
           else
           {
               if (obj is null)
                    obj = new OUT();
               bytes.fromProtobuf!OUT(obj);
               return false;
           }
       }
   }

   Status finish()
   {
       return _status;
   }

    void push( ubyte[] packet = null)
    {
        if(packet !is null)
        {
            _condition.mutex().lock();

            _queue.insertBack( packet);
            _condition.notify();

            _condition.mutex().unlock();
        }
    }

   ubyte[] pop()
   {
       _condition.mutex().lock();
       if (_queue.empty())
           {
               _condition.mutex().unlock();
               return null;
           }
       auto packet = _queue.front();
       _queue.removeFront();
       _condition.mutex().unlock();
       return packet;
       //}
    }

    void setCallBack(Callback dele)
    {
        if (_dele is null && dele !is null)
        {
            _dele = dele;
            _asyn = true;
        }
    }

    void onCallBack(ubyte[] complete)
    {
        if (_dele !is null)
        {
            _dele(complete);
        }
    }

    void reSet()
    {
        _read_buffer.reset();
    }

    bool isAsyn() {
        return _asyn;
    }

    bool end() {
        return _end;
    }

    bool                _end;
    bool                _asyn;
    Condition           _condition;
    Mutex               _mutex;
    DList!(ubyte[])     _queue;
    EvBuffer!ubyte      _read_buffer;
    Stream              _stream;
    Status              _status;
    Callback            _dele;
    Mutex               _write_mutex;
}
