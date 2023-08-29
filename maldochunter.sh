#!/bin/bash
# Requirements:
# -Python3.7
# -sudo apt install python3-tk python3-pip
# -sudo pip install oletools
# -Create logs path on /var/log/olerec_p1
# -Create a Daemon, so you can run it on background
# ---sudo cp olerec /usr/bin/.
# ---sudo vim /etc/systemd/system/olerec.service
# -----[Unit]
# -----Description=Recursive OLE
# -----
# -----[Service]
# -----ExecStart=/usr/bin/olerec
# -----Restart=on-failure
# -----
# -----[Install]
# -----WantedBy=multi-user.target
# ---sudo systemctl start olerec

log_path="/var/log/olerec_p2"
target_path="/mnt/target_path/"
extensions_of_interest="extensions_of_interest.txt"
general_log="general_log.log"

OutputCheck () {
# Check the file for External References and log the files location and name
if [[ $cond1 == *"1"* ]]; then
	underline_manipulation=`echo "$files_path" | tr \/ _ `
	echo $underline_manipulation
	touch "$log_path/$counter - $underline_manipulation.log"
	echo "=================================================================" >> "$log_path/$counter - $underline_manipulation.log"
	echo "### HAVE EXTERNAL FILE REFERENCE:">>"$log_path/$counter - $underline_manipulation.log"
	oleobj $files_path | grep -i external >>"$log_path/$counter - $underline_manipulation.log"
	echo "=================================================================">>"$log_path/$counter - $underline_manipulation.log"
fi

# Check the file for Macros and copy ONLY the Macro content to Log
if [[ $cond2 == *"Yes"* ]]; then
	underline_manipulation=`echo "$files_path" | tr \/ _ `
	echo $underline_manipulation
	touch "$log_path/$counter - $underline_manipulation.log"
	echo "=================================================================" >> "$log_path/$counter - $underline_manipulation.log"
	echo "### FILE HAVE MACRO" >> "$log_path/$counter - $underline_manipulation.log"
	olevba $files_path >> "$log_path/$counter - $underline_manipulation.log"
	echo "=================================================================" >> "$log_path/$counter - $underline_manipulation.log"
fi
}

# Create a counter to start
counter=0

# Manipulation of names and special chars on it (you're welcome)
OIFS="$IFS"
IFS=$'\n'

# Check for existing files in case of stop in the middle of the process. It will save you a lot of time.
if test -f "$log_path/$general_log"; then
	echo "FILE $log_path/$general_log ALREADY EXISTS, ENTERING IN RESTAURATION MODE"
	new_id=$(tail -n 1 $log_path/$general_log | awk '{ print $4 }')
	# Check the last log ID in "counter", it will know where to start
	counter=$new_id
	echo "New counter ID: $counter"
	# Check the last file readed in log
	id_chars=$(echo -n "$new_id" | wc -c)
	echo "ID $new_id have $id_chars chars."
	# There are a static number of chars that the script will check. NOTE: I am translating this script to english, so you do not need to learn portuguese, so it can be changed.
	pattern_chars="17"
	echo "Chars pattern: $pattern_chars"
	# Extract the counter from file name
	start_chars=$(expr $pattern_chars + $id_chars)
	echo "Chars 17 + ID: $start_chars"
    # Remove the string of the last readed file, in case of corruption
	last_readed_file=$(tail -n 1 $log_path/$general_log | tail -c +$start_chars | head -c -19)
	echo "Last file readed before parenthesis: $last_readed_file"
	last_readed_file_space=`echo "$last_readed_file" | tr " " "\ "`
	echo "Last readed file: $last_readed_file_space"
	# Check the number of lines from the original file
	total_lines=$(wc -l $log_path/$extensions_of_interest | awk '{ print $1 }')
	echo "Original file have $total_lines lines."
    # Check the total file count versus the total files readed
	missing_lines=$(expr $total_lines - $new_id)
	echo "Missing $missing_lines files to check."
    # Cat the last lines of the file, the unreaded files.
	new_input_lines=$(tail -n $missing_lines $log_path/$extensions_of_interest > $log_path/extensions_of_interest_tmp.txt)
	echo "New temp file created."
    # Internal temp file
	extensions_of_interest="$diretorios_logs/extensions_of_interest_tmp.txt"
	echo "New extensions of interest: $extensions_of_interest"
else
	echo "Log files not found. Starting new process."
	touch "$log_path/$general_log"
    # Read all paths and subpaths getting only the NEXT file types, this creates the extensions of interest, make good choices here
    # CHANGE THIS PART IF YOU WANNA OTHER FILE TYPES
	find $target_path | grep '.xls\|\.doc' > $log_path/$extensions_of_interest
fi

# This FOR reads the files with desired extensions
for files_path in $(cat $log_path/$extensions_of_interest)
# Find the files which can contain malicious content
do
	let counter++

    # CHANGE THIS PART IF YOU WANNA OTHER FILE TYPES
	if [[ $files_path == *".xls"* || *".doc"* ]]; then
        files_path_space=`echo "$files_path" | tr " " "\ "`
        echo $files_path_space
        date_time=$(date +'%Y/%m/%d_%HH:%M:%S')
		echo "=================================================================" >> "$log_path/general_log.log"
		echo "Date and Time: $date_time" >> "$log_path/general_log.log"
		echo "File ID number $counter ($files_path) begins to be checked." >> "$log_path/general_log.log"
		cond0=`oleid $files_path | grep -i 'external\|Macros'`
		cond1=`echo $cond0 | grep -i external`
		cond2=`echo $cond0 | grep -i Macros`
		OutputCheck
	fi
done
IFS="$OIFS"
