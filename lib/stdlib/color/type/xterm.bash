stdlib_import "array/join"
stdlib_import "string/underscore"
stdlib_import "terminal/palette"

stdlib_color_type_xterm_format() {
  __stdlib_color_type_xterm_load_list

  # First we need to convert the color into a format we can search on
  local x11_formatted="${ stdlib_color_type_x11_format; }"

  # This is a crime against nature. Here I'm querying the values of all 256
  # colors in the terminal. It'd be nice if there's a better way to do this, but
  # this is fine for now. This output from this is:
  #
  #    0=rgb:xx/xx/xx
  #    1=rgb:xx/xx/xx
  #    2=rgb:xx/xx/xx
  #    etc.
  #
  local response="${ stdlib_terminal_palette_query 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255; }"

  # Now that we've got our x11 formatted rgb color, and list of colors from the
  # terminal, find the one that matches the current color
  local number=""
  while IFS=$'\n' read -r line; do
    if [[ "$line" == *"$x11_formatted"* ]]; then
      number="${line/"=$x11_formatted"/}"
      break
    fi
  done <<< "$response"

  # Finally! We have our number, now we can find the name that matches the number
  local key
  for key in "${!__stdlib_color_type_xterm_list[@]}"; do
    if [[ "${__stdlib_color_type_xterm_list["$key"]}" == "$number" ]]; then
      printf "xterm:%s\n" "$key"
      return
    fi
  done
}

