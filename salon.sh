#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "Please choose a service from the list below:" 
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
  else
    SERVICE_ID_CHECK=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_CHECK ]]
    then
      MAIN_MENU "This service doesn't exist"
    else
      echo "Please provide your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "Please type your name"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo "Please provide service time"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "insert into appointments(time,service_id,customer_id) values('$SERVICE_TIME', $SERVICE_ID_SELECTED, $CUSTOMER_ID)")
    SERVICE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    SERVICE_FORMATTED=$(echo $SERVICE | sed 's/ |/"/')
    NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    echo -e "I have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED."
    fi
  fi
}
MAIN_MENU


