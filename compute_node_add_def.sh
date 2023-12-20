#!/bin/bash

echo "Now you are adding Node Definition !!!"

read -p "Enter the start node no: " start_node_no
read -p "Enter the last node no: " last_node_no


#cn_prefix="cn"
ip_network="172.10.3."

# Check if mac.txt file exists
if [ ! -f "mac.txt" ]; then
  echo "Error: mac.txt file not found!"
  exit 1
fi

for ((i = start_node_no; i <= last_node_no; i++)); do
  # Read MAC address from mac.txt
  mac=$(sed -n "${i}p" mac.txt)

  if [ -z "$mac" ]; then
    echo "Error: MAC address not found for node $i in mac.txt"
    exit 1
  fi

  a=$((i))
  b=10
  c=100

  if [ $a -lt $b ]; then
    cn_prefix="cn00"
  elif [ $a == $b ] || [ $a -gt $b ] || [ $a -lt $c ]; then
    cn_prefix="cn0"
  elif [ $a == $c ] || [ $a -gt $c ]; then
    cn_prefix="cn"
  else
    echo "None of the conditions met"
    exit 1
  fi

  # Add node definition
  mkdef -t node "${cn_prefix}${i}" groups=compute,all mgt=ipmi ip="${ip_network}${i}" mac="$mac" netboot=xnba postscripts="confignetwork -s"
done
