def walk(is_root; prefix; path):
  if type == "object" then
    # (if path != "" then [path + "={}"] else [] end) +
    (to_entries | map(
      ((if is_root then prefix else path + "." end) + .key) as $key |
      (.value | walk(false; ""; $key))
    ) | flatten)
  elif type == "array" then
    # (if path != "" then [path + "=[]"] else [] end) +
    (to_entries | map(
      (path + ("[" + (.key | @text) + "]")) as $key |
      (.value | walk(false; ""; $key))
    ) | flatten)
  else
    [path + "=" + (. | tojson)]
  end;

def flatten(prefix):
  walk(true; prefix; "") | .[];
