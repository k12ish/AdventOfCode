Part one of this challenge was originally solved with a hacky oneliner:

```bash
cat $1 | xargs -I ii \
  sh -c "cat $1 | xargs -I j sh -c \
  'if [ ii -gt j ] && eval \"[ 2020 -eq \$(( j + ii )) ]\"; then \
    eval \"echo \$(( ii * j ))\"; fi'" 
```

This takes _22 seconds_ on the 200 line input file. Needless to say, this did not work for part two.
