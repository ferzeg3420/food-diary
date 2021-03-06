#! /bin/bash

#set -x 

EXEC_NAME=${0##*/}
EXEC_NAME=${EXEC_NAME/\//}

if [ -e "$(dirname "$0")/nutrition_db_functions.sh" ]
then
   . "$(dirname "$0")/nutrition_db_functions.sh"
else
   . "$(dirname "$0")/food_diary_directory/nutrition_db_functions.sh"
fi

if [ -e "$(dirname "$0")/nutrition_calc_funtions.sh" ]
then
   . "$(dirname "$0")/nutrition_calc_functions.sh"
else
   . "$(dirname "$0")/food_diary_directory/nutrition_calc_functions.sh"
fi

function print_usage() 
{
  echo "Usage: $EXEC_NAME [-ea] [-vd] [-o tags] file [file2 ...] "
}

e_flags='' # for editing the food database

a_flags='' # add an entry to the food database.

d_flag='' # Display nutrition info for the entire day. This is useful when
          # combined with a search for a specific tags.

o_tag='' # tags for the o flag
verbose='false'

while getopts 'eado:v' flag
do
  case "${flag}" 
  in
    e) e_flag='true' ; break ;; 
    a) a_flag='true' ; break ;; 
    d) d_flag='true' ;;
    o) o_tag=${OPTARG} ;;
    v) verbose='true' ;;
    *) print_usage
       exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ ! -z $e_flag ]
then
   db_edit
   exit 0
fi

if [ ! -z $a_flag ]
then
   db_add_entry
   exit 0
fi

if [ -z $d_flag  ] && [ -z $o_tag ]
then 
   d_flag='true'
fi

if [ ! -z $d_flag ]
then
   if [ "$verbose" = 'true' ]
   then
      nutri_calc -v "$@"
   else
      nutri_calc "$@"
   fi
fi
   
if [ ! -z $o_tag ]
then
   if [ "$verbose" = 'true' ]
   then
      o_tag=$( echo "$o_tag" | sed 's/^--* *\(.*\)/\1/')
      nutri_calc -v -o "${o_tag}" "$@"
   else
      o_tag=$( echo "$o_tag" | sed 's/^--* *\(.*\)/\1/')
      nutri_calc -o "${o_tag}" "$@"
   fi
fi
