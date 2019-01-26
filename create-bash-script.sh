#!/usr/bin/env bash

function usage()
{
  local just_help=$1
  local missing_required=$2
  local invalid_argument=$3
  local invalid_option=$4

  local help="Usage: create-bash-script.sh [OPTIONS]

This script creates a bash script in your current working directory
with command line argument parsing based on your desired arguments.

Example: create-bash-script.sh --seperator SPACE
                               --arguments region,name,account
                               --short-arguments r,,a
                               --name test.sh

The above command will create a bash script named test.sh with space seperated
argument parsing where the argument options are --region, --name, and --account,
and it creates short argument options for region: -r, and account: -a, but
does not create a short argument option for name.

Options (* indicates it is required):
 *  -n, --name                name of the output script
 *  -a, --arguments           a comma seperated list of arguments to parse in your script
    -s, --seperator           only two options: SPACE | EQUALS (defaults to SPACE)
    -sa, --short-arguments    a comma seperated list of short names for your arguments"

  if [ "$just_help" != "" ]
  then
    echo "$help"
    return
  fi

  if [ "$missing_required" != "" ]
  then
    echo "Missing required argument: $missing_required"
  fi
  if [ "$invalid_option" != "" ]
  then
    echo "Invalid option: $invalid_option"
  fi
  if [ "$invalid_argument" != "" ]
  then
    echo "Invalid argument: $invalid_argument"
  fi

  echo -e "\n"
  echo "$help"
  return
}

function beginswith() {
  case $2 in "$1"*) true;; *) false;; esac;
}

# required argument list:
REQ_ARGS=("arguments" "name")

# get command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -s|--seperator)
    seperator="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--arguments)
    arguments="$2"
    shift
    shift
    ;;
    -n|--name)
    name="$2"
    shift
    shift
    ;;
    *)
    POSITIONAL+=("$1") # saves unknown option in array
    shift
    ;;
esac
done

# for i in "${POSITIONAL[@]}"; do
#   echo "$i"
#   if beginswith "-" "$i"; then
#     echo "it begins with dash"
#   fi
# done

for i in "${REQ_ARGS[@]}"; do
  # $i is the string of the variable name
  # ${!i} is a parameter expression to get the value
  # of the variable whose name is i.
  req_var=${!i}
  if [ "$req_var" = "" ]
  then
    usage "" "--$i"
    exit
  fi
done

# number_of_arguments=${#POSITIONAL[@]}

# echo "number_of_argumnets: $number_of_arguments"
# last_argument=${POSITIONAL[$number_of_arguments - 1]}
# second_last_argument=${POSITIONAL[$number_of_arguments - 2]}
# echo "last argument: $last_argument"
# echo "second to last argument: $second_last_argument"

# if beginswith "-" "$second_last_argument"; then
  # this means user only provided a single comma seperated list
  # which means that they only want long options

# check if that file already exists
if [ -f "$name" ]; then
  echo "file: $name already exists. Are you sure you want to overwrite it? (y or n)"
  read answer
  if ! beginswith "y" "$answer"; then
    echo "Overwriting of file: $name was denied. Script terminating."
    exit
  else
    > "$name"
  fi
fi

echo "#!/usr/bin/env bash

function usage()
{
  local just_help=\$1
  local missing_required=\$2
  local invalid_argument=\$3
  local invalid_option=\$4

  local help=\"Usage: $name [OPTIONS]

[ENTER YOUR DESCRIPTION HERE]

Example: $name [ENTER YOUR EXAMPLE ARGUMENTS HERE]

Options (* indicates it is required):
 *  -n, --name                name of the output script
 *  -a, --arguments           a comma seperated list of arguments to parse in your script
    -s, --seperator           only two options: SPACE | EQUALS (defaults to SPACE)
    -sa, --short-arguments    a comma seperated list of short names for your arguments\"

  if [ \"\$just_help\" != \"\" ]
  then
    echo \"\$help\"
    return
  fi

  if [ \"\$missing_required\" != \"\" ]
  then
    echo \"Missing required argument: \$missing_required\"
  fi
  if [ \"\$invalid_option\" != \"\" ]
  then
    echo \"Invalid option: \$invalid_option\"
  fi
  if [ \"\$invalid_argument\" != \"\" ]
  then
    echo \"Invalid argument: \$invalid_argument\"
  fi

  echo -e \"\n\"
  echo \"\$help\"
  return
}

# get command line arguments
POSITIONAL=()
while [[ \$# -gt 0 ]]
do
key=\"\$1\"
case \$key in
    -s|--seperator)
    seperator=\"\$2\"
    shift # past argument
    shift # past value
    ;;
    -a|--arguments)
    arguments=\"\$2\"
    shift
    shift
    ;;
    -n|--name)
    name=\"\$2\"
    shift
    shift
    ;;
    *)
    POSITIONAL+=(\"\$1\") # saves unknown option in array
    shift
    ;;
esac
done
" >> "$name"
