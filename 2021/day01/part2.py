total = 0

with open('input.txt') as f:
    lines = list(map(int, f.readlines()))
    triplets = zip(lines[0:], lines[1:], lines[2:])
    prev = None
    for item in map(sum, triplets):
        if prev and item > prev:
            total += 1
        prev = item


print(total)
