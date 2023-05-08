#!/bin/bash

### Depends on:
### gron  - tool to transform JSON into discrete, greppable assignments
### python3, and its modules yaml,json

set -e
CWD=$(dirname $(realpath "$0"))
SRC=${1:?need yaml-file as arg1}
TGT=${2}
if [ "$SRC" == "-" ] ; then
  SRC=./yaml2dir.tmp
  cat /dev/stdin > $SRC
  trap "rm $SRC" INT EXIT QUIT
fi
[ ! "$TGT" ] && TGT="${SRC}.dir"  ||:

yaml2json(){
 python3 -c "import sys,yaml,json; print(json.dumps(yaml.safe_load(sys.stdin.read()) , indent=2, sort_keys=False ))"
}
json2yaml(){
 python3 -c "import sys,yaml,json; print(yaml.dump(json.loads(sys.stdin.read()) , indent=2, sort_keys=False ))"
}

gron2dir(){
 local TGT=${1:-$TGT}
cat \
| sort -u \
| grep -P '=\s*[^\[\{\s]+' \
| sed 's/;$//' \
| while read L; do
##echo "L='$L'" 1>&2
  F=$( sed -r 's/\s*=.*//' <<<"$L" | tr '[].' '/' | sed -r 's@/([0-9]+)/@.\1/@g' | sed "s@^json.@$TGT/root.@" )  #)'
  C=$( sed -r 's/.*=\s*//' <<<"$L" | sed 's/^"//; s/"$//;' )
##echo "L='$L'; F='$F'" 1>&2
  if grep -q '/$' <<<"$F" ; then
    F="$F/.content"
  fi
  mkdir -p $(dirname "$F")
  echo "$C" > "$F"
done
}

yaml2json < "$SRC" | gron | gron2dir "$TGT"
