#!/bin/bash
# source /user/local/lib/functions/fn.ghdl_latest_release.sh
ghdl_latest_release(){
    local repo=""; local user="";
    local filename=""
    local method="legacy"; which jq &>/dev/null && method="jq"
    local variant="0"
    local readfile=""
    local download=false
    local outfile=""
    local outdir=""; outdir="$(realpath "$(pwd)")"
    local chmod=777
    local chown=""
    local output="url"
    local curl_flags=( "-L" "-s")
    local curl_dl_flags=("--progress-bar")
    local curl_flags_loop=("${curl_flags[@]}")
    local curl_auth_flags=()
    local wget_flags=("--quiet" "--tries=1" "--random-wait" "--no-cache" "--no-http-keep-alive" "--no-cookies" "--no-check-certificate" "--show-progress" )
    local wget_flags_loop=("${wget_flags[@]}")

    local auth_token=""
    while [ "$#" != "0" ] && [ "${1:0:1}" == "-" ]; do
        [ "$1" == '-at' ] || [ "$1" == '--auth-token' ] && {
            auth_token="${2}" && shift && shift;
            curl_auth_flags=( "--request" "GET" "--header" "Authorization: Bearer ${auth_token}" )
            wget_auth_flags=( "--header" "Authorization: Bearer ${auth_token}" )

        }
        [ "$1" == '-rd' ] || [ "$1" == '--readfile' ] && readfile="${2}" && shift && shift;
        [ "$1" == '-rf' ] || [ "$1" == '--release-filename' ] && filename="${2}" && shift && shift;
        [ "$1" == '-r' ] || [ "$1" == '--repo' ] && repo="${2}" && shift && shift;
        [ "$1" == '-u' ] || [ "$1" == '--user' ] && user="${2}" && shift && shift;
        [ "$1" == '-dl' ] || [ "$1" == '--download' ] && download=true && shift;
        [ "$1" == '-of' ] || [ "$1" == '--output-file' ] && outfile="${2}" && shift && shift;
        [ "$1" == '-o' ] || [ "$1" == '--output' ] && {
            [ "${2}" == "cmd_curl" ] || [ "${2}" == "cmd_wget" ] || [ "${2}" == "url" ] && output="$2"
            shift && shift;
        }
        [ "$1" == '--chmod' ] && chmod="${2}" && shift && shift;
        [ "$1" == '--chown' ] && chown="${2}" && shift && shift;
        [ "$1" == '-m' ] || [ "$1" == '--method' ] && {
            if  [ "${2}" == "legacy" ]; then 
                method="${2}"
                variant="0"
                shift; shift; continue
            elif which jq &>/dev/null; then
                if      [ "${2}" == "jq" ];     then method="jq" && variant="0" && shift && shift && continue;
                elif    [ "${2}" == "jq:0" ];   then method="jq" && variant="0" && shift && shift && continue; 
                elif    [ "${2}" == "jq:1" ];   then method="jq" && variant="1" && shift && shift && continue; 
                elif    [ "${2}" == "jq:2" ];   then method="jq" && variant="2" && shift && shift && continue; 
#                elif    [ "${2}" == "jq:3" ];   then method="jq" && variant="3" && shift && shift && continue;
                fi
            fi
            shift && shift;
        }
    done
    
    
    
    if [ "$repo" == "" ] && [ "$#" != "0" ]; then repo="$1"; shift; fi
    local repo_l="${repo}"; 
    
    if [ "$user" != "" ]; then repo_l="${user%/}/${repo_l%/}"; fi
    local url="https://api.github.com/repos/${repo_l%/}/releases/latest"
    
    local dl_urls=()
  
    [ "$download" == true  ] && [ "${output}" != "cmd_curl" ] && [ "${output}" != "cmd_wget" ] && output="cmd_curl"
    
    if [ "$method" == "jq" ] && [ "$variant" == "0" ]; then
        local filename_jq_select=""
        [ "$filename" != "" ] && filename_jq_select="select(.filename==\"${filename}\")"
        while read -r dl_url; do [ "$dl_url" != "" ] && dl_urls+=("$dl_url"); done < <( \
            { [ "$readfile" != "" ] && cat "$readfile" || curl "${curl_flags[@]}" "${curl_auth_flags[@]}" --url "${url}" 2>/dev/null; } \
            | jq -rc '.assets[] | { "filename": .name, "url": .browser_download_url }' \
            | ( [ "$filename" != "" ] && cat - | jq "${filename_jq_select}" || cat -) \
            | jq -r '.url' \
        )
    elif [ "$method" == "jq" ] && [ "$variant" == "1" ]; then
        while read -r dl_url; do [ "$dl_url" != "" ] && dl_urls+=("$dl_url"); done < <( \
            { [ "$readfile" != "" ] && cat "$readfile" || curl "${curl_flags[@]}" "${curl_auth_flags[@]}" --url "${url}" 2>/dev/null; } \
            | jq -rc '.assets[] | { "filename": .name, "url": .browser_download_url }' \
            | jq -rc '.filename + ":" + .url' \
            | grep -E "^${filename}:" \
            | cut -d ':' -f2-99 \
        )
    elif [ "$method" == "jq" ] && [ "$variant" == "2" ]; then
        while read -r dl_url; do [ "$dl_url" != "" ] && dl_urls+=("$dl_url"); done < <( \
            { [ "$readfile" != "" ] && cat "$readfile" || curl "${curl_flags[@]}" "${curl_auth_flags[@]}" --url "${url}" 2>/dev/null; } \
            | jq -rc '.assets[] | .name + ":" + .browser_download_url' \
            | grep -E "^${filename}:" \
            | cut -d ':' -f2-99 \
        )
    else
        while read -r dl_url; do [ "$dl_url" != "" ] && dl_urls+=("$dl_url"); done < <( \
            { [ "$readfile" != "" ] && cat "$readfile" || curl "${curl_flags[@]}" "${curl_auth_flags[@]}" --url "${url}" 2>/dev/null; } \
            | grep "browser_download_url.*/${filename}\"" 2>/dev/null \
            | cut -d ':' -f 2,3 2>/dev/null \
            | tr -d '"' 2>/dev/null \
            | sed 's/^[ \t]*//;s/[ \t]*$//' 2>/dev/null \
        )
    fi
    local ret=false;
    

    [ "${#dl_urls[@]}" != "0" ] && for dl_url in "${dl_urls[@]}"; do
        curl_flags_loop=("${curl_flags[@]}")
        wget_flags_loop=("${wget_flags[@]}")
    
        dl_filename="$(basename "$dl_url")"
        if [ "$outfile" == "" ]; then
            outdir="$(pwd)"
            outfile="${outdir%/}/${dl_filename}"
        elif [ -d "$outfile" ]; then
            outdir="$(realpath "$outfile")"
            outfile="${outdir%/}/${dl_filename}"
        else
            outfile="$(realpath "$outfile")"
            outdir="$(dirname "$outfile")"
        fi
        
        
        if [ "$download" == true ]; then
            [ ! -d "$outdir" ] && mkdir -p "${outdir%/}"
            if [ -d "$outdir" ]; then
                [ "$chmod" != "" ] && chmod ${chmod} "${outdir%/}"
                [ "$chown" != "" ] && chown ${chown} "${outdir%/}"
            fi
        fi

        ## FLAGS: CURL
        curl_flags_loop=( \
            "${curl_flags[@]}" \
            "${curl_dl_flags[@]}" \
            "${curl_auth_flags[@]}" \
            "--url" "${dl_url}" \
        )
        [ "$outfile" != "" ] &&  curl_flags_loop+=("-o" "${outfile}")

        ## FLAGS: WGET
        wget_flags_loop=("${wget_auth_flags[@]}")
        [ "$outfile" != "" ] && wget_flags_loop+=("-O" "${outfile}")
        wget_flags_loop+=("${wget_flags[@]}" "${dl_url}" )
        
        ret=1
        if [ "${output}" == "cmd_curl" ] && [ "$download" == true ]; then
            
            curl "${curl_flags_loop[@]}" && sleep 1s && [ -f "${outfile}" ] && {
                ret=0 
                [ "$chmod" != "" ] && chmod ${chmod} "${outfile}"
                [ "$chown" != "" ] && chown ${chown} "${outfile}"
            }                
            [ "$ret" == "1" ] && {
                echo "# [ERROR] Could not download file with wget"
                echo "# - CMD  : curl ${curl_flags_loop[@]}"
                echo "# - From : ${dl_url}"
                echo "# - To   : ${outfile}"
            }         
        elif [ "${output}" == "cmd_curl" ] && [ "$download" != true ]; then
            echo -n "curl"
            for flag in "${curl_flags_loop[@]}"; do
                [ "${flag:0:1}" == "-" ] \
                && echo -n " $flag" \
                || echo -n " \"${flag}\""
            done    
            [ "$chmod" != "" ] && echo -n " && chmod ${chmod} \"${outfile}\""
            [ "$chown" != "" ] && echo -n " && chown ${chown} \"${outfile}\""
            ret=0; echo ""
        elif [ "${output}" == "cmd_wget" ] && [ "$download" == true ]; then            
            wget "${wget_flags_loop[@]}" && sleep 1s && [ -f "${outfile}" ] && {
                ret=0 
                [ "$chmod" != "" ] && chmod ${chmod} "${outfile}"
                [ "$chown" != "" ] && chown ${chown} "${outfile}"
            }
            [ "$ret" == "1" ] && {
                echo "# [ERROR] Could not download file with wget"
                echo "# - CMD  : wget ${wget_flags_loop[@]}"
                echo "# - From : ${dl_url}"
                echo "# - To   : ${outfile}"
            }
        elif [ "${output}" == "cmd_wget" ] && [ "$download" == false ]; then
            echo -n "wget"
            for flag in "${wget_flags_loop[@]}"; do
                [ "${flag:0:1}" == "-" ] \
                && echo -n " $flag" \
                || echo -n " \"${flag}\""
            done    
            [ "$chmod" != "" ] && echo -n " && chmod ${chmod} \"${outfile}\""
            [ "$chown" != "" ] && echo -n " && chown ${chown} \"${outfile}\""
             ret=0; echo ""
#        elif [ "${output}" == "url" ]; then echo "$dl_url" && ret=0; 
        else echo "$dl_url" && ret=0; 
        fi
    done
    [ "$ret" == false ] && return 1 || return ${ret}

}

