def make_translation_table(input):
    table = {}
    lens = {}
    for w in input:
        if len(w) in lens:
            lens[len(w)] = lens[len(w)] + ' ' + w
        else:
            lens[len(w)] = w
    table[lens[2]] = 1
    table[lens[3]] = 7
    table[lens[4]] = 4
    table[lens[7]] = 8

    # Consider 2,3,5
    four_segments = set('abcdefg').intersection(*(lens[6].split()))
    for w in lens[5].split():
        # 3 is the only char which supercedes 1
        if set(w).issuperset(set(lens[2])):
            table[w] = 3
        # 5 is the only char which supercedes the intercept of 0,6,9
        elif set(w).issuperset(four_segments):
            table[w] = 5
        else:
            table[w] = 2

    # Consider 0,6,9
    for w in lens[6].split():
        # 9 is the only char which supercedes 4
        if set(w).issuperset(set(lens[4])):
            table[w] = 9
        # 6 is the only char which doesnt supercede 1
        elif not set(w).issuperset(set(lens[2])):
            table[w] = 6
        else:
            table[w] = 0
    
    return table


def translate(words, table):
    words = [frozenset(w) for w in words]
    table = {frozenset(k):v for (k,v) in table.items()}
    sum = 0
    for word in words:
        sum *= 10
        sum += table[word]
    return sum

    

sum = 0
with open('input.txt') as f:
    for line in f.readlines():
        line = line.split('|')
        input, output = line[0].split(), line[1].split()
        table = make_translation_table(input)
        print(table)
        print(output)
        sum += translate(output, table)

print(sum)