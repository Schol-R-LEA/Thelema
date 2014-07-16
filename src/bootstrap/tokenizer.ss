#!r6rs

(library 
 (thelema bootstrap tokenizer)
 (export make-token-stream eat-line)
 (import 
  (rnrs base (6))
  (rnrs unicode (6))
  (rnrs io ports (6))
  (srfi :41)
  (bootstrap tokens))
 
 (define (make-token-stream src)
   (if (not (port? src))
       (error "data source not a port or file"))
   (let ((char-stream (port->stream src)))
     (stream-lambda 
      ()
      (stream-let loop ((first-char (char-stream)))
                  (stream-cons 
                   (case (first-char)
                     ((#\space) (loop (char-stream)))
                     ((#\newline) (loop (char-stream)))
                     ((#\;)
                      (eat-line char-stream)
                      (loop (char-stream)))
                     ((#\() (make-token first-char 'lparen))
                     ((#\)) (make-token first-char 'rparen)) 
                     ((#\.) (make-token first-char 'period))         
                     ((#\,) (make-token first-char 'comma))
                     ((#\') (make-token first-char 'single-quote))         
                     ((#\`) (make-token first-char 'back-quote))        
                     ((#\@) (make-token first-char 'at))
                     (else 
                      (cond
                        ((char-numeric? first-char) (parse-number char-stream first-char))
                        ((char=? first-char #\") (parse-string char-stream first-char)) 
                        (else (parse-symbol char-stream first-char)))))
                   (loop (char-stream)))))))
 
 (define (eat-line char-stream)
   (if (char=? (stream-car char-stream) #\newline)
       '()
       (eat-line (stream-cdr char-stream))))
 
 (define (parse-number char-stream first-char)
   '())
 
 (define (parse-string char-stream first-char)
   '())
 
 (define (parse-symbol char-stream first-char)
   '()))