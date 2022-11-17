#!/usr/bin/env sh

 SCRIPT_NAME="$0"

set_index_replicas()
{
    curl -XPUT 'localhost:9200/sampleindex/_settings?pretty' \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d @- <<- \
	----------------------------------------------------------
	{
	  "settings": {
	    "index": {
	      "number_of_replicas": 2
	    }
	  }
	}
	----------------------------------------------------------
}

cmd_list()
{
    echo "Available args:"
    echo
   #echo ${FUNCNAME}
    bash -c "source '$SCRIPT_NAME' 'cmd_list'; compgen -A function" | grep -v cmd_list
}

if [ $# = 0 ]; then
    echo "To see available arguments use this:\n\n$0 cmd_list"
    exit 1
fi

set -x
$1
