# claude-notifier

A meme-sound notifier for [Claude Code](https://www.anthropic.com/claude-code). Plays a different sound on **9 different hook events** so you always know what the agent is doing — when it starts your turn, when it finishes, when it needs your attention, when a subagent completes, and when a `git push` actually happens.

Cross-platform: **macOS** (`afplay`), **Linux** (`paplay` / `aplay`), **Windows** (PowerShell via Git Bash).

---

## Sound map

| Event | Sound | Fires when |
|---|---|---|
| `UserPromptSubmit` | Vine boom | You hit Enter on a message |
| `Stop` | Rizz sound effect | Claude finishes its reply |
| `Notification` | Among Us role reveal | Permission prompt / idle-waiting |
| `SessionStart` | Spiderman meme song | You open Claude Code |
| `SessionEnd` | Tuco "get out" | You close the session |
| `SubagentStop` | Dexter meme | A subagent (Task/Agent tool) finishes |
| `PreCompact` | Cat laugh | Context is about to be compacted |
| `PreToolUse` (Edit / Write / MultiEdit) | Anime wow | Before any file edit |
| `PostToolUse` (Bash with `git push`) | Auraa | When you push to GitHub — the moment |

`faaah.mp3` also ships in `assets/` if you want to swap Rizz back to the original gag.

---

## Install

From inside Claude Code:

```
/plugin marketplace add Moustafa-abdelsattar/claude-notifier
/plugin install claude-notifier@claude-notifier
/reload-plugins
```

That's it. 10 mp3s + 3 scripts get pulled from this repo, hooks register automatically.

---

## Customize

### Swap a single sound
Drop a new `.mp3` or `.wav` file into `assets/` with the same filename (e.g. replace `submit.mp3` with your own). Run `/reload-plugins`.

### Change the event mapping
Edit `hooks/hooks.json`. Each event block points to a filename in `assets/` — change the filename to remap.

### Re-download everything from myinstants
```bash
bash scripts/setup.sh           # download any missing sounds
bash scripts/setup.sh --force   # overwrite existing sounds (refresh)
bash scripts/setup.sh submit.mp3   # only download one by target filename
```

The manifest at the top of `setup.sh` maps `target-filename.mp3 → myinstants-page-slug`. Edit it and re-run if you want a totally different soundboard.

### Remove an event you don't want
Delete that event's block from `hooks/hooks.json` and `/reload-plugins`. The `.mp3` file can stay (unused but harmless).

---

## How playback works

`hooks/hooks.json` runs `scripts/play-sound.sh <filename>` on each event. That script picks the right playback tool for your OS:

- **macOS** → `afplay <file> &`
- **Linux** → `paplay <file> &` (falls back to `aplay`)
- **Windows (Git Bash / MSYS / Cygwin)** → shells out to `scripts/play-sound.ps1`, which uses `System.Media.SoundPlayer` for `.wav` and `System.Windows.Media.MediaPlayer` for `.mp3`. Runs with `-WindowStyle Hidden` so no terminal flashes on every hook fire.

The `git push` detection is a second script, `play-on-git-push.sh`, registered on `PostToolUse` with a `Bash` matcher. It reads the tool-call JSON from stdin and only plays the Auraa sound if the executed command matched `git push`.

---

## Windows prerequisites

- **Git Bash** (bundled with Git for Windows). This is how Claude Code runs hook `command` entries prefixed with `bash`.
- **PowerShell** (built in). Used by the Windows leg of the playback script.

No extra packages, no audio libraries — `System.Media.SoundPlayer` and `System.Windows.Media.MediaPlayer` are both in the standard .NET runtime shipped with Windows.

---

## Heads-up on hook frequency

Some of these hooks fire **a lot** in a typical Claude Code session:

- `PreToolUse (Edit|Write|MultiEdit)` — every time Claude edits a file. In a heavy coding turn that's 5–15 Anime-wows in a row. Delete this hook if it gets old.
- `UserPromptSubmit` + `Stop` — every single turn. Vine boom + Rizz, twice per exchange. Also deletable.

If a sound starts to grate, just remove that hook block from `hooks/hooks.json`. The rest keep working.

---

## File layout

```
.
├── .claude-plugin/
│   ├── plugin.json          # plugin manifest
│   └── marketplace.json     # marketplace descriptor
├── hooks/
│   └── hooks.json           # event → script wiring
├── scripts/
│   ├── play-sound.sh        # cross-platform playback dispatcher
│   ├── play-sound.ps1       # Windows playback (WAV + MP3)
│   ├── play-on-git-push.sh  # Bash PostToolUse filter for git push
│   └── setup.sh             # (re-)download sounds from myinstants
├── assets/
│   └── *.mp3                # 10 committed sound files
├── LICENSE
└── README.md
```

---

## Credits

- **Original FAAAH concept + sample:** [StanMarek/claude-faaah-plugin](https://github.com/StanMarek/claude-faaah-plugin) (MIT)
- **Meme sounds:** [myinstants.com](https://www.myinstants.com/) — short clips used for personal/non-commercial use. If you're the rights holder of any clip here and want it removed, open an issue.

## License

MIT for the code (see `LICENSE`). The bundled `.mp3` files are third-party meme clips and are **not** covered by the MIT license — they're included for personal use.
