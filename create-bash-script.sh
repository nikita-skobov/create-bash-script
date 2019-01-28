#!/usr/bin/env bash

function usage()
{
  local just_help=$1
  local missing_required=$2
  local invalid_value=$3
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
    -sa, --short-arguments    a comma seperated list of short names for your arguments
         --help               displays this usage text"

  if [ "$just_help" != "" ]
  then
    echo "$help"
    return
  fi

  if [ "$missing_required" != "" ]
  then
    echo "Missing required argument: $missing_required"
  fi

  if [ "$invalid_option" != "" ] && [ "$invalid_value" = "" ]
  then
    echo "Invalid option: $invalid_option"
  elif [ "$invalid_value" != "" ]
  then
    echo "Invalid value: $invalid_value for option: --$invalid_option"
  fi

  echo -e "\n"
  echo "$help"
  return
}

function beginswith() {
  case $2 in "$1"*) true;; *) false;; esac;
}

function endswith() {
  case $2 in *"$1") true;; *) false;; esac;
}

function create_arg_array() {
  local long_arg_csv=$1
  local short_arg_csv=$2
  IFS=',' read -r -a temp_arr1 <<< "$long_arg_csv"
  IFS=',' read -r -a temp_arr2 <<< "$short_arg_csv"

  arg_array=()

  for index in "${!temp_arr1[@]}"
  do
    arg_array+=("${temp_arr1[$index]},${temp_arr2[$index]}")
  done
}