ghdl_latest_release_demo(){
  # Usage: 
  # Create yout own private token on Github (https://github.com/settings/tokens) to prevent api quota errors
  # Call Demo Function "ghdl_latest_release_demo" to see if everything works
  # All arguments of the demo function are appended to the main function call
  # For example to set your Github Token for the demo you can run it like this
  # ghdl_latest_release_demo --auth-token "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  # 
  
  repo="mikefarah/yq"
  release_filename="yq_linux_amd64"
  output_file="/tmp/ghdl_latest_release/bin/yq";
  
  methods=( "legacy" "jq" "jq:0" "jq:1" "jq:1" )
  outputs=( "cmd_curl" "cmd_wget" "url" )
  
  for method in "${methods[@]}"; do
    for output in "${outputs[@]}"; do
      echo "##############################################################"
      echo "# ghdl_latest_release \\"
      ghdl_flags=( \
        --repo "${repo}" \
        --release-filename "${release_filename}" \
        --method "${method}" \
        --output "${output}" \
        --output-file "${output_file}" \
        "${@}" \
      )
      [  "${auth_token}" !="" ] && ghdl_flags+=("--auth-token" "${auth_token}")
      for ghdl_flag in "${ghdl_flags[@]}"; do 
        [ "${ghdl_flag:0:1}" == "-" ] && echo -n '\\' && echo "# " && echo -n $'\t'
        echo -n "${ghdl_flag}"
      done
      echo "# -----------------------------------------------------------"; 
      ghdl_latest_release "${ghdl_flags[@]}"
      echo "##############################################################"
      echo "";
    done
  done
}
