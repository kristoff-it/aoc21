const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n ");
    var final_result: usize = 0;

    outer: while (true) {
        var unique_digits = [1]u7{0} ** 10;
        var final_digits = [1]u7{0} ** 4;

        for (unique_digits) |*d| {
            const string = it.next() orelse break :outer;
            for (string) |c| {
                d.* |= @as(u7, 1) << @intCast(u3, c - 'a');
            }
        }
        if (!std.mem.eql(u8, "|", it.next().?)) @panic("bad parser");
        for (final_digits) |*d| {
            const string = it.next().?;
            for (string) |c| {
                d.* |= @as(u7, 1) << @intCast(u3, c - 'a');
            }
        }

        // 1 and 7 find the `a` segment and the `cf` candidates
        const digit_one = for (unique_digits) |d| {
            if (@popCount(u7, d) == 2) break d;
        } else unreachable;

        const digit_seven = for (unique_digits) |d| {
            if (@popCount(u7, d) == 3) break d;
        } else unreachable;

        const digit_four = for (unique_digits) |d| {
            if (@popCount(u7, d) == 4) break d;
        } else unreachable;

        const segment_a = digit_seven & ~digit_one;
        const segments_cf = digit_one;

        const segments_bd = digit_four & ~digit_one;

        var digits_zero_six_nine: [3]u7 = undefined;
        {
            var i: usize = 0;
            for (unique_digits) |d| {
                if (@popCount(u7, d) == 6) {
                    digits_zero_six_nine[i] = d;
                    i += 1;
                }
            }

            if (i != 3) unreachable;
        }

        for (digits_zero_six_nine) |d, idx| std.debug.print(">[{d}] {b:0>7}\n", .{ idx, d });

        // find which is b and which is d
        var segment_b: u7 = 0;
        var segment_d: u7 = 0;
        var digit_zero: u7 = 0;
        {
            for (digits_zero_six_nine) |d| {
                const common_segments = d & segments_bd;
                if (@popCount(u7, common_segments) == 1) {
                    digit_zero = d;
                    segment_b = common_segments;
                    segment_d = segments_bd & ~segment_b;
                    break;
                }
            } else unreachable;
        }

        // find f and c
        var segment_c: u7 = 0;
        var segment_f: u7 = 0;
        var digit_six: u7 = 0;
        {
            for (digits_zero_six_nine) |d| {
                const common_segments = d & segments_cf;
                if (@popCount(u7, common_segments) == 1) {
                    digit_six = d;
                    segment_f = common_segments;
                    segment_c = segments_cf & ~segment_f;
                    break;
                }
            } else unreachable;
        }

        // find e and g
        var segment_e: u7 = 0;
        var segment_g: u7 = 0;
        var digit_nine: u7 = 0;
        {
            var segments_eg = ~(digit_four | segment_a);
            for (digits_zero_six_nine) |d| {
                const common_segments = d & segments_eg;
                if (@popCount(u7, common_segments) == 1) {
                    digit_nine = d;
                    segment_g = common_segments;
                    segment_e = segments_eg & ~segment_g;
                    break;
                }
            } else unreachable;
        }

        const digit_eight = ~@as(u7, 0);

        const digit_two = segment_a | segment_c | segment_d | segment_e | segment_g;
        const digit_three = segment_a | segment_c | segment_d | segment_f | segment_g;
        const digit_five = segment_a | segment_b | segment_d | segment_f | segment_g;
        const digits: [10]u7 = .{
            digit_zero,
            digit_one,
            digit_two,
            digit_three,
            digit_four,
            digit_five,
            digit_six,
            digit_seven,
            digit_eight,
            digit_nine,
        };

        for (digits) |d, idx| std.debug.print("[{d}] {b:0>7}\n", .{ idx, d });

        var partial_result: usize = 0;
        for (final_digits) |fd| {
            const n = for (digits) |d, idx| {
                if (fd == d) break idx;
            } else unreachable;

            partial_result *= 10;
            partial_result += n;
        }

        final_result += partial_result;
    }

    std.debug.print("result: {}\n", .{final_result});
}

pub fn main1() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, "\n ");
    var counter: usize = 0;

    outer: while (true) {
        var unique_digits: [10][]const u8 = undefined;
        var final_digits: [4][]const u8 = undefined;

        for (unique_digits) |*d| d.* = it.next() orelse break :outer;

        if (!std.mem.eql(u8, "|", it.next().?)) @panic("bad parser");

        for (final_digits) |*d| d.* = it.next().?;

        for (final_digits) |d| {
            switch (d.len) {
                2, 3, 4, 7 => {
                    counter += 1;
                },
                else => {},
            }
        }
    }

    std.debug.print("result: {}\n", .{counter});
}
