# run multiple times for redundancy - sometimes it might fail
n=30
for (( i=1; i<=$n; i++ ))
  do
    echo "test $i/$n"
    ./test.sh
  done