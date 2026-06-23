(import (scheme base) (scheme write)
        (kaappi template))

(define pass 0)
(define fail 0)

(define-syntax check
  (syntax-rules (=>)
    ((_ expr => expected)
     (let ((result expr) (exp expected))
       (if (equal? result exp)
           (set! pass (+ pass 1))
           (begin
             (set! fail (+ fail 1))
             (display "FAIL: ") (write 'expr)
             (display " => ") (write result)
             (display ", expected ") (write exp)
             (newline)))))))

;; --- Plain text substitution ---

(display "Variable substitution\n")

(check (template-render "Hello, {{.name}}!" '(("name" . "Alice")))
  => "Hello, Alice!")

(check (template-render "{{.a}} + {{.b}} = {{.c}}"
                        '(("a" . 1) ("b" . 2) ("c" . 3)))
  => "1 + 2 = 3")

(check (template-render "no vars here" '())
  => "no vars here")

(check (template-render "{{.}}" "world")
  => "world")

;; --- Nested keys ---

(display "Nested keys\n")

(check (template-render "{{.user.name}}"
                        '(("user" . (("name" . "Bob")))))
  => "Bob")

;; --- Conditionals ---

(display "Conditionals\n")

(check (template-render "{{if .show}}visible{{end}}" '(("show" . #t)))
  => "visible")

(check (template-render "{{if .show}}visible{{end}}" '(("show" . #f)))
  => "")

(check (template-render "{{if .x}}yes{{else}}no{{end}}" '(("x" . #t)))
  => "yes")

(check (template-render "{{if .x}}yes{{else}}no{{end}}" '(("x" . #f)))
  => "no")

(check (template-render "{{if .x}}yes{{else}}no{{end}}" '(("x" . "")))
  => "no")

(check (template-render "{{if .items}}has items{{end}}" '(("items" . (1 2))))
  => "has items")

(check (template-render "{{if .items}}has items{{end}}" '(("items" . ())))
  => "")

;; --- Range (loops) ---

(display "Range loops\n")

(check (template-render "{{range .items}}[{{.}}]{{end}}"
                        '(("items" . ("a" "b" "c"))))
  => "[a][b][c]")

(check (template-render "{{range .nums}}{{.}} {{end}}"
                        '(("nums" . (1 2 3))))
  => "1 2 3 ")

(check (template-render "{{range .people}}{{.name}} {{end}}"
                        '(("people" . ((("name" . "Alice")) (("name" . "Bob"))))))
  => "Alice Bob ")

(check (template-render "{{range .empty}}x{{end}}"
                        '(("empty" . ())))
  => "")

;; --- HTML escaping ---

(display "HTML escaping\n")

(check (template-render-html "{{.content}}"
                             '(("content" . "<script>alert('xss')</script>")))
  => "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;")

(check (template-render-html "{{.x}}" '(("x" . "a&b")))
  => "a&amp;b")

(check (template-render-html "{{.x}}" '(("x" . "\"quoted\"")))
  => "&quot;quoted&quot;")

;; Plain text mode does NOT escape
(check (template-render "{{.x}}" '(("x" . "<b>bold</b>")))
  => "<b>bold</b>")

;; --- Whitespace handling ---

(display "Whitespace\n")

(check (template-render "{{ .name }}" '(("name" . "trimmed")))
  => "trimmed")

(check (template-render "{{  if .x  }}yes{{  end  }}" '(("x" . #t)))
  => "yes")

;; --- Helpers ---

(define (string-contains? haystack needle)
  (let ((hlen (string-length haystack))
        (nlen (string-length needle)))
    (let loop ((i 0))
      (cond
        ((> (+ i nlen) hlen) #f)
        ((string=? (substring haystack i (+ i nlen)) needle) #t)
        (else (loop (+ i 1)))))))

;; --- Combined ---

(display "Combined\n")

(define page-tmpl "
<h1>{{.title}}</h1>
{{if .items}}<ul>
{{range .items}}<li>{{.}}</li>
{{end}}</ul>{{end}}")

(define page-data '(("title" . "My List")
                    ("items" . ("Apple" "Banana" "Cherry"))))

(define page-result (template-render-html page-tmpl page-data))
(check (string-contains? page-result "&lt;") => #f)
(check (string-contains? page-result "My List") => #t)
(check (string-contains? page-result "Apple") => #t)

;; --- Helpers ---

(define (string-contains? haystack needle)
  (let ((hlen (string-length haystack))
        (nlen (string-length needle)))
    (let loop ((i 0))
      (cond
        ((> (+ i nlen) hlen) #f)
        ((string=? (substring haystack i (+ i nlen)) needle) #t)
        (else (loop (+ i 1)))))))

;; --- Summary ---

(newline)
(display pass) (display " passed, ")
(display fail) (display " failed\n")
(when (> fail 0) (exit 1))
