#!/usr/bin/env bash

source "$STDLIB_PATH/lib/stdlib.sh/debugger.sh"

coproc conn ( sqlite3 -init "sqliteinit" -interactive "$HOME/Code/northwind.db"  )

while read -r line; do
  echo "intro: $line"
done <&"${conn[0]}"

echo "The print coprocess array: ${conn[@]}"

echo "The PID of the print coprocess is ${conn_PID}"

split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
   printf '%s\n' "${arr[@]}"
}

readco() {
  while read -r line; do
    echo "${line}"
  done <&"${conn[0]}"

  # echo "$stdout"
  # echo -E "----> ${stdout@Q}"
  # echo "$(echo "$stdout" | tail -n +2)"



}

readco

sql() {
  echo "$1; .print hello"  >&"${conn[1]}"
  readco
}

results=$(sql "select EmployeeID, FirstName, LastName from Employees;")

# while IFS= read -d $'\036' -r row; do
#   IFS=$'\037' read -a cols -r <<< "$row"
#
#   for col in ${cols[@]}; do
#     printf 'emp %s\n' "$col"
#   done
#
#   echo
# done <<< "$results"
#
# exit

ROWS=$'\036'

while IFS=$ROWS read -r row; do
  echo "RECORD: $row"
  # You can perform other operations on each line here
done <<< "$results"


# writeandwait "hello there"

# stdlib::debugger
