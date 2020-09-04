
#!/usr/bin/bash

help() {
    echo "REDMINE COMMAND LINE"
    echo ""
    echo "SYNOPSIS"
    echo "      rcn <command> <option> <value>"
    echo "      rcn <command> <option> <value> [<option> <value>...]"
    echo "      version: 1.0"
    echo ""
    echo "COMMANDS"
    echo "      First parameter is taken as command to select a mode."
    echo "      a = add"
    echo "          Used to add hour record. Need atleat one activity hour option."
    echo "          possible options: -P(can be blank), -J(can be blank), -D(today's date if blank),"
    echo "                            -C(can be blank), -a|d|q|m|r|g|s|u(at least one needed)"
    echo "          Example:"
    echo "              rcl a -P fffcms1 -J 123456 -a 2 -d 4"
    echo "                  Adds record for today"
    echo "              rcl a -g 2 -D 'yesterday'"
    echo "                  Adds record for 'General' for yesterday"
    echo "      r = remove"
    echo "          Used to remove a record. One record can be removed at a time"
    echo "          possible options: -N, -D, -P"
    echo "          Multiple options can be selected to create a filter"
    echo "          Example:"
    echo "              rcl r -D 'today' -P testms1"
    echo "                  All the records with prefix testms1 of today will be deleted"
    echo "              rcl r -D 'today' -N 2"
    echo "                  Todays last 2 records will be deleted"
    echo "      u = update"
    echo "          Used to assign a Jeff number for a Prefix."
    echo "          possible options: -P(needed), -J(needed), -M"
    echo "          Example:"
    echo "              rcl u -P fffcms2 -J 99999 -M 08"
    echo "                  It will add jeff number to all records with prefix fffcms2 for October"
    echo "      v = view"
    echo "          Used to view records. This is default if any command is not selected"
    echo "          possible options: -P, -M, -J, -D"
    echo "          Multiple options can be selected to create a filter."
    echo "          If no option is selected then todays record will be showed."
    echo ""
    echo "OPTIONS"
    echo "  All Options are immune to position. This means after command you can set options in any position. They will"
    echo "  not change their behavior with their position."
    echo "      -P <Prefix>"
    echo "          Uniq prefix for a job."
    echo "      -J <Jeff Number>"
    echo "          Jeff Number. Value should be a number. Can be assigned for a prefix in update mode."
    echo "      -D <date>"
    echo "          Value can be any unix date string. Possible values: MM/DD | MM/DD/YY[YY] | today | yesterday"
    echo "      -M <month>"
    echo "          Value to select a month. Possible values: MM | MMYY | MM/YY"
    echo "      -C <comment>"
    echo "          String to set a comment."
    echo "      -N <number>"
    echo "          Number of records to delete. Only used for remove mode."
    echo "      -h"
    echo "          View help. If this option is selected then program will only show help and exit"
    echo ""
    echo "  Options to set activity hour"
    echo "      These options are same as redmine's activity. Multiple options can be selected at a same time but for each"
    echo "      option one record will be created"
    echo "      -a <hour> analysis"
    echo "      -d <hour> development"
    echo "      -q <hour> QA"
    echo "      -m <hour> meeting"
    echo "      -r <hour> research & design"
    echo "      -g <hour> General"
    echo "      -s <hour> Support/Research"
    echo "      -u <hour> Mapping/Sow updates"
    echo ""
    echo ""
    echo "Created By: Amir Rahat"
    echo "Created Date: 09/04/2020"
}

