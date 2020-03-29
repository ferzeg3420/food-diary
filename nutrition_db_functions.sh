#!/bin/bash

DATA_BASE='/Users/Fernando/Documents/food_nutrition.db'

db_edit()
{
   vim "${DATA_BASE}"
   return $?
}

check_if_quit()
{
   if [[ "$1" =~ [Qq] ]]
   then
      exit 0
   fi
}

db_add_entry()
{
  echo "Press [CTRL+C] or type 'q' to exit"
  while true
  do
     # food name, calories, protein, carbs, fats, fiber
     echo -n "Name (ASCII): "
     read name
     check_if_quit "$name"

     echo -n "Default weight in grams: "
     read default_weight
     check_if_quit "$default_weight"

     echo -n "Calories in kilocalories (per gram of food): "
     read calories
     check_if_quit "$calories"

     echo -n "Proteins in grams (per gram of food): "
     read proteins
     check_if_quit "$proteins"

     echo -n "Carbohydrates in grams (per gram of food): "
     read carbs
     check_if_quit "$carbs"

     echo -n "Fats in grams (per gram of food): "
     read fats
     check_if_quit "$fats"

     echo -n "Fiber in grams (per gram of food): "
     read fiber
     check_if_quit "$fiber"
     
     echo "${name},"     "${default_weight}," \
          "${calories}," "${proteins},"       \
          "${carbs},"    "${fats},"           \
          "${fiber} "   >> ${DATA_BASE} 
     echo >> ${DATA_BASE}
  done
  return $?
}
