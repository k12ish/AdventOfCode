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

pub fn main(init: std.process.Init) !void {
    const dir = std.Io.Dir.cwd();
    const file = try dir.openFile(init.io, "./input.txt", .{
        .allow_directory = false,
        .mode = .read_only,
    });
    defer file.close(init.io);
    var buffer: [1000]u8 = undefined;
    var reader = file.reader(init.io, &buffer);

    const img = try parse_image(init.gpa, &reader.interface);
    defer @constCast(&img.map).clearAndFree();

    var conv = std.AutoHashMap(Point, u8).init(init.gpa);
    defer conv.deinit();

    // fill out convolution
    {
        var iter = img.map.iterator();
        while (iter.next()) |val| {
            const x, const y = val.key_ptr.*;
            for ([_]isize{ -1, 0, 1 }) |i| {
                for ([_]isize{ -1, 0, 1 }) |j| {
                    if (i == 0 and j == 0) continue;

                    const entry = try conv.getOrPutValue(.{ x + i, y + j }, 0);
                    entry.value_ptr.* += 1;
                }
            }
        }
    }

    // read convolution
    var count: isize = 0;
    for (0..img.h) |y| {
        for (0..img.w) |x| {
            const key: Point = .{ @intCast(x), @intCast(y) };
            const original_had_paper = img.map.contains(key);
            const neighbour_count = conv.get(key) orelse 0;
            // std.log.info("pair {}, {} had {} neighbours with {} ", .{ i, j, neighbour_count, original_had_paper });

            if (original_had_paper)
                std.debug.print("@", .{})
            else
                std.debug.print(".", .{});

            if (original_had_paper and neighbour_count < 4) count += 1;
        }
        std.debug.print("\n", .{});
    }

    std.log.debug("h,w: {}, {}", .{ img.h, img.w });
    std.log.debug("Count {}", .{count});
}
