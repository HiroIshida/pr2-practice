#!usr/bin/env python
import rospy
from jsk_recognition_msgs.msg import BoundingBoxArray
from sensor_msgs.msg import PointCloud2

rospy.init_node('pcl')

def callback(data):
    #print "recieved"
    #print data.boxes[1].pose.position
    print len(data.boxes)
    #for i in range(len(data.boxes)):
        #print data.boxes[i].dimensions


sub = rospy.Subscriber('/kinect_head/depth_registered/boxes', BoundingBoxArray, callback)
#sub = rospy.Subscriber('/kinect_head/depth_registered/hsi_output', PointCloud2, callback)

print "aaaa"
rospy.spin()

