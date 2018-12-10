module grpc.Status;

import grpc.StatusCode;



class Status
{
   static this()
   {
        OK = new Status();
    }

    this(StatusCode code = StatusCode.OK
     , string error_message = string.init ,
     string error_details = string.init)
    {
        _code = code;
        _error_message = error_message;
        _binary_error_details = error_details;
    }

    static Status OK;


    StatusCode errorCode()
    {
        return _code;
    }

    string errorMessage()
    {
        return _error_message;
    }

    string error_details()
    {
        return _binary_error_details;
    }

    bool ok() {
        return _code == StatusCode.OK;
    }

    
    private:

    StatusCode  _code;
    string      _error_message;
    string      _binary_error_details;
}