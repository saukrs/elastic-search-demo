#!/usr/bin/env sh

 SCRIPT_NAME="$0"

set_index_replicas()
{
    INDEX_NAME=${1:-sampleindex}
    REPLIC_NUM=${2:-2}
    curl -XPUT 'localhost:9200/$INDEX_NAME/_settings?pretty' \
      -H 'Content-Type: application/json; charset=utf-8' \
      -d @- <<- \
	----------------------------------------------------------
	{
	  "settings": {
	    "index": {
	      "number_of_replicas": $REPLIC_NUM
	    }
	  }
	}
	----------------------------------------------------------
}

cmds()
{
   #echo ${FUNCNAME}
    echo "Available args:"
    echo
   # TODO: Investigate -- unsure why I need $1 here (any value would do).
   # Without it the `source ...` fails in a strange way:
    bash -c "source '$SCRIPT_NAME' TRUE; compgen -A function" 2>/dev/null | grep -vw cmds
}

if [ $# = 0 ]; then
    echo "To see available arguments use this:\n\n$0 cmds"
    exit 1
fi

if [ $1 != "cmds" ]; then
    set -x
fi

CMD=$1; shift; $CMD $@
