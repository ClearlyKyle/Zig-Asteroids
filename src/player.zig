const std = @import("std");
const SDL = Graphics.SDL;
const vec2 = @import("vec2.zig").Vec2;
const Graphics = @import("graphics.zig");
const Bullet = @import("bullet.zig").Bullet;

// TODO: Break this up into "Game" and "Player"
const Player = struct {
    position: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    velocity: vec2(f32) = vec2(f32){ .x = 0.0, .y = 0.0 },
    object_verticies: [3]vec2(f32) = undefined,
    trans_verticies: [3]vec2(f32) = undefined,
    angle: f32 = 0.0,
    lives: u8 = 0,
    score: u8 = 0,

    bullets: [10]Bullet = undefined,

    const Self = @This();

    pub fn draw(self: *const Self) void {
        if (self.lives > 0) {
            const graphics_manager = Graphics.GrpahicsManager;

            _ = SDL.SDL_SetRenderDrawColor(graphics_manager.renderer, 255, 255, 255, 255);

            // Beautiful wideass code))
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[0].x), @floatToInt(c_int, self.trans_verticies[0].y), @floatToInt(c_int, self.trans_verticies[1].x), @floatToInt(c_int, self.trans_verticies[1].y));
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[1].x), @floatToInt(c_int, self.trans_verticies[1].y), @floatToInt(c_int, self.trans_verticies[2].x), @floatToInt(c_int, self.trans_verticies[2].y));
            _ = SDL.SDL_RenderDrawLine(graphics_manager.renderer, @floatToInt(c_int, self.trans_verticies[2].x), @floatToInt(c_int, self.trans_verticies[2].y), @floatToInt(c_int, self.trans_verticies[0].x), @floatToInt(c_int, self.trans_verticies[0].y));
        }

        for (self.bullets) |bullet| {
            if (bullet.visible)
                bullet.draw();
        }
    }

    pub fn update(self: *Self, time: f32) void {
        // Check for bullets being out of screen

        const width = @intToFloat(f32, Graphics.GrpahicsManager.width);
        const height = @intToFloat(f32, Graphics.GrpahicsManager.height);

        for (self.bullets, 0..) |_, index| {
            self.bullets[index].update(time);

            if (self.bullets[index].x < 0.0 or
                self.bullets[index].y < 0.0 or
                self.bullets[index].x > width or
                self.bullets[index].y > height)
            {
                self.bullets[index].visible = false;
            }
        }

        // Rotate
        self.trans_verticies[0] = self.object_verticies[0].rotate(self.angle);
        self.trans_verticies[1] = self.object_verticies[1].rotate(self.angle);
        self.trans_verticies[2] = self.object_verticies[2].rotate(self.angle);

        // Scale
        self.trans_verticies[0].scale(3);
        self.trans_verticies[1].scale(3);
        self.trans_verticies[2].scale(3);

        // Translate
        self.trans_verticies[0].translate(self.position);
        self.trans_verticies[1].translate(self.position);
        self.trans_verticies[2].translate(self.position);
    }

    // Stay within the bounds of the screen with wrapping
    pub fn wrap(self: *Self) void {
        const width = @intToFloat(f32, Graphics.GrpahicsManager.width);
        const height = @intToFloat(f32, Graphics.GrpahicsManager.height);

        if (self.position.x < 0.0)
            self.position.x += width;
        if (self.position.x >= width)
            self.position.x -= width;

        if (self.position.y < 0.0)
            self.position.y += height;
        if (self.position.y >= height)
            self.position.y -= height;
    }

    pub fn fire(self: *Self) void {
        for (self.bullets, 0..) |_, index| {
            if (self.bullets[index].visible == false) { // we can fire a bullet
                self.bullets[index].x = self.position.x;
                self.bullets[index].y = self.position.y;
                self.bullets[index].vel_x = self.velocity.x + 150.0 * std.math.sin(self.angle);
                self.bullets[index].vel_y = self.velocity.y - 150.0 * std.math.cos(self.angle);
                self.bullets[index].visible = true;
                break;
            }
        }
    }
};

// TODO : do this all at compile time?
pub fn player_init() Player {
    var player: Player = Player{};

    const half_screen_width = @intToFloat(f32, Graphics.GrpahicsManager.width) / 2.0;
    const half_screen_height = @intToFloat(f32, Graphics.GrpahicsManager.height) / 2.0;

    player.position = vec2(f32){ .x = half_screen_width, .y = half_screen_height };
    player.velocity = vec2(f32){ .x = 0.0, .y = 0.0 };
    player.angle = 0.0;
    player.lives = 5;
    player.score = 0;

    player.object_verticies = [3]vec2(f32){
        vec2(f32){ .x = 0.0, .y = -5.0 },
        vec2(f32){ .x = -2.5, .y = 2.5 },
        vec2(f32){ .x = 2.5, .y = 2.5 },
    };

    return player;
}
