#!/bin/bash 

OUT_WIDTH=72

lookup_default_serving_size() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 2` 

  exec 3<&-
}

lookup_per_gram_calories() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 3` 

  exec 3<&-
}

lookup_per_gram_proteins() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 4` 

  exec 3<&-
}

lookup_per_gram_carbs() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 5` 

  exec 3<&-
}

lookup_per_gram_fats() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 6` 

  exec 3<&-
}

lookup_per_gram_fiber() 
{
  exec 3< ~/Documents/food_nutrition.db

  echo `grep "^$1\>" <&3 \
       | head -n 1 \
       | cut -d , -f 7` 

  exec 3<&-
}

parse_serving_size() 
{
   local serving_size=0
   local food_name=''
   if [[ "$1" =~ ^\ *[0-9][0-9]*\ \ *UNIT ]]
   then
      serving_size=`echo $1 | grep -o '^ *[0-9]*'`
   elif [[ "$1" =~ ^\ *[0-9][0-9]*.* ]]
   then
      food_name=$(echo "$1" | sed -E 's/^ *[0-9]+ *//')
      serving_size=`lookup_default_serving_size "$food_name"`
   else
      serving_size=`lookup_default_serving_size "$1"`
   fi 
   echo $serving_size
}

parse_number_of_servings() 
{
   local number_of_servings=0
   if [[ "$1" =~ ^\ *[0-9][0-9]*\ \ *UNIT ]]
   then
      number_of_servings=1
   elif [[ "$1" =~ ^\ *[0-9][0-9]*.* ]]
   then
      number_of_servings=`echo $1 | grep -o '^ *[0-9]*'`
   else
      number_of_servings=1
   fi 
   echo $number_of_servings
}

parse_food_name() 
{
   local food_name=''
   if [[ "$1" =~ ^\ *[0-9][0-9]*\ \ *UNIT ]]
   then
      food_name=$(echo "$1" | sed -E 's/^ *[0-9]+ *UNIT  *//')
   elif [[ "$1" =~ ^\ *[0-9][0-9]*.* ]]
   then
      food_name=$(echo "$1" | sed -E 's/^ *[0-9]+ *//')
   else
      food_name="$1"
   fi 
   echo $food_name
}

clean_file() 
{
   if [ -e "${1}.tag" ]
   then
      infile="${1}.tag"
   else 
      infile="${1}.in"
   fi
   outfile="${1}.clean"

   grep -v '^---.*$' "$infile"                       \
      | grep -v '^ *#'                               \
      | tr '[A-Z]' '[a-z]'                           \
      | grep -v '^ *$'                               \
      | sed 's/  / /g'                               \
      | sed 's/, *and\([^\.][^\.]*\.* *\)$/,\1/g'    \
      | sed 's/\. *$//'                              \
      | awk 'BEGIN{FS=", ";OFS="\n";ORS="\n"}\
                  {for (i=1; i<=NF; i++) print $i }' \
      > "${outfile}"
}

preprocess_clean_file()
{
   infile="${1}.clean"
   outfile="${1}.preproc"

   sed 's/^[[:space:]]*a[[:space:]]/1 /' "${infile}" \
   | awk\
     '{
         if ($1 ~ /[0-9]/ && $2 ~ /grams?|mililiters?/) 
         {
            $2="UNIT"   
            if ( $3 ~ /of/ )
            {
               $3=""
            }
            print $0
         }
         else if ($1 ~ /[0-9]+/ && $2 ~ /glass|glasses/) 
         {
            $1=$1 * 240
            $2="UNIT"   
            if ( $3 ~ /of/ )
            {
               $3=""
            }
            print $0
         }
         else 
           print $0
      }' \
      | sed 's/  / /g' > "$outfile"
}

calc_calories() 
{
   # $2 is the default, or user-provided, serving size
   # $3 is the number of servings, always 1 if given by the user

   local food_name="$1"
   local serving_size="$2"
   local num_servings="$3"

   local calories_per_gram=`lookup_per_gram_calories "$food_name"`
   local calories_per_serving=`echo "$calories_per_gram * $serving_size" | bc`
   local total_calories=`echo "$calories_per_serving * $num_servings" | bc`
   echo $total_calories
}

calc_proteins() 
{
   # $2 is the default, or user-provided, serving size
   # $3 is the number of servings, always 1 if given by the user

   local food_name="$1"
   local serving_size="$2"
   local num_servings="$3"

   local proteins_per_gram=`lookup_per_gram_proteins "$food_name"`
   local proteins_per_serving=`echo "$proteins_per_gram * $serving_size" | bc`
   local total_proteins=`echo "$proteins_per_serving * $num_servings" | bc`
   echo $total_proteins
}

calc_carbs() 
{
   # $2 is the default, or user-provided, serving size
   # $3 is the number of servings, always 1 if given by the user

   local food_name="$1"
   local serving_size="$2"
   local num_servings="$3"

   local carbs_per_gram=`lookup_per_gram_carbs "$food_name"`
   local carbs_per_serving=`echo "$carbs_per_gram * $serving_size" | bc`
   local total_carbs=`echo "$carbs_per_serving * $num_servings" | bc`
   echo $total_carbs
}

calc_fats() 
{
   # $2 is the default, or user-provided, serving size
   # $3 is the number of servings, always 1 if given by the user

   local food_name="$1"
   local serving_size="$2"
   local num_servings="$3"

   local fats_per_gram=`lookup_per_gram_fats "$food_name"`
   local fats_per_serving=`echo "$fats_per_gram * $serving_size" | bc`
   local total_fats=`echo "$fats_per_serving * $num_servings" | bc`
   echo $total_fats
}

calc_fiber() 
{
   # $2 is the default, or user-provided, serving size
   # $3 is the number of servings, always 1 if given by the user

   local food_name="$1"
   local serving_size="$2"
   local num_servings="$3"

   local fiber_per_gram=`lookup_per_gram_fiber "$food_name"`
   local fiber_per_serving=`echo "$fiber_per_gram * $serving_size" | bc`
   local total_fiber=`echo "$fiber_per_serving * $num_servings" | bc`
   echo $total_fiber
}

round()
{
  read -r input
  echo "$input + 0.5" | bc | sed 's/\.[0-9]*[[:space:]]*$//'
}

show_nutrition()
{
   other_grams=`echo "$1 - $3 - $4 - $5 - $6" | bc`
   local protein_percentage=`echo \
      "scale=2;( $3 / $1 ) * 100 " | bc | round`
   local carbs_percentage=`echo   \
      "scale=2;( $4 / $1 ) * 100 " | bc | round`
   local fats_percentage=`echo    \
      "scale=2;( $5 / $1 ) * 100 " | bc | round`
   local fiber_percentage=`echo   \
      "scale=2;( $6 / $1 ) * 100 " | bc | round`
   local other_percentage=`echo   \
      "scale=2;( $other_grams / $1 ) * 100 " | bc | round`

   echo
   printf "Calories               %10.2f kilocalories.\n" $2
   printf "Meal weight            %10.2f grams.\n" $1
   echo

   printf "Proteins         ~%3d%% %10.2f grams.\n" \
          "$protein_percentage"                     \
          "$3"

   printf "Carbohydrates    ~%3d%% %10.2f grams.\n" \
          "$carbs_percentage"                       \
          "$4"

   printf "Fats             ~%3d%% %10.2f grams.\n" \
          "$fats_percentage"                        \
          "$5"

   printf "Fiber            ~%3d%% %10.2f grams.\n" \
          "$fiber_percentage"                       \
          "$6"

   printf "Other            ~%3d%% %10.2f grams.\n" \
          "$other_percentage"                       \
          "$other_grams" 
   echo
}

process_meal_log()
{
   infile="${1}.preproc"

   local weight_counter=0
   local calories_counter=0
   local proteins_counter=0
   local carbs_counter=0
   local fats_counter=0
   local fiber_counter=0

   while read -r line
   do

      local food_name=`parse_food_name "$line"` 
      local serving_size=`parse_serving_size "$line"` 
      local number_of_servings=`parse_number_of_servings "$line"` 

      local calories=`calc_calories "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      local proteins=`calc_proteins "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      local carbs=`calc_carbs       "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      local fats=`calc_fats         "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      local fats=`calc_fats         "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      local fiber=`calc_fiber       "$food_name" \
                                    "$serving_size" \
                                    "$number_of_servings"`

      weight=`echo $serving_size \* $number_of_servings | bc`

      local weight_counter=`echo   $weight_counter   + $weight   | bc`
      local calories_counter=`echo $calories_counter + $calories | bc`
      local proteins_counter=`echo $proteins_counter + $proteins | bc`
      local carbs_counter=`echo    $carbs_counter    + $carbs    | bc`
      local fats_counter=`echo     $fats_counter     + $fats     | bc`
      local fiber_counter=`echo    $fiber_counter    + $fiber    | bc`

   done < "${infile}"

   show_nutrition $weight_counter   \
                  $calories_counter \
                  $proteins_counter \
                  $carbs_counter    \
                  $fats_counter     \
                  $fiber_counter
}

