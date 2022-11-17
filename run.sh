#!/usr/bin/env sh

 SCRIPT_NAME="$0"

create_index()
{
    INDEX_NAME=${1:-sampleindex}
    curl -XPUT "localhost:9200/$INDEX_NAME?pretty"
}

list_indices()
{
    curl -XGET "localhost:9200/_cat/indices?v"
}

list_nodes()
{
    curl -XGET "localhost:9200/_cat/nodes?v"
}

list_shards()
{
    curl -XGET "localhost:9200/_cat/shards?v"
}

set_index_replicas()
{
    INDEX_NAME=${1:-sampleindex}
    REPLIC_NUM=${2:-2}
    curl -XPUT "localhost:9200/$INDEX_NAME/_settings?pretty" \
      -H "Content-Type: application/json; charset=utf-8" \
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
    echo "Available sub-commands:"
    echo
   # TODO: Investigate -- unsure why I need $1 here (any value would do).
   # Without it the `source ...` fails in a strange way:
    bash -c "source '$SCRIPT_NAME' TRUE; compgen -A function" 2>/dev/null | grep -vw cmds
}

if [ $# = 0 ]; then
    echo "To see available sub-commands use this:\n\n$0 cmds"
    exit 1
fi

CMD=$1; shift

if [ $CMD != "cmds" ]; then
    set -x
fi

$CMD $@
