const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var dots = std.AutoHashMap([2]u32, void).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n,=");
    while (it.next()) |tok| {
        if (tok[0] != 'f') {
            const x = try std.fmt.parseInt(u32, tok, 10);
            const y = try std.fmt.parseInt(u32, it.next().?, 10);
            try dots.put(.{ x, y }, {});
        } else {
            const axis = tok[tok.len - 1];
            const partial_coord = try std.fmt.parseInt(u32, it.next().?, 10);
            var dots_temp = std.AutoHashMap([2]u32, void).init(alloc);

            var cit = dots.iterator();
            while (cit.next()) |entry| {
                // if it's above / left of the line, do nothing
                // otherwise "flip"
                var coords = entry.key_ptr.*;

                switch (axis) {
                    'y' => {
                        if (coords[1] > partial_coord) {
                            coords[1] = (partial_coord * 2) - coords[1];
                        }
                    },
                    'x' => {
                        if (entry.key_ptr[0] > partial_coord) {
                            coords[0] = (partial_coord * 2) - coords[0];
                        }
                    },
                    else => unreachable,
                }

                try dots_temp.put(coords, {});
            }

            dots.deinit();
            dots = dots_temp;
        }
    }

    var y: u32 = 0;
    while (y < 15) : (y += 1) {
        var x: u32 = 0;
        while (x < 40) : (x += 1) {
            const v = if (dots.contains(.{ x, y })) "⚡" else "..";
            std.debug.print("{s}", .{v});
        }
        std.debug.print("\n", .{});
    }
    // std.debug.print("result: {}\n", .{dots.count()});
}
