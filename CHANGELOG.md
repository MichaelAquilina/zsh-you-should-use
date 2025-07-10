Changelog for zsh-you-should-use
================================

1.10.1
------
* Fix bug where hardcore mode would run even when not enabled (#148)

1.10.0
------
* Add support for hardcore mode on specific aliases via `YSU_HARDCORE_ALIASES`
* Improvements to zunit setup and teardown
* thankyou to @mattarau for this release!

1.9.0
-----
* massive performance improvement to `check_alias_usage` #139 (Thanks @AtifChy!)
* remove dependency on `wc`

1.8.0
-----
* Fix bug in `check_alias_usage` command which would spam `entry=` to stdout

1.7.5
-----
* Minor optimization to the way global aliases are checked (#135)

1.7.4
-----
* Fix test failures when key and value are not split correctly (#132)

1.7.3
-----
* Fix further issue where local variables would leak into users environment

1.7.2
-----
* Fix issue where `key` and `entry` variables would leak into users environment

1.7.1
-----
* Fix issue where \ and % would not be escaped correctly in messages (Issue #98)

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
