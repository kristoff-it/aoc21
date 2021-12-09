const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var oxy_nums = std.StringHashMap(void).init(alloc);
    var co2_nums = std.StringHashMap(void).init(alloc);
    {
        var it = std.mem.tokenize(u8, input, "\n");
        while (it.next()) |bin| {
            try oxy_nums.put(bin, {});
            try co2_nums.put(bin, {});
        }
    }

    // oxy
    {
        var column: usize = 0;
        while (oxy_nums.count() > 1) : (column += 1) {
            // Find most popular bit among the alive numbers
            const good_bit: u8 = blk: {
                var count: isize = 0;
                var it = oxy_nums.keyIterator();
                while (it.next()) |key_ptr| {
                    count += switch (key_ptr.*[column]) {
                        '0' => @as(isize, -1),
                        '1' => 1,
                        else => unreachable,
                    };
                }

                break :blk if (count >= 0) @as(u8, '1') else '0';
            };

            // Kill numbers without it
            var it = oxy_nums.keyIterator();
            while (it.next()) |key_ptr| {
                if (key_ptr.*[column] != good_bit) {
                    _ = oxy_nums.remove(key_ptr.*);
                    it = oxy_nums.keyIterator();
                }
            }
        }
    }

    //co2
    {
        var column: usize = 0;
        while (co2_nums.count() > 1) : (column += 1) {
            // Find most popular bit among the alive numbers
            const good_bit: u8 = blk: {
                var count: isize = 0;
                var it = co2_nums.keyIterator();
                while (it.next()) |key_ptr| {
                    count += switch (key_ptr.*[column]) {
                        '0' => @as(isize, -1),
                        '1' => 1,
                        else => unreachable,
                    };
                }

                break :blk if (count >= 0) @as(u8, '0') else '1';
            };

            // Kill numbers without it
            var it = co2_nums.keyIterator();
            while (it.next()) |key_ptr| {
                if (key_ptr.*[column] != good_bit) {
                    _ = co2_nums.remove(key_ptr.*);
                    it = co2_nums.keyIterator();
                }
            }
        }
    }
    const oxy = oxy_nums.keyIterator().next().?.*;
    const co2 = co2_nums.keyIterator().next().?.*;

    std.debug.print("oxy: {s}\n", .{oxy});
    std.debug.print("co2: {s}\n", .{co2});
    std.debug.print("result: {d}\n", .{
        (try std.fmt.parseInt(usize, oxy, 2)) *
            (try std.fmt.parseInt(usize, co2, 2)),
    });
}

pub fn main1() !void {
    var it = std.mem.tokenize(u8, input, "\n");

    var counts = [1]isize{0} ** 12;

    while (it.next()) |bin| {
        for (bin) |c, idx| {
            counts[idx] += switch (c) {
                '0' => @as(isize, -1),
                '1' => 1,
                else => unreachable,
            };
        }
    }

    var gamma: u12 = 0;
    for (counts) |c, idx| {
        if (c > 0) gamma |= @as(u12, 1) << @intCast(u4, idx);
    }

    gamma = @bitReverse(u12, gamma);

    const epsilon = ~gamma;

    std.debug.print("gamma:   {b}\n", .{gamma});
    std.debug.print("epsilon: {b:0>12}\n", .{epsilon});

    std.debug.print("result: {}\n", .{gamma * @as(u64, epsilon)});
}
