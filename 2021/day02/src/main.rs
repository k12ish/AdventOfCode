use std::fs::File;
use std::io::{prelude::*, BufReader};
use std::str::FromStr;

fn main() {
    part_1();
    part_2();
}

fn part_1() {
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);

    let mut depth = 0;
    let mut distance = 0;
    for line in reader.lines() {
        let dir = Direction::from_str(&line.unwrap()).unwrap();
        match dir {
            Direction::Forward(n) => distance += n,
            Direction::Down(n) => depth += n,
            Direction::Up(n) => depth -= n,
        }
    }
    println!("Part 1, Depth * Distance: {}", depth * distance);
}

fn part_2() {
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);

    let mut depth = 0;
    let mut distance = 0;
    let mut aim = 0;

    for line in reader.lines() {
        let dir = Direction::from_str(&line.unwrap()).unwrap();
        match dir {
            Direction::Forward(n) => {
                distance += n;
                depth += aim * n
            }
            Direction::Down(n) => aim += n,
            Direction::Up(n) => aim -= n,
        }
    }
    println!("Part 2, Depth * Distance: {}", depth * distance);
}

#[derive(Debug)]
enum Direction {
    Forward(u64),
    Down(u64),
    Up(u64),
}

impl FromStr for Direction {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let tokens = s.split_whitespace().collect::<Vec<_>>();

        if let [dir, num] = tokens[..] {
            let distance = u64::from_str(num).unwrap();
            match dir {
                "forward" => Ok(Direction::Forward(distance)),
                "down" => Ok(Direction::Down(distance)),
                "up" => Ok(Direction::Up(distance)),
                _ => Err(()),
            }
        } else {
            Err(())
        }
    }
}
