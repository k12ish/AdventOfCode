class Board:

    """Create a board using a string representation of its state"""

    def __init__(self, string) -> None:
        self.state = [[int(elem) for elem in row.split()] for row in string.split('\n')]
        self.groups = [set(row) for row in self.state] + [
            set(col) for col in zip(*self.state)
        ]

    """"return the sum of undrawn numbers in a board, if a group is complete"""

    def bingo(self, drawn):
        drawn = set(drawn)
        for group in self.groups:
            if drawn.issuperset(group):
                numbers = {i for row in self.state for i in row}
                undrawn = numbers - drawn
                return sum(undrawn)


def first_score(boards, to_be_drawn):
    best = boards[0]
    min = len(to_be_drawn)
    for board in boards:
        while board.bingo(to_be_drawn[: min - 1]):
            min -= 1
            best = board

    total = best.bingo(to_be_drawn[:min])
    print("Part 1 Score:", total * to_be_drawn[min - 1])


def last_score(boards, to_be_drawn):
    best = boards[0]
    max = 0
    for board in boards:
        while not board.bingo(to_be_drawn[: max + 1]):
            max += 1
            best = board

    total = best.bingo(to_be_drawn[: max + 1])
    print("Part 2 Score:", total * to_be_drawn[max])


if __name__ == '__main__':
    with open("input.txt") as file:
        to_be_drawn = [int(x) for x in file.readline().split(',')]
        board_strs = file.read().replace('\r', '').strip().split('\n\n')
        boards = [Board(s) for s in board_strs]
    first_score(boards, to_be_drawn)
    last_score(boards, to_be_drawn)
