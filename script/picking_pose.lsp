
(load "package://pr2eus/pr2-interface.l")
(pr2-init) 
(setq *robot* *pr2*)

;; picking up pose
(send *robot* :reset-pose)
(send *robot* :l_shoulder_pan_joint :joint-angle 100)
(send *robot* :l_shoulder_pan_joint :joint-angle 100)
(send *robot* :l_shoulder_lift_joint :joint-angle -20)
(send *robot* :head_tilt_joint :joint-angle 50)
(send *robot* :head_pan_joint :joint-angle 15)
(send *ri* :angle-vector (send *robot* :angle-vector) 5000)

