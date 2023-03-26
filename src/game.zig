const std = @import("std");
const Player = @import("player.zig");
const Bullet = @import("bullet.zig").Bullet;
const Graphics = @import("graphics.zig");

// TODO: Break this up into "Game" and "Player"
pub const Game = struct {
    player: Player.Player,
    bullets: [10]Bullet = undefined,

    lives: u8 = 0,
    score: u8 = 0,

    const Self = @This();

    pub fn draw(self: *const Self) void {
        if (self.lives > 0) {
            self.player.draw();
        }

        for (self.bullets) |bullet| {
            if (bullet.visible)
                bullet.draw();
        }
    }

    pub fn update(self: *Self, time: f32) void {
        // Update all visible bullets
        for (self.bullets, 0..) |_, index| {
            self.bullets[index].update(time);

            const SCREEN_WIDTH = @intToFloat(f32, Graphics.GrpahicsManager.width);
            const SCREEN_HEIGHT = @intToFloat(f32, Graphics.GrpahicsManager.height);

            // Check for bullets being out of screen
            // and stop drawing them if they are not visible
            if (self.bullets[index].x < 0.0 or
                self.bullets[index].y < 0.0 or
                self.bullets[index].x > SCREEN_WIDTH or
                self.bullets[index].y > SCREEN_HEIGHT)
            {
                self.bullets[index].visible = false;
            }
        }

        // Update the Player
        self.player.update(time);
    }

    pub fn fire_bullet(self: *Self) void {
        for (self.bullets, 0..) |_, index| {
            if (self.bullets[index].visible == false) { // we can fire a bullet

                // Should be tip of the triangle
                self.bullets[index].x = self.player.trans_verticies[0].x;
                self.bullets[index].y = self.player.trans_verticies[0].y;

                self.bullets[index].vel_x = self.player.velocity.x + 150.0 * std.math.sin(self.player.angle);
                self.bullets[index].vel_y = self.player.velocity.y - 150.0 * std.math.cos(self.player.angle);

                self.bullets[index].visible = true;
                break;
            }
        }
    }
};

pub fn game_init() Game {
    return .{
        .player = Player.player_init(),
        .lives = 5,
        .score = 0,
    };
}
