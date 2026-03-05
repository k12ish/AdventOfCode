const std = @import("std");

const SAMPLE =
    \\11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
;

const INPUT =
    \\9191906840-9191941337,7671-13230,2669677096-2669816099,2-12,229599-392092,48403409-48523311,96763-229430,1919163519-1919240770,74928-96389,638049-668065,34781-73835,736781-819688,831765539-831907263,5615884-5749554,14101091-14196519,7134383-7169141,413340-625418,849755289-849920418,7745350-7815119,16717-26267,4396832-4549887,87161544-87241541,4747436629-4747494891,335-549,867623-929630,53-77,1414-3089,940604-1043283,3444659-3500714,3629-7368,79-129,5488908-5597446,97922755-98097602,182-281,8336644992-8336729448,24-47,613-1077
;

/// Iterates over pairs of numbers in a ',' delimited string
const ItemIterator = struct {
    buf: []const u8,
    cursor: usize,

    fn next(self: *@This()) ?struct { []const u8, []const u8 } {
        if (self.cursor >= self.buf.len) return null;

        const rest = self.buf[self.cursor..];
        const comma = std.mem.indexOfScalar(u8, rest, ',') orelse rest.len;
        const segment = rest[0..comma];
        self.cursor += comma + 1;

        const dash = std.mem.indexOfScalar(u8, segment, '-') orelse return null;
        return .{ segment[0..dash], segment[dash + 1 ..] };
    }
};

/// Returns true if n is a repeated digit sequence (e.g. 1234 repeated >= 2 times).
fn is_repeated(n: u64) bool {
    var buf: [20]u8 = undefined;
    const s = std.fmt.bufPrint(&buf, "{}", .{n}) catch return false;
    const len = s.len;
    var k: usize = 1;
    while (k <= len / 2) : (k += 1) {
        if (len % k != 0) continue;
        const block = s[0..k];
        var valid = true;
        var i: usize = k;
        while (i < len) : (i += k) {
            if (!std.mem.eql(u8, s[i .. i + k], block)) {
                valid = false;
                break;
            }
        }
        if (valid) return true;
    }
    return false;
}

fn sum_invalid_p2_in_range(lo: u64, hi: u64) u64 {
    var total: u64 = 0;
    var n = lo;
    while (n <= hi) : (n += 1) {
        if (is_repeated(n)) total += n;
    }
    return total;
}

/// Sum all invalid IDs in [lo, hi] using arithmetic series per digit-length class.
/// A 2k-digit number is invalid iff it's a multiple of 10^k + 1.
fn sum_invalid_in_range(lo: u64, hi: u64) u64 {
    var total: u64 = 0;
    var pow10k: u64 = 10; // 10^k, starting at k=1
    while (pow10k <= 1_000_000_000) : (pow10k *= 10) {
        const step = pow10k + 1;
        const min_2k = pow10k / 10 * pow10k; // 10^(2k-1): smallest 2k-digit number
        const max_2k = pow10k * pow10k - 1; // 10^(2k) - 1: largest 2k-digit number

        const eff_lo = @max(lo, min_2k);
        const eff_hi = @min(hi, max_2k);
        if (eff_lo > eff_hi) continue;

        const first = ((eff_lo + step - 1) / step) * step;
        if (first > eff_hi) continue;
        const last = (eff_hi / step) * step;

        const count = (last - first) / step + 1;
        total += count * (first + last) / 2;
    }
    return total;
}

pub fn main() !void {
    var p1: u64 = 0;
    var p2: u64 = 0;
    var iter = ItemIterator{ .buf = INPUT, .cursor = 0 };
    while (iter.next()) |pair| {
        const lo = try std.fmt.parseInt(u64, pair[0], 10);
        const hi = try std.fmt.parseInt(u64, pair[1], 10);
        p1 += sum_invalid_in_range(lo, hi);
        p2 += sum_invalid_p2_in_range(lo, hi);
    }

    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ p1, p2 });
}

test sum_invalid_p2_in_range {
    var total: u64 = 0;
    var iter = ItemIterator{ .buf = SAMPLE, .cursor = 0 };
    while (iter.next()) |pair| {
        const lo = try std.fmt.parseInt(u64, pair[0], 10);
        const hi = try std.fmt.parseInt(u64, pair[1], 10);
        total += sum_invalid_p2_in_range(lo, hi);
    }
    try std.testing.expectEqual(total, 4174379265);
}

test sum_invalid_in_range {
    var total: u64 = 0;
    var iter = ItemIterator{ .buf = SAMPLE, .cursor = 0 };
    while (iter.next()) |pair| {
        const lo = try std.fmt.parseInt(u64, pair[0], 10);
        const hi = try std.fmt.parseInt(u64, pair[1], 10);
        total += sum_invalid_in_range(lo, hi);
    }
    try std.testing.expectEqual(total, 1227775554);
}

test ItemIterator {
    var iter = ItemIterator{ .buf = "11-22,333-444", .cursor = 0 };

    const ones, const twos = iter.next() orelse return error.Fail;
    try std.testing.expectEqualStrings(ones, "11");
    try std.testing.expectEqualStrings(twos, "22");

    const threes, const fours = iter.next() orelse return error.Fail;
    try std.testing.expectEqualStrings(threes, "333");
    try std.testing.expectEqualStrings(fours, "444");

    try std.testing.expectEqual(iter.next(), null);
    try std.testing.expectEqual(iter.next(), null);
}
