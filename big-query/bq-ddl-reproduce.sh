#! /bin/bash
#
# retrieves the DDL of a table.

# prints the usage message if the provided argument or flag is invalid.
print_usage() {
	echo "Usage: $0 <project_id> <dataset> <table>"
}

# checks if the required arguments are provided.
if [[ $1 == "" || $2 == "" || $3 == "" ]]; then
	print_usage
	exit 0
fi

#while getopts 'd:t:' flag; do
#	case "${flag}" in
#		d) dataset="${OPTARG}" ;;
#		t) table="${OPTARG}" ;; 
#		*) print_usage
#			exit 1 ;;
#       	esac
#done

table_info=$(bq show --format=prettyjson $1:$2.$3)
col_names=( $(echo $table_info | jq '.schema.fields[].name') )
col_types=( $(echo $table_info | jq '.schema.fields[].type') )
col_modes=( $(echo $table_info | jq '.schema.fields[].mode') )    
printf '%s\n' "${col_names[@]}"
printf '%s\n' "${col_types[@]}"
printf '%s\n' "${col_modes[@]}"
