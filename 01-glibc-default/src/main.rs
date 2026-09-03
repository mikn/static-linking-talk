fn main() {
    println!("[init] hello from pid {}", std::process::id());
    loop {
        std::thread::park();
    }
}
