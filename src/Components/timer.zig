pub const Timer = struct {
    current_time: f32 = 0.0,
    max_time: f32 = 1.0,
    is_looping: bool = false,
    is_paused: bool = true,
    is_finished: bool = false,
    on_start: *const fn () void,
    on_timeout: *const fn () void,

    // Will reset current time
    pub fn play(self: *Timer) void {
        self.current_time = 0.0;
        self.is_paused = false;
        self.is_finished = false;
        self.on_start(); // Calls the on_start func
    }
};
