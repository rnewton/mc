# MC

This is about as alpha as you can get. I wouldn't recommend using it unless you're willing to fiddle with it for a while. I'm planning on writing an install script as well as expanding the instructions and options, but this is supposed to be something quick. Right now it matches *my* workflow and it's unlikely to match yours.

### Requirements

- `$PATH` includes `$HOME/.bin`
- `git clone` This repo and symlink mc into `$HOME/.bin`
- Desk -> https://github.com/jamesob/desk
  - symlink to `$HOME/.bin`
  - Install in the standard spot `$HOME/.desk/desks` with `desk init`
- Create and source `$HOME/.mc` file with the following options:
  - `MC_LOCAL_PATH` -> Absolute path to where you keep your project files (I use `$HOME/Dev/betas`)
  - `MC_REMOTE_PATH` -> Absolute path to where you keep project files on the remote server (I use `$HOME`)
  - `MC_REMOTE_USER` -> ssh username on remote server
  - `MC_REMOTE_SERVER` -> IP/Hostname for ssh
  - `MC_DEFAULT_REPO_OWNER` -> Username on github for repositories
  - `MC_JIRA_URL` -> URL for Jira tasks with protocol and no trailing slash

### Usage

```
Usage:

    mc
        List the current project workspace details. If no workspace is loaded,
        list the available workspaces.
    mc (list|ls)
        List the available workspaces.
    mc (create|c)
        Create a new workspace.
    mc (edit|e)
        Edit an existing workspace.
    mc (delete|d) workspace-name
        Delete a workspace.
    mc (.|go) workspace-name
        Switch to a workspace.
    mc help
        Show this text.
    mc version
        Show version info.
```

```
$ mc c
Enter project name: task-61
Enter repository: github.com/rnewton/some-module
Enter the name of your branch (default: feature/task-61): 
Enter the name of the remote tracking branch (default: master): 
Run `ant init` (y|n) y

Check your settings:
Project path: /Users/robertnewton/Dev/betas/task-61
Remote path: /home/rnewton/task-61
Repository: git@github.com:rnewton/some-module.git - feature/task-61 -> master
Init: y

Okay? [Enter to confirm]
...
```
