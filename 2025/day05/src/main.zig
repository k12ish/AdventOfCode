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
        ranges: std.array_list.Managed(struct { usize, usize }),
        points: std.array_list.Managed(usize),

        fn deinit(self: *@This()) void {
            self.ranges.deinit();
            self.points.deinit();
        }

        /// returns count of FRESH items
        fn count(self: *const @This()) usize {
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

    try std.testing.expectEqual(input.count(), 3);
}

const INPUT = @embedFile("./input.txt");

pub fn main(init: std.process.Init) !void {
    var reader = std.Io.Reader.fixed(INPUT);
    var input = try Parser.parse(init.gpa, &reader);
    defer input.deinit();

    std.log.info("item count in ranges: {}", .{input.ranges.items.len});
    std.log.info("item count in points: {}", .{input.points.items.len});

    std.log.info("part one result: {}", .{input.count()});
}
