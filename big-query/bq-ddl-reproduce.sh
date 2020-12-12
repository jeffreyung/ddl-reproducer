#! /bin/bash
#
# retrieves the DDL of a table.

# prints the usage message if the provided argument or flag is invalid.
print_usage() {
	echo "Usage: $0 <project_id> <dataset> <table>"
}

# converts an array to a string
function join {
	local IFS="$1"; shift; echo "$*";
}

# checks if the required arguments are provided.
if [[ $1 == "" || $2 == "" || $3 == "" ]]; then
	print_usage
	exit 0
fi

project=$1
dataset=$2
table=$3
table_info=$(bq show --format=prettyjson $1:$2.$3)
table_type=( $(echo $table_info | jq '.type') )
col_names=( $(echo $table_info | jq '.schema.fields[].name') )
col_types=( $(echo $table_info | jq '.schema.fields[].type') )
col_modes=( $(echo $table_info | jq '.schema.fields[].mode') )
partitioning_field=$(echo $table_info | jq '.timePartitioning.field')                                                   partitioning_type=$(echo $table_info | jq '.timePartitioning.type')  
clustering_fields=( $(echo $table_info | jq '.clustering.fields[]') )

cols=()
for i in "${!col_names[@]}"; do
	cols+="${col_names[$i]}-$(echo "${col_types[$i]}" | sed "s/INTEGER/INT64/" | sed "s/FLOAT/FLOAT64/" | sed "s/BOOLEAN/BOOL/") "
done

joined_cols=$(join ", " ${cols[@]})
joined_cols=${joined_cols//\"/}
joined_cols=${joined_cols//\-/ }

joined_clusters=$(join ", " $clustering_fields)
joined_clusters=${joined_clusters//\"/}
echo "CREATE OR REPLACE TABLE \`$project.$dataset.$table\` ($joined_cols) CLUSTER BY $joined_clusters;"
