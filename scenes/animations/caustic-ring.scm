
; Dette er scenen bag tracer50big.png som 
; findes p� bloggen 2004-06-16.

(load "../lib/raygay.scm")

;(set-renderer "raytracer")
(set-renderer "photonrenderer")

(set-camera 
  (make-pinhole-camera 
    '( pos 	#(200 500 1100)
       up 	#(0 1 0)
       lookat 	#(0 0 0)
       fov 	45
       aa 	3)))

(set-settings 
 '( globalphotons  	1000
    causticphotons 	100000
    estimateradius 	30
    estimatesamples 	300
    finalgatherrays 	0
    cachetolerance 	0.1))

(set-image-size '(640 480))
(set-image-size '(1280 720))
(set-background #(0.0 0.0 0.0))

(add-to-scene
  (make-spotlight #(1000 1000 400) #(0 0 0) 16 13 #(100000 100000 100000)))

(define chrome
  (make-material
    '( diffuse 	#(0.8 0.8 0.8)
       kd 	0.2
       specular #(1 1 1)
       specpow 	30
       ks 	0.8)))

(define glass
  (make-material
    '( diffuse 	#(0 0 0)
       kd 	0.0
       specular #(1 1 1)
       specpow 	30
       ks 	0.5
       kt 	0.5
       eta 	1.33)))

(define table_mat
  (make-material
    '( diffuse 	#(1 0.5 0.2)
       kd 	0.95
       ks 	0
       specpow 	0)))

(add-to-scene
	 (list 
	   (make-solid-box #(-1000 -100 -1000) #(1000 0 1000) table_mat)
	   (rotate
	   (rotate
	     (translate 
	     (make-difference
	        (make-cylinder #(0 0 0) #(0 100 0) 300)
	        (make-cylinder #(0 -20 0) #(0 120 0) 290)
	        chrome)
        #(0 53 0))
	      x-axis
	      10)
	      y-axis
	      (* clock 360))    
	   (make-sphere #(0 80 0) 80 glass)))
