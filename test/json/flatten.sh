eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "json/flatten"

json='{
  "name": "Alice Johnson",
  "age": 28,
  "active": true,
  "score": null,
  "user": {
    "id": 12345,
    "email": "alice@example.com",
    "verified": false
  },
  "tags": ["premium", "beta-tester"],
  "preferences": {
    "theme": "dark",
    "notifications": true,
    "languages": ["en", "es", "fr"]
  },
  "metadata": {
    "created": "2024-01-15",
    "settings": {
      "privacy": "public",
      "sync": true
    }
  },
  "scores": [85, 92, 78],
  "balance": 1250.50
}'
stdout=$(echo "$json" | stdlib_json_flatten)
assert "$stdout" == '$.name="Alice Johnson"
$.age=28
$.active=true
$.score=null
$.user.id=12345
$.user.email="alice@example.com"
$.user.verified=false
$.tags[0]="premium"
$.tags[1]="beta-tester"
$.preferences.theme="dark"
$.preferences.notifications=true
$.preferences.languages[0]="en"
$.preferences.languages[1]="es"
$.preferences.languages[2]="fr"
$.metadata.created="2024-01-15"
$.metadata.settings.privacy="public"
$.metadata.settings.sync=true
$.scores[0]=85
$.scores[1]=92
$.scores[2]=78
$.balance=1250.50'
