#!/usr/bin/env roseus
(require "package://pr2eus/pr2-interface.l")

(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")
(print "finish initializing")

(pr2-init)
(setq *tfl* (instance ros::transform-listener :init))
(setq *robot* *pr2*)

(defun robot-init ()
  (send *robot* :reset-pose)
  (send *robot* :l_shoulder_pan_joint :joint-angle 100)
  (send *robot* :l_shoulder_pan_joint :joint-angle 100)
  (send *robot* :l_shoulder_lift_joint :joint-angle -20)
  (send *robot* :head_tilt_joint :joint-angle 50)
  (send *robot* :head_pan_joint :joint-angle 15)
  (send *robot* :angle-vector (send *ri* :state :potentio-vector))
  (objects (list *robot*))
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

(setq ik-pos nil)
(defun callback (bbox)
  (let* (
         (coords (get-box-global-coords bbox))
         )
    (setq ik-pos (send coords :pos))
    ))


(defun solve-ik (&key (id 0))
  (send *robot* :inverse-kinematics ik-pos :move-target (send *robot* :larm :end-coords) :link-list (send *robot* :larm :links) :rotation-axis nil :debug-view t)
  )

(require "models/arrow-object.l")
(setq coord-a (arrow))
(send coord-a :newcoords (make-coords :pos ik-pos))

(setq ll (send *robot* :link-list (send *robot* :larm :end-coords :parent)))
(send *robot* :inverse-kinematics
      (send coord-a :copy-worldcoords)
      :link-list ll
      :move-target (send *robot* :larm :end-coords)
      :rotation-axis nil)
(objects (list *robot* coord-a))





  

(ros::subscribe "/bounding_box_marker/selected_box" jsk_recognition_msgs::BoundingBox #'callback)

(ros::rate 100)
(do-until-key
  (ros::sleep)
  (ros::spin-once))
(exit)


