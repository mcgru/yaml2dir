#!/bin/bash

### Depends on:
### gron  - tool to transform JSON into discrete, greppable assignments
### python3, and its modules yaml,json

set -e
CWD=$(dirname $(realpath "$0"))
SRC=${1:?need folder name as arg1}
TGT=${2}
[ ! "$TGT" ] && TGT=/dev/stdout

yaml2json(){
 python3 -c "import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin.read()) , indent=2, sort_keys=False ))"
}
json2yaml(){
 python3 -c "import sys,yaml,json; print(yaml.dump(json.loads(sys.stdin.read()) , indent=2, sort_keys=False ))"
}


dir2gron(){
local SRC=${1:-$SRC}
##echo "json = [];"
find "$SRC" -type f | while read F; do
  B=$(basename "$F")
  D=$(dirname  "$F")
  J=$( sed -r 's@\.([0-9]+)$@[\1]@; s@\.([0-9]+)/@[\1]@g; s@/@.@g' <<<"${D#$SRC/}" | sed "s@^root@json@" )    #)'
#  J="json${J}"
  if [ "$B" == .content ]; then
    echo -n "$J = "
  else
    echo -n "$J.$B = "
  fi
  cat "$F" | sed 's/"/\\"/g; s/^/"/; s/$/" ;/'
done
}

dir2gron "$SRC" | gron -u | json2yaml > "$TGT"
