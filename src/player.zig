const std = @import("std");
const SDL = Graphics.SDL;
const vec2 = @import("vec2.zig").Vec2;
const Graphics = @import("graphics.zig");

const Player = struct {
    position: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    velocity: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    verticies: [3]vec2(f32) = undefined,

    lives: u8 = 0,

    const Self = @This();

    pub fn draw(self: *const Self) void {
        if (self.lives > 0) {
            const graphics_manager = Graphics.GrpahicsManager;

            _ = SDL.SDL_SetRenderDrawColor(graphics_manager.renderer, 255, 255, 255, 255);

            // Beautiful wideass code))
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.verticies[0].x), @floatToInt(c_int, self.verticies[0].y), @floatToInt(c_int, self.verticies[1].x), @floatToInt(c_int, self.verticies[1].y));
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.verticies[1].x), @floatToInt(c_int, self.verticies[1].y), @floatToInt(c_int, self.verticies[2].x), @floatToInt(c_int, self.verticies[2].y));
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.verticies[2].x), @floatToInt(c_int, self.verticies[2].y), @floatToInt(c_int, self.verticies[0].x), @floatToInt(c_int, self.verticies[0].y));
        }
    }
};

// TODO : do this all at compile time?
pub fn player_init() Player {
    var player: Player = Player{};

    player.position = vec2(f32){ .x = 100.0, .y = 100.0 };
    player.velocity = vec2(f32){ .x = 0.0, .y = 0.0 };
    player.lives = 5;

    var object_verticies = [3]vec2(f32){
        vec2(f32){ .x = 0.0, .y = 1.5 },
        vec2(f32){ .x = -1.0, .y = -1.0 },
        vec2(f32){ .x = 1.0, .y = -1.0 },
    };

    var translation = vec2(f32){
        .x = @intToFloat(f32, Graphics.GrpahicsManager.width) / 2.0,
        .y = @intToFloat(f32, Graphics.GrpahicsManager.height) / 2.0,
    };

    player.verticies[0] = object_verticies[0].scaled(12).translated(translation);
    player.verticies[1] = object_verticies[1].scaled(12).translated(translation);
    player.verticies[2] = object_verticies[2].scaled(12).translated(translation);

    return player;
}
