function fish_job_summary -a job_id is_foreground cmd_line signal_or_end_name signal_desc proc_pid proc_name
    if test "$signal_or_end_name" = SIGINT; and test $is_foreground -eq 1
        return
    end

    set -l max_cmd_len 32
    set cmd_line (string shorten -m$max_cmd_len -- $cmd_line)

    set -l message
    switch $signal_or_end_name
        # case STOPPED
        #     set message (printf ( _ "fish: Job %s, '%s' has stopped\n" ) $job_id $cmd_line)
        case ENDED
            set message (printf ( _ "fish: Job %s, '%s' has ended\n" ) $job_id $cmd_line)
        case 'SIG*'
            if test -n "$proc_pid"
                set message (printf ( _ "fish: Process %s, '%s' from job %s, '%s' terminated by signal %s (%s)\n" ) \
                    $proc_pid $proc_name $job_id $cmd_line $signal_or_end_name $signal_desc)
            else
                set message (printf ( _ "fish: Job %s, '%s' terminated by signal %s (%s)\n" ) \
                    $job_id $cmd_line $signal_or_end_name $signal_desc)
            end
    end

    if test $is_foreground -eq 0; and test $signal_or_end_name != STOPPED
        __fish_echo string join \n -- $message
    else
        string join >&2 \n -- $message
    end
end
