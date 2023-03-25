const std = @import("std");
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;
const Player = @import("player.zig");
//const Vec2 = @import("vec2.zig");

pub fn main() anyerror!void {
    std.debug.print("Starting program!\n", .{});

    Graphics.init(800, 600, "Asteroids");
    defer Graphics.destroy();

    const player = Player.player_init();

    // Main window loop
    mainLoop: while (true) {
        var ev: SDL.SDL_Event = undefined;
        while (SDL.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                SDL.SDL_QUIT => break :mainLoop,
                SDL.SDL_KEYDOWN => {
                    switch (ev.key.keysym.scancode) {
                        SDL.SDL_SCANCODE_ESCAPE => break :mainLoop,
                        else => std.log.info("key pressed: {}\n", .{ev.key.keysym.scancode}),
                    }
                },

                else => {},
            }
        }
        _ = SDL.SDL_SetRenderDrawColor(Graphics.GrpahicsManager.renderer, 0, 0, 0, 255);
        _ = SDL.SDL_RenderClear(Graphics.GrpahicsManager.renderer);

        // Render Player
        player.draw();

        SDL.SDL_RenderPresent(Graphics.GrpahicsManager.renderer);
    }
}
