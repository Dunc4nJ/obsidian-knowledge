---
created: 2026-03-31
description: A tmux workflow where each project gets an auto-named session based on the current directory, with shell helpers (tm, tp, tv) and vim-style keybindings for zero-friction session management.
source: https://x.com/fcoury/status/2038693821543014506
type: learning
---

## Key Takeaways

The core insight is that **the directory name IS the session name** — no mental overhead deciding what to call things. This maps cleanly to how [[CLIs are the agent-native interface because legacy tooling is already machine-readable|agent workflows already organize around project directories]], and a one-session-per-project discipline keeps context boundaries clean. The `tm` function is ~10 lines of shell that handles both attach-if-exists and create-if-not, which is the same idempotent pattern we use in [[ntm]] for agent session management.

The `tp` fuzzy picker using fzf with attached-sessions-first sorting is a nice touch — it means the most relevant sessions bubble up naturally. The keybinding philosophy of remapping prefix to Ctrl-s and using vim-style h/j/k/l for pane navigation reduces context-switching cost, similar to how [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|agent-first engineering]] optimizes the environment rather than the task itself.

The Alt-k trick that detects whether a program is running (by checking ps for non-shell processes) before deciding between clear-scrollback vs Ctrl-l is genuinely clever — it solves a common annoyance where clearing the screen blows away a running program's output. The git worktree integration (`tw`/`twd`) that pairs worktrees with tmux sessions is a natural extension — each branch gets its own isolated workspace.

The remote session management via SSH with emoji-prefixed terminal titles (local vs remote) is a simple but effective way to maintain spatial awareness across machines. Combined with tmux-resurrect and tmux-continuum for persistence, this creates a nearly stateless developer experience where you can reboot and get back to exactly where you were.

## External Resources

