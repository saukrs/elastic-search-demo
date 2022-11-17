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
   #echo ${FUNCNAME}
    bash -c "source '$SCRIPT_NAME'; compgen -A function" | grep -v cmd_list
}

set -x
set_index_replicas
