# kaappi-template

Text and HTML template engine for [Kaappi Scheme](https://github.com/kaappi/kaappi).

Pure Scheme — no C dependencies, no build step.

## Install

```bash
thottam install kaappi-template
```

## Quick start

```scheme
(import (kaappi template))

;; Plain text (no escaping)
(template-render "Hello, {{.name}}!" '(("name" . "Alice")))
;=> "Hello, Alice!"

;; HTML (auto-escapes <>&"')
(template-render-html "<p>{{.content}}</p>"
  '(("content" . "<script>alert('xss')</script>")))
;=> "<p>&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</p>"
```

## Template syntax

### Variables

```
{{.name}}          Access a key from the data alist
{{.user.email}}    Nested access (dotted path)
{{.}}              Current value (useful inside range)
```

### Conditionals

```
{{if .show}}
  This is visible
{{end}}

{{if .logged_in}}
  Welcome!
{{else}}
  Please log in.
{{end}}
```

Falsy values: `#f`, `'null`, `""`, `()`, `0`

### Loops

```
{{range .items}}
  Item: {{.}}
{{end}}

{{range .users}}
  {{.name}} ({{.email}})
{{end}}
```

## API

```scheme
(template-render template-string data)       ; plain text (no escaping)
(template-render-html template-string data)  ; HTML (auto-escapes)
```

Data is an alist: `'(("key" . value) ...)`. Nested data uses nested alists.

### Lower-level API

```scheme
(template-parse template-string)             ; parse to AST (reusable)
(template-execute ast data escape-fn)        ; execute with custom escape
(html-escape string)                         ; HTML entity escaping
```

## License

MIT
