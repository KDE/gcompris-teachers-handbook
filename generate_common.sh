function get_doc_dir {
requested_module=$1

while read line; do
    if [ -z "$line" ]; then
        continue
    fi

    if [[ $line = \#* ]]; then
        continue
    fi

    IFS=' ' read -ra tokens <<< $line
    ntokens=${#tokens[@]}
    if [ $ntokens -lt 2 ]; then
        echo "The number of tokens is not valid - $line"
    else
        if [ "${tokens[0]}" = "entry" ]; then
            if [ $ntokens -lt 3 ] || [ $ntokens -gt 4 ]; then
                echo "The number of tokens (${ntokens}) is not valid - ${line}"
            else
                doc_dir=""
                if [ $ntokens -eq 4 ]; then
                    doc_dir="${tokens[3]}"
                fi
                entry_dir="${tokens[1]}"

                module_name="${tokens[2]}"
                if [ "${requested_module}" != "${module_name}" ]; then
                    # if a specific module is requested, only update it
                    continue
                fi
                echo $doc_dir
                return
            fi
        fi
    fi
done < documentation_paths.${transmod}
}
