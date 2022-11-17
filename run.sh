#!/usr/bin/env sh

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

set -x
set_index_replicas
