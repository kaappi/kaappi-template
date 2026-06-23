(define-library (kaappi template html)
  (import (scheme base) (scheme char))
  (export html-escape no-escape)
  (begin

    (define (html-escape s)
      (let ((port (open-output-string)))
        (let loop ((i 0))
          (when (< i (string-length s))
            (let ((ch (string-ref s i)))
              (cond
                ((char=? ch #\&) (write-string "&amp;" port))
                ((char=? ch #\<) (write-string "&lt;" port))
                ((char=? ch #\>) (write-string "&gt;" port))
                ((char=? ch #\") (write-string "&quot;" port))
                ((char=? ch #\') (write-string "&#39;" port))
                (else (write-char ch port)))
              (loop (+ i 1)))))
        (get-output-string port)))

    (define (no-escape s) s)))
