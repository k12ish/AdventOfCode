package main

import (
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
	"strings"
)

func main() {
	buf, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.Trim(string(buf), "\n"), ",")
	nums := make([]int, len(lines))

	// If we consider the fuel required as a function of position, we can see
	// that this function is in the form:
	// 	  f(x) = |x-s1| + |x-s2| ... + |x-sn|
	// The gradient of this function is strictly increasing, has an initial
	// value of -n and final value of n. Since the gradient increases by two
	// past each crab, f'(x) is zero at the median value of s.

	for i, s := range lines {
		if num, err := strconv.ParseInt(s, 10, 64); err == nil {
			nums[i] = int(num)
		} else {
			panic(err)
		}
	}
	sort.Ints(nums)
	fmt.Println("Part 1: ", fuel1(nums, nums[len(nums)/2]))

	// If we consider the fuel required as a function of position, we can see
	// that this function is in the form:
	// 	  f(x) = (x-s1)^2 + (x-s2)^2 ... + (x-sn)^2
	// Differentiate and set to zero:
	// 	 f'(x) = 2(x-s1) + 2(x-s2) ... + 2(x-sn)
	// 	     0 = nx + (s1 + s2 ... + sn)
	// Rearrange to show that x is minimized at the mean position.

	var sum int
	for _, n := range nums {
		sum += n
	}
	mean := int(math.Round(float64(sum) / float64(len(nums))))
	best := MinOf(fuel2(nums, mean-1), fuel2(nums, mean), fuel2(nums, mean+1))

	fmt.Println("Part 2: ", best)
}

func MinOf(vars ...int) int {
	min := vars[0]
	for _, i := range vars {
		if min > i {
			min = i
		}
	}
	return min
}

func fuel1(num []int, pos int) int {
	var sum int
	for _, val := range num {
		if pos-val < 0 {
			sum += val - pos
		} else {
			sum += pos - val
		}
	}
	return sum
}

func fuel2(num []int, pos int) int {
	var sum int
	for _, val := range num {
		if pos-val < 0 {
			sum += (val - pos) * (val - pos + 1) / 2
		} else {
			sum += (pos - val) * (pos - val + 1) / 2
		}
	}
	return sum
}
