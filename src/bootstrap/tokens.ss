#!r6rs

(library 
 (thelema bootstrap tokens)
 (export token-type token-type-set token make-token token? display-token)
 
 (import 
  (rnrs base (6))
  (rnrs enums (6))
  (rnrs io simple (6))
  (rnrs records syntactic (6)))
 
 (define-enumeration token-type
   (empty-list
    lparen rparen period
    single-quote double-quote back-quote comma at
    hash semi-colon colon 
    symbol char integer floating-point)
   token-type-set)
 
 (define-record-type (token make-token token?)
   (fields (immutable token get-token)
           (immutable type get-type))
   (protocol 
    (lambda (t)
      (lambda (tk ty)
        (if (and 
             (or (string? tk) (char? tk))
             (enum-set-member? ty (enum-set-universe (token-type-set))))
            (t tk ty)
            #f)))))
 
 (define (display-token t)
   (display #\<)
   (display #\")
   (display (get-token t))
   (display #\")
   (display #\:)
   (display #\space)
   (display (get-type t))
   (display #\>)
   t))