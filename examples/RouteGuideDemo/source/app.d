module routeguide.example;



import std.stdio;
import std.file;
import std.getopt;
import std.algorithm;
import std.math;

import routeguide.route_guide;
import routeguide.route_guiderpc;

import grpc;

import hunt.util.Serialize;
import hunt.logging;

__gshared Feature[] list;



float convertToRadians(float num) {
  return num * 3.1415926 /180;
}

float getDistance(Point start , Point end)
{
  float kCoordFactor = 10000000.0;
  float lat_1 = start.latitude / kCoordFactor;
  float lat_2 = end.latitude / kCoordFactor;
  float lon_1 = start.longitude / kCoordFactor;
  float lon_2 = end.longitude / kCoordFactor;
  float lat_rad_1 = convertToRadians(lat_1);
  float lat_rad_2 = convertToRadians(lat_2);
  float delta_lat_rad = convertToRadians(lat_2-lat_1);
  float delta_lon_rad = convertToRadians(lon_2-lon_1);
  float a = pow(sin(delta_lat_rad/2), 2) + cos(lat_rad_1) * cos(lat_rad_2) *
            pow(sin(delta_lon_rad/2), 2);
  float c = 2 * atan2(sqrt(a), sqrt(1-a));
  int R = 6371000; // metres
  return R * c;
}

string getFeatureName( Point point,
                           Feature[] feature_list) {
  foreach ( f ; feature_list) {
    if (f.location.latitude == point.latitude &&
        f.location.longitude == point.longitude) {
      return f.name;
    }
  }
  return "";
}

class RouteGuideImpl : RouteGuideBase
{
    override Status GetFeature( Point point, ref Feature feature){ 
        logInfo("GetFeature ", toJson(point));
        feature.name = getFeatureName(point , list);
        feature.location = point;
        return Status.OK; 
    }

    override Status ListFeatures(Rectangle rectangle , ServerWriter!Feature writer) {
        logInfo("ListFeatures ", toJson(rectangle));
        auto lo = rectangle.lo;
        auto hi = rectangle.hi;
        long left = min(lo.longitude, hi.longitude);
        long right = max(lo.longitude, hi.longitude);
        long top = max(lo.latitude, hi.latitude);
        long bottom = min(lo.latitude, hi.latitude);
        foreach (  f ; list) {
            if (f.location.longitude >= left &&
                f.location.longitude <= right &&
                f.location.latitude >= bottom &&
                f.location.latitude <= top) {    
                writer.write(f);
            }
        }
        return Status.OK;
    }

    override Status RecordRoute(ServerReader!Point reader, ref RouteSummary summary ){
        
        Point point;
        int point_count = 0;
        int feature_count = 0;
        float distance = 0.0;
        Point previous;
        import core.stdc.time;
        auto start_time = cast(int)time(null);
        while (reader.read(point)) {
            point_count++;
            if (getFeatureName(point, list) != "") {
                feature_count++;
            }
            if (point_count != 1) {
                distance += getDistance(previous, point);
            }
            previous = point;
        }
        
        auto end_time =  cast(int)time(null);
        summary.pointCount = point_count;
        summary.featureCount = feature_count;
        summary.distance = cast(int)distance;
        auto secs = 
            end_time - start_time;
        summary.elapsedTime = secs;

        return Status.OK;
    }

    override Status RouteChat(ServerReaderWriter!(RouteNote , RouteNote) stream){
        RouteNote[] received_notes;
        RouteNote note;
        while (stream.read(note)) {
            foreach ( n ; received_notes) {
                if (n.location.latitude == note.location.latitude &&
                    n.location.longitude == note.location.longitude) {
                    stream.write(n);
                }
            }
            received_notes ~= note;
        }
        return Status.OK;
    }
}


//////////////////////////////client code ////////////////////////////////
enum kCoordFactor_ = 10000000.0;

Point MakePoint(int latitude, int longitude) {
  Point p = new Point();
  p.latitude = latitude;
  p.longitude = longitude;
  return p;
}

Feature MakeFeature(string name,
                    int latitude, int longitude) {
  Feature f = new Feature();
  f.name = name ;
  f.location = MakePoint(latitude, longitude);
  return f;
}

