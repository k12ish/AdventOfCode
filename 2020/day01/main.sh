# Solution to 2020 Day 01
# Execute this program like so:
#   ./main.sh sample.txt

while read i; do
  while read j; do
    if [ $i -gt $j ]; then
      while read k; do
        if [ $j -gt $k ]; then
          if [ 2020 == $(( $i + $j + $k )) ]; then
            echo $(( $i * $j * $k ))
          fi
        fi
      done <$1
    fi
  done <$1
done <$1

