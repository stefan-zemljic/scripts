# Don't overwrite the history file, append instead
shopt -s histappend

# Save each command as soon as it is executed
PROMPT_COMMAND='history -a'

# When a new shell starts, load history from file
history -r

# History size
HISTSIZE=10000
HISTFILESIZE=20000

# History control: ignore duplicates and erase older duplicates
HISTCONTROL=ignoredups:erasedups