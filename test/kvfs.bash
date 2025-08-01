eval "$(stdlib shellenv)"

stdlib_import "assert"
stdlib_import "kvfs"

test_store_path="$(mktemp -d)"

stdout=$(stdlib_kvfs_keypath "/Users/person-name/.local/my-name/kvfs" "https://help.my-website.com/en/articles/32452354-how-to-use-stdlib-to-make-cool-programs-and-other-things-for-lots-of-fun")
assert "$stdout" == "/Users/person-name/.local/my-name/kvfs/1171663190"

stdout=$(stdlib_kvfs_keypath "/tmp/known_store" "foo")
assert "$stdout" == "/tmp/known_store/101574"

stdlib_kvfs_set "$test_store_path" "my_key" "my_value"
assert "$?" == 0

stdout=$(stdlib_kvfs_get "$test_store_path" "my_key")
assert "$stdout" == "my_value"

stdlib_kvfs_set "$test_store_path" "and_another" "another_value"
assert "$?" == 0

stdout=$(stdlib_kvfs_get "$test_store_path" "and_another")
assert "$stdout" == "another_value"

stdout=$(stdlib_kvfs_list "$test_store_path")
assert "$stdout" == $'my_key\nand_another'

stdlib_kvfs_delete "$test_store_path" "and_another"
assert "$?" == 0

stdlib_kvfs_get "$test_store_path" "and_another"
assert "$?" == 1

stdlib_kvfs_reset "$test_store_path"
assert "$?" == 0

stdout=$(stdlib_kvfs_list "$test_store_path")
assert "$stdout" == ""

test_store_proxy() {
  stdlib_kvfs_create_proxy "${FUNCNAME[0]}" "$@"
}

test_value="my cool $(date)"
test_store_proxy set "key" "$test_value"

stdout=$(test_store_proxy get "key")
assert "$stdout" == "$test_value"
