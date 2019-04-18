#!/usr/bin/env roseus
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::roseus "listener" :anonymous t)


(defun callback (box)
  (print "hello"))


(ros::subscribe "/bounding_box_marker/selected_box" jsk_recognition_msgs::BoundingBox #'callback)

(ros::rate 100)
(do-until-key
  (ros::sleep)
  (ros::spin-once))
(exit)
