(define-library (kaappi template)
  (import (scheme base)
          (kaappi template engine)
          (kaappi template html))
  (export template-render template-render-html
          template-parse template-execute
          html-escape)
  (begin

    (define (template-render tmpl-string data)
      (let ((nodes (template-parse tmpl-string)))
        (template-execute nodes data no-escape)))

    (define (template-render-html tmpl-string data)
      (let ((nodes (template-parse tmpl-string)))
        (template-execute nodes data html-escape)))))
