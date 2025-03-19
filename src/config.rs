use std::collections::{HashMap, HashSet};
use std::sync::OnceLock;

/// Get the mapping of programming languages to their file extensions
pub fn languages() -> &'static HashMap<&'static str, &'static str> {
    static LANGUAGES: OnceLock<HashMap<&'static str, &'static str>> = OnceLock::new();
    LANGUAGES.get_or_init(|| {
        let mut map = HashMap::new();
        map.insert("Rust", "rs");
        map.insert("Haskell", "hs");
        map.insert("Lua", "lua");
        map.insert("TypeScript", "ts");
        map.insert("JavaScript", "js");
        map.insert("Go", "go");
        map
    })
}

/// Get the set of directory names that should be ignored during analysis
pub fn ignored_dirs() -> &'static HashSet<&'static str> {
    static IGNORED_DIRS: OnceLock<HashSet<&'static str>> = OnceLock::new();
    IGNORED_DIRS.get_or_init(|| {
        let mut set = HashSet::new();
        set.insert("node_modules");
        set.insert("dist");
        set.insert(".dist");
        set.insert("out");
        set.insert("build");
        set.insert(".build");
        set.insert("__pycache__");
        set.insert(".git");
        set.insert("venv");
        set.insert("env");
        set.insert(".venv");
        set.insert("target");
        set.insert(".target");
        set
    })
}
