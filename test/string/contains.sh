eval "$(stdlib shellenv)"

stdlib::import "assert"
stdlib::import "string/contains"

stdlib::string::contains "foo" "bar"
stdlib::assert [ "$?" == 1 ]

stdlib::string::contains "foo" "foo"
stdlib::assert [ "$?" == 0 ]

stdlib::string::contains "hello world" "hell"
stdlib::assert [ "$?" == 0 ]

stdlib::string::contains "hello world" " world"
stdlib::assert [ "$?" == 0 ]

stdlib::string::contains "my file name.exe" "."
stdlib::assert [ "$?" == 0 ]

stdlib::string::contains "my file name" "."
stdlib::assert [ "$?" == 1 ]
