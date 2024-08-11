#!/bin/bash



hcmnts() {
    # adds comments to bash history entries

    # the *S*hort version of hcmnt (which has many more features)

    # by Dennis Williamson
    # http://stackoverflow.com/questions/945288/saving-current-directory-to-bash-history
    # (thanks to Lajos Nagy for the idea)

    # INSTALLATION: source this file in your .bashrc

    # will not work if HISTTIMEFORMAT is used - use hcmntextra instead
    export HISTTIMEFORMAT=

    # HISTTIMEFORMAT still works in a subshell, however, since it gets unset automatically:

    #   $ htf="%Y-%m-%d %R "    # save it for re-use
    #   $ (HISTTIMEFORMAT=$htf; history 20)|grep 11:25

    local hcmnt
    local cwd
    local extra

    hcmnt=$(history 1)
    hcmnt="${hcmnt# *[0-9]*  }"

    if [[ ${hcmnt%% *} == "cd" ]]
    then
        cwd=$OLDPWD
    else
        cwd=$PWD
    fi

    extra=$(eval "$hcmntextra")

    hcmnt="${hcmnt% ### *}"
    hcmnt="$hcmnt ### ${extra:+$extra }$cwd"

    history -s "$hcmnt"
}

# set a default (must use -e option to include it)
export hcmntextra='date "+%Y%m%d %R"'      # you must be really careful to get the quoting right

# start using it
[ "$hcmnt_variant" == "lite" ] \
&& export PROMPT_COMMAND='hcmnts' \
|| export PROMPT_COMMAND='hcmnt'
