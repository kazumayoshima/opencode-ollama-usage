# opencode-ollama-usage

Fixed top bar in **tmux** showing **Ollama Cloud** usage for opencode:

```
0:tmux*  Ollama Pro - Model most used this week  deepseek-v4-flash:0731 · 2131 req   ⏱ 0:05
         Ｓｅｓｓｉｏｎ  Ｕｓａｇｅ  ███▊░░░░░░░░░░░░░░░░░░░░░░░░░░░░  10.6%  resets in 02:02:12
         ──────────────────────────────────────────────────────────────────────────
         Ｗｅｅｋｌｙ  Ｕｓａｇｅ   █████▋░░░░░░░░░░░░░░░░░░░░░░░░░░░  14.1%  resets in 10:04:08
         ──────────────────────────────────────────────────────────────────────────
```

- Session and weekly usage (bars + % + reset in `HH:MM:SS`)
- Most-used model of the week and session time
- The API key is read at runtime from opencode (`~/.local/share/opencode/auth.json`); it is never stored or printed

## Requirements

`tmux` ≥ 3.0, `opencode` logged in with Ollama Cloud, plus `curl`, `awk`, `grep`, `sed`, `date`, `stat`.

## Installation

```bash
cd ~/opencode-ollama-usage
./install.sh
```

## Usage

```bash
opencode-tmux
```

Re-running `opencode-tmux` re-attaches to the session. To apply changes: `tmux kill-session -t opencode`.

## Uninstall

```bash
rm -f ~/.local/bin/opencode-tmux ~/.local/bin/ollama-usage ~/.local/bin/opencode-ruler ~/.local/bin/opencode-session-time
```
