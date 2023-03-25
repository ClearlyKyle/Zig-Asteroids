const std = @import("std");

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn make(x: T, y: T) Self {
            return .{ .x = x, .y = y };
        }

        pub fn translate(self: *Self, vec2: Self) void {
            self.x += vec2.x;
            self.y += vec2.y;
        }

        pub fn translated(self: Self, vec2: Self) Self {
            return .{ .x = self.x + vec2.x, .y = self.y + vec2.y };
        }

        pub const add = translate;
        pub const added = translated;

        pub fn subtract(self: *Self, vec2: Self) void {
            self.x -= vec2.x;
            self.y -= vec2.y;
        }

        pub fn subtracted(self: Self, vec2: Self) Self {
            return .{ .x = self.x - vec2.x, .y = self.y - vec2.y };
        }

        pub fn scaled(self: Self, s: T) Self {
            return .{ .x = self.x * s, .y = self.y * s };
        }

        pub fn dot(self: Self, vec2: Self) T {
            return self.x * vec2.x + self.y * vec2.y;
        }

        pub fn lengthSquared(self: Self) T {
            return self.dot(self);
        }

        pub fn length(self: Self) T {
            return std.math.sqrt(self.lengthSquared());
        }

        pub fn angle(self: Self) T {
            return std.math.atan2(T, self.y, self.x);
        }

        pub fn eql(self: Self, vec2: Self) bool {
            return self.x == vec2.x and self.y == vec2.y;
        }

        pub fn lerp(a: Self, b: Self, t: T) Self {
            return .{ .x = mix(a.x, b.x, t), .y = mix(a.y, b.y, t) };
        }

        fn mix(a: T, b: T, t: T) T {
            return (1 - t) * a + t * b;
        }

        pub fn min(a: Self, b: Self) Self {
            return .{ .x = std.math.min(a.x, b.x), .y = std.math.min(a.y, b.y) };
        }

        pub fn max(a: Self, b: Self) Self {
            return .{ .x = std.math.max(a.x, b.x), .y = std.math.max(a.y, b.y) };
        }
    };
}
