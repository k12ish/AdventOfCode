class SnailFishNumber:
    def __init__(self, left, right, parent=None):
        if isinstance(left, SnailFishNumber):
            self.left = left
            self.left.parent = self
        elif isinstance(left, list):
            self.left = SnailFishNumber(*left, parent=self)
        elif isinstance(left, int):
            self.left = left
        else:
            RuntimeError("Weird type:", left)

        if isinstance(right, SnailFishNumber):
            self.right = right
            self.right.parent = self
        elif isinstance(right, list):
            self.right = SnailFishNumber(*right, parent=self)
        elif isinstance(right, int):
            self.right = right
        else:
            RuntimeError("Weird type:", right)

        self.parent = parent

    def __repr__(self) -> str:
        return "[{},{}]".format(self.left, self.right)

    def __add__(self, other):
        assert isinstance(other, SnailFishNumber)
        return SnailFishNumber(self, other).reduce()

    def reduce(self):
        self.explode()
        while self._split():
            pass
        return self

    def magnitude(self):
        sum = 0
        if isinstance(self.left, SnailFishNumber):
            sum += 3 * self.left.magnitude()
        elif isinstance(self.left, int):
            sum += 3 * self.left
        if isinstance(self.right, SnailFishNumber):
            sum += 2 * self.right.magnitude()
        elif isinstance(self.right, int):
            sum += 2 * self.right
        return sum

    def root(self):
        ancestor = self
        while ancestor.parent is not None:
            ancestor = ancestor.parent
        return ancestor

    def depth(self):
        depth = 0
        ancestor = self
        while ancestor.parent is not None:
            depth += 1
            ancestor = ancestor.parent
        return depth
        
    """explode all offending children"""
    def explode(self, depth=0):
        if depth == 3:
            if isinstance(self.left, SnailFishNumber):
                self._explode_left_sfn()
            if isinstance(self.right, SnailFishNumber):
                self._explode_right_sfn()
        else:
            if isinstance(self.left, SnailFishNumber):
                self.left.explode(depth=depth + 1)
            if isinstance(self.right, SnailFishNumber):
                self.right.explode(depth=depth + 1)

    """split as much as possible, return True if more calls to self._split() required"""
    def _split(self, depth=0):
        if isinstance(self.left, SnailFishNumber):
            if self.left._split(depth=depth + 1):
                return True
        elif isinstance(self.left, int):
            if self.left >= 10:
                small, big = self.left // 2, self.left - self.left // 2
                self.left = SnailFishNumber(small, big, parent=self)
                if depth == 3:
                    self._explode_left_sfn()
                    return True
                elif big >= 10:
                    return True

        if isinstance(self.right, SnailFishNumber):
            if self.right._split(depth=depth + 1):
                return True
        elif isinstance(self.right, int):
            if self.right >= 10:
                small, big = self.right // 2, self.right - self.right // 2
                self.right = SnailFishNumber(small, big, parent=self)
                if depth == 3:
                    self._explode_right_sfn()
                    return True
                elif big >= 10:
                    return True

    """explode self.left"""
    def _explode_left_sfn(self):
        """Find right neighbour and add self.left.right"""
        # self.right is the right neighbours ancestor

        if isinstance(self.right, SnailFishNumber):
            sfn_to_right = self.right
            # find leftmost child of right neighbours ancestor
            while isinstance(sfn_to_right.left, SnailFishNumber):
                sfn_to_right = sfn_to_right.left
            sfn_to_right.left += self.left.right
        else:
            self.right += self.left.right

        """Find left neighbour and add self.left.left"""
        ancestor = self
        while ancestor.parent is not None:
            # traverse up graph until we find a left neighbour
            if ancestor.parent.left is not ancestor:
                if isinstance(ancestor.parent.left, SnailFishNumber):
                    # find rightmost child of right neighbour
                    sfn_to_left = ancestor.parent.left
                    while isinstance(sfn_to_left.right, SnailFishNumber):
                        sfn_to_left = sfn_to_left.right
                    sfn_to_left.right += self.left.left
                else:
                    ancestor.parent.left += self.left.left
                break
            ancestor = ancestor.parent

        self.left = 0

    """explode self.right"""
    def _explode_right_sfn(self):
        """Find left neighbour and add self.right.left"""
        # self.left is the left neighbours ancestor
        if isinstance(self.left, SnailFishNumber):
            sfn_to_left = self.left
            # find rightmost child of left neighbours ancestor
            while isinstance(sfn_to_left.right, SnailFishNumber):
                sfn_to_left = sfn_to_left.right
            sfn_to_left.right += self.right.left
        else:
            self.left += self.right.left

        """Find right neighbour and add self.right.right"""
        ancestor = self
        while ancestor.parent is not None:
            # traverse up graph until we find right neighbour's ancestor
            if ancestor.parent.right is not ancestor:
                if isinstance(ancestor.parent.right, SnailFishNumber):
                    # find leftmost child of right neighbour's ancestor
                    sfn_to_right = ancestor.parent.right
                    while isinstance(sfn_to_right.left, SnailFishNumber):
                        sfn_to_right = sfn_to_right.left
                    sfn_to_right.left += self.right.right
                else:
                    ancestor.parent.right += self.right.right
                break
            ancestor = ancestor.parent

        self.right = 0


with open("input.txt") as f:
    list_of_lists = [eval(line) for line in f.readlines()]

sum = SnailFishNumber(*list_of_lists[0])
for elem in list_of_lists[1:]:
    sum += SnailFishNumber(*elem)
print("Sum:", sum.magnitude())

mag = 0
for item1 in list_of_lists:
    for item2 in list_of_lists:
        sum = SnailFishNumber(*item1) + SnailFishNumber(*item2)
        mag = max(mag, sum.magnitude())
print("Maximum magnitude:", mag)
