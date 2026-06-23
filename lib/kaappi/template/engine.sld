(define-library (kaappi template engine)
  (import (scheme base) (scheme char) (scheme write)
          (kaappi template parse))
  (export template-parse template-execute
          tmpl-ref tmpl-ref-dot)
  (begin

    (define (template-parse str)
      (tmpl-parse-tokens (tmpl-tokenize str)))

    (define (template-execute nodes data escape-fn)
      (let ((port (open-output-string)))
        (exec-nodes nodes data escape-fn port)
        (get-output-string port)))

    (define (exec-nodes nodes data escape-fn port)
      (for-each
        (lambda (node) (exec-node node data escape-fn port))
        nodes))

    (define (exec-node node data escape-fn port)
      (let ((tag (car node)))
        (cond
          ((eq? tag 'text) (write-string (cdr node) port))
          ((eq? tag 'var)
           (write-string (escape-fn (val->str (tmpl-ref-dot data (cdr node)))) port))
          ((eq? tag 'if) (exec-if node data escape-fn port))
          ((eq? tag 'range) (exec-range node data escape-fn port)))))

    (define (exec-if node data escape-fn port)
      (let ((key (list-ref node 1))
            (then-n (list-ref node 2))
            (else-n (list-ref node 3)))
        (if (truthy? (tmpl-ref-dot data key))
            (exec-nodes then-n data escape-fn port)
            (exec-nodes else-n data escape-fn port))))

    (define (exec-range node data escape-fn port)
      (let ((key (list-ref node 1))
            (body-n (list-ref node 2)))
        (let ((items (tmpl-ref-dot data key)))
          (when (list? items)
            (for-each
              (lambda (item) (exec-nodes body-n item escape-fn port))
              items)))))

    (define (truthy? val)
      (cond
        ((eq? val #f) #f)
        ((eq? val 'null) #f)
        ((and (string? val) (string=? val "")) #f)
        ((and (list? val) (null? val)) #f)
        ((eqv? val 0) #f)
        (else #t)))

    (define (val->str val)
      (cond
        ((string? val) val)
        ((number? val) (number->string val))
        ((eq? val #t) "true")
        ((eq? val #f) "false")
        ((eq? val 'null) "")
        (else (let ((p (open-output-string))) (write val p) (get-output-string p)))))

    (define (tmpl-ref-dot data key)
      (cond
        ((string=? key ".") data)
        ((has-dot? key)
         (let loop ((d data) (ps (split-dot key)))
           (if (null? ps) d (loop (tmpl-ref d (car ps)) (cdr ps)))))
        (else (tmpl-ref data key))))

    (define (tmpl-ref data key)
      (if (and (pair? data) (pair? (car data)) (string? (caar data)))
          (let ((p (assoc key data))) (if p (cdr p) #f))
          #f))

    (define (has-dot? s)
      (let loop ((i 0))
        (cond ((= i (string-length s)) #f)
              ((char=? (string-ref s i) #\.) #t)
              (else (loop (+ i 1))))))

    (define (split-dot s)
      (let loop ((i 0) (start 0) (acc '()))
        (cond
          ((= i (string-length s))
           (reverse (cons (substring s start i) acc)))
          ((char=? (string-ref s i) #\.)
           (loop (+ i 1) (+ i 1) (cons (substring s start i) acc)))
          (else (loop (+ i 1) start acc)))))))
