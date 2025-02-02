
(load "records-procedural.scm")

(load "vector-math.scm")
(load "paths.scm")
(load "handy-extensions.scm")
(load "image-sizes.scm")
(load "mesh.scm")
(load "object-factory.scm")
(load "color-defs.scm")

(define (add-to-scene thing . rest)
  "Add a sceneobject or a list of sceneobjects to scene"
  (if (list? thing)
    (for-each add-to-scene thing)
    (__add-to-scene__ thing))
  (if (not (null? rest)) (add-to-scene rest)))  

(define (set-image-size size)
  (set! __image-size__ size))

(define (set-background b)
  (set! __background__ b))

(define (set-renderer r)
  (set! __renderer__ r))

(define (set-camera c)
  (set! __camera__ c))

(load "objects.scm")    
