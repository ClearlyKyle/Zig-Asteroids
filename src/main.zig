const std = @import("std");
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;
const Player = @import("player.zig");
//const Vec2 = @import("vec2.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting program!\n", .{});

    Graphics.init(800, 600, "Asteroids");
    defer Graphics.destroy();

    var player = Player.player_init();

    var old_time: u32 = SDL.SDL_GetTicks();
    // Main window loop
    mainLoop: while (true) {
        const new_time = SDL.SDL_GetTicks();
        const time_elapsed = @intToFloat(f32, new_time - old_time) / 1000.0;

        SDL.SDL_PumpEvents();

        const state = SDL.SDL_GetKeyboardState(null);

        if (state[SDL.SDL_SCANCODE_ESCAPE] > 0) {
            break :mainLoop;
        }

        if (state[SDL.SDL_SCANCODE_UP] > 0) {
            player.velocity.x += std.math.sin(player.angle) * 64.0 * time_elapsed;
            player.velocity.y += -std.math.cos(player.angle) * 64.0 * time_elapsed;
        }

        if (state[SDL.SDL_SCANCODE_LEFT] > 0) {
            player.angle -= 6.0 * time_elapsed;
        }

        if (state[SDL.SDL_SCANCODE_RIGHT] > 0) {
            player.angle += 6.0 * time_elapsed;
        }

        //player.position += player.veloctiy * time_elapsed;
        player.position = player.position.added(player.velocity.scaled(time_elapsed));

        player.wrap(); // Stay within the screen

        var ev: SDL.SDL_Event = undefined;
        while (SDL.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                SDL.SDL_QUIT => break :mainLoop,
                SDL.SDL_KEYDOWN => {
                    switch (ev.key.keysym.scancode) {
                        SDL.SDL_SCANCODE_ESCAPE => break :mainLoop,
                        SDL.SDL_SCANCODE_SPACE => player.fire(),
                        else => {},
                    }
                },

                else => {},
            }
        }
        _ = SDL.SDL_SetRenderDrawColor(Graphics.GrpahicsManager.renderer, 0, 0, 0, 255);
        _ = SDL.SDL_RenderClear(Graphics.GrpahicsManager.renderer);

        // Update player transformed verticies
        player.update(time_elapsed);

        // Render Player
        player.draw();

        SDL.SDL_RenderPresent(Graphics.GrpahicsManager.renderer);

        old_time = new_time;
    }
}
