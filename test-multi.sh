# run multiple times for redundancy - sometimes it might fail
n=3
for (( i=1; i<=$n; i++ ))
  do
    echo "test $i/$n"
    ./test.sh
  done