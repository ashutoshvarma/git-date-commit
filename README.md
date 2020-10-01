# Git Date Commit
Simple bash script for automating commits in bulk for given date range while executing command/script.

## Usage

```
Usage: gdc.sh [optional] -x COMMAND -s START_DATE

  -x COMMAND          command/script to execute before every commit. Any  
  --execute           'eval' compatible command is supported. Also you can
                      use day and date placeholders.

  -s START_DATE       date to start commits. (all GNU 'date' compatible dates
  --start             string are supported. Example-'2020/08/04')

  -e END_DATE         date of last commit.
  --end

  -c MSG              commit message. Placeholders for day and date is supported.
  --commit_msg

  -n NUMBER           no of commits per day.
  --commit_count

  -q                  no progess bar.
  --no_progressbar

  -v                  version
  --version

  -h                  help message
  --help


Placeholders:-
Two placeholders for current processing date '${date}' and current day count
'${day}' and current day commit number '${commit_count}' are provided for
use in COMMAND and COMMIT_MSG. NOTE that placeholder syntax is exactly similar
to bash variable so make sure to use SINGLE QUOTES while assigning them in shells.

Examples:-
Run custom script with date and day as args before commits ranging from date
2020/08/04 to 2020/12/31.
  $ gdc.sh -s '2020/08/04' -e '2020/12/31' -x './myscript.sh ${date} ${day}'
Note the single quotes in -x to prevent variable substitution for placeholders
```

## LICENSE
MIT
Copyright (c) 2020 Ashutosh Varma
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
