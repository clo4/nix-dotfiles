function trash
    set -l rm_rf_targets
    set -l trash_targets

    for target in $argv
        set name (path basename -- $target)
        # Well, this is horrifying. Fish doesn't really have sane grouping,
        # so we need this utterly deranged nested if statement with two grouped
        # conditions in `begin; ...; end` blocks.
        # The idea is that all symlinks should be rm'd, and any files/dirs
        # in their respective kill-lists.
        if path is -l -- $target
            or begin
                path is -f -- $target
                and contains -- $name $skip_trash_files
            end
            or begin
                path is -d -- $target
                and begin
                    contains -- $name $skip_trash_directories
                    or test (count (command ls -A $target)) -eq 0
                end
            end
            or begin
                path is -x -- $target
                and test (head -c 2 $target) != "#!"
            end
            set -a rm_rf_targets $target
        else
            set -a trash_targets $target
        end
    end

    set total_rm (count $rm_rf_targets)
    if test "$total_rm" -gt 0
        echo "Permanently deleting $total_rm item(s)"
        command rm -rf $rm_rf_targets
    end

    set total_trash (count $trash_targets)
    if test "$total_trash" -gt 0
        echo "Trashing $total_trash item(s)"
        command trash $trash_targets
    end
end
