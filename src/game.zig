const std = @import("std");
const Player = @import("player.zig");
const Bullet = @import("bullet.zig").Bullet;
const Asteroid = @import("asteroid.zig").Asteroid;
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;
const vec2 = @import("vec2.zig").Vec2;
const RndGen = std.rand.DefaultPrng;

var SCREEN_WIDTH: f32 = 0.0;
var SCREEN_HEIGHT: f32 = 0.0;

// once clear, we restart with more
//keeping it simple
// an array of asteroids
// - starting with 2 big ones (spawn 2 big)
// - if bullet hits, half the size (spawn 2 after each hit at size / 2)
// - keep halfing until a limit

const MAX_NUMBER_OF_ASTEROIDS = 8;

// TODO: Break this up into "Game" and "Player"
pub const Game = struct {
    player: Player.Player,
    bullets: [10]Bullet = undefined,

    asteroids: [MAX_NUMBER_OF_ASTEROIDS]Asteroid = undefined,
    asteroid_verticies: [20]vec2(f32) = undefined,

    lives: u8 = 0,
    score: u8 = 0,

    const Self = @This();

    pub fn draw(self: *const Self) void {
        self.asteroids_draw();

        if (self.lives > 0) {
            self.player.draw();
        }

        for (self.bullets) |bullet| {
            if (bullet.visible)
                bullet.draw();
        }
    }

    pub fn update(self: *Self, time: f32) void {

        // Update Asteroids
        for (&self.asteroids) |*asteroid| {
            asteroid.update(time);
            asteroid.angle += 0.5 * time; // Small rotation

            screen_wrap(asteroid.x, asteroid.y, &asteroid.x, &asteroid.y);
        }

        // Update all visible bullets
        for (self.bullets, 0..) |_, index| {
            self.bullets[index].update(time);

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
        screen_wrap(self.player.position.x, self.player.position.y, &self.player.position.x, &self.player.position.y);
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

    fn asteroids_draw(self: Self) void {
        for (self.asteroids) |asteroid| {
            if (asteroid.size > 0.0) {
                std.debug.print("Drawing an Asteroid\n", .{});
                _ = SDL.SDL_SetRenderDrawColor(Graphics.GrpahicsManager.renderer, 255, 255, 255, 255);

                const vert_count = self.asteroid_verticies.len;
                for (0..vert_count) |i| {
                    // Rotate
                    var v1: vec2(f32) = self.asteroid_verticies[i].rotate(asteroid.angle);
                    var v2: vec2(f32) = self.asteroid_verticies[(i + 1) % vert_count].rotate(asteroid.angle);
                    // Scale
                    v1.scale(asteroid.size);
                    v2.scale(asteroid.size);
                    // Translate
                    v1.add(vec2(f32){ .x = asteroid.x, .y = asteroid.y });
                    v2.add(vec2(f32){ .x = asteroid.x, .y = asteroid.y });

                    _ = SDL.SDL_RenderDrawLine(Graphics.GrpahicsManager.renderer, @floatToInt(c_int, v1.x), @floatToInt(c_int, v1.y), @floatToInt(c_int, v2.x), @floatToInt(c_int, v2.y));
                }
            }
        }
    }
};

// Stay within the bounds of the screen with wrapping
fn screen_wrap(current_x: f32, current_y: f32, new_x: *f32, new_y: *f32) void {
    new_x.* = current_x;
    new_y.* = current_y;

    if (current_x < 0.0)
        new_x.* = current_x + SCREEN_WIDTH;
    if (current_x >= SCREEN_WIDTH)
        new_x.* = current_x - SCREEN_WIDTH;

    if (current_y < 0.0)
        new_y.* = current_y + SCREEN_HEIGHT;
    if (current_y >= SCREEN_HEIGHT)
        new_y.* = current_y - SCREEN_HEIGHT;
}

pub fn game_init() Game {
    var rnd = RndGen.init(0);

    SCREEN_WIDTH = @intToFloat(f32, Graphics.GrpahicsManager.width);
    SCREEN_HEIGHT = @intToFloat(f32, Graphics.GrpahicsManager.height);

    var game: Game = Game{
        .player = Player.player_init(),
    };

    // Create the astroid shape verticies
    const asteroid_verticies_len = @intToFloat(f32, game.asteroid_verticies.len);
    for (&game.asteroid_verticies, 0..) |*vert, index| {
        const noise = rnd.random().float(f32) * 0.4 + 0.8;

        vert.x = noise * std.math.sin((@intToFloat(f32, index) / asteroid_verticies_len) * (2.0 * std.math.pi));
        vert.y = noise * std.math.cos((@intToFloat(f32, index) / asteroid_verticies_len) * (2.0 * std.math.pi));
    }

    // Initial 2 astroids positions
    game.asteroids[0] = Asteroid{
        .x = SCREEN_WIDTH / 4.0,
        .y = SCREEN_HEIGHT / 4.0,
        .vel_x = 8.0,
        .vel_y = -6.0,
        .angle = 0.0,
        .size = 64,
    };

    game.asteroids[1] = Asteroid{
        .x = -SCREEN_WIDTH / 4.0,
        .y = -SCREEN_HEIGHT / 4.0,
        .vel_x = -5.0,
        .vel_y = 3.0,
        .angle = 0.0,
        .size = 64,
    };

    game.lives = 5;
    game.score = 0;

    return game;
}
