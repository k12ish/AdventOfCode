from collections import defaultdict

graph = defaultdict(set)

with open("input.txt") as w:
    for line in w.readlines():
        source, dest = line.strip().split("-")
        graph[source] = {dest, *graph[source]}
        graph[dest] = {source, *graph[dest]}

"""
Depth first search of 'end' through graph

yields list[str] where each each list represents a path through graph
"""


def DFS(origin: str, banned: set, forgive=False):
    if origin.islower():
        # very important to not use set.add
        # recursive function call will modify parent variables
        banned = banned | {origin}

    for dest in graph[origin]:
        if dest == "end":
            yield [origin, "end"]
            continue

        if dest not in banned:
            yield from map(lambda l: [origin] + l, DFS(dest, banned, forgive=forgive))

        if dest in banned and dest != "start" and forgive:
            yield from map(lambda l: [origin] + l, DFS(dest, banned, forgive=False))


count = 0
for path in DFS("start", set(), forgive=False):
    count += 1
print("Part 1:", count)

count = 0
for path in DFS("start", set(), forgive=True):
    count += 1
print("Part 2:", count)
