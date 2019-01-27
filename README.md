# create-bash-script
A bash script designed to create other bash scripts with basic argument parsing.

## Installation:

This script was designed to be used as a global program to easily create
bash scripts within any directory. If you want to use it this way, this script must be on your systems PATH, or add it as an alias.

(A note for Windows users: As far as I know, you cannot run bash scripts natively on windows. You would need to either run it through powershell, or some other third party shell like [GitBash](https://git-scm.com/downloads).
The following two examples should work with GitBash)

- Add as an alias:
```sh
git clone https://github.com/nikita-skobov/create-bash-script.git
cd create-bash-script/
alias create-bash-script="bash /path/to/this/directory/create-bash-script/create-bash-script.sh"
# then you should be able to run the script from any folder by running:
# create-bash-script [OPTIONS]
```

- Add to system PATH:
```sh
git clone https://github.com/nikita-skobov/create-bash-script.git
cd create-bash-script/
echo $PATH # to see which folders are part of your path
# pick one of the folders (I reccommend /usr/local/bin)
sudo cp create-bash-script.sh /usr/local/bin # or any other folder thats part of your PATH
# then you can run the script from any folder by running:
# create-bash-script.sh [OPTIONS]
# NOTE that this way you have to specify the .sh file extension
# If you don't want to do this, then you can rename your script:
# sudo mv /usr/local/bin/create-bash-script.sh /usr/local/bin/create-bash-script
```

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