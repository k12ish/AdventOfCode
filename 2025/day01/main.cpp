#include <iostream>
#include <print>

int main() {

  char direction;
  int amount;

  int dial = 50;

  int part_one_tally = 0;
  int part_two_tally = 0;

  while (std::cin >> direction >> amount) {
    bool forward;

    if (direction == 'L') {
      forward = false;
    } else if (direction == 'R') {
      forward = true;
    } else {
      throw std::format("Bad parsing: '{}', {}", direction, amount);
    }

    for (auto i = 0; i < amount; i++) {
      if (forward) {
        dial += 1;
      } else {
        dial -= 1;
      }
      if (dial % 100 == 0) {
        part_two_tally++;
      }
    }

    if (dial % 100 == 0) {
      part_one_tally++;
    }
  }
  std::println("Part One: {}", part_one_tally);
  std::println("Part Two: {}", part_two_tally);
}
