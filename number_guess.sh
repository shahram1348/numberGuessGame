#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


# Generate a random number between 1 and 1000 and put it in a variable.

GENERATE_SECRET_NUMBER() {
NUM1=$RANDOM
NUM2=32767
result=$((NUM1 * 1000))
SECRET_NUMBER=$((result / NUM2))
}
GENERATE_SECRET_NUMBER

# Function for guess number and check if it is an integer number, if not ask again for guessing untill user enter an integer.
CHECK_INPUT_IS_INTEGER() {
read GUESS_NUMBER
while [[ ! $GUESS_NUMBER =~ ^-?[0-9]+$ ]]
do
  echo -e "\nThat is not an integer, guess again:"
  read GUESS_NUMBER
done
}

# Function for asking the user for a guess
GUESS() {
SECRET_NUMBER_NOT_FOUND=0
COUNT=0
echo -e "\nGuess the secret number between 1 and 1000:"
CHECK_INPUT_IS_INTEGER
((COUNT++))
while [[ $SECRET_NUMBER_NOT_FOUND -eq 0 ]]
do

  if [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    CHECK_INPUT_IS_INTEGER
    ((COUNT++))
  elif [[ $GUESS_NUMBER -lt $SECRET_NUMBER ]]
  then 
    echo -e "\It's higher than that, guess again:"
    CHECK_INPUT_IS_INTEGER
    ((COUNT++))
  else
    echo -e "\nYou guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!\n" 
    SECRET_NUMBER_NOT_FOUND=1
  fi
done
}

# ask user the username:
echo "Enter your username: "
read USER_NAME

USER_IS_IN_DATABASE=$($PSQL "SELECT username FROM records where username='$USER_NAME';")

# Check if the username has been used before.
if [[ -z $USER_IS_IN_DATABASE ]]
then
	# Print the message:
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here.\n"
  # Update records table by insert into new username.
  UPDATE_FOR_NEW_USER_NAME=$($PSQL "INSERT INTO records(username, best_game, games_played) values('$USER_NAME', 100000, 0);")  
  GUESS
  BEST_GAME=100000
  GAMES_PLAYED=0
else
	# read username data from records table:
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM records where username='$USER_NAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM records where username='$USER_NAME';")
  	# Print the message
  echo -e "\nWelcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  GUESS
fi
((GAMES_PLAYED++))
# Compare the COUNT with the BEST_GAME, if COUNT is lower, set BEST_GAME equal to COUNT
if [[ $COUNT -lt $BEST_GAME ]]
then 
BEST_GAME=$COUNT
fi

# Update records table
  UPDATE_NEW_BEST_GAME=$($PSQL "UPDATE records SET best_game='$BEST_GAME', games_played='$GAMES_PLAYED' WHERE username='$USER_NAME';")