stdlib_color_type_xterm_parse() {
  if [[ "$1" == "xterm:"* ]]; then
    __stdlib_color_type_xterm_load_list

    # First thing we need to do is find the color in the list
    local name="${ stdlib_string_underscore "${1/xterm://}"; }"
    local number="${__stdlib_color_type_xterm_list["$name"]}"
    if [[ "$number" == "" ]]; then
      return 1
    fi

    # Now we've got the number, let's query the terminal for it's current rgb
    # value. The result should be: "num=rgb:xx/xx/xx"
    local rgb="${ stdlib_terminal_palette_query "$number"; }"
    if [[ "$rgb" != "${number}=rgb:"* ]]; then
      return 1
    fi

    # We can now use our x11 parser to get the RGB (we gotta remove the number
    # prefix first though)
    if ! stdlib_color_type_x11_parse "${rgb/$number=/}"; then
      return 1
    fi

    # Since we were cheeky and stold the x11 formatter, we gotta replace the
    # type in COLOR with our name
    COLOR[0]="xterm"

    return 0
  fi

  return 1
}

stdlib_color_type_xterm_list() {
  __stdlib_color_type_xterm_load_list

  local -a keys=()
  for name in "${!__stdlib_color_type_xterm_list[@]}"; do
    keys+=("$name")
  done

  printf "%s\n" "${ stdlib_array_join --delim $'\n' -a keys; }"
}

__stdlib_color_type_xterm_load_list() {
  declare -A -g __stdlib_color_type_xterm_list=(
    ["black"]=0
    ["red"]=1
    ["green"]=2
    ["yellow"]=3
    ["blue"]=4
    ["magenta"]=5
    ["cyan"]=6
    ["white"]=7
    ["lightblack"]=8
    ["lightred"]=9
    ["lightgreen"]=10
    ["lightyellow"]=11
    ["lightblue"]=12
    ["lightmagenta"]=13
    ["lightcyan"]=14
    ["lightwhite"]=15
    ["grey0"]=16
    ["navyblue"]=17
    ["darkblue"]=18
    ["blue3"]=19
    ["blue3_2"]=20
    ["blue1"]=21
    ["darkgreen"]=22
    ["deepskyblue4"]=23
    ["deepskyblue4_2"]=24
    ["deepskyblue4_3"]=25
    ["dodgerblue3"]=26
    ["dodgerblue2"]=27
    ["green4"]=28
    ["springgreen4"]=29
    ["turquoise4"]=30
    ["deepskyblue3"]=31
    ["deepskyblue3_2"]=32
    ["dodgerblue1"]=33
    ["green3"]=34
    ["springgreen3"]=35
    ["darkcyan"]=36
    ["lightseagreen"]=37
    ["deepskyblue2"]=38
    ["deepskyblue1"]=39
    ["green3_2"]=40
    ["springgreen3_2"]=41
    ["springgreen2"]=42
    ["cyan3"]=43
    ["darkturquoise"]=44
    ["turquoise2"]=45
    ["green1"]=46
    ["springgreen2_2"]=47
    ["springgreen1"]=48
    ["mediumspringgreen"]=49
    ["cyan2"]=50
    ["cyan1"]=51
    ["darkred"]=52
    ["deeppink4"]=53
    ["purple4"]=54
    ["purple4_2"]=55
    ["purple3"]=56
    ["blueviolet"]=57
    ["orange4"]=58
    ["grey37"]=59
    ["mediumpurple4"]=60
    ["slateblue3"]=61
    ["slateblue3_2"]=62
    ["royalblue1"]=63
    ["chartreuse4"]=64
    ["darkseagreen4"]=65
    ["paleturquoise4"]=66
    ["steelblue"]=67
    ["steelblue3"]=68
    ["cornflowerblue"]=69
    ["chartreuse3"]=70
    ["darkseagreen4_2"]=71
    ["cadetblue"]=72
    ["cadetblue_2"]=73
    ["skyblue3"]=74
    ["steelblue1"]=75
    ["chartreuse3_2"]=76
    ["palegreen3"]=77
    ["seagreen3"]=78
    ["aquamarine3"]=79
    ["mediumturquoise"]=80
    ["steelblue1_2"]=81
    ["chartreuse2"]=82
    ["seagreen2"]=83
    ["seagreen1"]=84
    ["seagreen1_2"]=85
    ["aquamarine1"]=86
    ["darkslategray2"]=87
    ["darkred_2"]=88
    ["deeppink4_2"]=89
    ["darkmagenta"]=90
    ["darkmagenta_2"]=91
    ["darkviolet"]=92
    ["purple"]=93
    ["orange4_2"]=94
    ["lightpink4"]=95
    ["plum4"]=96
    ["mediumpurple3"]=97
    ["mediumpurple3_2"]=98
    ["slateblue1"]=99
    ["yellow4"]=100
    ["wheat4"]=101
    ["grey53"]=102
    ["lightslategrey"]=103
    ["mediumpurple"]=104
    ["lightslateblue"]=105
    ["yellow4_2"]=106
    ["darkolivegreen3"]=107
    ["darkseagreen"]=108
    ["lightskyblue3"]=109
    ["lightskyblue3_2"]=110
    ["skyblue2"]=111
    ["chartreuse2_2"]=112
    ["darkolivegreen3_2"]=113
    ["palegreen3_2"]=114
    ["darkseagreen3"]=115
    ["darkslategray3"]=116
    ["skyblue1"]=117
    ["chartreuse1"]=118
    ["lightgreen_2"]=119
    ["lightgreen_3"]=120
    ["palegreen1"]=121
    ["aquamarine1_2"]=122
    ["darkslategray1"]=123
    ["red3"]=124
    ["deeppink4_3"]=125
    ["mediumvioletred"]=126
    ["magenta3"]=127
    ["darkviolet_2"]=128
    ["purple_2"]=129
    ["darkorange3"]=130
    ["indianred"]=131
    ["hotpink3"]=132
    ["mediumorchid3"]=133
    ["mediumorchid"]=134
    ["mediumpurple2"]=135
    ["darkgoldenrod"]=136
    ["lightsalmon3"]=137
    ["rosybrown"]=138
    ["grey63"]=139
    ["mediumpurple2_2"]=140
    ["mediumpurple1"]=141
    ["gold3"]=142
    ["darkkhaki"]=143
    ["navajowhite3"]=144
    ["grey69"]=145
    ["lightsteelblue3"]=146
    ["lightsteelblue"]=147
    ["yellow3"]=148
    ["darkolivegreen3_3"]=149
    ["darkseagreen3_2"]=150
    ["darkseagreen2"]=151
    ["lightcyan3"]=152
    ["lightskyblue1"]=153
    ["greenyellow"]=154
    ["darkolivegreen2"]=155
    ["palegreen1_2"]=156
    ["darkseagreen2_2"]=157
    ["darkseagreen1"]=158
    ["paleturquoise1"]=159
    ["red3_2"]=160
    ["deeppink3"]=161
    ["deeppink3_2"]=162
    ["magenta3_2"]=163
    ["magenta3_3"]=164
    ["magenta2"]=165
    ["darkorange3_2"]=166
    ["indianred_2"]=167
    ["hotpink3_2"]=168
    ["hotpink2"]=169
    ["orchid"]=170
    ["mediumorchid1"]=171
    ["orange3"]=172
    ["lightsalmon3_2"]=173
    ["lightpink3"]=174
    ["pink3"]=175
    ["plum3"]=176
    ["violet"]=177
    ["gold3_2"]=178
    ["lightgoldenrod3"]=179
    ["tan"]=180
    ["mistyrose3"]=181
    ["thistle3"]=182
    ["plum2"]=183
    ["yellow3_2"]=184
    ["khaki3"]=185
    ["lightgoldenrod2"]=186
    ["lightyellow3"]=187
    ["grey84"]=188
    ["lightsteelblue1"]=189
    ["yellow2"]=190
    ["darkolivegreen1"]=191
    ["darkolivegreen1_2"]=192
    ["darkseagreen1_2"]=193
    ["honeydew2"]=194
    ["lightcyan1"]=195
    ["red1"]=196
    ["deeppink2"]=197
    ["deeppink1"]=198
    ["deeppink1_2"]=199
    ["magenta2_2"]=200
    ["magenta1"]=201
    ["orangered1"]=202
    ["indianred1"]=203
    ["indianred1_2"]=204
    ["hotpink"]=205
    ["hotpink_2"]=206
    ["mediumorchid1_2"]=207
    ["darkorange"]=208
    ["salmon1"]=209
    ["lightcoral"]=210
    ["palevioletred1"]=211
    ["orchid2"]=212
    ["orchid1"]=213
    ["orange1"]=214
    ["sandybrown"]=215
    ["lightsalmon1"]=216
    ["lightpink1"]=217
    ["pink1"]=218
    ["plum1"]=219
    ["gold1"]=220
    ["lightgoldenrod2_2"]=221
    ["lightgoldenrod2_3"]=222
    ["navajowhite1"]=223
    ["mistyrose1"]=224
    ["thistle1"]=225
    ["yellow1"]=226
    ["lightgoldenrod1"]=227
    ["khaki1"]=228
    ["wheat1"]=229
    ["cornsilk1"]=230
    ["grey100"]=231
    ["grey3"]=232
    ["grey7"]=233
    ["grey11"]=234
    ["grey15"]=235
    ["grey19"]=236
    ["grey23"]=237
    ["grey27"]=238
    ["grey30"]=239
    ["grey35"]=240
    ["grey39"]=241
    ["grey42"]=242
    ["grey46"]=243
    ["grey50"]=244
    ["grey54"]=245
    ["grey58"]=246
    ["grey62"]=247
    ["grey66"]=248
    ["grey70"]=249
    ["grey74"]=250
    ["grey78"]=251
    ["grey82"]=252
    ["grey85"]=253
    ["grey89"]=254
    ["grey93"]=255
  )

  __stdlib_color_type_xterm_load_list() {
    :
  }
}
