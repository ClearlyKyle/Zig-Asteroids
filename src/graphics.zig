const std = @import("std");
pub const SDL = @cImport(@cInclude("SDL2/SDL.h"));

//So this makes the file a giant struct?
const Graphics = @This();

window: ?*SDL.SDL_Window = null,
renderer: ?*SDL.struct_SDL_Renderer = null,

const Self = @This();

pub fn init(width: i16, height: i16, title: []const u8) Self {
    if (SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) < 0)
        sdlPanic();

    // WINDOW
    const window = SDL.SDL_CreateWindow(
        title.ptr,
        SDL.SDL_WINDOWPOS_CENTERED,
        SDL.SDL_WINDOWPOS_CENTERED,
        width,
        height,
        SDL.SDL_WINDOW_SHOWN,
    ) orelse sdlPanic();

    // RENDERER
    const renderer = SDL.SDL_CreateRenderer(window, -1, SDL.SDL_RENDERER_ACCELERATED) orelse sdlPanic();

    return Self{
        .window = window,
        .renderer = renderer,
    };
}

pub fn destroy(self: Graphics) void {
    std.debug.print("Graphics cleanup...\n", .{});
    defer std.debug.print("Graphics cleanup finished!\n", .{});

    _ = SDL.SDL_DestroyWindow(self.window);
    _ = SDL.SDL_DestroyRenderer(self.renderer);
    _ = SDL.SDL_Quit();
}

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}
