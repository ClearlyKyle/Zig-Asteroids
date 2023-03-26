const std = @import("std");
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;

pub const Bullet = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    vel_x: f32 = 0.0, //veloctiy in x direction
    vel_y: f32 = 0.0, //veloctiy in y direction
    visible: bool = false, // Should we draw the bullet or not?

    const Self = @This();

    pub fn draw(self: Self) void {
        _ = SDL.SDL_RenderDrawPoint(Graphics.GrpahicsManager.renderer, @floatToInt(c_int, self.x), @floatToInt(c_int, self.y));
    }

    pub fn update(self: *Self, time: f32) void {
        self.x += self.vel_x * time;
        self.y += self.vel_y * time;
    }
};
