eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "lock"
stdlib_import "debugger"

lock_name="$(basename "$(mktemp -t "test")")"
test_lock_path="${DEFAULT_LOCK_DIR}/${lock_name}.lock"

stat "$test_lock_path" &>/dev/null
assert "$?" == 1

stdlib_lock_acquire "$lock_name"
assert "$(<"$test_lock_path")" == $$

stat "$test_lock_path" &>/dev/null
assert "$?" == 0

stdlib_lock_release "$lock_name"
stat "$test_lock_path" &>/dev/null
assert "$?" == 1
