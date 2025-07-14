def infer(is_root):
  if type == "object" then
    (
      if is_root then
        {
          "$schema": "https://json-schema.org/draft/2020-12/schema"
        } + (
          if $TITLE != "" then
            { title: $TITLE }
          else
            {}
          end
        )
      else
        {}
      end
    ) + {
      type: "object",
      properties: (to_entries | map({
        key: .key,
        value: (.value | infer(false))
      }) | from_entries)
    }
  elif type == "array" then
    {
      type: "array",
      items: (if length > 0 then .[0] | infer(false) else {} end)
    }
  elif type == "string" then
    {
      type: "string"
    } + (
      if test("^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"; "i") then
        { format: "uuid" }
      elif test("^[a-zA-Z][a-zA-Z0-9+.-]*:[^\\s]*$") then
        { format: "uri" }
      elif test("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}") then
        { format: "date-time" }
      else
        {}
      end
    )
  elif type == "null" then
    {}
  else
    { type: type }
  end;
