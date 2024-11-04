#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~ Salon.sh ~~~~"
echo -e "\n"

MAIN_MENU () {
  # this will post a message if its passed into the function
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # menu title
  echo -e "\n~~~ Main Menu ~~~\n"  
  # print out the menu from the services table
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  #user input, selecting service
  read SERVICE_ID_SELECTED  
  #check if input is valid, first check if its a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # not a number, go back to main menu 
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # check if this entry exists ie is a valid service selection
    if [[ -z $VALID_SERVICE ]]
    then
      #doesnt exist, back to main  menu
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #selection is valid so we gather information from customer
      #get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #check number against the customer table to see if its in there
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        #nothing returned so input the new customer into the table
        #get the name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        #input into table
        RESULT_FROM_NEW_CUSTOMER_INPUT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        #get name of requested service
        REQUESTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        #ask what time is wanted for said service
        echo -e "\nWhat time would you like your $REQUESTED_SERVICE, $CUSTOMER_NAME?"
        read SERVICE_TIME
        #put info into appointment table
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        RESULT_FROM_NEW_APPOINTMENT_INPUT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        #inform that appointmnet has been made
        echo -e "\nI have put you down for a $REQUESTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        else
        #if the number gets a result from table
         #get name of requested service
        REQUESTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        #ask what time is wanted for said service
        echo -e "\nWhat time would you like your $REQUESTED_SERVICE, $CUSTOMER_NAME?"
        read SERVICE_TIME
        #put info into appointment table
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        RESULT_FROM_NEW_APPOINTMENT_INPUT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        #inform that appointmnet has been made
        echo -e "\nI have put you down for a $REQUESTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
   
}   


MAIN_MENU