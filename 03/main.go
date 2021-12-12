package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	buf, err := os.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Fields(string(buf))

	y_len := len(lines)
	x_len := len(lines[0])

	bit_count := make([]int, x_len)

	for _, line := range lines {
		for j, char := range line {
			if char == '1' {
				bit_count[j] += 1
			}
		}
	}

	epsilon_bin := make([]byte, x_len)
	gamma_bin := make([]byte, x_len)

	for i, count := range bit_count {
		if count > y_len/2 {
			gamma_bin[i] = byte('1')
		} else {
			epsilon_bin[i] = byte('1')
		}
	}
	var epsilon = binary_str_to_int(string(epsilon_bin))
	var gamma = binary_str_to_int(string(gamma_bin))

	fmt.Println("Part 1: Gamma * Epsilon", gamma*epsilon)

	var carbon int
	var oxygen int

	carbon_idx := makeRange(0, y_len)

	for j := 0; j < x_len; j++ {
		// the number of 1s in this column
		var count int
		for _, i := range carbon_idx {
			if lines[i][j] == '1' {
				count++
			}
		}
		// the correct char in the jth column
		accepted := '0'
		if count < len(carbon_idx)-count {
			accepted = '1'
		}
		// reject the incorrect idxs
		i := 0
		for i < len(carbon_idx) && len(carbon_idx) > 1 {
			if lines[carbon_idx[i]][j] != byte(accepted) {
				// Golang doesn't have a .pop() method :(
				carbon_idx = append(carbon_idx[:i], carbon_idx[i+1:]...)
			} else {
				i++
			}
		}
		if len(carbon_idx) == 1 {
			carbon = binary_str_to_int(lines[carbon_idx[0]])
		}
	}

	oxygen_idx := makeRange(0, y_len)

	for j := 0; j < x_len; j++ {
		// the number of 1s in this column
		var count int
		for _, i := range oxygen_idx {
			if lines[i][j] == '1' {
				count++
			}
		}
		// the correct char in the jth column
		accepted := '1'
		if len(oxygen_idx)-count > count {
			accepted = '0'
		}
		// reject the incorrect idxs
		i := 0
		for i < len(oxygen_idx) && len(oxygen_idx) > 1 {
			if lines[oxygen_idx[i]][j] != byte(accepted) {
				// Golang doesn't have a .pop() method :(
				oxygen_idx = append(oxygen_idx[:i], oxygen_idx[i+1:]...)
			} else {
				i++
			}
		}
		if len(oxygen_idx) == 1 {
			oxygen = binary_str_to_int(lines[oxygen_idx[0]])
		}
	}

	fmt.Println("Part 2: Carbon * Oxygen", carbon*oxygen)
}

func makeRange(min, max int) []int {
	a := make([]int, max-min)
	for i := range a {
		a[i] = min + i
	}
	return a
}

func binary_str_to_int(str string) int {
	var num int
	for _, bit := range str {
		num <<= 1
		if bit == '1' {
			num += 1
		}
	}
	return num
}
