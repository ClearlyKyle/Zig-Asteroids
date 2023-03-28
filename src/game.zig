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

            // Check Bullet collision with asteroid :D
            for (&self.asteroids, 0..) |*asteroid, asteroid_index| {
                if (is_there_a_point_inside_the_asteroid(asteroid.*, self.bullets[index].x, self.bullets[index].y) and self.bullets[index].visible) {
                    std.debug.print("Bullet hit an asteroid!\n", .{});
                    self.score += 1;
                    self.bullets[index].visible = false;

                    if (asteroid.size > 31.0) // Spawn two new smaller asteroids, baby asteroids
                    {
                        std.debug.print("Drawing a new Asteroid\n", .{});
                        const asteroid_verticies_len = @intToFloat(f32, self.asteroid_verticies.len);
                        const angle1 = std.math.sin((@intToFloat(f32, asteroid_index) / asteroid_verticies_len) * (2.0 * std.math.pi));
                        const angle2 = std.math.cos((@intToFloat(f32, asteroid_index) / asteroid_verticies_len) * (2.0 * std.math.pi));

                        // update the current asteroid to be half the size
                        asteroid.*.size /= 2.0;
                        asteroid.*.vel_x = 10.0 * std.math.sin(angle1);
                        asteroid.*.vel_y = 10.0 * std.math.cos(angle1);
                        asteroid.*.angle = 0.0;

                        // now find a free place in the astroid list to put the second new astroid
                        // as once an asteroid is hit, it splits into two
                        for (&self.asteroids) |*free_asteroid| {
                            if (free_asteroid.size < 15.0) {
                                free_asteroid.x = asteroid.x;
                                free_asteroid.y = asteroid.y;
                                free_asteroid.size = asteroid.size;
                                free_asteroid.vel_x = 10.0 * std.math.sin(angle2);
                                free_asteroid.vel_y = 10.0 * std.math.cos(angle2);
                                free_asteroid.angle = 45.0;
                                break;
                            }
                        }
                    } else {
                        asteroid.size = 0.0; // asteroid is reached the limit of size and wont be drawn anymore
                    }
                }
            }
        }

        // Check if there are no Asteroids left and spawn some more :D
        for (self.asteroids) |asteroid| {
            if (asteroid.size > 15.0)
                break;
        } else {
            // No more asteroids so time to spawn some
            self.initialise_two_asteroids();
        }

        // Update the Player
        screen_wrap(self.player.position.x, self.player.position.y, &self.player.position.x, &self.player.position.y);
        self.player.update(time);

        // Check if the player collides here))
        for (self.asteroids) |asteroid| {
            // This way checks the center of the spaceship against an asteroid
            //if (is_there_a_point_inside_the_asteroid(asteroid, self.player.position.x, self.player.position.y)) {
            //    self.alive = false;
            //    break;
            //}

            //  This way checks all verticies of the spaceship triangle against an asteroid
            if (is_there_a_point_inside_the_asteroid(asteroid, self.player.trans_verticies[0].x, self.player.trans_verticies[0].y) or
                is_there_a_point_inside_the_asteroid(asteroid, self.player.trans_verticies[1].x, self.player.trans_verticies[1].y) or
                is_there_a_point_inside_the_asteroid(asteroid, self.player.trans_verticies[2].x, self.player.trans_verticies[2].y))
            {
                self.alive = false;
                break;
            }
        }
        // Show score and lives
        const title_text = std.fmt.allocPrint(std.heap.page_allocator, "Score : {}", .{self.score}) catch unreachable; // I think this is sketchy!
        SDL.SDL_SetWindowTitle(Graphics.GrpahicsManager.window, title_text.ptr);
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

    pub fn is_there_a_point_inside_the_asteroid(asteroid: Asteroid, point_x: f32, point_y: f32) bool {
        return std.math.sqrt((asteroid.x - point_x) * (asteroid.x - point_x) + (asteroid.y - point_y) * (asteroid.y - point_y)) < asteroid.size;
    }

    fn asteroids_draw(self: Self) void {
        for (self.asteroids) |asteroid| {
            if (asteroid.size > 0.0) {
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

    fn initialise_two_asteroids(self: *Self) void {
        const half_of_pi = std.math.pi / 2.0;
        _ = half_of_pi;
        var rnd = RndGen.init(0);

        self.asteroids[0] = Asteroid{
            .x = self.player.position.x + 50.0 + rnd.random().float(f32) * SCREEN_WIDTH,
            .y = self.player.position.y + 50.0 + rnd.random().float(f32) * SCREEN_HEIGHT,
            .vel_x = 16.0 * std.math.sin(self.player.angle),
            .vel_y = -12.0 * std.math.cos(self.player.angle),
            .angle = 0.0,
            .size = 64,
        };

        self.asteroids[1] = Asteroid{
            .x = self.player.position.x - 50.0 + rnd.random().float(f32) * SCREEN_WIDTH,
            .y = self.player.position.y - 50.0 + rnd.random().float(f32) * SCREEN_HEIGHT,
            .vel_x = -10.0 * std.math.sin(-self.player.angle),
            .vel_y = 6.0 * std.math.cos(-self.player.angle),
            .angle = 0.0,
            .size = 64,
        };
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
        .vel_x = 16.0,
        .vel_y = -12.0,
        .angle = 0.0,
        .size = 64,
    };

    game.asteroids[1] = Asteroid{
        .x = -SCREEN_WIDTH / 4.0,
        .y = -SCREEN_HEIGHT / 4.0,
        .vel_x = -10.0,
        .vel_y = 6.0,
        .angle = 0.0,
        .size = 64,
    };

    game.lives = 5;
    game.score = 0;

    return game;
}