crop_out_non_tag()
{
   local tag="$1" 
   local infile="${2}.in" 
   local outfile="${2}.tag" 
   sed -n "/^--*[[:space:]]*${tag}/,/^--*/p" "$infile" > "$outfile"
}

pad()
{
   local pad="$1"
   local msg="$2"
   local len=`echo "$msg" | wc -m`
   local padding=`expr $OUT_WIDTH - $len` 
   for i in $(seq 1 $padding); do echo -n $pad ; done
   echo "$2"
}

verbose_output() 
{
  pad "-" " ${1}:"
  cat "$1" | fmt -w 71
  pad "-"  
  echo 
}

nutri_calc()
{
   local verbose=
   if [ "$1" = '-v' ]
   then
      verbose='true'
      shift
   fi

   local tag=
   if [ "$1" = '-o' ]
   then
      tag="$2"
      shift 2
   fi
      
   for file in "$@"
   do
      if [ ! -e "$file" ]
      then
         exit 1
      fi
      
      [ ! -z "$verbose" ] &&  verbose_output "$file"
      infile="$file"
      local filename="${infile##*/}"
      local outfile_no_extension="/tmp/${filename}"   
       
      [ -e "${infile}.tag" ] && rm "${infile}.tag" 

      cp "$infile" "${outfile_no_extension}.in"

      [ ! -z "$tag" ] && crop_out_non_tag "$tag" "${outfile_no_extension}"
      clean_file "${outfile_no_extension}"
      preprocess_clean_file "${outfile_no_extension}"
      process_meal_log "${outfile_no_extension}"
   done
}
