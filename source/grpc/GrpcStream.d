module grpc.GrpcStream;

import grpc.Status;


import hunt.http.codec.http.stream;
import hunt.http.codec.http.frame;
import hunt.http.codec.http.model;

import hunt.container;
import hunt.util.functional;

import hunt.logging;

import google.protobuf;

import core.thread;
import core.sync.condition;
import core.sync.mutex;

import std.array;
import std.container : DList;
import std.bitmanip;
import std.conv;

import grpc.StatusCode;



class GrpcStream
{ 

    this()
    {
       status = Status.OK;
       end = false;
       condition = new Condition(new Mutex());
    }

    void attachStream(Stream stream)
    {
        this.stream = stream;   
    }

   /// client status.
   void onHeaders(Stream stream, HeadersFrame frame) 
   {
       if(frame.isEndStream())
       {    
           end = true;
           push();
       }
       auto data = frame.getMetaData();
       auto fileds = data.getFields();
       auto status = fileds.get("grpc-status");
       auto error = fileds.get("grpc-message");
       if(status !is null)
       {
           this.status = new Status(cast(StatusCode)to!int(status) , error);
       }
   }    

   void onData(Stream stream, DataFrame frame) 
   {
        auto bytes = cast(ubyte[])BufferUtils.toString(frame.getData());
        /// no data
        if(bytes.length < 5)
        { 
            return;
        }
        push(bytes[5 .. $]);

        if(frame.isEndStream())
        {
            end = true;
            push();
        }
   }

   void write(IN)(IN obj , bool end = false)
   {  
        ubyte compress = 0;
        ubyte[] data = obj.toProtobuf.array;
        ubyte[4] len = nativeToBigEndian(cast(int)data.length);
        ubyte[] grpc_data;
        grpc_data ~= compress;
        grpc_data ~= len;
        grpc_data ~= data;
        auto dataFrame = new DataFrame(stream.getId(),
            ByteBuffer.wrap(cast(byte[])grpc_data), end);
        stream.data(dataFrame , new NoopCallback());
   }

   void writesdone()
   {
       auto dataFrame = new DataFrame(stream.getId() ,
       ByteBuffer.wrap(null) , true);
       stream.data(dataFrame , new NoopCallback());
   }

   bool read(OUT)(ref OUT obj)
   {
       while(1)
       {
           auto bytes = pop();
           if(bytes.length == 0)
           {
               if(!end)
               {
                   condition.mutex().lock();
                   condition.wait();
                   condition.mutex().unlock();
                   continue;
               }
               else
               {
                   return false;
               }
           }
           else  
           {
               if(obj is null)
                    obj = new OUT();
               bytes.fromProtobuf!OUT(obj);
               return true;
           }
       }
   }

   Status finish()
   {
       while(!end)
       {}
       return status;
   }

    void push( ubyte[] packet = null)
    { 
        if(packet !is null)
        {
            synchronized(this){
                queue.insertBack(packet);
            }
        }
        condition.notify();
    }
   
   ubyte[] pop()
   {
        synchronized(this){
            if(queue.empty())
                return null;
            auto packet = queue.front();
            queue.removeFront();
            return packet;
        }
    }

    bool                end;
    Condition           condition;
    DList!(ubyte[])     queue;
    Stream              stream;
    Status              status;
}