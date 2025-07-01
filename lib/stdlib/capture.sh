#!/usr/bin/env sh

_CTRL_Z_=$'\cZ'

capture() {
    {
        IFS=$'\n'"${_CTRL_Z_}" read -r -d "${_CTRL_Z_}" "${1}";
        IFS=$'\n'"${_CTRL_Z_}" read -r -d "${_CTRL_Z_}" "${2}";
        (IFS=$'\n'"${_CTRL_Z_}" read -r -d "${_CTRL_Z_}" _ERRNO_; return ${_ERRNO_});
    } <<EOF
$((printf "${_CTRL_Z_}%s${_CTRL_Z_}%d${_CTRL_Z_}" "$(((({ ${3}; echo "${?}" 1>&3-; } | cut -z -d"${_CTRL_Z_}" -f1 | tr -d '\0' 1>&4-) 4>&2- 2>&1- | cut -z -d"${_CTRL_Z_}" -f1 | tr -d '\0' 1>&4-) 3>&1- | exit "$(cat)") 4>&1-)" "${?}" 1>&2) 2>&1)
EOF
}