- [Felipe Coury's config repo](https://github.com/fcoury/config) — full dotfiles including tmux and fish configs
- [Fish tmux functions](https://github.com/fcoury/config/blob/master/fish/conf.d/tmux.fish) — the shell helpers (tm, tp, tv, tn, zm)
- [.tmux.conf](https://github.com/fcoury/config/blob/master/.tmux.conf) — keybindings and plugin config

## Original Content

> @fcoury (Felipe Coury) — 2026-03-30
>
> **My tmux workflow: one session per project, zero friction**
>
> I use tmux every day. Over time I've built a small set of shell helpers and keybindings that make session management nearly frictionless — locally and on remote machines. Here's the full setup. All configs linked at the end.
>
> **THE CORE IDEA**
>
> Every project gets its own tmux session named after the directory. cd code/myapp, then type tm, and you're in a session called myapp. Dots become underscores (my.project → my_project) so tmux doesn't choke.
>
> You never think about session names — the directory IS the name.
>
> **THE SHELL HELPERS**
>
> I have 5 commands. They all follow the same pattern: attach if the session exists, create it if it doesn't.
>
> - tm — attach/create session for current directory
> - tp — fuzzy-pick a session with fzf
> - tv — like tm but starts neovim
> - tn — create a session with an explicit name
> - zm — same as tm but for zellij
>
> **tm: THE WORKHORSE**
>
> The one I use 50 times a day. Sets the terminal title with an emoji so I can spot it in my tab bar.
>
> Fish:
>
> ```
> function tm
>     set session_name (basename (pwd) | string replace '.' '_')
>     printf '\033]0;💻 %s\007' "$session_name"
>     if tmux has-session -t "$session_name"
>         tmux attach-session -t "$session_name"
>     else
>         tmux new-session -s "$session_name"
>     end
> end
> ```
>
> Bash/Zsh:
>
> ```
> tm() {
>   local session_name
>   session_name=$(basename "$PWD" | tr '.' '_')
>   printf '\033]0;💻 %s\007' "$session_name"
>   if tmux has-session -t "$session_name" 2>/dev/null; then
>     tmux attach-session -t "$session_name"
>   else
>     tmux new-session -s "$session_name"
>   fi
> }
> ```
>
> **tp: THE SESSION PICKER**
>
> No args: pops up fzf with all running sessions, sorted with attached sessions first. Pick one and you're in. Escape falls back to a cwd session.
>
> With args (tp work): attaches to or creates the work session.
>
> No sessions at all: creates one for the current directory.
>
> Fish:
>
> ```
> function tp
>     if not command -q tmux
>         echo "tmux is not installed"
>         return 1
>     end
>
>     if test (tmux list-sessions 2>/dev/null | wc -l) -eq 0
>         set session_name (basename (pwd) | string replace '.' '_')
>         printf '\033]0;💻 %s\007' "$session_name"
>         tmux new-session -s "$session_name"
>         return
>     end
>
>     if test (count $argv) -eq 0
>         set selected_session (tmux list-sessions -F "#{session_attached} #{session_name}#{?session_attached, (attached),}" | sort -rn | string replace -r '^\d+ ' '' | fzf --height 40% --reverse | string replace -r ' \(attached\)$' '')
>
>         if test -n "$selected_session"
>             printf '\033]0;💻 %s\007' "$selected_session"
>             tmux attach-session -t "$selected_session"
>         else
>             set session_name (basename (pwd) | string replace '.' '_')
>             printf '\033]0;💻 %s\007' "$session_name"
>             if tmux has-session -t "$session_name" 2>/dev/null
>                 tmux attach-session -t "$session_name"
>             else
>                 tmux new-session -s "$session_name"
>             end
>         end
>     else
>         set session_name $argv[1]
>         printf '\033]0;💻 %s\007' "$session_name"
>         if tmux has-session -t "$session_name" 2>/dev/null
>             tmux attach-session -t "$session_name"
>         else
>             tmux new-session -s "$session_name"
>         end
>     end
> end
> ```
>
> **tv: NEOVIM MODE**
>
> Same as tm, but the session starts with neovim. Pass a filename to open it directly: tv src/main.rs.
>
> Fish:
>
> ```
> function tv
>     set session_name (basename (pwd) | string replace '.' '_')
>
>     if test (count $argv) -gt 0
>         set file_to_edit $argv[1]
>     else
>         set file_to_edit ""
>     end
>
>     if tmux has-session -t "$session_name"
>         tmux attach-session -t "$session_name"
>     else
>         if test -n "$file_to_edit"
>             tmux new-session -s "$session_name" "nvim $file_to_edit"
>         else
>             tmux new-session -s "$session_name" "nvim"
>         end
>     end
> end
> ```
>
> **KEY BINDINGS**
>
> I remapped prefix from Ctrl-b to Ctrl-s — easier to reach, and I never need to send Ctrl-s to anything. Prefix twice sends a literal Ctrl-s through.
>
> Everything else follows vim conventions:
>
> - prefix h/j/k/l — navigate panes
> - prefix H/J/K/L — resize panes (repeatable)
> - prefix d — split horizontal
> - prefix s — split vertical
> - prefix z — zoom/fullscreen a pane
> - prefix x — kill pane
> - prefix - — quick detach
> - prefix i — pull last pane into this window
> - prefix e — open scrollback in neovim
> - prefix o — fuzzy session switcher (sessionx)
> - prefix g — reload config
> - Alt-1..9 — switch to window by number
> - Alt-k — clear screen + scrollback (like Cmd-k)
>
> New splits open in the same directory. Seems obvious but isn't the default:
>
> ```
> bind d split-window -h -c "#{pane_current_path}"
> bind s split-window -v -c "#{pane_current_path}"
> ```
>
> **THE Alt-k TRICK**
>
> This one I'm particularly happy with.
>
> In a plain shell: clears screen AND scrollback (like Cmd-k in a native macOS terminal).
>
> If a program is running (neovim, dev server, etc.): sends Ctrl-l instead, so it doesn't blow away whatever the program is doing.
>
> It detects this by checking ps for processes that aren't shells:
>
> ```
> is_program="ps -o comm= -t '#{pane_tty}' | grep -vE '^-?(fish|bash|zsh|sh|ps|grep|awk|sed|cut|sort|uniq|head|cat|echo|printf)$' | grep -q ."
> bind -n M-k if-shell "$is_program" "send-keys C-l" "send-keys -R; clear-history"
> ```
>
> *Felipe's tmux setup in action*
> ![[fcoury-014506-001.jpg]]
>
> **REMOTE SESSIONS**
>
> I work on a remote Mac called m3pro (in my SSH config). The tms script does the same session management over SSH.
>
> - tms — fzf pick from remote sessions
> - tms deploy — attach/create deploy on the remote
>
> Terminal title gets a linkage prefix so I can tell remote vs local tabs at a glance.
>
> The script works in bash (no fish dependency on the remote) and falls back to a numbered menu if fzf isn't installed.
>
> **GIT WORKTREES**
>
> I use worktrees to keep multiple branches checked out simultaneously — one main, one for the current feature, one for a hotfix if needed.
>
> - tw \<name\> — create a worktree + tmux session for it
> - twd — delete the worktree and session together
>
> **PLUGINS**
>
> - tmux-resurrect — saves and restores sessions across reboots
> - tmux-continuum — auto-saves every 15 min
> - tmux-yank — clipboard integration (works with OSC 52 over SSH)
>
> **SETTINGS**
>
> - Prefix: Ctrl-a (closer than Ctrl-b)
> - Base index: 1 (windows and panes start at 1, not 0)
> - Automatic rename off — names come from the session scripts, not the current command
>
> Engagement: 557 likes | 56 retweets | 9 replies
> [Original post](https://x.com/fcoury/status/2038693821543014506)
