const std = @import("std");

pub const Asteroid = struct {
    x: f32,
    y: f32,
    vel_x: f32,
    vel_y: f32,
    angle: f32,
    size: f32, //scale

    const Self = @This();

    pub fn init(x: f32, y: f32, vel_x: f32, vel_y: f32, angle: f32, size: f32) Asteroid {
        return Asteroid{
            .x = x,
            .y = y,
            .vel_x = vel_x,
            .vel_y = vel_y,
            .angle = angle,
            .size = size,
        };
    }

    pub fn update(self: *Self, time: f32) void {
        self.x += self.vel_x * time;
        self.y += self.vel_y * time;
    }
};
