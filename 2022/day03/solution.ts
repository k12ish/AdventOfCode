import * as fs from "fs";

export class RuckSack {
  // each rucksack contains a set of its left and right items
  left: Set<string>;
  right: Set<string>;

  constructor(line: string) {
    const trimmed = line.trim();
    this.left = new Set(trimmed.slice(0, trimmed.length / 2));
    this.right = new Set(trimmed.slice(trimmed.length / 2));
  }

  // finds the score of the item common to both partitions of the rucksack
  duplicate_item_score(): number {
    let intersect = new Set([...this.left].filter(i => this.right.has(i)));
    let [item] = [...intersect];
    return item_score(item)
  }

}

export function group_item_score(group: Array<RuckSack>): number {
  let intercept = group.map(
    rucksack => new Set([...rucksack.left, ...rucksack.right])
  ).reduce(
    (a, b) => new Set([...a].filter(i => b.has(i)))
  )
  let [item] = [...intercept];
  return item_score(item)
}


export function item_score(letter: string) {
  if (letter.toLocaleLowerCase() === letter) {
    return letter.charCodeAt(0) - 96;
  } else {
    return letter.charCodeAt(0) - 38;
  }
}

function main() {
  const file: string = fs.readFileSync("input.txt", "utf8");

  let rucksacks: RuckSack[] = file
    .split("\n")
    .filter(line => line != "")
    .map(line => new RuckSack(line));

  let part_one = rucksacks.reduce(
    (accum, current) => accum + current.duplicate_item_score(),
    0
  );

  console.log("Part one: ", part_one);

  let part_two = 0;
  for (let i = 0; i < rucksacks.length; i += 3) {
    part_two += group_item_score(rucksacks.slice(i, i + 3))
  }

  console.log("Part two: ", part_two);
}

if (require.main == module) {
  main();
}
