use std::fs::File;
use std::io::{prelude::*, BufReader};

fn main() {
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);
    let mut part_1 = 0;
    let mut part_2 = Vec::new();
    for line in reader.lines() {
        match Syntax::line_score(&line.unwrap()) {
            Score::Errors(i) => part_1 += i,
            Score::AutoCorrect(i) => part_2.push(i),
        }
    }
    part_2.sort();
    println!("Part 1: {}", part_1);
    println!("Part 2: {}", part_2[part_2.len() / 2]);
}

#[derive(Default, Debug)]
struct Syntax {
    vec: Vec<char>,
}

enum Score {
    AutoCorrect(i64),
    Errors(i64),
}

impl Syntax {
    fn line_score(line: &str) -> Score {
        let mut syntax = Self::default();
        for c in line.chars() {
            if let Some(score) = syntax.extend(c) {
                return Score::Errors(score);
            }
        }
        Score::AutoCorrect(syntax.autocorrect())
    }

    /// Update syntax, return Some(i64) if char is incompatible with stack
    fn extend(&mut self, c: char) -> Option<i64> {
        match c {
            '(' => self.vec.push(')'),
            '<' => self.vec.push('>'),
            '[' => self.vec.push(']'),
            '{' => self.vec.push('}'),
            '\n' => panic!("Unexpected newline"),
            _ => {
                if c == *self.vec.last().unwrap_or(&'\n') {
                    self.vec.pop();
                } else {
                    return Some(char_error_score(c));
                }
            }
        }
        None
    }

    fn autocorrect(self) -> i64 {
        let mut score = 0;
        for c in self.vec.iter().rev() {
            score = 5 * score + char_autocorrect_score(*c)
        }
        score
    }
}

fn char_error_score(c: char) -> i64 {
    match c {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        _ => panic!("{:?}", c),
    }
}

fn char_autocorrect_score(c: char) -> i64 {
    match c {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        _ => panic!("{:?}", c),
    }
}
