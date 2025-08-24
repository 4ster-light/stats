use std::collections::HashSet;
use std::sync::OnceLock;

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
        set.insert("bin");
        set.insert("obj");
        set.insert(".luarocks");
        set.insert("lua_modules");
        set
    })
}
