rg "stdlib::.+() \{$" | sed -E "s/\{//g" | sed -E "s/lib\/stdlib.sh\/([a-z]+)(\.sh)?://"
