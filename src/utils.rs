pub fn right_pad(s: &str, length: usize) -> String {
    if s.len() >= length {
        s[..length].to_string()
    } else {
        format!("{}{}", s, " ".repeat(length - s.len()))
    }
}

pub fn left_pad(s: &str, length: usize) -> String {
    if s.len() >= length {
        s[..length].to_string()
    } else {
        format!("{}{}", " ".repeat(length - s.len()), s)
    }
}
