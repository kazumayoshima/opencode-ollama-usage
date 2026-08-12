# opencode-ollama-usage

Barra superior fija en **tmux** con el uso de **Ollama Cloud** para opencode:

```
0:tmux*  Ollama Pro - Model most used this week  deepseek-v4-flash:0731 · 2131 req   ⏱ 0:05
         Ｓｅｓｓｉｏｎ  Ｕｓａｇｅ  ███▊░░░░░░░░░░░░░░░░░░░░░░░░░░░░  10.6%  resets in 02:02:12
         ──────────────────────────────────────────────────────────────────────────
         Ｗｅｅｋｌｙ  Ｕｓａｇｅ   █████▋░░░░░░░░░░░░░░░░░░░░░░░░░░░  14.1%  resets in 10:04:08
         ──────────────────────────────────────────────────────────────────────────
```

- Uso de sesión y semanal (barras + % + reset en `HH:MM:SS`)
- Modelo más usado de la semana y tiempo de sesión
- La API key se lee en runtime de opencode (`~/.local/share/opencode/auth.json`), nunca se guarda ni imprime

## Requisitos

`tmux` ≥ 3.0, `opencode` con Ollama Cloud logueado, y `curl`, `awk`, `grep`, `sed`, `date`, `stat`.

## Instalación

```bash
cd ~/opencode-ollama-usage
./install.sh
```

## Uso

```bash
opencode-tmux
```

Reabrir `opencode-tmux` vuelve a adjuntarse a la sesión. Para aplicar cambios: `tmux kill-session -t opencode`.

## Desinstalar

```bash
rm -f ~/.local/bin/opencode-tmux ~/.local/bin/ollama-usage ~/.local/bin/opencode-ruler ~/.local/bin/opencode-session-time
```
