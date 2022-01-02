use std::fs::File;
use std::io::{prelude::*, BufReader};

fn main() {
    let file = File::open("input.txt").unwrap();
    let reader = BufReader::new(file);
    let hex = reader.lines().next().unwrap().unwrap();

    let mut bits = hex_to_bits(&hex);
    let packet = Packet::new(&mut bits);

    println!("Part 1: Version sum {}", packet.version_sum());
    println!("Part 2: Value {}", packet.value());
}

#[derive(Debug)]
struct Packet {
    version: u8,
    type_id: u8,
    len: usize,
    data: PacketData,
}

impl Packet {
    fn new(iter: &mut impl Iterator<Item = bool>) -> Self {
        let version = n_bits_to_int(iter, 3) as u8;
        let type_id = n_bits_to_int(iter, 3) as u8;

        let (len, data) = if type_id == 4 {
            PacketData::new_literal(iter)
        } else {
            PacketData::new_operator(iter)
        };

        Packet {
            version,
            type_id,
            // Add 6 bits for packet header (version, type_id)
            len: len + 6,
            data,
        }
    }

    fn version_sum(&self) -> u64 {
        self.version as u64
            + match &self.data {
                PacketData::Literal(..) => 0,
                PacketData::Operator(subpackets) => {
                    subpackets.iter().map(|p| p.version_sum()).sum()
                }
            }
    }

    fn value(&self) -> u64 {
        use PacketData::*;
        match (self.type_id, &self.data) {
            (0, Operator(packets)) => packets.iter().map(|s| s.value()).sum(),
            (1, Operator(packets)) => packets.iter().map(|s| s.value()).product(),
            (2, Operator(packets)) => packets.iter().map(|s| s.value()).min().unwrap(),
            (3, Operator(packets)) => packets.iter().map(|s| s.value()).max().unwrap(),
            (4, Literal(value)) => *value,
            (5, Operator(packets)) => (packets[0].value() > packets[1].value()) as u64,
            (6, Operator(packets)) => (packets[0].value() < packets[1].value()) as u64,
            (7, Operator(packets)) => (packets[0].value() == packets[1].value()) as u64,
            _ => panic!(),
        }
    }
}

#[derive(Debug)]
enum PacketData {
    Literal(u64),
    Operator(Vec<Packet>),
}

impl PacketData {
    fn new_literal(iter: &mut impl Iterator<Item = bool>) -> (usize, Self) {
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
        (len, PacketData::Literal(num))
    }

    fn new_operator(iter: &mut impl Iterator<Item = bool>) -> (usize, Self) {
        let mut subpackets = Vec::new();
        let mut operator_len = 0;

        // Add 1 to compensate for length type ID
        operator_len += 1;

        if iter.next().unwrap() {
            let num_of_subpackets = n_bits_to_int(iter, 11);
            // Add 11 to compensate for length of num_of_subpackets
            operator_len += 11;
            for _ in 0..num_of_subpackets {
                let packet = Packet::new(iter);
                operator_len += packet.len;
                subpackets.push(packet)
            }
        } else {
            let len_of_subpackets = n_bits_to_int(iter, 15) as usize;
            // Add 15 to compensate for length of len_of_subpackets
            operator_len += 15;

            let mut len = 0;
            while len != len_of_subpackets {
                let packet = Packet::new(iter);
                len += packet.len;
                subpackets.push(packet);
            }
            // Add len of subpackets
            operator_len += len_of_subpackets;
        }
        (operator_len, PacketData::Operator(subpackets))
    }
}

fn hex_to_bits(s: &str) -> impl Iterator<Item = bool> + '_ {
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