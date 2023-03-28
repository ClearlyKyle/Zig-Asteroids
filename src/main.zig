const std = @import("std");
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;
const Game = @import("game.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting!\n", .{});

    Graphics.init(800, 600, "Asteroids");
    defer Graphics.destroy();

    var game = Game.game_init();

    var old_time: u32 = SDL.SDL_GetTicks();

    mainLoop: while (true) { // Main window loop
        const new_time = SDL.SDL_GetTicks();
        const time_elapsed = @intToFloat(f32, new_time - old_time) / 1000.0;

        SDL.SDL_PumpEvents();

        const state = SDL.SDL_GetKeyboardState(null);

        if (state[SDL.SDL_SCANCODE_ESCAPE] > 0) {
            break :mainLoop;
        }

        var p = &game.player;

        if (state[SDL.SDL_SCANCODE_UP] > 0) {
            p.velocity.x += std.math.sin(p.angle) * 64.0 * time_elapsed;
            p.velocity.y += -std.math.cos(p.angle) * 64.0 * time_elapsed;
        }

        if (state[SDL.SDL_SCANCODE_LEFT] > 0) {
            p.angle -= 6.0 * time_elapsed;
        }

        if (state[SDL.SDL_SCANCODE_RIGHT] > 0) {
            p.angle += 6.0 * time_elapsed;
        }

        //player.position += player.veloctiy * time_elapsed;
        p.position = p.position.added(p.velocity.scaled(time_elapsed));

        var ev: SDL.SDL_Event = undefined;
        while (SDL.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                SDL.SDL_QUIT => break :mainLoop,
                SDL.SDL_KEYDOWN => {
                    switch (ev.key.keysym.scancode) {
                        SDL.SDL_SCANCODE_ESCAPE => break :mainLoop,
                        SDL.SDL_SCANCODE_SPACE => game.fire_bullet(),
                        else => {},
                    }
                },

                else => {},
            }
        }
        _ = SDL.SDL_SetRenderDrawColor(Graphics.GrpahicsManager.renderer, 0, 0, 0, 255);
        _ = SDL.SDL_RenderClear(Graphics.GrpahicsManager.renderer);

        // Update all game components
        game.update(time_elapsed);

        // When the player crashes into an asteroid, the game will restart
        if (game.alive == false) {
            std.debug.print("You crashed! restarting game\n", .{});
            game = Game.game_init();
        }

        // Draw the game
        game.draw();

        SDL.SDL_RenderPresent(Graphics.GrpahicsManager.renderer);

        old_time = new_time;
    }
}
