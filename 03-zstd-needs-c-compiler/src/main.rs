fn main() {
    println!("[init] hello from pid {}", std::process::id());
    println!("[init] zstd {}", zstd::zstd_safe::version_string());
    loop {
        std::thread::park();
    }
}
