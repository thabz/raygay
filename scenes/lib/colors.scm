
;; Inspired by http://nodebox.net/code/index.php/Colors
;; All procedures working on a single color, should also
;; work on a list of colors.

(define (red-component c)
  (vector-ref c 0))
(define (green-component c)
  (vector-ref c 1))
(define (blue-component c)
  (vector-ref c 2))
(define (hue-component c)
  (vector-ref (rgb->hsv c) 0))
(define (saturation-component c)
  (vector-ref (rgb->hsv c) 1))
(define (value-component c)
  (vector-ref (rgb->hsv c) 2))
(define (brightness-component c)
  (vector-ref (rgb->hsv c) 2))

; See http://en.wikipedia.org/wiki/HSV_color_space
(define (hsv->rgb hsv)
  (let* ((H (mod (* (vector-ref hsv 0) 360) 360))
         (S (vector-ref hsv 1))
         (V (vector-ref hsv 2))
         (Hi (mod (floor (/ H 60.0)) 6.0))
         (f (- (/ H 60.0) Hi))
         (p (* V (- 1.0 S)))
         (q (* V (- 1.0 (* f S))))
         (t (* V (- 1.0 (* (- 1.0 f) S)))))
    (case (floor Hi) 
      ((0.0) (vector V t p))     
      ((1.0) (vector q V p))     
      ((2.0) (vector p V t))     
      ((3.0) (vector p q V))     
      ((4.0) (vector t p V))     
      ((5.0) (vector V p q)))))

; See http://en.wikipedia.org/wiki/HSV_color_space
(define (rgb->hsv rgb)
  (let* ((r (red-component rgb))
         (g (green-component rgb))
         (b (blue-component rgb))
         (maxx (max r g b))
         (minn (min r g b))
         (max-min-inv (/ 60.0 (- maxx minn)))
         (h (cond 
           ((= maxx minn) 0.0)
           ((and (= maxx r) (>= g b))
              (* (- g b) max-min-inv))
           ((and (= maxx r) (< g b))
              (+ 360.0 (* (- g b) max-min-inv)))
           ((= maxx g)
              (+ 120.0 (* (- b r) max-min-inv)))
           (else
              (+ 240.0 (* (- r g) max-min-inv)))))        
         (v maxx)
         (s (cond  
           ((zero? maxx) 0.0)
           (else (- 1 (/ minn maxx))))))
      (vector (/ h 360.0) s v)))      

; Converts "#ff80ff" to #(1 128/256 1)
(define (hex->rgb hex-string)
  (let* ((r (string->number (substring hex-string 1 3) 16))
         (g (string->number (substring hex-string 3 5) 16))
         (b (string->number (substring hex-string 5 7) 16)))
     (vector (/ r 255) (/ g 255) (/ b 255))))

(define (two-digit-string s)
 (if (= 1 (string-length s))
  (string-append "0" s)
  s))

(define (rgb->hex c)
  (string-append "#"
    (two-digit-string (number->string (inexact->exact (floor (* 255 (red-component c)))) 16))
    (two-digit-string (number->string (inexact->exact (floor (* 255 (green-component c)))) 16))
    (two-digit-string (number->string (inexact->exact (floor (* 255 (blue-component c)))) 16))))

(define (normalize-hsv hsv)
  (vector 
    (mod (vector-ref hsv 0) 1.0)
    (max (min (vector-ref hsv 1) 1.0) 0.0)
    (max (min (vector-ref hsv 2) 1.0) 0.0)))

(define (color-rotate rgb angle)
  (if (list? rgb)
    (map (lambda (c) (color-rotate c angle)) rgb)
    (let ((hsv (rgb->hsv rgb)))
      (hsv->rgb
	      (normalize-hsv 
	        (vector 
	          (+ angle (vector-ref hsv 0))
	          (vector-ref hsv 1)
	          (vector-ref hsv 2)))))))

