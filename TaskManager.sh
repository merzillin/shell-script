#!/bin/bash

generate_id() {
  date +%s%N | sha1sum | cut -c1-3
}

AddTask() {
    read -p "Enter Task ID: " taskId
    read -p "Enter Task Details: " taskDetails
    read -p "Notes: " taskNotes

createdOn=$(date +"%d-%m-%Y %I:%M:%S %p")
taskNotes=${taskNotes:-"-"}

uniqueId=$(generate_id)

echo "$uniqueId;$taskId;$taskDetails;$taskNotes;$createdOn;-;-;-;-" >> sample.txt
}

DisplayAll() {
  read -p "Enter Task ID (partial allowed): " id

  awk -F';' -v key="$id" '
    BEGIN {
      found=0
    }
    index($2, key) > 0 {
      found=1
      print "\n----------------------------------"
      printf "Unique ID  : %s\n", $1
      printf "Task ID    : %s\n", $2
      printf "Details    : %s\n", $3
      printf "Notes      : %s\n", $4
      printf "Created At : %s\n", $5
      printf "DEV Status : %s\n", $6
      printf "QC Status  : %s\n", $7
      printf "UAT Status : %s\n", $8
      printf "Client UAT : %s\n", $9
      print "----------------------------------"
    }
    END {
      if (!found) {
        print "No record found for Task ID:", key
      }
    }
  ' sample.txt
}



UpdateStatus() {

  DisplayAll
  read -p "Enter Unique ID: " id

  oldRecord=$(awk -F';' -v uId="$id" '$1==uId' sample.txt)

  if [[ -z "$oldRecord" ]]; then
    echo "No record found for Unique ID: $id"
    return
  fi

  echo -e "a. DEV\nb. QC\nc. UAT\nd. Client UAT"
  read -p "Choose option: " op
  read -p "Date & Time (press Enter for current): " timestamp

  currentTimeStamp=$(date +"%d-%m-%Y %I:%M:%S %p")
  timestamp=${timestamp:-"$currentTimeStamp"}

  IFS=';' read -r \
    uId taskId details notes createdAt \
    devStatus qcStatus uatStatus clientUatStatus <<< "$oldRecord"

  case $op in
    a) devStatus="$timestamp" ;;
    b) qcStatus="$timestamp" ;;
    c) uatStatus="$timestamp" ;;
    d) clientUatStatus="$timestamp" ;;
    *) echo "Invalid option"; return ;;
  esac

  updatedRecord="$uId;$taskId;$details;$notes;$createdAt;$devStatus;$qcStatus;$uatStatus;$clientUatStatus"

  awk -F';' -v uId="$id" -v newLine="$updatedRecord" '
    BEGIN { OFS=";" }
    $1==uId { print newLine; next }
    { print }
  ' sample.txt > sample.tmp && mv sample.tmp sample.txt

  echo "Task status updated successfully!"
}


UpdateById() {
  read -p "Enter Task ID to update: " id

  # Check if record exists
  oldRecord=$(awk -F';' -v taskId="$id" '$2==taskId' sample.txt)

  if [[ -z "$oldRecord" ]]; then
    echo "No record found for Task ID: $id"
    return
  fi

  echo "Current Record:"
  echo "$oldRecord"
  echo

  # Split existing values
  IFS=';' read -r uId oldId oldDetails oldNotes oldDate devStatus qcStatus uatStatus clientUatStatus<<< "$oldRecord"

  read -p "Enter new Task Details [${oldDetails}]: " newDetails
  read -p "Enter new Notes [${oldNotes}]: " newNotes

  # Keep old values if empty
  newDetails=${newDetails:-"$oldDetails"}
  newNotes=${newNotes:-"$oldNotes"}

  updatedRecord="$uId;$oldId;$newDetails;$newNotes;$oldDate;$devStatus;$qcStatus;$uatStatus$clientUatStatus"

  # Update file safely using temp file
  awk -F';' -v taskId="$id" -v newLine="$updatedRecord" '
    BEGIN { OFS=";" }
    $2==taskId { print newLine; next }
    { print }
  ' sample.txt > sample.tmp && mv sample.tmp sample.txt

  echo "Task updated successfully!"
}

Export() {

}



while true; do
  echo -e "Menus
  \n1. Add Task\n2. Display Task Details\n3. Update Status\n4. Update Task By Id\n5. Exit\n6. Export"
  read -p "Enter your option: " option

  echo "Option $option"

  case $option in
    1) AddTask ;;
    2) DisplayAll ;;
    3) UpdateStatus ;;
    4) UpdateById ;;
    5) echo "Exiting..."; break ;;
    6) Export ;;
    *) echo "Invalid option" ;;
  esac

  echo
done
