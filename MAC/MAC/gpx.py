from pymongo import MongoClient

uri = "mongodb://yk:kim@ds011389.mlab.com:11389/otg"
dbName = "otg"

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
    query = {"user":"yk"}
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
        break
gpx()