function create_usage_single() {
  local single_arg_csv=$1
  IFS=',' read -r -a temp_arr1 <<< "$single_arg_csv"

  local short_opt="${temp_arr1[1]}"
  local long_opt="${temp_arr1[0]}"
  local is_required=" "

  if beginswith "*" $long_opt
  then
    is_required="*"
    # remove the first character: *
    long_opt=$(echo ${long_opt#\*})
  fi

  if endswith "-" $long_opt
  then
    # remove the last character: -
    long_opt=$(echo ${long_opt%\-})
  fi

  if [ "$short_opt" = "" ]
  then
    if [[ $(echo $no_arg_string | grep $long_opt) ]];
    then
      if [ "$long_opt" = "help" ];
      then
	echo -e "\\ \\--$long_opt\\[Print help function and exit]"
      else
	echo -e "  $is_required\\ \\--$long_opt\\[ENTER YOUR DESCRIPTION HERE]"
      fi
    else
      echo -e "  $is_required\\ \\--$long_opt$seperator\\[ENTER YOUR DESCRIPTION HERE]"
    fi
  else
    if [[ $(echo $no_arg_string | grep $long_opt) ]];
    then
      if [ "$long_opt" = "help" ];
      then
	echo "\\-$short_opt,\\--$long_opt\\[Print help function and exit]"
      else
        echo "  $is_required\\-$short_opt,\\--$long_opt\\[ENTER YOUR DESCRIPTION HERE]"
      fi
    else
      echo "  $is_required\\-$short_opt$seperator,\\--$long_opt$seperator\\[ENTER YOUR DESCRIPTION HERE]"
    fi
  fi
}

function create_req_arg_string() {
  req_arg_string="REQ_ARGS=("

  for item in "${arg_array[@]}"
  do
    IFS=',' read -r -a temp_arr1 <<< "$item"
    local long_opt="${temp_arr1[0]}"

    if endswith "-" $long_opt
    then
      # remove the last character: -
      long_opt=$(echo ${long_opt%\-})
    fi

    if beginswith "*" $long_opt
    then
      is_required="*"
      # remove the first character: *
      long_opt=$(echo "$long_opt" | cut -c 2-)
      req_arg_string="$req_arg_string\"$long_opt\" "
    fi
  done

  req_arg_string="$req_arg_string)"
}

function create_no_arg_string() {
  no_arg_string="NO_ARGS=("

  for item in "${arg_array[@]}"
  do
    IFS=',' read -r -a temp_arr1 <<< "$item"
    local long_opt="${temp_arr1[0]}"

    if beginswith "*" $long_opt
    then
      is_required="*"
      # remove the first character: *
      long_opt=$(echo ${long_opt#\*})
    fi

    if endswith "-" $long_opt
    then
      # remove the last character: -
      long_opt=$(echo ${long_opt%\-})
      no_arg_string="$no_arg_string\"$long_opt\" "
    fi
  done

  no_arg_string="$no_arg_string)"
}

function create_parse_string() {
  parse_string=""

  for item in "${arg_array[@]}"
  do
    IFS=',' read -r -a temp_arr1 <<< "$item"
    local long_opt="${temp_arr1[0]}"
    local short_opt="${temp_arr1[1]}"

    if beginswith "*" $long_opt
    then
      # remove the first character: *
      long_opt=$(echo "$long_opt" | cut -c 2-)
    fi

    if endswith "-" $long_opt
    then
      # remove the last character: -
      long_opt=$(echo ${long_opt%\-})
    fi

    if [ "$seperator" = " " ]
    then
      if [ "$short_opt" = "" ]
      then
	if [[ $(echo $no_arg_string | grep $long_opt) ]]; 
	then
	  if [ "$long_opt" = "help" ];
	  then
	    parse_string="$parse_string\n\t--$long_opt)\n\t\tusage 1 && exit 0\n\t\t;;"
	  else
	    parse_string="$parse_string\n\t--$long_opt)\n\t\t$long_opt=\"true\"\n\t\tshift\n\t\t;;"
	  fi
	else
          parse_string="$parse_string\n\t--$long_opt)\n\t\t$long_opt=\"\$2\"\n\t\tshift\n\t\tshift\n\t\t;;"
	fi
      else
	if [[ $(echo $no_arg_string | grep $long_opt) ]]; 
	then
	  if [ "$long_opt" = "help" ];
          then
            parse_string="$parse_string\n\t-$short_opt|--$long_opt)\n\t\tusage 1 && exit 0\n\t\t;;"
          else
	    parse_string="$parse_string\n\t-$short_opt|--$long_opt)\n\t\t$long_opt=\"true\"\n\t\tshift\n\t\t;;"
	  fi
	else
          parse_string="$parse_string\n\t-$short_opt|--$long_opt)\n\t\t$long_opt=\"\$2\"\n\t\tshift\n\t\tshift\n\t\t;;"
	fi
      fi
    else
      if [ "$short_opt" = "" ]
      then
	if [[ $(echo $no_arg_string | grep $long_opt) ]]; 
	then
          parse_string="$parse_string\n\t--$long_opt)\n\t\t$long_opt=\"true\"\n\t\tshift\n\t\t;;"
	else
          parse_string="$parse_string\n\t--$long_opt=*)\n\t\t$long_opt=\"\${key#*=}\"\n\t\tshift\n\t\t;;"
	fi
      else
	if [[ $(echo $no_arg_string | grep $long_opt) ]]; 
	then
	  parse_string="$parse_string\n\t-$short_opt|--$long_opt)\n\t\t$long_opt=\"true\"\n\t\tshift\n\t\t;;"
	else
          parse_string="$parse_string\n\t-$short_opt=*|--$long_opt=*)\n\t\t$long_opt=\"\${key#*=}\"\n\t\tshift\n\t\t;;"
	fi
      fi
    fi
  done
}

# required argument list:
REQ_ARGS=("arguments" "name")

# get command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    --help)
    usage 1
    exit
    ;;
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
    -sa|--short-arguments)
    short_arguments="$2"
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

if [ "$seperator" = "" ] || [ "$seperator" = "SPACE" ]
then
  seperator=" "
elif [ "$seperator" = "EQUALS" ]
then
  seperator="="
else
  usage "" "" "$seperator" "seperator"
  exit
fi

create_arg_array "$arguments" "$short_arguments"
create_req_arg_string
create_no_arg_string
create_parse_string
usage_string=""

for item in "${arg_array[@]}"
do
  single_usage_item=$(create_usage_single "$item")
  usage_string="$usage_string $single_usage_item\n"
done

loop_type_string=""
loop_positional_string=""

if [ "$seperator" = " " ]
then
  loop_positional_string="POSITIONAL+=(\"\$1\") # saves unknown option in array"
  loop_type_string="while [[ \$# -gt 0 ]]\ndo\nkey=\"\$1\"\n"
else
  loop_positional_string="POSITIONAL+=(\"\$key\") # saves unknown option in array"
  loop_type_string="for key in \"\$@\"\ndo\n"
fi


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

# output to file
echo -e "#!/usr/bin/env bash

function usage()
{
  local just_help=\$1
  local missing_required=\$2
  local invalid_argument=\$3
  local invalid_option=\$4

  local help=\"Usage: $name [OPTIONS]

[ENTER YOUR DESCRIPTION HERE]

Example: $name [ENTER YOUR EXAMPLE ARGUMENTS HERE]

Options (* indicates it is required):\"
  local help_options=\"$usage_string\"

  if [ \"\$missing_required\" != \"\" ]
  then
    echo \"Missing required argument: \$missing_required\"
  fi

  if [ \"\$invalid_option\" != \"\" ] && [ \"\$invalid_value\" = \"\" ]
  then
    echo \"Invalid option: \$invalid_option\"
  elif [ \"\$invalid_value\" != \"\" ]
  then
    echo \"Invalid value: \$invalid_value for option: --\$invalid_option\"
  fi

  echo -e \"\\n\"
  echo \"\$help\"
  echo \"\$help_options\" | column -t -s'\\\'
  return
}
function init_args()
{
$req_arg_string

# get command line arguments
POSITIONAL=()
$loop_type_string
case \$key in$parse_string
\t*)
\t\t$loop_positional_string
\t\tshift
\t\t;;
esac
done

for i in \"\${REQ_ARGS[@]}\"; do
  # \$i is the string of the variable name
  # \${!i} is a parameter expression to get the value
  # of the variable whose name is i.
  req_var=\${!i}
  if [ \"\$req_var\" = \"\" ]
  then
    usage \"\" \"--\$i\"
    exit
  fi
done
}
init_args \$@
" >> "$name"
chmod u+x $name
