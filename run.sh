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

cmds()
{
    echo "Available args:"
    echo
   #echo ${FUNCNAME}
    bash -c "source '$SCRIPT_NAME' TRUE; compgen -A function" 2>/dev/null | grep -vw cmds
}

if [ $# = 0 ]; then
    echo "To see available arguments use this:\n\n$0 cmds"
    exit 1
fi

if [ $1 != "cmds" ]; then
    set -x
fi

$1
