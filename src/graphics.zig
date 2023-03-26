const std = @import("std");
pub const SDL = @cImport(@cInclude("SDL2/SDL.h"));

pub var GrpahicsManager: Graphics = Graphics{}; //init to 0?

const Graphics = struct {
    window: ?*SDL.SDL_Window = null,
    renderer: ?*SDL.SDL_Renderer = null,
    width: u16 = 0,
    height: u16 = 0,
};

pub fn init(width: u16, height: u16, title: []const u8) void {
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

    GrpahicsManager.window = window;
    GrpahicsManager.renderer = renderer;
    GrpahicsManager.width = width;
    GrpahicsManager.height = height;
}

pub fn destroy() void {
    std.debug.print("Graphics cleanup...\n", .{});
    defer std.debug.print("Graphics cleanup finished!\n", .{});

    _ = SDL.SDL_DestroyWindow(GrpahicsManager.window);
    _ = SDL.SDL_DestroyRenderer(GrpahicsManager.renderer);
    _ = SDL.SDL_Quit();

    GrpahicsManager = Graphics{};
}

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}
