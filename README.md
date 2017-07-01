You Should Use
==============

![Travis CI](https://img.shields.io/travis/MichaelAquilina/hashedindex.svg)

Simple zsh plugin that reminds you that you should use one of your existing aliases for a command you just typed.

Also supports detection of global and git aliases.

Usage
-----

You dont need to do anything. Once it's installed, `zsh-you-should-use` will let you know if you wrote a
command with an existing alias.

```
$ alias gc="git commit"
$ git commit -m "test commit"
Found existing alias for "git commit". You should use: "gc"
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
	modified:   README.md

no changes added to commit
```

`you-should-use` also detects global aliases:

```
$ alias -g NE="2>/dev/null"
$ find . -name "*.zsh" 2>/dev/null
Found existing alias for "2>/dev/null". You should use: "NE"
./you-should-use.plugin.zsh
```

and Git aliases:

```
$ git config --global alias.config cfg
$ git config --get-regexp alias\..
Found existing git alias for "config". You should use: "git cfg"
alias.cp cherry-pick
alias.cfg config
```

Requirements
------------
`you-should-use` officially supports zsh versions larger than 5.0. It is possible it might work
on even older versions but they are not officially tested as part of the build process.

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

[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

Copy this repository to `$ZSH/custom/plugins`, where `$ZSH` is the root directory of oh-my-zsh.  Then add this line to your `.zshrc`
```
plugins=(you-should-use $plugins)
```

Displaying Results
------------------

By default, `you-should-use` will display *all* matches with aliases found. However, you can change
this so that it only displays the best match found by setting the value of `YSU_MODE`.

* To enable best match: `export YSU_MODE=BESTMATCH`
* To enable all (default): `export YSU_MODE=ALL`

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

Now if you type a command that has an alias defined and you didnt use it, zsh will refuse to execute that command:

```
$ export YSU_HARDCORE=1
$ ls -lh
Found existing alias for "ls -lh". You should use: "ll"
You Should Use hardcore mode enabled. Use your aliases!
$ ll
total 8.0K
-rw-r--r-- 1 michael users 2.4K Jun 19 20:46 README.md
-rw-r--r-- 1 michael users  650 Jun 19 20:42 you-should-use.plugin.zsh
```

Contributing
------------

Pull requests and Feedback are welcome! :tada:

I have tried to cater for as many use cases that I can think of. However, they are naturally tailored to
to my own workflow and I could be missing many others.

Because of this if there is a specific use case that does not work as you would expect
or if you have any suggestions to how the plugin should behave, feel free to
[open an issue](https://github.com/MichaelAquilina/zsh-you-should-use/issues/new)


Running Tests
-------------

Install [zunit](https://zunit.xyz/). Run `zunit` in the root directory of the repo.

```
$ zunit
Launching ZUnit
ZUnit: 0.7.0
ZSH:   zsh 5.3.1 (x86_64-suse-linux-gnu)

✔ ysu message correct output
✔ ysu global message correct output
✔ ysu git message correct output
```

NOTE: The tests that run move your git configuration to a temporary location during
the test process so that your user configuration does not interfere with tests. This will
be restored at the end of each test so there is no risk in losing your settings. If for
some strange reason zunit crashes or does not restore your git configuration automatically,
all you need to do is run `mv ~/.gitconfig.bak ~/.gitconfig`
