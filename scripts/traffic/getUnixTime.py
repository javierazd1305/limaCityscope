import time
import datetime
#year, month, day, hour, minute
#d = datetime.datetime(2017,9,20,15,30)
d = datetime.datetime(2017,10,2,19,30)
unixtime = time.mktime(d.timetuple())
print int(unixtime)