command=$1
if [ $# -eq 0 ]; then
    command=v
elif [[ $command =~ ^- ]]; then
    command=v
elif [[ $command =~ ^(a|u|r|v) ]]; then
    shift
else
    echo "Error: Invalid Command"
    exit 1
fi

csv_dir=/home/$USER/test/rcl ## Test value <<----------------- update in release
declare -a activity hour
activity=(Analysis Development QA Meeting "Research & Design" General "Support/Research" "Mapping/Sow Update")
yyyymmdd=`date '+%Y%m%d'`

while getopts 'P:J:D:M:C:N:a:d:q:m:r:g:s:u:A:hs:' opt; do
    case $opt in
        P)  prefix=$OPTARG ;;
        J)  jeff=$OPTARG
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: JEFF Number is not correct"
                exit 1
            fi
            ;;
        D)  date=$OPTARG
            yyyymmdd=`date '+%Y%m%d' -d "$date" 2> /dev/null`
            if [ $? -ne 0 ]; then
                echo "Error: Wrong date format"
                exit 1
            fi
            ;;
        M)  month=$OPTARG
            if [[ $month =~ ^[0-9]{2}$ ]]; then 
                month=`date '+%y'`$month
            elif [[ $month =~ ^[0-9]{4}$ ]]; then
                month=${month:2:2}${month:0:2}
            elif [[ $month =~ ^[0-9]{2}/[0-9]{2}$ ]]; then
                month=`echo $month | cut -d'/' -f2``echo $month | cut -d'/' -f1`
            elif [[ $month =~ ^[0-9]{1}/[0-9]{2}$ ]]; then
                month=`echo $month | cut -d'/' -f2`0`echo $month | cut -d'/' -f1`
            elif [[ $month =~ ^[0-9]{2}/[0-9]{1}$ ]]; then
                month=0`echo $month | cut -d'/' -f2``echo $month | cut -d'/' -f1`
            elif [[ $month =~ ^[0-9]{1}/[0-9]{1}$ ]]; then
                month=0`echo $month | cut -d'/' -f2`0`echo $month | cut -d'/' -f1`
            else
                echo "Error: Wrong value for month: $month. Should be MM|MMYY|MM/YY"
                exit 1
            fi
            ;;
        C)  comment=$OPTARG ;;
        N)  number=$OPTARG 
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Number: $OPTARG is not correct"
                exit 1
            fi
            ;; 
        a)  hour[0]=$OPTARG
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;; ##Analysis
        d)  hour[1]=$OPTARG   ##development
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        q)  hour[2]=$OPTARG   ##QA
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        m)  hour[3]=$OPTARG   ##Meeting
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        r)  hour[4]=$OPTARG   ##Research & Design
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        g)  hour[5]=$OPTARG   ##general
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        s)  hour[6]=$OPTARG   ##Support/Research
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        u)  hour[7]=$OPTARG   ##Mapping/Sow Updates
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Hour: $OPTARG is not correct"
                exit 1
            fi
            ;;
        A)  addjeff=$OPTARG ;;
        h) help; exit 0 ;;
        \?)
            echo "Error: Unknown Switch: $opt"
            help
            exit 1
            ;;
        :)
            echo "Error: Switch without value: $opt"
            help
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

# Check directory and file
if [ ! -d $csv_dir ]; then 
    echo "Creating working directory: $csv_dir"
    mkdir $csv_dir
    if [ $? -ne 0 ]; then 
        echo "Could not create working directory: $csv_dir"
        exit 1
    fi
fi
yyyy=${yyyymmdd:0:4}
yy=${yyyymmdd:2:2}
mm=${yyyymmdd:4:2}
dd=${yyyymmdd:6:2}


