LANGUAGES: dict[str, str] = {
    "Python": "py",
    "Rust": "rs",
    "Haskell": "hs",
    "Lua": "lua",
    "TypeScript": "ts",
    "JavaScript": "js",
    "Nix": "nix",
    "Elixir": "exs",
    "Swift": "swift",
}

IGNORED_DIRS: set[str] = {
    "node_modules",
    "dist",
    "build",
    "__pycache__",
    ".git",
    "venv",
    "env",
    ".venv",
    "target"
}
