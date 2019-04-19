#!/usr/bin/env roseus
(require "package://pr2eus/pr2-interface.l")

(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(print "finish loading")

(pr2-init)
(setq *tfl* (instance ros::transform-listener :init))
(setq *robot* *pr2*)
(print "finish initializing")

(defun robot-init ()
  (print "robot init ok?")
  (send *robot* :reset-pose)
  (send *robot* :l_shoulder_pan_joint :joint-angle 100)
  (send *robot* :l_shoulder_pan_joint :joint-angle 100)
  (send *robot* :l_shoulder_lift_joint :joint-angle -20)
  (send *robot* :head_tilt_joint :joint-angle 50)
  (send *robot* :head_pan_joint :joint-angle 15)
  (send *ri* :angle-vector (send *robot* :angle-vector) 5000)
  (send *ri* :stop-grasp :larm)
  )

(defun get-box-global-coords (bbox)
  (let* (
         (coords-local (ros::tf-pose->coords (send bbox :pose)))
         (tf-local->global (send *tfl* :lookup-transform "/base_footprint" (send bbox :header :frame_id) (ros::time 0)))
         (print (send bbox :header :frame_id))
         (coords-global (send tf-local->global :transform coords-local))
         )
    coords-global
    ))

(defun bbox->irt-cube (bbox)
  (let* (
         (dims (ros::tf-point->pos (send bbox :dimensions)))
         (irt-cube (make-cube (elt dims 0) (elt dims 1) (elt dims 2)))
         (send irt-cube :newcoords (get-box-global-coords bbox))
         )
    irt-cube
    ))

(setq *ik-pos* nil)
(print "fuck")
(defun callback (bbox)
  (let* (
         (coords (get-box-global-coords bbox))
         )
    (print "message received")
    (setq *ik-pos* (send coords :pos))
    (solve-ik)
    ))


(defun solve-ik ()
    (require "models/arrow-object.l")
    (setq coord-a (arrow))
    (send coord-a :newcoords (make-coords :pos *ik-pos*))
    (setq ll (send *robot* :link-list (send *robot* :larm :end-coords :parent)))
    (send *robot* :inverse-kinematics
          (send coord-a :copy-worldcoords)
          :link-list ll
          :move-target (send *robot* :larm :end-coords)
          :rotation-axis nil)
    (print "start grasping")
    (send *ri* :angle-vector (send *robot* :angle-vector) 8000)
    (send *ri* :wait-interpolation)
    (send *ri* :start-grasp :larm)
    (send *ri* :wait-interpolation)
    )

(robot-init)
(ros::subscribe "/bounding_box_marker/selected_box" jsk_recognition_msgs::BoundingBox #'callback)
(ros::rate 100)
(do-until-key
  (ros::sleep)
  (ros::spin-once))
(exit)


