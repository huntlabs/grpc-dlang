module grpc.EvBuffer;

import std.array;
import std.stdio;

class  EvBuffer(T) {
    this( ulong  sz = 0){
        _buffer = new T [sz];
        _buf_sz = 0;
    }

public:

    void mergeBuffer ( ref T [] buf)
    {
        if (buf != null)
        {
            this._buffer ~= buf;
            _buf_sz += buf.length;
        }
    }

    bool copyOutFromHead (ref T [] buf , ref const ulong len)
    {
        if (_buf_sz >= len && buf != null)
        {
            buf[0 .. len] = _buffer [0 .. len];
            return true;
        } else
        {
            return false;
        }
    }

    bool drainBufferFromHead (ref const ulong len)
    {
        if (_buf_sz < len)
        {
            return false;
        } else {
            _buffer = _buffer[len .. $];
            _buf_sz -= len;
            return true;
        }
    }

    bool removeBufferFromHead (ref T [] buf , ref const ulong len)
    {
        if (_buf_sz < len)
        {
            return false;
        } else {
            buf[0 .. len] = _buffer [0 .. len];
            _buffer = _buffer[len .. $];
            _buf_sz -= len;
            return true;
        }
    }

    void reset(){
        _buffer = new T [0];
        _buf_sz = 0;
    }

    ulong getBufferLength () { return this._buf_sz ;}


    void print () {
        writeln(this._buffer);
    }

private:
    T []        _buffer;
    ulong       _buf_sz;
}
