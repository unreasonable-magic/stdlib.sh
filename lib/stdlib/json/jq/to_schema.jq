def to_schema:
  if type == "object" then
    {
      type: "object",
      properties: (to_entries | map({
        key: .key,
        value: (.value | to_schema)
      }) | from_entries)
    }
  elif type == "array" then
    {
      type: "array",
      items: (if length > 0 then .[0] | to_schema else {} end)
    }
  else
    { type: type }
  end;
