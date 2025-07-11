def walk(path):
  if type == "object" then
    to_entries | map(
      ((if path == "" then "" else path + "." end) + .key) as $key |
      (.value | walk($key))
    ) | flatten
  elif type == "array" then
    if length > 0 then
      [path + "=array"] + (.[] | walk(path + "[]"))
    else
      [path + "=array"]
    end
  else
    [path + "=" + type]
  end;

def shape:
  walk("") | unique | .[]
;
