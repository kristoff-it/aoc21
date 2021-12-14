const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var rules = std.AutoHashMap([2]u8, u8).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n ");

    var base = it.next().?;

    while (it.next()) |from| {
        if (!std.mem.eql(u8, it.next().?, "->")) unreachable;
        const to = it.next().?;

        try rules.put(from[0..2].*, to[0]);
    }

    var buffer = std.ArrayList(u8).init(alloc);
    var temp = std.ArrayList(u8).init(alloc);

    try buffer.appendSlice(base);
    {
        var j: usize = 0;
        while (j < 20) : (j += 1) {
            temp.clearRetainingCapacity();
            var p: usize = 0;
            // std.debug.print("[{s}]\n", .{buffer.items});
            while (p < buffer.items.len - 1) : (p += 1) {
                const pair = buffer.items[p..buffer.items.len][0..2].*;
                const expansion = rules.get(pair).?;
                try temp.appendSlice(&.{ pair[0], expansion });
                // counts[expansion - 'A'] += 1;
            }
            try temp.append(buffer.items[buffer.items.len - 1]);
            var t = temp;
            temp = buffer;
            buffer = t;
        }
    }

    std.debug.print("DONE EXPANDING!\n", .{});
    base = buffer.toOwnedSlice();

    var rule_scores = std.AutoHashMap([2]u8, [26]usize).init(alloc);
    {
        var rit = rules.keyIterator();
        var rit_i: usize = 0;
        while (rit.next()) |rule_ptr| : (rit_i += 1) {
            const rule_len = rules.count();
            std.debug.print("[{}/{}] [{s}]\n", .{ rit_i, rule_len, rule_ptr });
            buffer.clearRetainingCapacity();
            try buffer.appendSlice(rule_ptr);
            var counts_per_rule = std.mem.zeroes([26]usize);

            var j: usize = 0;
            while (j < 20) : (j += 1) {
                temp.clearRetainingCapacity();
                var p: usize = 0;
                while (p < buffer.items.len - 1) : (p += 1) {
                    const pair = buffer.items[p..buffer.items.len][0..2].*;
                    const expansion = rules.get(pair).?;

                    // std.debug.print("p: {}, pair: {s}, ex: {c}\n", .{ p, pair, expansion });
                    try temp.appendSlice(&.{ pair[0], expansion });
                }
                try temp.append(buffer.items[buffer.items.len - 1]);
                // std.debug.print("[{s}]\n\n", .{temp.items});
                var t = temp;
                temp = buffer;
                buffer = t;
            }

            // std.debug.print("[{s}]\n[{s}]\n\n", .{ rule_ptr, buffer.items });
            for (buffer.items) |c| counts_per_rule[c - 'A'] += 1;
            counts_per_rule[rule_ptr[1] - 'A'] -= 1;

            try rule_scores.put(rule_ptr.*, counts_per_rule);
        }
    }

    var counts = std.mem.zeroes([26]usize);

    var i: usize = 0;
    while (i < base.len - 1) : (i += 1) {
        std.debug.print("[{}/{}]\n", .{ i, base.len });
        const pair = base[i..base.len][0..2].*;

        const partial = rule_scores.get(pair).?;
        for (partial) |p, j| counts[j] += p;
    }

    counts[base[base.len - 1] - 'A'] += 1;

    // for (base) |b| counts[b - 'A'] += 1;

    std.sort.sort(usize, &counts, {}, comptime std.sort.asc(usize));
    const high = counts[counts.len - 1];
    const min = for (counts) |c| {
        if (c > 0) break c;
    } else unreachable;

    std.debug.print("result: {d}\n", .{high - min});
}
