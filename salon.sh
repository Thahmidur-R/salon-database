#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ My Salon ~~~~~\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
MAIN_MENU(){
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  echo -e "\nWelcome to My Salon, what would you like?"
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  # get service request
  read SERVICE_ID_SELECTED

  # get services id list and format it like this: 1|2|3|4
  SERVICES_ID_LIST=$($PSQL "SELECT service_id FROM services")
  FORMATTED_LIST=$(echo $SERVICES_ID_LIST | sed 's/ /|/g; s/^|//; s/|$//')

  # compare input to list
eval "case '$SERVICE_ID_SELECTED' in
    $FORMATTED_LIST)
        SERVICE_ID=$SERVICE_ID_SELECTED
        CUSTOMER_MENU;;
    *)
        MAIN_MENU 'Please enter a valid option.' ;;
esac";}


CUSTOMER_MENU(){
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nWhat's your name?"
read CUSTOMER_NAME
INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
echo -e "\nWhat time would you like to book, $CUSTOMER_NAME?"
read SERVICE_TIME
APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id,name,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME', '$SERVICE_TIME')")
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')
echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU