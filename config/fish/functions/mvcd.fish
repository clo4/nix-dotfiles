function mvcd
    set cwd $PWD
    set newcwd $argv[1]
    cd ..
    mv $cwd $newcwd
    cd $newcwd
    pwd
end
