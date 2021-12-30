use std::fs::File;
use std::io::{prelude::*, BufReader};

fn main() {
    let file = File::open("sample1.txt").unwrap();
    let reader = BufReader::new(file);
    let hex = reader.lines().next().unwrap().unwrap();

    let mut bits = hex_to_bits(&hex);

    let packet = Packet::new(&mut bits);
}


#[derive(Debug)]
struct Packet {
    version: u8,
    type_id: u8,
    data: PacketData,
}

impl Packet {
    fn new(mut iter: &mut impl Iterator<Item = bool>) -> Self {
        let version = n_bits_to_int(iter, 3) as u8;
        let type_id = n_bits_to_int(iter, 3) as u8;
        println!("Version: {}", version);
        println!("Type Id: {}", type_id);

        let data = if type_id == 4 {
            PacketData::new_literal(&mut iter)
        } else {
            PacketData::new_operator(&mut iter)
        };

        Packet {
            version,
            type_id,
            data,
        }
    }

    fn len(&self) -> usize {
        6 + self.data.len()
    }
}

#[derive(Debug)]
enum PacketData {
    Literal(usize, u32),
    Operator(Vec<Packet>),
}

impl PacketData {
    fn len(&self) -> usize {
        match self {
            PacketData::Literal(len, _) => *len,
            PacketData::Operator(subpackets) => subpackets.iter().map(|p| p.len()).sum(),
        }
    }

    fn new_literal(iter: &mut impl Iterator<Item = bool>) -> Self {
        let mut num = 0;
        let mut len = 0;
        let mut should_continue = true;
        while should_continue {
            should_continue = iter.next().unwrap();
            for _ in 0..4 {
                num <<= 1;
                if iter.next().unwrap() {
                    num += 1
                }
            }
            len += 5
        }
        PacketData::Literal(len, num)
    }

    fn new_operator(mut iter: &mut impl Iterator<Item = bool>) -> Self {
        let mut subpackets = Vec::new();
        if iter.next().unwrap() {
            let num_of_subpackets = n_bits_to_int(iter, 11);
            for _ in 0..num_of_subpackets {
                subpackets.push(Packet::new(&mut iter))
            }
        } else {
            panic!()
        }
        PacketData::Operator(subpackets)
    }
}

fn hex_to_bits<'a>(s: &'a str) -> impl Iterator<Item = bool> + 'a {
    s.chars().flat_map(&|c| match c {
        '0' => vec![false, false, false, false],
        '1' => vec![false, false, false, true],
        '2' => vec![false, false, true, false],
        '3' => vec![false, false, true, true],
        '4' => vec![false, true, false, false],
        '5' => vec![false, true, false, true],
        '6' => vec![false, true, true, false],
        '7' => vec![false, true, true, true],
        '8' => vec![true, false, false, false],
        '9' => vec![true, false, false, true],
        'A' => vec![true, false, true, false],
        'B' => vec![true, false, true, true],
        'C' => vec![true, true, false, false],
        'D' => vec![true, true, false, true],
        'E' => vec![true, true, true, false],
        'F' => vec![true, true, true, true],
        _ => panic!("Not hexadecimal"),
    })
}

fn n_bits_to_int(iter: &mut impl Iterator<Item = bool>, n: usize) -> u64 {
    let mut ret = 0;
    for _ in 0..n {
        ret <<= 1;
        if iter.next().unwrap() {
            ret += 1
        }
    }
    ret
}
