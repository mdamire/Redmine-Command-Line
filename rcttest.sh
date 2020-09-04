rm ~/test/rcl/*.csv
# set -x
bash rcl.sh a -g 2 -s 2
echo ""
bash rcl.sh a -P testms1 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '9/1'
echo ""
bash rcl.sh a -P testms1 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D yesterday -J 99999 -C "Creating script"

# bash rcl.sh a -P testms1 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '08/31'
# echo ""
# bash rcl.sh a -P testms2 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '08/31'
# echo ""
# bash rcl.sh a -P testms1 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '08/30'
# echo ""
# bash rcl.sh a -P testms2 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '12/20/19'
# echo ""
# bash rcl.sh a -P testms2 -a 2 -d 2 -q 2 -m 2 -r 2 -g 2 -s 2 -u 2 -D '01/01/21'

echo ""
ls ~/test/`rcl/*.csv