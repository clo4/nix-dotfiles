function pathify
    for p in $argv
        set --path $p $$p
    end
end
