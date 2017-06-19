You Should Use
==============

Simple zsh plugin that reminds you that you should use one of your existing aliases for a command you just typed.

Usage
-----

You dont need to do anything. Once it's installed, `zsh-you-should-use` will let you know if you wrote a
command with an existing alias.

```
$ git commit -m "test commit"
Found existing alias for "git commit". You should use: "gc"
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
	modified:   README.md

no changes added to commit
```

List Aliases
------------

I have also included a bonus command `lsalias` as part of this plugin that will allow you to list your existing aliases.

```
$ lsalias
.. = "cd .."
gc = "git commit"
cd.. = "cd .."
gd = "git diff"
xc = "xcopy"
h = "history"
LS = "LS -e"
gap = "git add -p"
xp = "xpaste"
t = "tig"
...
```

Hardcore Mode
-------------

For the brave and adventerous only.

You can enable Hardcore mode to enforce the use of aliases. Enabling this will cause zsh to refuse to execute commands you
have entered if an alternative alias for it exists. This is a handy way of forcing you to use your aliases and help you
turn those aliases into muscle memory.

Enable hardcore mode by setting the variable `YSU_HARDCORE` to 1.

```
export YSU_HARDCORE=1
```

Now if you type a command that has an alias defined for it and you didnt use it, zsh will refuse to execute that command:

```
$ export YSU_HARDCORE=1
$ ls -lh
Found existing alias for "ls -lh". You should use: "ll"
You Should Use hardcore mode enabled. Use your aliases!
$ ll
drwx------  3 michael users    16 Jun 18 21:47 Documents
drwxr-xr-x  6 michael users    16 Jun 18 21:54 Development
-rw-------  1 michael users    16 Jun 18 21:57 Pictures
-rw-r--r--  1 michael users    16 Jun  4 10:35 Music
drwx------  2 michael users    16 Jun 19 20:17 bin
```

Installation
------------

Add one of the following to your `.zshrc` file depending on your package manager:

[ZPlug](https://github.com/zplug/zplug)
```
zplug "MichaelAquilina/zsh-you-should-use"
```

[Antigen](https://github.com/zsh-users/antigen)
```
antigen bundle "MichaelAquilina/zsh-you-should-use"
```

[Zgen](https://github.com/tarjoilija/zgen)
```
zgen load "MichaelAquilina/zsh-you-should-use"
```

Contributing
------------

Pull requests and Feedback are welcome! Feel free to open an issue for any bugs that you find! :tada:
