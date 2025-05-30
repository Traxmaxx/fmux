![logo with a fish in it](logo.png)
# fmux tmux-sessionizer

fmux is a tmux session manager entirely written in and for [fish](https://fishshell.com). It is heavily inspired by and somewhat compatible with [ThePrimeagen's tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer/tree/master) and [tm](https://brettterpstra.com/2019/12/17/tm-wrapper-for-tmux-redux-with-fish-tab-completion)

 These paths have not yet faced the trials of combat. Dragons await those who dare venture forward with reckless abandon.

## Installation

Using [Fisher](https://github.com/jorgebucaran/fisher):

```
fisher install Traxmaxx/fmux
```

## Usage

### fm - Find and manage tmux sessions

The `fmux_fm` command helps you find and manage tmux sessions:

```
fmux_fm [directory]
```

- When run without arguments, it displays a fuzzy finder with available directories from your configured search paths
- When provided with a directory path, it creates or attaches to a tmux session for that directory
- If already inside a tmux session, it will switch to the selected session
- If not in tmux, it will create a new session or attach to an existing one

### fmk - Kill tmux sessions

The `fmux_fmk` command allows you to kill tmux sessions:

```
fmux_fmk
```

- Shows a fuzzy finder with all current tmux sessions
- Select a session to kill it
- You can select multiple sessions to kill by using tab

### .tmux-sessionizer Support

fmux is compatible with `.tmux-sessionizer` project files. If your project directory contains a `.tmux-sessionizer` file, fmux will use its contents to:

- Set a custom session name
- Define a specific window/pane layout
- Run commands on session startup
- Configure project-specific settings

This provides a convenient way to automatically set up your development environment consistently each time you open a project.

## Configuration

You can customize search directories for the `-f` option:

```fish
set -g search_dirs "$HOME/dev" "$HOME/projects" "$HOME/work"
```

and I prefer to use shorter aliases:

```fish
# Create function aliases to allow direct use of fmux as fm and fmk commands
alias fm='fmux_fm'
alias fmk='fmux_fmk'
```

## License

MIT