RouteNote MakeRouteNote(string message,
                        int latitude, int longitude) {
  RouteNote n = new RouteNote();
  n.message = message;
  n.location = MakePoint(latitude, longitude);
  return n;
}


 bool GetOneFeature(RouteGuideClient client , Point point , ref Feature feature ) {
    point = MakePoint(409146138, -746188906);
    feature = client.GetFeature(point);
    if(feature is null){
        writeln("GetFeature rpc failed.");
        return false;
    }

    if(feature.name == ""){
        writeln("Found no feature at " ,
         feature.location.latitude /kCoordFactor_ ,", ",
          feature.location.longitude /kCoordFactor_ );
    }else{
        writeln("Found feature called " ,
         feature.location.latitude /kCoordFactor_ ,", ",
          feature.location.longitude /kCoordFactor_ );
    }

    return true;
   
  }

  void getFeature(RouteGuideClient client)
  {
    Point point;
    Feature feature = new Feature();
    point = MakePoint(409146138, -746188906);
    GetOneFeature(client , point, feature);
    point = MakePoint(0, 0);
    feature = new Feature();
    GetOneFeature(client ,point, feature);
  }

  void listFeatures(RouteGuideClient client) {
    Rectangle rect = new Rectangle();
    Feature feature;
    rect.lo = MakePoint(400000000 ,-750000000);
    rect.hi = MakePoint(420000000 , -730000000);
    writeln("Looking for features between 40, -75 and 42, -73");

    auto reader = client.ListFeatures(rect);
    while (reader.read(feature)) {
        writeln("Found feature called ",
                 feature.name , " at ",
                 feature.location.latitude/kCoordFactor_ , ", ",
                feature.location.longitude/kCoordFactor_ );
    }
    Status status = reader.finish();
    if (status.ok()) {
      writeln("ListFeatures rpc succeeded.");
    } else {
      writeln("ListFeatures rpc failed.");
    }
  } 

    void recordRoute(RouteGuideClient client) {
        import std.random;
        import core.stdc.time;
        import core.time;
        import core.thread;
        Point point;
        RouteSummary stats = new RouteSummary();
        const int kPoints = 10;
        auto rnd = new Random(cast(uint)time(null));

 

        auto writer = client.RecordRoute(stats);
        for (int i = 0; i < kPoints; i++) {
            auto f = list[uniform(0,list.length , rnd)];
            writeln( "Visiting point " ,
                        f.location.latitude/kCoordFactor_ , ", " ,
                         f.location.longitude/kCoordFactor_);
            if (!writer.write(f.location)) {
                // Broken stream.
                break;
            }
            Thread.sleep(dur!"msecs"(uniform(500,1500)));
        }

        writer.writesDone();
        Status status = writer.finish();
        if (status.ok()) {
            writeln("Finished trip with " , stats.pointCount , " points\n",
                    "Passed " , stats.featureCount , " features\n",
                    "Travelled " , stats.distance , " meters\n",
                    "It took " , stats.elapsedTime , " seconds");
        } 
        else {
            writeln("RecordRoute rpc failed.");
        }
  }

void routeChat(RouteGuideClient client) {
    import core.thread;
    auto  stream = client.RouteChat();

    auto thread = new Thread( (){
      RouteNote[] notes=[
        MakeRouteNote("First message", 0, 0),
        MakeRouteNote("Second message", 0, 1),
        MakeRouteNote("Third message", 1, 0),
        MakeRouteNote("Fourth message", 0, 0)];
        foreach (note ; notes) {
            writeln( "Sending message " , note.message,
                     " at " , note.location.latitude , ", ",
                     note.location.longitude);            
                     stream.write(note);
        }
        stream.writesDone();
    }).start();

    RouteNote server_note;
    while (stream.read(server_note)) {
      writeln( "Got message " , server_note.message,
                 " at " , server_note.location.latitude , ", ",
                 server_note.location.longitude);
    }
    thread.join();
    Status status = stream.finish();
    if (!status.ok()) {
      writeln( "RouteChat rpc failed.");
    }
  }





int main( string []args)
{
   
    string path; 
    // Usage: command --db_path=path/to/route_guide_db.json.
    auto oprions = getopt(args,"db_path|f","database file",&path);
    string data = readText(path);
    auto json = parseJSON(data);
    list = toObject!(Feature[])(json);
    writeln("DB parsed, loaded " , list.length , " features.");
    string host = "0.0.0.0";
    ushort port = 30051;

    Server server = new Server();
    server.listen(host , port);
    server.register( new RouteGuideImpl());
    server.start();

    auto channel = new Channel("127.0.0.1" , port);
    RouteGuideClient client = new RouteGuideClient(channel);

    writeln("-------------- GetFeature --------------");
    client.getFeature();
    writeln("-------------- ListFeatures --------------");
    client.listFeatures();
    writeln("-------------- RecordRoute --------------");
    client.recordRoute();
    writeln("-------------- RouteChat --------------");
    client.routeChat();

    getchar();
    return 0;
}
