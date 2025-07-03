rg --no-filename "stdlib_.+() \{$" | sed -E "s/\{//g" | sed -E "s/\(\)//g" | sort
