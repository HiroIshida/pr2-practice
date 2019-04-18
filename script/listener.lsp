#!/usr/bin/env roseus
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(ros::roseus "listener" :anonymous t)
(require :pr2-interface "package://pr2eus/pr2-interface.l")


(defun callback (box)
  (let* ((pos (send box :pose :position))
         (x (send pos :x))
         (y (send pos :y))
         (z (send pos :z)))
    (print x)))

(ros::subscribe "/bounding_box_marker/selected_box" jsk_recognition_msgs::BoundingBox #'callback)

(ros::rate 100)
(do-until-key
  (ros::sleep)
  (ros::spin-once))
(exit)
