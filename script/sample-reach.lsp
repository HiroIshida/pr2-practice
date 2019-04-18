#!/usr/bin/env roseus
(require "package://pr2eus/pr2-interface.l")


(defmacro pushback (el lst)
  `(if (null ,lst)
       (setf ,lst (list ,el))
     (nconc ,lst (list ,el))))
(defun send-av (time)
  (send *ri* :angle-vector (send *robot* :angle-vector) time))


(ros::roseus "reaching")
(ros::load-ros-manifest "jsk_recognition_msgs")
(ros::load-ros-manifest "roseus")

(setq *tfl* (instance ros::transform-listener :init))

(defun robot-init ()
  (pr2-init)
  (setq *robot* *pr2*)
  (send *robot* :angle-vector (send *ri* :state :potentio-vector))
  (objects (list *robot*))
  )


(defun bbox->cube (bbox)
  (let* ((dims (ros::tf-point->pos (send bbox :dimensions)))
         (bx (make-cube (elt dims 0) (elt dims 1) (elt dims 2))))
    (send bx :newcoords (pr2-tf-pose->coords (send bbox :header :frame_id) (send bbox :pose)))
    bx))

(defun pr2-tf-pose->coords (frame_id pose)
  (let (coords)
    (setq coords (ros::tf-pose->coords pose))
    (send (send *tfl* :lookup-transform "/base_footprint" frame_id (ros::time 0)) :transform coords)
    ))

(defun recognize-obj ()
  (let (msg)
    (setq msg (one-shot-subscribe "/boxes" jsk_recognition_msgs::BoundingBoxArray :after-stamp (ros::time)))
    (setq *obj* nil)
    (dolist (bbox (send msg :boxes)) (pushback (bbox->cube bbox) *obj*))
    (objects (append (list *robot*) *obj*))
    ))

(defun solve-ik (&key (id 0))
  (send *robot* :inverse-kinematics (elt *obj* id) :move-target (send *robot* :larm :end-coords) :link-list (send *robot* :larm :links) :rotation-axis nil :debug-view t)
  )

(defun check-obj (&key (id 0))
  (send (elt *obj* id) :draw-on :flush t)
  )

(warn "(robot-init)~%")
(warn "(recognize-obj)~%")
(warn "(send *ri* :stop-grasp)~%")
(warn "(check-obj :id 0)~%")
(warn "(solve-ik :id 0)~%")
(warn "(send *ri* :angle-vector (send *robot* :angle-vector) 8000)~%")
(warn "(send *ri* :start-grasp :larm)~%")
(warn "(send *robot* :larm :move-end-pos #f(-100 0 0) :local)~%")
(warn "(send *ri* :angle-vector (send *robot* :angle-vector) 8000)~%")
