
(load "lib/raygay.scm")

(set-image-size '(96 96))
(set-image-size '(800 800))
(set-background '(0.3 0.6 0.7 0.0))

(set-renderer "raytracer")
(set-camera 
  (make-pinhole-camera 
    '( pos (200 1400 2000)
       lookat (0 0 0)
       up (0 1 0)
       fov 27 
       aa 0)))

(define brown
  (make-material
    '( diffuse (0.7 0.4 0.2)
       kd 1.0
       ks 0.0)))

(define earth
(make-texture "gfx/earth.jpg" 1 1 'bilinear))

(define green
  (make-material
     (list 'diffuse earth
;    (list 'diffuse '(0.1 0.4 0.5)
       'kd 0.9
       'ks 0.0)))

(define glass
  (make-material
    '( diffuse (0.8 0.8 0.8)
       kd 0.0
       specular (1.0 1.0 1.0)
       ks 0.3
       kt 0.7
       eta 1.33
       specpow 30)))


(add-to-scene (list
  (make-pointlight '(500 1300 1300))
  (make-pointlight '(-500 1300 1300))))

(define longitudes 10)
(define lattitudes 8)
(define R 400)
(define r 4)

(let loop ((i 0))
  (if (< i longitudes)
   (begin
    (add-to-scene
      (rotate
	(rotate
	  (make-torus R r brown)
	  '(1 0 0 ) 90)
	'(0 1 0) (* i (/ 180 longitudes))))
    (loop (+ i 1)))))

(let loop ((i (- 1 lattitudes)))
  (if (< i lattitudes)
    (let* ((a (* π (/ i (* 2 lattitudes))))
	   (RR (* R (cos a)))
	   (h  (* R (sin a))))
      (add-to-scene
	(translate 
	  (make-torus RR r brown)
	  (list 0 h 0)))
      (loop (+ i 1)))))

