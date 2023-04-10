#!/usr/bin/env bash

main() {
    local -A dict
    dict['default_java']='/usr/lib/jvm/default-java'
    if [[ -d "${dict['default_java']}" ]]
    then
        koopa_linux_java_update_alternatives "${dict['default_java']}"
    fi
    return 0
}
