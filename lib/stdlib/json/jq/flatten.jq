def walk(path):
  if type == "object" then
    to_entries | map(
      ((if path == "" then "" else path + "." end) + .key) as $key |
      (.value | walk($key))
    ) | flatten
  elif type == "array" then
    to_entries | map(
      (path + ("[" + (.key | @text) + "]")) as $key |
      (.value | walk($key))
    )
  else
    [path + "=" + (. | tojson)]
  end;

def flatten(prefix):
  walk(prefix) | .[]
;
