import * as fs from "fs";
const file: string = fs.readFileSync("input.txt", "utf8");

enum Play {
  Rock = 1,
  Paper = 2,
  Scissors = 3,
}

enum Result {
  Lose = 0,
  Draw = 3,
  Win = 6,
}

let part_one: number = file
  .split("\n")
  .map((line) => {
    switch (line) {
      // Rock versus ..
      case "A X":
        return Play.Rock + Result.Draw;
      case "A Y":
        return Play.Paper + Result.Win;
      case "A Z":
        return Play.Scissors + Result.Lose;

      // Paper versus ..
      case "B X":
        return Play.Rock + Result.Lose;
      case "B Y":
        return Play.Paper + Result.Draw;
      case "B Z":
        return Play.Scissors + Result.Win;

      // Scissors versus ..
      case "C X":
        return Play.Rock + Result.Win;
      case "C Y":
        return Play.Paper + Result.Lose;
      case "C Z":
        return Play.Scissors + Result.Draw;
    }
    return 0;
  })
  .reduce((a, b) => a + b);

let part_two: number = file
  .split("\n")
  .map((line) => {
    switch (line) {
      // We need to loose
      case "A X":
        return Play.Scissors + Result.Lose;
      case "B X":
        return Play.Rock + Result.Lose;
      case "C X":
        return Play.Paper + Result.Lose;

      // We need to draw
      case "A Y":
        return Play.Rock + Result.Draw;
      case "B Y":
        return Play.Paper + Result.Draw;
      case "C Y":
        return Play.Scissors + Result.Draw;

      // We need to win
      case "A Z":
        return Play.Paper + Result.Win;
      case "B Z":
        return Play.Scissors + Result.Win;
      case "C Z":
        return Play.Rock + Result.Win;
    }
    return 0;
  })
  .reduce((a, b) => a + b);

console.log("Part one", part_one);
console.log("Part two", part_two);
