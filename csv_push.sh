input_csv=$1
proc_count=0
declare -A activity
activity[Analysis]=12
activity[Development]=9
activity[QA]=10
activity[Meeting]=16
activity["ResearchDesign"]=14
activity[General]=13
activity["SupportResearch"]=17

echo "Pushing record to https://track.infoimageinc.com/:"
echo "Are you sure? (Y/n)"
read ans
[[ "$ans" =~ ^(Y|y)$ ]] || exit 0
while read -r line; do
    line=`echo "$line" | tr -d '\r'`
    prefix=`echo "$line" | cut -d',' -f1`
    [ "`echo $prefix | tr [A-Z] [a-z]`" = 'prefix' ] && continue
    JeffNo=`echo "$line" | cut -d',' -f2`
    Date=`echo "$line" | cut -d',' -f3`
    ActivityOPT=`echo "$line" | cut -d',' -f4 | tr -d "/& "`
    Hour=`echo "$line" | cut -d',' -f5`
    Comment=`echo "$line" | cut -d',' -f6`

    activity_id=${activity[$ActivityOPT]}
    if [ -z "$activity_id" ]; then
        echo "Could not find activity ID for $ActivityOPT"
        continue
    fi
    Date=${Date:0:4}-${Date:4:2}-${Date:6:2}

    id="issue_id"
    if [ -z "$JeffNo" ]; then
        id="project_id"
        JeffNo=2
    fi

    JSON="{\"time_entry\":{\"$id\":\"$JeffNo\",\"spent_on\":\"$Date\",\"hours\":\"$Hour\",\"activity_id\":\"$activity_id\",\"comments\":\"$Comment\"}}"
    # response=`curl -u 'amirR:oradinplus' -X POST -H "Content-Type: application/json" -d "$JSON" -w "%{http_code}\n" "https://track.infoimageinc.com/time_entries.json" --silent -o /dev/null`
    if [ "$response" != "201" ]; then
        echo "Could not send entry for record: Prefix: $prefix, Jef: $JeffNO, Date: $Date, Activity: $ActivityOPT"
        continue
    fi
    printf "."
    ((proc_count++))
done < $input_csv
echo ""

