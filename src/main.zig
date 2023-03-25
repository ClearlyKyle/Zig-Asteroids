const std = @import("std");
const Graphics = @import("graphics.zig");
const SDL = Graphics.SDL;

pub fn main() anyerror!void {
    std.debug.print("Starting program!\n", .{});

    const window = Graphics.init(800, 600, "Asteroids");
    defer window.destroy();

    // Triangle verticies
    const vertices = [_]SDL.SDL_Vertex{
        .{
            .position = .{ .x = 400, .y = 150 },
            .color = .{ .r = 255, .g = 0, .b = 0, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
        .{
            .position = .{ .x = 200, .y = 450 },
            .color = .{ .r = 0, .g = 0, .b = 255, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
        .{
            .position = .{ .x = 600, .y = 450 },
            .color = .{ .r = 0, .g = 255, .b = 0, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
    };

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

        _ = SDL.SDL_SetRenderDrawColor(window.renderer, 0, 0, 0, SDL.SDL_ALPHA_OPAQUE);
        _ = SDL.SDL_RenderClear(window.renderer);
        _ = SDL.SDL_RenderGeometry(
            window.renderer,
            null,
            &vertices,
            vertices.len,
            null,
            0,
        );

        SDL.SDL_RenderPresent(window.renderer);
    }
}
