use std::cmp;
use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::num::ParseIntError;
use std::str::FromStr;

fn main() {
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);

    let lines = reader
        .lines()
        .map(|s| Line::from_str(&s.unwrap()).unwrap())
        .collect::<Vec<Line>>();

    let max_x = lines.iter().map(|l| cmp::max(l.x1, l.x2)).max().unwrap();
    let max_y = lines.iter().map(|l| cmp::max(l.y1, l.y2)).max().unwrap();
    part_1(&lines, max_x, max_y);
    part_2(&lines, max_x, max_y);
}

fn part_1(lines: &[Line], max_x: usize, max_y: usize) {
    let mut grid = vec![vec![0usize; max_x + 1]; max_y + 1];
    for line in lines {
        let x_range = range_inclusive(line.x1, line.x2);
        let y_range = range_inclusive(line.y1, line.y2);
        if line.is_horizontal() {
            for x in x_range {
                grid[line.y1][x] += 1
            }
        } else if line.is_vertical() {
            for y in y_range {
                grid[y][line.x1] += 1
            }
        }
    }
    let count: usize = grid
        .iter()
        .flatten()
        .map(|i| if i > &1 { 1 } else { 0 })
        .sum();
    println!("Part 1: {:?}", count);
}

fn part_2(lines: &[Line], max_x: usize, max_y: usize) {
    let mut grid = vec![vec![0usize; max_x + 1]; max_y + 1];
    for line in lines {
        let x_range = range_inclusive(line.x1, line.x2);
        let y_range = range_inclusive(line.y1, line.y2);

        if line.is_horizontal() {
            for x in x_range {
                grid[line.y1][x] += 1
            }
        } else if line.is_vertical() {
            for y in y_range {
                grid[y][line.x1] += 1
            }
        } else {
            for (x, y) in x_range.zip(y_range) {
                grid[y][x] += 1
            }
        }
    }
    let count: usize = grid
        .iter()
        .flatten()
        .map(|i| if i > &1 { 1 } else { 0 })
        .sum();
    println!("Part 2: {:?}", count);
}

#[derive(Debug, Copy, Clone)]
struct Line {
    x1: usize,
    y1: usize,
    x2: usize,
    y2: usize,
}

impl FromStr for Line {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let tokens = s.split_whitespace().collect::<Vec<_>>();

        if let [p1, "->", p2] = tokens[..] {
            let mut p1_split = p1.split(',');
            let mut p2_split = p2.split(',');
            Ok(Line {
                x1: usize::from_str(p1_split.next().unwrap())?,
                y1: usize::from_str(p1_split.next().unwrap())?,
                x2: usize::from_str(p2_split.next().unwrap())?,
                y2: usize::from_str(p2_split.next().unwrap())?,
            })
        } else {
            panic!("invalid format: {:?}", s)
        }
    }
}

impl Line {
    fn is_horizontal(&self) -> bool {
        self.y1 == self.y2
    }
    fn is_vertical(&self) -> bool {
        self.x1 == self.x2
    }
}

fn range_inclusive(a: usize, b: usize) -> impl Iterator<Item = usize> {
    let range: Box<dyn Iterator<Item = usize>> = if b > a {
        Box::new(a..=b)
    } else {
        Box::new((b..=a).rev())
    };
    range
}
