

(define (square x)
 (* x x))

;; See http://mathworld.wolfram.com/Chair.html
(define (iso-chair k a b x y z) 
  (- (square (+ (square x)
		(square y)
		(square z)
		(- (* a k k))))
     (* b
	(- (square (- z k))
	   (* 2 x x))
	(- (square (+ z k))
	   (* 2 y y )))))

;; See http://mathworld.wolfram.com/Tanglecube.html
(define (iso-tanglecube x y z)
 (let ((x2 (* x x))
       (y2 (* y y))
       (z2 (* z z)))
  (+ (* x2 x2)
     (* -5 x2)
     (* y2 y2)
     (* -5 y2)
     (* z2 z2)
     (* -5 z2)
     11.8)))

;; See http://mathworld.wolfram.com/GoursatsSurface.html
(define (iso-goursats-surface a b c x y z)
 (let* ((x2 (* x x))
       (y2 (* y y))
       (z2 (* z z))
       (sumxyz (+ x2 y2 z2)))
  (+ (* x2 x2)
     (* y2 y2)
     (* z2 z2)
     (* a (square sumxyz))
     (* b sumxyz))))

(define (iso-torus r_major r_minor x y z)
 0)