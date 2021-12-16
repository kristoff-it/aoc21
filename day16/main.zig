const input = @embedFile("input.txt");

const std = @import("std");

const Packet = struct {
    version: u3,
    type_id: u3,

    extra: union(enum) {
        literal: usize,
        operator: []Packet,
    },
};

const MyBitReader = struct {
    reader: std.io.BitReader(.Big, std.io.FixedBufferStream([]u8).Reader),
    count: usize = 0,

    pub fn readBits(self: *MyBitReader, comptime T: type, bits: usize) !T {
        var c: usize = undefined;
        const result = self.reader.readBits(T, bits, &c);

        if (c != bits) unreachable;
        self.count += c;
        return result;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var bytes: [@divExact(input.len, 2)]u8 = undefined;

    if ((try std.fmt.hexToBytes(&bytes, input)).len != bytes.len) unreachable;

    var fbs = std.io.fixedBufferStream(&bytes);
    var bits = MyBitReader{ .reader = std.io.bitReader(.Big, fbs.reader()) };

    const p = try parsePacket(&bits, alloc);

    std.debug.print("result p1: {}\n", .{sumVersions(p)});
    std.debug.print("result p2: {}\n", .{evaluate(p)});
}

fn parsePacket(bits: *MyBitReader, alloc: std.mem.Allocator) !Packet {
    const version = try bits.readBits(u3, 3);
    const type_id = try bits.readBits(u3, 3);

    return Packet{
        .version = version,
        .type_id = type_id,
        .extra = switch (type_id) {
            4 => .{ .literal = try parseLiteral(bits) },
            else => .{ .operator = try parseOperator(bits, alloc) },
        },
    };
}

fn parseOperator(bits: *MyBitReader, alloc: std.mem.Allocator) anyerror![]Packet {
    const lti = try bits.readBits(u1, 1);

    switch (lti) {
        0 => {
            const bit_end = (try bits.readBits(u15, 15)) + bits.count;

            var result = std.ArrayList(Packet).init(alloc);

            while (bits.count < bit_end) {
                try result.append(try parsePacket(bits, alloc));
            }

            if (bits.count != bit_end) unreachable;
            return result.toOwnedSlice();
        },
        1 => {
            const packet_count = try bits.readBits(u11, 11);

            var result = try alloc.alloc(Packet, packet_count);

            var i: usize = 0;
            while (i < packet_count) : (i += 1) {
                result[i] = try parsePacket(bits, alloc);
            }
            return result;
        },
    }
}

fn parseLiteral(bits: *MyBitReader) !usize {
    var result: usize = 0;
    var consumed: usize = 0;

    while ((try bits.readBits(u1, 1)) == 1) : (consumed += 5) {
        result <<= 4;
        result |= try bits.readBits(u4, 4);
    }

    result <<= 4;
    result |= try bits.readBits(u4, 4);
    consumed += 5;

    // // read any extra zero
    // const rem = consumed % 4;
    // if (rem > 0) {
    //     if ((try bits.readBits(usize, rem)) != 0) unreachable;
    // }

    return result;
}

fn sumVersions(p: Packet) usize {
    var result: usize = p.version;
    switch (p.extra) {
        .literal => {},
        .operator => |o| {
            for (o) |sp| result += sumVersions(sp);
        },
    }
    return result;
}

fn evaluate(p: Packet) usize {
    var result: usize = 0;

    switch (p.extra) {
        .literal => |l| {
            result = l;
        },
        .operator => |o| {
            switch (p.type_id) {
                0 => {
                    for (o) |sp| result += evaluate(sp);
                },
                1 => {
                    result = 1;
                    for (o) |sp| result *= evaluate(sp);
                },
                2 => {
                    result = evaluate(o[0]);
                    for (o) |sp| result = std.math.min(result, evaluate(sp));
                },
                3 => {
                    result = evaluate(o[0]);
                    for (o) |sp| result = std.math.max(result, evaluate(sp));
                },
                4 => unreachable,
                5 => {
                    if (evaluate(o[0]) > evaluate(o[1])) result = 1;
                },
                6 => {
                    if (evaluate(o[0]) < evaluate(o[1])) result = 1;
                },
                7 => {
                    if (evaluate(o[0]) == evaluate(o[1])) result = 1;
                },
            }
        },
    }
    return result;
}
