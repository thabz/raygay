
(define (test-bytevectors)
 (test "native-endianness" (symbol? (native-endianness)))
 (test "endianness 1" (symbol? (endianness 'little)))
 (test "endianness 2" (symbol? (endianness 'big)))
 (test "endianness 3" (equal? (endianness 'little) 'little))
 (test "endianness 4" (equal? (endianness 'big) 'big))
 (test "" (equal? (bytevector? (make-bytevector 1000 200)) #t))
 (test "" (equal? (bytevector? #vu8(1 2 3 )) #t))
 (test "" (equal? (make-bytevector 3 200) #vu8(200 200 200)))
 (test "" (equal? (make-bytevector 2 -1) #vu8(255 255)))
 (test "" (equal? (make-bytevector 0) #vu8()))
 ;(fail "" (equal? (make-bytevector 0 'a)))
 (test "" (equal? (bytevector-length #vu8(1 2 3 4)) 4))
 (test "" (equal? (bytevector-length (make-bytevector 9000 200)) 9000))
 (test "" (bytevector=? (make-bytevector 900 200) (make-bytevector 900 200)))
 (test "" (equal? (bytevector=? (make-bytevector 901 200) (make-bytevector 900 200)) #f))
 (test "" (equal? (bytevector=? (make-bytevector 900 201) (make-bytevector 900 200)) #f))
 (test "" (equal? (bytevector=? #vu8(1 2 3 5) #vu8(1 2 3 5)) #t))
 (test "" (equal? (bytevector=? #vu8(1 2 3 5) #vu8(1 2 4 5)) #f))
 (test "" (equal? (bytevector=? (make-bytevector 0) (make-bytevector 0)) #t))
 ;(fail "" (bytevector=? (make-bytevector 0))))
 ;(fail "" (bytevector=?)))
 (test "" (equal? (equal? (make-bytevector 900 200) (make-bytevector 900 200)) #t))
 (test "" (equal? (let ((b (make-bytevector 3 200))) (bytevector-fill! b 10) b) #vu8(10 10 10)))
 (test "" (equal? (let ((b (u8-list->bytevector '(1 2 3 4 5 6 7 8)))) (bytevector-copy! b 0 b 3 4) (bytevector->u8-list b)) '(1 2 3 1 2 3 4 8)))
 (test "" (equal? (let ((b (u8-list->bytevector '(1 2 3 4 5 6 7 8)))) (bytevector-copy! b 3 b 0 4) (bytevector->u8-list b)) '(4 5 6 7 5 6 7 8)))
 (test "" (equal? (bytevector-copy #vu8(1 2 3)) #vu8(1 2 3)))
 
 (test "" (equal? (let ((b1 (make-bytevector 16 -127)) (b2 (make-bytevector 16 255))) (list (bytevector-s8-ref b1 0) (bytevector-u8-ref b1 0) (bytevector-s8-ref b2 0) (bytevector-u8-ref b2 0))) '(-127 129 -1 255)))
 (test "" (equal? (bytevector-u8-ref #vu8(1 2 3) 0) 1))
 (test "" (equal? (bytevector-u8-ref #vu8(1 2 3) 2) 3))
 ;(fail "" (bytevector-u8-ref #vu8(1 2 3) 3)))
 (test "" (equal? (bytevector-s8-ref #vu8(1 2 -128) 2) -128))
 (test "" (equal? (bytevector-s8-ref #vu8(255 2 -128) 0) -1))
 ;(fail "" (bytevector-s8-ref #vu8(1 2 3) 3)))
 (test "" (equal? (let ((b (make-bytevector 16 -127))) (bytevector-s8-set! b 0 -126) (bytevector-u8-set! b 1 246) (list (bytevector-s8-ref b 0) (bytevector-u8-ref b 0) (bytevector-s8-ref b 1) (bytevector-u8-ref b 1))) '(-126 130 -10 246)))
 ;(fail "" (bytevector-u8-set! #vu8(1 2 3 ) 0 1)))
 ;(fail "" (bytevector-u8-set! (make-bytevector 10 0) 10 1)))
 ;(fail "" (bytevector-u8-set! (make-bytevector 10 0) -1 1)))
 ;(fail "" (bytevector-u8-set! (make-bytevector 10 0) 0 256)))
 ;(fail "" (bytevector-u8-set! (make-bytevector 10 0) -1 -1)))
 ;(fail "" (bytevector-s8-set! #vu8(1 2 3 ) 0 1)))
 ;(fail "" (bytevector-s8-set! (make-bytevector 10 0) 10 1)))
 ;(fail "" (bytevector-s8-set! (make-bytevector 10 0) -1 1)))
 ;(fail "" (bytevector-s8-set! (make-bytevector 10 0) 0 128)))
 ;(fail "" (bytevector-s8-set! (make-bytevector 10 0) 0 -129)))
 (test "" (equal? (u8-list->bytevector '(-1 2 3)) #vu8(255 2 3)))
 (test "" (equal? (u8-list->bytevector '()) #vu8()))
 ;(fail "" (u8-list->bytevector '(1 2 3 800))))
 ;(fail "" (u8-list->bytevector)))
 (test "" (equal? (bytevector->u8-list #vu8(255 128 1 2 3)) '(255 128 1 2 3)))
 (test "" (equal? (bytevector->u8-list #vu8()) ()))
 ;(fail "" (bytevector->u8-list 'a)))
 (define b (u8-list->bytevector '(255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253)))
 (test "" (equal? (bytevector-u16-ref b 14 'little) 65023))
 (test "" (equal? (bytevector-u16-ref b 14 'big) 65533))
 (test "" (equal? (bytevector-s16-ref b 14 'little) -513))
 (test "" (equal? (bytevector-s16-ref b 14 'big) -3))

 (test "" (equal? (string->utf8 (string #\x05D0)) #vu8(215 144)))
 (test "" (equal? (string->utf8 (string #\x00A2)) #vu8(194 162)))
 (test "" (equal? (string->utf8 (string #\x25E6)) #vu8(226 151 166)))
 (test "" (equal? (string->utf8 (string #\x10146)) #vu8(240 144 133 134)))
 (test "" (equal? (string->utf8 (utf8->string #vu8(195 134 98 108 101 103 114 195 184 100))) #vu8(195 134 98 108 101 103 114 195 184 100)))

 ; Operations on 64-bit integers
 (set! b (make-bytevector 8 0))
 (bytevector-u64-set! b 0 #x1020304050607080 (endianness 'little))
 (test "" (equal? b #vu8(#x80 #x70 #x60 #x50 #x40 #x30 #x20 #x10)))
 (bytevector-u64-set! b 0 #x1020304050607080 (endianness 'big))
 (test "" (equal? b #vu8(#x10 #x20 #x30 #x40 #x50 #x60 #x70 #x80)))
 (bytevector-s64-set! b 0 -2 (endianness 'little))
 (test "" (equal? b #vu8(254 255 255 255  255 255 255 255)))
 (bytevector-s64-set! b 0 -2 (endianness 'big))
 (test "" (equal? b #vu8(255 255 255 255  255 255 255 254)))
)

(run-test "R6RS lib bytevectors" test-bytevectors)
