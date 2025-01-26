function sayresult
    announce $argv
    set -l cmd_status $status

    if not command -q say
        return $cmd_status
    end

    if test $cmd_status -eq 0
        say "Command succeeded"
    else
        say "Command failed"
    end

    return $cmd_status
end
