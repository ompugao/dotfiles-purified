function run_edic() {
    # Prepend "info" to the command line and run it. 
    BUFFER="edic $BUFFER" 
    zle accept-line
} 
# Define a widget called "run_edic", mapped to our function above. 
zle -N run_edic 
# Bind it to ESC-e. 
bindkey "^[e" run_edic

function run_weblio() {
    # Prepend "info" to the command line and run it. 
    BUFFER="weblio $BUFFER" 
    zle accept-line
} 
# Define a widget called "run_weblio", mapped to our function above. 
zle -N run_weblio 
# Bind it to ESC-e. 
bindkey "^[w" run_weblio
