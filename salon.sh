#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Define psql command with options
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Function to display services with numbered list
display_services() {
    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    while IFS='|' read -r service_id service_name; do
        echo "$service_id) $service_name"
    done <<< "$SERVICES"
}

# Display services
display_services

# Read the user's choice
while true; do
    read SERVICE_ID_SELECTED
    if [[ $(echo "$SERVICES" | grep "^$SERVICE_ID_SELECTED") ]]; then
        break
    fi
    echo -e "\nTry again\n"
    display_services
done

# Fetch service name based on user's choice
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if the phone number exists in the customers table
PHONE_EXISTS=$($PSQL "SELECT EXISTS (SELECT 1 FROM customers WHERE phone = '$CUSTOMER_PHONE')")
if [[ "$PHONE_EXISTS" == "t" ]]; then
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name from customers WHERE phone = '$CUSTOMER_PHONE'")
    echo "What time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    echo "I have put you down for $SERVICE_TIME, $CUSTOMER_NAME."
else
    echo "I don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    echo "What time would you like your $SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    echo "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone = '$CUSTOMER_PHONE'")
fi

$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')"
