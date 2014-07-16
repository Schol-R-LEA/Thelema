#!r6rs

(import 
 (rnrs base (6))
 (rnrs r5rs (6))
 (srfi :41)
 (srfi :64)
 (rnrs records syntactic (6))
 (rnrs io simple (6))
 (bootstrap tokens)
 (bootstrap tokenizer))

(test-begin "simple token definition") 
(let ((a (make-token "symbol" 'symbol)))
  (test-assert (token? a)))
(test-end "simple token definition")

(test-begin "single character token definition")
(let ((a (make-token #\( 'lparen)))
  (test-assert (token? a)))
(test-end "single character token definition")

(test-begin "comment elimination")
(let ((test-stream
       (stream-cons #\;
                    (stream-cons #\a
                                 (stream-cons #\b
                                              (stream-cons #\c
                                                           (stream-cons #\newline
                                                                        stream-null)))))))
  (test-assert (null? (eat-line test-stream))))
(test-end "comment elimination")