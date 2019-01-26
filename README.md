# create-bash-script
A bash script designed to create other bash srcipts with argument parsing and default value setting

## Usage

```sh
  create-bash-script --name [OUTPUT FILE NAME] --arguments [COMMA SEPERATED LIST]
```

#### Options:
  - --name | -n (required)
    - the file name to output. (eg: my-script.sh)
  - --arguments | -a (required)
    - a comma seperated list of argument names
    for example, providing `--arguments name,*country,postal-code,population`
    will create a script that parses the command line arguments and creates a
    variable for each argument name. If you put an asterisk (*) in front of a
    variable name, it will become a required argument, and the script will exit if a user does not provide that required value.
  - --short-arguments | -sa
    - a comma seperated list of short argument names to use
    as alternatives to the long argument names. The comma seperated list must be in the same order as the long argument comma seperated list.
    for example:`--arguments name,*country,postal-code,population --short-arguments n,c,pc,p` will create a script that will have the following usage: `[scriptname.sh] --country usa` OR `[scriptname.sh] -c usa`
  - --seperator | -s
    - two possible values: SPACE or EQUALS
    defaults to SPACE. if you specify EQUALS then your script usage will use equals seperated argument parsing like so: `[scriptname.sh] --country=usa` whereas if you keep the default, or explicitly specify SPACE, then your usage will be: `[scriptname.sh] --country usa`
  - --help
    - displays the scripts usage