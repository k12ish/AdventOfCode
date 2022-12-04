import * as fs from "fs";
const file: string = fs.readFileSync("input.txt", "utf8");

// calories of each elf sorted in decreasing order
let calories: number[] = file
  .split("\n\n")
  .map(
    // find sum of each paragraph
    (lines) => {
      lines
        .split("\n")
        .map((line) => parseInt(line.trim()) || 0)
        .reduce((sum, next) => sum + next, 0);
    }
  )
  .sort((a, b) => b - a);

console.log("Part one: ", calories[0]);
console.log(
  "Part two: ",
  calories.slice(0, 3).reduce((a, b) => a + b, 0)
);
