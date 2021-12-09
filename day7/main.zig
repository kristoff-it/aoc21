const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, ",");
    var positions = std.ArrayList(i32).init(alloc);

    while (it.next()) |token| {
        const p = try std.fmt.parseInt(i32, token, 10);
        try positions.append(p);
    }

    std.sort.sort(i32, positions.items, {}, comptime std.sort.asc(i32));

    var sum: f64 = 0;
    for (positions.items) |p| sum += @intToFloat(f64, p);
    const mean: i32 = @floatToInt(i32, @floor(sum / @intToFloat(f64, positions.items.len)));
    std.debug.print("mean: {d}\n", .{mean});

    var res: i32 = 0;
    for (positions.items) |p| res += cost(try std.math.absInt(p - mean));

    std.debug.print("result: {}\n", .{res});
}

fn cost(n: i32) i32 {
    return @divExact(n * (n + 1), 2);
}

pub fn main1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var it = std.mem.tokenize(u8, input, ",");
    var positions = std.ArrayList(i32).init(alloc);

    while (it.next()) |token| {
        const p = try std.fmt.parseInt(i32, token, 10);
        try positions.append(p);
    }

    std.sort.sort(i32, positions.items, {}, comptime std.sort.asc(i32));

    const median = positions.items[@divExact(positions.items.len, 2)];

    var res: i32 = 0;
    for (positions.items) |p| res += try std.math.absInt(p - median);

    std.debug.print("result: {}\n", .{res});
}
