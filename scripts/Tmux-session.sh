tmux switch-client -t "$(
  tmux list-sessions -F '#S' |
    fzf --preview 'tmux capture-pane -pt {} -S -50'
)"

# tmux switch-client -t $(tmux list-session -F '#S' | fzf)
