# dotfiles

PowerShell + oh-my-posh setup, shared by PowerShell 7 and Windows PowerShell 5.1.

| Path | What |
|---|---|
| `powershell/profile.ps1` | The one real profile. Loads Terminal-Icons, PSReadLine, oh-my-posh |
| `powershell/jandedobbeleer.omp.json` | oh-my-posh theme, loaded from next to the profile (`$PSScriptRoot`) |
| `windows-terminal/settings.json` | Windows Terminal (font: CaskaydiaCove Nerd Font) |
| `cursor/settings.json` | Cursor user settings (terminal font set here) |
| `install.ps1` | Sets up a machine |

## New machine

```powershell
git clone https://github.com/sidsanc/dotfiles $HOME\dotfiles
& $HOME\dotfiles\install.ps1                    # profile + prerequisites only
& $HOME\dotfiles\install.ps1 -WithAppSettings   # also Windows Terminal + Cursor settings
```

Open a new terminal afterwards. `install.ps1` backs up any file it replaces (`*.bak`).

## Editing

Change files in this repo, not the copies under Documents. The real profiles are
one-line stubs that dot-source `powershell/profile.ps1`. Commit and push, then
`git pull` on the other machine.

`windows-terminal/settings.json` and `cursor/settings.json` are copies, not links:
edits made in the apps are not picked up automatically. Copy them back here to save changes.

## Machine-specific bits

`cursor/settings.json` contains `python.defaultInterpreterPath` (this PC's path) and a
`terminal.integrated.env.windows` PATH entry. Adjust them on a machine where they differ.
