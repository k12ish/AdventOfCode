from dataclasses import dataclass
import heapq

with open("input.txt") as f:
    input_grid = [[int(i) for i in line.strip()] for line in f.readlines()]


@dataclass
class Node:
    x: int
    y: int
    risk: int

    def __lt__(self, other):
        return self.risk < other.risk

    def move_by(self, x, y, grid):
        return Node(self.x + x, self.y + y, self.risk + grid[self.y + y][self.x + x])


class PathFinder:
    def __init__(self, grid) -> None:
        self.risk = [[None for val in row] for row in grid]
        self.risk[0][0] = 0
        self.heap = [Node(0, 0, 0)]
        self.grid = grid

    def min_risk(self):
        while True:
            point = heapq.heappop(self.heap)
            if point.y + 1 == len(self.grid) and point.x + 1 == len(self.grid[0]):
                return point.risk

            if point.x != 0:
                self._push(point.move_by(-1, 0, self.grid))

            if point.x + 1 != len(self.grid[0]):
                self._push(point.move_by(1, 0, self.grid))

            if point.y != 0:
                self._push(point.move_by(0, -1, self.grid))

            if point.y + 1 != len(self.grid):
                self._push(point.move_by(0, 1, self.grid))

    def _push(self, point):
        if self.risk[point.y][point.x] is None:
            heapq.heappush(self.heap, point)
            self.risk[point.y][point.x] = point.risk
        elif point.risk < self.risk[point.y][point.x]:
            heapq.heappush(self.heap, point)
            self.risk[point.y][point.x] = point.risk


print("Part 1:", PathFinder(input_grid).min_risk())

tile_risk = [[x + y for x in range(5)] for y in range(5)]

x_max = len(input_grid[0])
y_max = len(input_grid)

wrap_9_to_1 = lambda n: (n - 1) % 9 + 1

scaled_grid = [
    [
        wrap_9_to_1(input_grid[y % y_max][x % x_max] + x // x_max + y // y_max)
        for x in range(5 * x_max)
    ]
    for y in range(5 * y_max)
]


print("Part 2:", PathFinder(scaled_grid).min_risk())