#!/bin/bash
#
#  Run smoke-test.sh on all endpoints

BASE=$(cd $(dirname $0)/..;pwd)
SMOKE_OUTPUT=$(mktemp)
RESULTS=$(mktemp)

SOUND_ENDPOINT_RE="0 failed, 0 skipped"

cat $BASE/etc/endpoints | while read name type url; do
    bin/smoke-test.sh -f $url > $SMOKE_OUTPUT
    echo -e "$name\t$type\t$(tail -1 $SMOKE_OUTPUT)" >> $RESULTS
done

column -t $RESULTS -s $'\t' > $SMOKE_OUTPUT
rm $RESULTS

if grep -q "$SOUND_ENDPOINT_RE" $SMOKE_OUTPUT; then
    echo
    echo "SOUND ENDPOINTS"
    echo
    grep "$SOUND_ENDPOINT_RE" $SMOKE_OUTPUT
fi

if grep -v -q "$SOUND_ENDPOINT_RE" $SMOKE_OUTPUT; then
    echo
    echo "PROBLEMATIC ENDPOINTS"
    echo
    grep -v "$SOUND_ENDPOINT_RE" $SMOKE_OUTPUT
fi

if grep -q "\[\*\]" $SMOKE_OUTPUT; then
    echo
    echo "  [*]  Indicates one or more known issues with the software."
fi

rm $SMOKE_OUTPUT
