Changelog for zsh-you-should-use
================================

1.7.0
-----
* Add support for ignoring global aliases

1.6.1
-----
* Fix detection of substrings with global aliases (#91)

1.6.0
-----
* Revert smart alias expansion detection feature from 1.5.0 release as it is causing numerous regressions

1.5.2
-----
* Fix bug in 1.5.0 where an alias would be recommended even though it had just been typed by the user

1.5.1
-----
* Temporary revert of 1.5.0 which causes a major bug in alias detection (see #84)

1.5.0
-----
* Suggest better available aliases if a user uses another alias (issue #79)

1.4.0
-----
* Aliases reminders are no longer shown if running commands with sudo

1.3.0
-----
* Add `check_alias_usage` function to generate report of aliases being used by user

1.2.1
-----
* Fix minor bug where variables would pollute user's environment

1.2.0
-----
* Add support for ignoring aliases

1.1.0
-----
* git aliases with parameters are now correctly matched (Thanks @crater2150)

1.0.0
-----
* Add ability to display reminder message *before* or *after* a command is executed

0.7.3
-----
* Fix Default message format conflicting with autoswitch-virtualenv plugin

0.7.2
-----
* Use type builtin to check if tput command is available

0.7.1
-----
* Suppress error messages showing when tput is not installed

0.7.0
-----
* Use tput command instead of raw escape codes

0.6.0
-----
* Improved colouring for default message

0.5.1
-----
* Minor fixes and updates to README.

0.5.0
-----
* Add functions to temporarily disable (and re-enable) you-should-use

0.4.4
-----
* export you-should-use version

0.4.3
-----
* Use yellow messages by default


0.4.2
-----
* Specify LICENSE (GPLv3)

0.4.1
-----
* Only use default message format if `$YSU_MESSAGE_FORMAT` is unset

0.4.0
-----
* Introduce CHANGELOG
* Add ability to change message output on alias detection
* Add index to README for quick navigation


0.3.2
-----
* Fixed bug in best match algorithm (see #34)
