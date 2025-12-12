function ipythonize(){
    type ipython 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        alias python='ipython'
    fi
}
ipythonize
