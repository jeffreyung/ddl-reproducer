#! /bin/bash
#
# Retrieves the DDL of a table 

print_usage() {
	echo "Usage: $0 <project_id> <dataset> <table>"
}

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

TABLE_INFO=$(bq show --format=prettyjson $1:$2.$3)
echo $TABLE_INFO
