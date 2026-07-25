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

fn parse_image(gpa: std.mem.Allocator, buf: []const u8) !Image {
    var img = std.AutoHashMap(Point, u1).init(gpa);

    var x: isize = 0;
    var y: isize = 0;

    for (buf) |char| {
        switch (char) {
            '.' => x += 1,
            '@' => {
                try img.put(.{ x, y }, 1);
                x += 1;
            },
            '\n' => {
                x = 0;
                y += 1;
            },
            else => return ParseError.InvalidImage,
        }
    }

    const h = std.mem.countScalar(u8, buf, '\n') + 1;
    const w = std.mem.findScalar(u8, buf, '\n') orelse return ParseError.InvalidImage;

    return .{ .h = h, .w = w, .map = img };
}

pub fn main(init: std.process.Init) !void {
    const img = try parse_image(init.gpa, SAMPLE);
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
