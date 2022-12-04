count = 0
with open('input.txt') as f:
    for line in f.readlines():
        for word in line.split()[-4:]:
            if len(word) in {2, 3, 4, 7}:
                count += 1

print(count)
