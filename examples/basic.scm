(import (kaappi template))

;; --- Plain text template ---

(display "=== Plain Text ===\n")
(display (template-render
  "Dear {{.name}},\n\nYour order #{{.order_id}} has been {{.status}}.\n\nItems:\n{{range .items}}- {{.}}\n{{end}}\nThank you!"
  '(("name" . "Alice")
    ("order_id" . 1234)
    ("status" . "shipped")
    ("items" . ("Widget" "Gadget" "Sprocket")))))
(newline)

;; --- HTML template (auto-escapes) ---

(display "\n=== HTML ===\n")
(display (template-render-html
  "<html>
<body>
  <h1>{{.title}}</h1>
  {{if .logged_in}}<p>Welcome, {{.user}}!</p>
  {{else}}<p>Please <a href=\"/login\">log in</a>.</p>
  {{end}}
  <ul>
  {{range .items}}<li>{{.name}} - ${{.price}}</li>
  {{end}}</ul>
</body>
</html>"
  '(("title" . "My Shop")
    ("logged_in" . #t)
    ("user" . "Bob <admin>")
    ("items" . ((("name" . "Widget") ("price" . "9.99"))
                (("name" . "Gadget & Co") ("price" . "24.99")))))))
(newline)
