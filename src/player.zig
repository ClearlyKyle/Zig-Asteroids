const std = @import("std");
const SDL = Graphics.SDL;
const vec2 = @import("vec2.zig").Vec2;
const Graphics = @import("graphics.zig");

// TODO: Break this up into "Game" and "Player"
pub const Player = struct {
    position: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    velocity: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    object_verticies: [3]vec2(f32) = undefined,
    trans_verticies: [3]vec2(f32) = undefined,

    angle: f32 = 0.0,

    const Self = @This();

    pub fn draw(self: *const Self) void {
        const graphics_manager = Graphics.GrpahicsManager;

        _ = SDL.SDL_SetRenderDrawColor(graphics_manager.renderer, 255, 255, 255, 255);

        // Beautiful wideass code))
        _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[0].x), @floatToInt(c_int, self.trans_verticies[0].y), @floatToInt(c_int, self.trans_verticies[1].x), @floatToInt(c_int, self.trans_verticies[1].y));
        _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[1].x), @floatToInt(c_int, self.trans_verticies[1].y), @floatToInt(c_int, self.trans_verticies[2].x), @floatToInt(c_int, self.trans_verticies[2].y));
        _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[2].x), @floatToInt(c_int, self.trans_verticies[2].y), @floatToInt(c_int, self.trans_verticies[0].x), @floatToInt(c_int, self.trans_verticies[0].y));
    }

    pub fn update(self: *Self, time: f32) void {
        _ = time; // not used

        // Rotate
        self.trans_verticies[0] = self.object_verticies[0].rotate(self.angle);
        self.trans_verticies[1] = self.object_verticies[1].rotate(self.angle);
        self.trans_verticies[2] = self.object_verticies[2].rotate(self.angle);

        // Scale would be here too but the value never changes

        // Translate
        self.trans_verticies[0].translate(self.position);
        self.trans_verticies[1].translate(self.position);
        self.trans_verticies[2].translate(self.position);
    }

    pub fn move(self: *Self, amount: f32) void {
        self.velocity.x += std.math.sin(self.angle) * amount;
        self.velocity.y += -std.math.cos(self.angle) * amount;
    }
};

pub fn player_init() Player {
    var player: Player = Player{};

    const half_screen_width = @intToFloat(f32, Graphics.GrpahicsManager.width) / 2.0;
    const half_screen_height = @intToFloat(f32, Graphics.GrpahicsManager.height) / 2.0;

    player.position = vec2(f32){ .x = half_screen_width, .y = half_screen_height };
    player.velocity = vec2(f32){ .x = 0.0, .y = 0.0 };
    player.angle = 0.0;

    player.object_verticies = [3]vec2(f32){
        vec2(f32){ .x = 0.0, .y = -5.0 },
        vec2(f32){ .x = -2.5, .y = 2.5 },
        vec2(f32){ .x = 2.5, .y = 2.5 },
    };

    // Scale the triangle up a little
    player.object_verticies[0].scale(4);
    player.object_verticies[1].scale(4);
    player.object_verticies[2].scale(4);

    return player;
}
