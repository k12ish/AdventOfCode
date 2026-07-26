const std = @import("std");

const SAMPLE =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

const Point = struct { isize, isize };
const Image = struct {
    map: std.AutoHashMap(Point, u1),
    h: usize,
    w: usize,

    fn is_accessible(self: *const @This(), pt: Point) bool {
        const x, const y = pt;
        var count: usize = 0;
        for ([_]isize{ -1, 0, 1 }) |i| {
            for ([_]isize{ -1, 0, 1 }) |j| {
                if (i == 0 and j == 0) continue;

                const neighbour: Point = .{ x + i, y + j };
                if (self.map.contains(neighbour)) count += 1;
            }
        }
        return count < 4;
    }
};

const ParseError = error{
    InvalidImage,
};

fn parse_image(gpa: std.mem.Allocator, reader: *std.Io.Reader) !Image {
    var img = std.AutoHashMap(Point, u1).init(gpa);

    var x: isize = 0;
    var y: isize = 0;

    var h: usize = undefined;
    var w: usize = undefined;

    // ensure that there is at least one '\n'
    _ = reader.peekDelimiterExclusive('\n') catch |err| switch (err) {
        error.EndOfStream => return ParseError.InvalidImage,
        else => unreachable,
    };

    while (try reader.takeDelimiter('\n')) |line| {
        for (line) |char| {
            switch (char) {
                '.' => x += 1,
                '@' => {
                    try img.put(.{ x, y }, 1);
                    x += 1;
                },
                else => return ParseError.InvalidImage,
            }
        }
        w = @intCast(x);
        h = @intCast(y + 1);

        x = 0;
        y += 1;
    }

    return .{ .h = h, .w = w, .map = img };
}

// split into (removed, kept) tuple
fn split(gpa: std.mem.Allocator, input: *const Image) !struct { Image, Image } {
    var removed: Image =
        .{
            .h = input.h,
            .w = input.w,
            .map = std.AutoHashMap(Point, u1).init(gpa),
        };
    var kept: Image =
        .{
            .h = input.h,
            .w = input.w,
            .map = std.AutoHashMap(Point, u1).init(gpa),
        };

    for (0..input.h) |y| {
        for (0..input.w) |x| {
            const key: Point = .{ @intCast(x), @intCast(y) };

            if (!input.map.contains(key)) continue;
            try if (input.is_accessible(key))
                removed.map.put(key, 1)
            else
                kept.map.put(key, 1);
        }
    }

    return .{ removed, kept };
}

test "sample data" {
    var input = std.Io.Reader.fixed(SAMPLE);
    const gpa = std.testing.allocator;
    var img = try parse_image(gpa, &input);
    defer img.map.deinit();

    var removed, var kept = try split(gpa, &img);

    defer removed.map.deinit();
    defer kept.map.deinit();

    try std.testing.expectEqual(removed.map.count(), 13);
    try std.testing.expectEqual(kept.map.count(), img.map.count() - 13);

    var removed2, var kept2 = try split(gpa, &kept);

    try std.testing.expectEqual(removed2.map.count(), 12);
    try std.testing.expectEqual(kept2.map.count(), kept.map.count() - 12);

    defer removed2.map.deinit();
    defer kept2.map.deinit();
}

pub fn main(init: std.process.Init) !void {
    const dir = std.Io.Dir.cwd();
    const file = try dir.openFile(init.io, "./input.txt", .{
        .allow_directory = false,
        .mode = .read_only,
    });
    defer file.close(init.io);
    var buffer: [1000]u8 = undefined;
    var reader = file.reader(init.io, &buffer);

    var img = try parse_image(init.gpa, &reader.interface);

    var total: usize = 0;

    while (true) {
        var removed, var kept = try split(init.gpa, &img);
        defer removed.map.deinit();
        defer kept.map.deinit();

        if (kept.map.count() == 0 or removed.map.count() == 0)
            break;

        total += removed.map.count();
        std.log.info("removed {} papers, total {}", .{ removed.map.count(), total });

        std.mem.swap(@TypeOf(img.map), &img.map, &kept.map);
    }

    defer img.map.deinit();
}