; Not working...
(define (color-gradient-smooth num col1 col2 . col-rest)
  (let* ((cols (cons col1 (cons col2 col-rest))))
    (set! cols (cons (v- col1 col2) cols))
    (set! cols (reverse cols))
    (set! cols (cons (v- (car cols) (cadr cols)) cols))
    (set! cols (reverse cols))
    (let ((spline (make-catmullrom-spline cols)))
      (let loop ((i 0) (result '()))
        (if (= i num) 
          result
          (loop (+ i 1) 
                (cons (point-on-path spline (/ i num)) result)))))))

(define (linear-ramp a b t)
  (+ (* t (- b a)) a))

(define (rgb-ramp c1 c2 t)
  (vector (linear-ramp (red-component c1)   (red-component c2)   t)
          (linear-ramp (green-component c1) (green-component c2) t)
          (linear-ramp (blue-component c1)  (blue-component c2)  t)))

(define (color-gradient-procedure colors)
  (let* ([cols (list->vector colors)]
         [cols-num (vector-length cols)]
         [segments-num (- cols-num 1)])
    (lambda (t) 
      (let* ([segment (floor (* segments-num t))]
             [offset (- (* t segments-num) segment)])
        (rgb-ramp (vector-ref cols segment) (vector-ref cols (+ 1 segment)) offset)))))

(define (color-gradient num colors)
  (let loop ([result '()]
             [t 0]
             [proc (color-gradient-procedure colors)])
    (if (>= t 1) (reverse result)
      (loop 
        (cons (proc t) result)
        (+ t (/ num))
        proc))))

; The ranges are (min . max) pairs
(define (color-range num h-range s-range v-range)
  (let loop ((i 0) (result '()))
    (if (= i num) (reverse result)
      (let ((t (/ i num)))
	(loop
	  (+ 1 i)
	  (cons 
	    (hsv->rgb 
	      (vector (linear-ramp (car h-range) (cdr h-range) t)
 		            (linear-ramp (car s-range) (cdr s-range) t)
		            (linear-ramp (car v-range) (cdr v-range) t)))
 	    result))))))

; Returns the complementary color, ie. the hue rotated 180 degrees.
(define (color-complement rgb)
   (color-rotate rgb 0.5))

(define (color-brighten rgb . amount)
  (let ([amount (if (null? amount) 0.1 (car amount))])
    (hsv->rgb (normalize-hsv
      (vector (hue-component rgb)
              (saturation-component rgb)
              (+ (brightness-component rgb) amount))))))       

(define (color-darken rgb . amount)
  (let ([amount (if (null? amount) 0.1 (car amount))])
    (color-brighten rgb (- amount))))

(define (color-darkest colors)
  (if (null? (cdr colors))
     (car colors)
     (let* ((darkest-of-cdr (color-darkest (cdr colors)))
            (brightness-of-cdr (brightness-component darkest-of-cdr))
            (brightness-of-car (brightness-component (car colors))))
       (if (< brightness-of-car brightness-of-cdr)
         (car colors)
         (darkest-of-cdr)))))

(define color-alice-blue '#(0.941 0.973 1.000))
(define color-antique-white #(0.980 0.922 0.843))
(define color-aquamarine #(0.498 1.000 0.831))
(define color-azure #(0.941 1.000 1.000))
(define color-beige #(0.961 0.961 0.863))
(define color-bisque #(1.000 0.894 0.769))
(define color-black #(0.000 0.000 0.000))
(define color-blanched-almond #(1.000 0.922 0.804))
(define color-blue-violet #(0.541 0.169 0.886))
(define color-blue #(0.000 0.000 1.000))
(define color-brown #(0.647 0.165 0.165))
(define color-burlywood #(0.871 0.722 0.529))
(define color-cadet-blue #(0.373 0.620 0.627))
(define color-chartreuse #(0.498 1.000 0.000))
(define color-chocolate #(0.824 0.412 0.118))
(define color-coral #(1.000 0.498 0.314))
(define color-cornflower-blue #(0.392 0.584 0.929))
(define color-cornsilk #(1.000 0.973 0.863))
(define color-cyan #(0.000 1.000 1.000))
(define color-dark-blue #(0.000 0.000 0.545))
(define color-dark-cyan #(0.000 0.545 0.545))
(define color-dark-goldenrod #(0.722 0.525 0.043))
(define color-dark-gray #(0.663 0.663 0.663))
(define color-dark-green #(0.000 0.392 0.000))
(define color-dark-khaki #(0.741 0.718 0.420))
(define color-dark-magenta #(0.545 0.000 0.545))
(define color-dark-olive-green #(0.333 0.420 0.184))
(define color-dark-orange #(1.000 0.549 0.000))
(define color-dark-orchid #(0.600 0.196 0.800))
(define color-dark-red #(0.545 0.000 0.000))
(define color-dark-salmon #(0.914 0.588 0.478))
(define color-dark-sea-green #(0.561 0.737 0.561))
(define color-dark-slate-blue #(0.282 0.239 0.545))
(define color-dark-slate-gray #(0.184 0.310 0.310))
(define color-dark-turquoise #(0.000 0.808 0.820))
(define color-dark-violet #(0.580 0.000 0.827))
(define color-deep-pink #(1.000 0.078 0.576))
(define color-deep-sky-blue #(0.000 0.749 1.000))
(define color-dodger-blue #(0.118 0.565 1.000))
(define color-firebrick #(0.698 0.133 0.133))
(define color-floral-white #(1.000 0.980 0.941))
(define color-forest-green #(0.133 0.545 0.133))
(define color-gainsboro #(0.863 0.863 0.863))
(define color-ghost-white #(0.973 0.973 1.000))
(define color-gold #(1.000 0.843 0.000))
(define color-goldenrod #(0.855 0.647 0.125))
(define color-gray #(0.745 0.745 0.745))
(define color-green-yellow #(0.678 1.000 0.184))
(define color-green #(0.000 1.000 0.000))
(define color-honeydew #(0.941 1.000 0.941))
(define color-hot-pink #(1.000 0.431 0.706))
(define color-indian-red #(0.804 0.361 0.361))
(define color-ivory #(1.000 1.000 0.941))
(define color-khaki #(0.941 0.902 0.549))
(define color-lavender #(0.902 0.902 0.980))
(define color-lavender-blush #(1.000 0.941 0.961))
(define color-lawn-green #(0.486 0.988 0.000))
(define color-lemon-chiffon #(1.000 0.980 0.804))
(define color-light-blue #(0.678 0.847 0.902))
(define color-light-coral #(0.941 0.502 0.502))
(define color-light-cyan #(0.878 1.000 1.000))
(define color-light-goldenrod #(0.933 0.867 0.510))
(define color-light-goldenrod-yellow #(0.980 0.980 0.824))
(define color-light-gray #(0.827 0.827 0.827))
(define color-light-green #(0.565 0.933 0.565))
(define color-light-pink #(1.000 0.714 0.757))
(define color-light-salmon #(1.000 0.627 0.478))
(define color-light-sea-green #(0.125 0.698 0.667))
(define color-light-sky-blue #(0.529 0.808 0.980))
(define color-light-slate-blue #(0.518 0.439 1.000))
(define color-light-slate-gray #(0.467 0.533 0.600))
(define color-light-steel-blue #(0.690 0.769 0.871))
(define color-light-yellow #(1.000 1.000 0.878))
(define color-lime-green #(0.196 0.804 0.196))
(define color-linen               #(0.980 0.941 0.902))
(define color-magenta             #(1.000 0.000 1.000))
(define color-maroon              #(0.690 0.188 0.376))
(define color-medium-blue         #(0.000 0.000 0.804))
(define color-medium-orchid       #(0.729 0.333 0.827))
(define color-medium-purple       #(0.576 0.439 0.859))
(define color-medium-sea-green    #(0.235 0.702 0.443))
(define color-medium-slate-blue   #(0.482 0.408 0.933))
(define color-medium-spring-green #(0.000 0.980 0.604))
(define color-medium-turquoise    #(0.282 0.820 0.800))
(define color-medium-violet-red   #(0.780 0.082 0.522))
(define color-midnight-blue       #(0.098 0.098 0.439))
(define color-mint-cream          #(0.961 1.000 0.980))
(define color-misty-rose          #(1.000 0.894 0.882))
(define color-moccasin            #(1.000 0.894 0.710))
(define color-navajo-white        #(1.000 0.871 0.678))
(define color-navy                #(0.000 0.000 0.502))
(define color-old-lace            #(0.992 0.961 0.902))
(define color-olive-drab #(0.420 0.557 0.137))
(define color-orange-red #(1.000 0.271 0.000))
(define color-orange #(1.000 0.647 0.000))
(define color-orchid #(0.855 0.439 0.839))
(define color-pale-goldenrod #(0.933 0.910 0.667))
(define color-pale-green #(0.596 0.984 0.596))
(define color-pale-turquoise #(0.733 1.000 1.000))
(define color-pale-violet-red #(0.859 0.439 0.576))
(define color-papaya-whip #(1.000 0.937 0.835))
(define color-peach-puff #(1.000 0.855 0.725))
(define color-peru #(0.804 0.522 0.247))
(define color-pink #(1.000 0.753 0.796))
(define color-plum #(0.867 0.627 0.867))
(define color-powder-blue #(0.690 0.878 0.902))
(define color-purple #(0.627 0.125 0.941))
(define color-red #(1.000 0.000 0.000))
(define color-rosy-brown #(0.737 0.561 0.561))
(define color-royal-blue #(0.255 0.412 0.882))
(define color-saddle-brown #(0.545 0.271 0.075))
(define color-salmon #(0.980 0.502 0.447))
(define color-sandy-brown #(0.957 0.643 0.376))
(define color-sea-green #(0.180 0.545 0.341))
(define color-seashell #(1.000 0.961 0.933))
(define color-sienna #(0.627 0.322 0.176))
(define color-sky-blue #(0.529 0.808 1.000))
(define color-slate-blue #(0.416 0.353 0.804))
(define color-slate-gray #(0.439 0.502 0.565))
(define color-snow #(1.000 0.980 0.980))
(define color-spring-green #(0.000 1.000 0.498))
(define color-steel-blue #(0.275 0.510 0.706))
(define color-tan #(0.824 0.706 0.549))
(define color-thistle #(0.847 0.749 0.847))
(define color-tomato #(1.000 0.388 0.278))
(define color-turquoise #(0.251 0.878 0.816))
(define color-violet #(0.933 0.510 0.933))
(define color-violet-red #(0.816 0.125 0.565))
(define color-wheat #(0.961 0.871 0.702))
(define color-white #(1.000 1.000 1.000))
(define color-yellow-green #(0.604 0.804 0.196))
(define color-yellow #(1.000 1.000 0.000))