# execute options
if [[ $command =~ ^a ]]; then
    csv_file=$csv_dir/rcl_${USER}_timelog_$yy$mm.csv

    if [ ${#hour[@]} -eq 0 ]; then
        echo "Error: Need hour switch with Add command"
        help
        exit 1
    fi

    if [ ! -s $csv_file ]; then
        echo "Creating new csv file: $csv_file"
        echo "Prefix,JeffNo,Date,Activity,Hour,Comment" > $csv_file
    fi

    # Find where to insert
    insert_number=0
    while read -r line; do
        line_date=`echo $line | cut -d',' -f3`
        [[ $line_date =~ ^[0-9]{8}$ && $line_date -gt $yyyymmdd ]] && break
        insert_number=`expr $insert_number + 1`
    done < $csv_file

    # Insert
    echo "Prefix:$prefix Jeff Number:$jeff Date:$mm/$dd/$yyyy Comment:$comment"
    for i in ${!hour[@]}; do
        if grep "$prefix,$jeff,$yyyymmdd,${activity[$i]},${hour[$i]},$comment" $csv_file &> /dev/null; then
            echo "    Skipping repeated entry: ${activity[$i]} --> ${hour[$i]}"
            continue
        fi
        sed -i -s $insert_number's:$:\n'"$prefix,$jeff,$yyyymmdd,${activity[$i]},${hour[$i]},$comment"':g' $csv_file
        insert_number=`expr $insert_number + 1`
        echo "    Added Record: ${activity[$i]} --> ${hour[$i]}"
    done

elif [[ $command =~ ^u ]]; then
    if [ -z "$prefix" -o -z "$jeff" ]; then
        echo "For update mode please provide -P <prefix> and -J <JeffNumber>"
        exit 1
    fi

    if [ -n "$month" ]; then
        csv_file=$csv_dir/rcl_${USER}_timelog_$month.csv
    else
        csv_file=`ls $csv_dir/rcl_${USER}_timelog_????.csv`
    fi

    if [ -z "$csv_file" ]; then
        echo "No record found"
        exit 0
    fi

    total_line=0
    for cfile in $csv_file; do
        updated=""
        for i in `grep -n "^$prefix" $cfile | cut -d':' -f1`; do
            record=`sed -n ${i}p $cfile`
            vr=`echo "$record" | cut -d',' -f3-`
            sed -i -s $i's:^.*$:'"$prefix,$jeff,$vr"':' $cfile
            total_line=`expr $total_line + 1`
            updated="y"
        done
        if [ -n "$updated" ]; then
            um=`echo ${cfile##*/} | cut -d'_' -f4 | cut -d'.' -f1`
            echo "Updated for month: ${um:2:2}/20${um:0:2}"
        fi
    done

    if [ $total_line -eq 0 ]; then
        echo "No record found"
    else
        echo "Total record modified: $total_line"
    fi

elif [[ $command =~ ^r ]]; then
    if [ -z "$date" -o -z "$number" ]; then
        echo "Please select -D<date> or/and -N<number> option"
        exit 1
    fi

    csv_file=$csv_dir/rcl_${USER}_timelog_$yy$mm.csv

    ## get line numbers to delete
    declare -a ln
    n=0
    while read -r line; do
        n=`expr $n + 1`
        if [ `echo $line | cut -d',' -f3` = $yyyymmdd ]; then 
            if [ -n "$prefix" ]; then
                [ `echo $line | cut -d',' -f1` = $prefix ] && ln+=($n)
            else
                ln+=($n)
            fi
        fi
    done < $csv_file
    
    length=${#ln[@]}
    if [ $length -eq 0 ]; then
        echo "No record found"
        exit 0
    fi

    ## delete numbers
    length=`expr $length - 1`
    while [ $length -gt -1 ]; do
        line_no=${ln[$length]}

        [ -n "$number" -a "$number" = 0 ] && break
        [ -n "$number" ] && number=`expr $number - 1`

        record=`sed -n ${line_no}p $csv_file`
        vp=`echo "$record" | cut -d',' -f1`
        [ "$vp" = 'Prefix' ] && continue
        vj=`echo "$record" | cut -d',' -f2`
        vd=`echo "$record" | cut -d',' -f3`
        va=`echo "$record" | cut -d',' -f4`
        vh=`echo "$record" | cut -d',' -f5`
        vc=`echo "$record" | cut -d',' -f6`
        echo "deleted record: Prefix:$vp Jeff:$vj date:$vd activity:$va hour:$vh comment: $vc"

        ## Remove record
        sed -i -s ${line_no}d $csv_file
        length=`expr $length - 1`
    done

elif [[ $command =~ ^v ]]; then
    ## View Mode
    # find csv file
    if [ -n "$date" ]; then
        csv_file=$csv_dir/rcl_${USER}_timelog_$yy$mm.csv
    elif [ -n "$month" ]; then
        csv_file=$csv_dir/rcl_${USER}_timelog_$month.csv
    else
        csv_file=`ls $csv_dir/rcl_${USER}_timelog_????.csv`
    fi

    if [ -z "$csv_file" ]; then
        echo "No record found"
        exit 0
    fi

    # Create search pattern
    search_pattern=''
    if [ -n "$prefix" ]; then
        search_pattern="^$prefix"
    else
        search_pattern='^.*'
    fi

    if [ -n "$jeff" ]; then
        search_pattern="$search_pattern,$jeff"
    else
        search_pattern="$search_pattern,.*"
    fi

    if [ -n "$date" ]; then
        search_pattern="$search_pattern,$yyyymmdd"
    else
        search_pattern="$search_pattern,.*"
    fi

    # Default
    if [ -z "$prefix$jeff$date$month" ]; then
        csv_file=$csv_dir/rcl_${USER}_timelog_$yy$mm.csv
        search_pattern="^.*,.*,$yyyymmdd"
    fi

    ## view from csv
    file_found=""
    record_found=""
    total_hour=0
    for i in $csv_file; do
        [ ! -s $i ] && continue
        while read -r record; do
            vp=`echo "$record" | cut -d',' -f1`
            [ "$vp" = 'Prefix' ] && continue
            vj=`echo "$record" | cut -d',' -f2`
            vd=`echo "$record" | cut -d',' -f3`
            va=`echo "$record" | cut -d',' -f4`
            vh=`echo "$record" | cut -d',' -f5`
            vc=`echo "$record" | cut -d',' -f6`

            su=""
            if [ "$sd" != "$vd" ]; then
                if [ -n "$record_found" ]; then
                    echo ""
                fi
                echo "==>Date: ${vd:4:2}/${vd:6:2}/${vd:0:4}"
                sd=$vd
                su='y'
            fi
            if [ "$sp" != "$vp" -o "$sj" != "$vj" -o "$sc" != "$vc" -o -n "$su" ]; then
                echo "-->Prefix: $vp  Jeff Number: $vj Comment: $vc"
                sp=$vp
                sj=$vj
                sc=$vc
            fi

            printf "%24s --> %s\n" "$va" $vh
            total_hour=`expr $total_hour + $vh`

            record_found=1
        done < <(grep -E "$search_pattern" $i)
        file_found=1
    done

    if [ -n "$record_found" ]; then
        echo -e "\nTotal Hour: $total_hour"
    fi

    if [ -z "$file_found" -o -z "$record_found" ]; then
        echo "No record found"
        exit 0
    fi
fi


