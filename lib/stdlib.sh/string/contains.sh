stdlib::string::contains () {
  local -r string="$1"
  local -r substring="$2"

  # This is a clever way of checking for a substring in Bash. The way it works
  # is by taking the original string, then tries to REMOVE the substring from
  # it, then checks to see if the resulting string is the same as the original.
  #
  # So here's how that looks:
  #
  #   stdlib::string::contains "hello world" "world"
  #
  # (eventually becomes...)
  #
  #   [ "hello " != "world" ]
  #
  [ "${string#*"$substring"}" != "$string" ]
}
