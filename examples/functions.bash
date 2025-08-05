#!/usr/bin/env bash

eval "$(stdlib shellenv)"

stdlib_import "function/location"
stdlib_import "function/define"
stdlib_import "function/definition"

# this is a great comment
my_function() {
  echo "calling 'stdlib_function_location' inside the function:"
  stdlib_function_location
  echo
}
my_function 

echo "calling 'stdlib_function_location my_function' from outside the function:"
stdlib_function_location "my_function"
echo

echo "calling 'stdlib_function_definition my_function' from outside the function:"
stdlib_function_definition "my_function"
echo
echo "comment only"
stdlib_function_definition --comment "my_function"
echo
echo "declaration only"
stdlib_function_definition --declaration "my_function"
echo
echo "body only"
stdlib_function_definition --body "my_function"
echo

echo "DEFINE HERE"
echo "-----------"

stdlib_function_define "new_function_here" <<EOF
  # do comments stay in
  echo "calling 'stdlib_function_location' inside the anonymous function:"
  stdlib_function_location
  echo
EOF

echo "-----------"

new_function_here

echo "calling 'stdlib_function_location new_function_here' from outside the function:"
stdlib_function_location "new_function_here"
echo

echo "calling 'stdlib_function_definition new_function_here' from outside the function:"
stdlib_function_definition "new_function_here"
echo
