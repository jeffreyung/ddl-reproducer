#! /bin/bash
#
# Retrieves the DDL of a table.

# Prints the usage message if the provided argument or flag is invalid.
print_usage() {
	echo "Usage: $0 <project_id> <dataset> <table>"
}

# Converts an array to a string
function join {
	local IFS="$1"; shift; echo "$*";
}

# Checks if the required arguments are provided.
if [[ $1 == "" || $2 == "" || $3 == "" ]]
then
	print_usage
	exit 0
fi

# Initialize new variables for arguments.
project=$1
dataset=$2
table=$3

# Get table definitions in a json format.
table_info=$(bq show --format=prettyjson $1:$2.$3)

# The table type can be either a 'table' or 'view'.
table_type=$(echo "$table_info" | jq '.type')

if [[ $table_type == "\"TABLE\"" ]]
then
	col_names=( $(echo "$table_info" | jq '.schema.fields[].name') )
	col_types=( $(echo "$table_info" | jq '.schema.fields[].type') )
	col_modes=( $(echo "$table_info" | jq '.schema.fields[].mode') )
	partitioning_field=$(echo "$table_info" | jq '.timePartitioning.field')
	partitioning_type=$(echo "$table_info" | jq '.timePartitioning.type')  
	clustering_fields=( $(echo "$table_info" | jq '.clustering.fields[]') )

	# Formatting string to a valid create statement (this will be messy).
	cols=()
	for i in "${!col_names[@]}"; do
		cols+="${col_names[$i]}-$(echo "${col_types[$i]}" | sed "s/INTEGER/INT64/" \
			| sed "s/FLOAT/FLOAT64/" | sed "s/BOOLEAN/BOOL/") "
	done

	joined_cols=$(join ", " ${cols[@]})
	joined_cols=${joined_cols//\"/}
	joined_cols=${joined_cols//\-/ }
	joined_clusters=$(join ", " $clustering_fields)
	joined_clusters=${joined_clusters//\"/}

	# Outputs the create statement for the table.
	echo "CREATE OR REPLACE TABLE \`$project.$dataset.$table\` ($joined_cols) \
		CLUSTER BY $joined_clusters;"
elif [[ $table_type == "\"VIEW\"" ]]
then
	query=$(echo "$table_info" | jq '.view.query')
	query=${query//\"/}
	legacy=$(echo "$table_info" | jq '.view.useLegacySql')
	if [[ $legacy == "false" ]]
	then
		echo "#standardSQL"
	else
    		echo "#legacySQL"
	fi
	echo "CREATE OR REPLACE VIEW \`$project.$dataset.$table\` AS ${query};"
else
	echo "Invalid table or view. Please check the syntax."
fi
