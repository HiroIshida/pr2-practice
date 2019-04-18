#!usr/bin/env python
import rospy
from jsk_recognition_msgs.msg import BoundingBoxArray
from jsk_recognition_msgs.msg import BoundingBox
from sensor_msgs.msg import PointCloud2

rospy.init_node('process_bounding_box')

def callback(box):
    print "recieved"
    pos = box.pose.position
    vec = box.dimensions
    print vec

sub = rospy.Subscriber('/bounding_box_marker/selected_box', BoundingBox, callback)
#sub = rospy.Subscriber('/kinect_head/depth_registered/hsi_output', PointCloud2, callback)

print "aaaa"
rospy.spin()

