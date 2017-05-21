from pymongo import MongoClient
from bson.objectid import ObjectId


uri = "mongodb://localhost:27017"
dbName = "otg_backup"

client = MongoClient(uri)
db = client[dbName]

'''
example of gpx file structure
<gpx>
    <name>route1</name>
    <number>1</number>
    <wpt lat="42.046908" lon="-87.679314">
      <ele>0</ele>
      <time>2016-12-29T00:01:00Z</time>
      <name>pt0</name>
    </wpt>
</gpx>
'''

def gpx():
    # collection that the location is stored.
    locations = db.locations

    # your query
    query = {"_id":ObjectId("58e6592fb9a31449b92de7c4")}
    # q_result = locations.find().sort("_id",-1).limit(2)
    q_result = db.locations.find(query)
    header = "<gpx>\n"
    header_end = "</gpx>"
    wpt_end = "</wpt>"
    cnt = 0
    indent = "  "
    for q in q_result:
        coords = q["coordinates"]
        user = q["user"]
        out_str = ""
        file_name = "%s_%d.gpx" % (user,cnt)
        file_name = "kapil_unnamed.gpx"

        out_str += header
        for coord in coords:
            lat = coord[0]
            lng = coord[1]
            waypoint = indent + '<wpt lat="%f" lon="%f">\n' % (lat,lng)
            out_str += waypoint
            out_str += indent + wpt_end + "\n"
        out_str += header_end
        with open(file_name,'w') as file:
            file.write(out_str)
            cnt += 1

gpx()
