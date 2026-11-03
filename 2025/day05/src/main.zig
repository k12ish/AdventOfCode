const std = @import("std");
const Io = std.Io;

const SAMPLE: []const u8 =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

const Parser = struct {
    const Result = struct {
        const Pair = struct { usize, usize };
        ranges: std.array_list.Managed(Pair),
        points: std.array_list.Managed(usize),

        fn deinit(self: *@This()) void {
            self.ranges.deinit();
            self.points.deinit();
        }

        /// returns count of FRESH items
        fn countPartOne(self: *const @This()) usize {
            var fresh: usize = 0;
            for (self.points.items) |point| {
                for (self.ranges.items) |pair| {
                    const start, const end = pair;

                    if (start <= point and point <= end) {
                        fresh += 1;
                        break;
                    }
                }
            }
            return fresh;
        }

        fn countPartTwo(self: *@This()) usize {
            const lessThan = struct {
                fn inner(_: void, lhs: Pair, rhs: Pair) bool {
                    if (lhs.@"0" < rhs.@"0") {
                        return true;
                    }
                    return false;
                }
            }.inner;

            std.sort.insertion(Pair, self.ranges.items, {}, lessThan);

            var min_start = self.ranges.items[0].@"0";
            var max_end = self.ranges.items[0].@"0";
            var count: usize = 0;
            for (self.ranges.items) |pair| {
                if (pair.@"0" > max_end) {
                    count += max_end - min_start + 1;
                    min_start = pair.@"0";
                    max_end = pair.@"1";
                } else {
                    max_end = @max(max_end, pair.@"1");
                }
            }
            count += max_end - min_start + 1;
            return count;
        }
    };

    fn parse(gpa: std.mem.Allocator, reader: *std.Io.Reader) !Result {
        // ensure error.EndOfStream not called
        _ = try reader.peekDelimiterExclusive('\n');

        var result: Result = .{
            .ranges = .init(gpa),
            .points = .init(gpa),
        };

        errdefer result.ranges.deinit();
        errdefer result.points.deinit();

        while (try reader.takeDelimiter('\n')) |line| {
            if (line.len == 0) continue;

            if (std.mem.indexOfScalar(u8, line, '-')) |idx| {
                const start = try std.fmt.parseInt(usize, line[0..idx], 10);
                const end = try std.fmt.parseInt(usize, line[idx + 1 .. line.len], 10);
                try result.ranges.append(.{ start, end });
            } else {
                const pt = try std.fmt.parseInt(usize, line, 10);
                try result.points.append(pt);
            }
        }

        return result;
    }
};

test Parser {
    var reader = std.Io.Reader.fixed(SAMPLE);
    var input = try Parser.parse(std.testing.allocator, &reader);
    defer input.deinit();

    try std.testing.expectEqual(input.ranges.items.len, 4);
    try std.testing.expectEqual(input.points.items.len, 6);

    try std.testing.expectEqual(input.countPartOne(), 3);
    try std.testing.expectEqual(input.countPartTwo(), 14);
}

const INPUT = @embedFile("./input.txt");

pub fn main(init: std.process.Init) !void {
    var reader = std.Io.Reader.fixed(INPUT);
    var input = try Parser.parse(init.gpa, &reader);
    defer input.deinit();

    std.log.info("item count in ranges: {}", .{input.ranges.items.len});
    std.log.info("item count in points: {}", .{input.points.items.len});

    std.log.info("part one result: {}", .{input.countPartOne()});
    std.log.info("part two result: {}", .{input.countPartTwo()});
}
