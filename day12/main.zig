const input = @embedFile("input.txt");

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    g = std.StringHashMap(std.ArrayList([]const u8)).init(alloc);
    visited_set = std.StringHashMap(void).init(alloc);

    var it = std.mem.tokenize(u8, input, "\n-");

    while (it.next()) |nodeA| {
        const nodeB = it.next().?;

        for ([2][2][]const u8{ .{ nodeA, nodeB }, .{ nodeB, nodeA } }) |kv| {
            const entry = try g.getOrPut(kv[0]);
            if (!entry.found_existing) entry.value_ptr.* = std.ArrayList([]const u8).init(alloc);
            try entry.value_ptr.append(kv[1]);
        }
    }

    // flip the second argument to true for part1 semantics
    try dfs("start", false);

    std.debug.print("result: {}\n", .{paths_count});
}

var g: std.StringHashMap(std.ArrayList([]const u8)) = undefined;
var visited_set: std.StringHashMap(void) = undefined;
var paths_count: usize = 0;

fn dfs(
    current_cave: []const u8,
    visited_twice: bool,
) anyerror!void {
    var visiting_twice_now = false;

    if (std.mem.eql(u8, current_cave, "end")) {
        paths_count += 1;
        return;
    }

    if (current_cave[0] >= 'a') {
        if (visited_set.contains(current_cave)) {
            if (visited_twice) return;
            visiting_twice_now = true;
        } else {
            try visited_set.put(current_cave, {});
        }
    }
    defer if (current_cave[0] >= 'a' and !visiting_twice_now) {
        _ = visited_set.remove(current_cave);
    };

    const value = g.get(current_cave) orelse return;

    for (value.items) |cave| {
        if (std.mem.eql(u8, cave, "start")) continue;
        if (visited_set.contains(cave) and visited_twice) continue;
        try dfs(cave, visited_twice or visiting_twice_now);
    }
}
