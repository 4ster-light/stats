open Printf
open Sys

(* Language file extensions mapping *)
let languages = [
  ("Python", "py");
  ("Go", "go");
  ("Templ", "templ");
  ("Rust", "rs");
  ("Haskell", "hs");
  ("OCaml", "ml");
  ("Lua", "lua");
  ("TypeScript", "ts");
  ("JavaScript", "js");
  ("Nix", "nix");
]

(* Directories to skip during analysis *)
let ignored_dirs = ["node_modules"; "dist"; "build"; "__pycache__"; ".git"]

(* Language stats type *)
type language_stats = {
  mutable files: int;
  mutable lines: int;
}

(* Analyze a single file for its language and line count *)
let analyze_file file_path =
  try
    (* Extract the file extension *)
    let ext = Filename.extension file_path in
    let ext = if String.length ext > 1 then String.sub ext 1 (String.length ext - 1) else "" in
    
    (* Find the corresponding language *)
    match List.find_opt (fun (_, lang_ext) -> lang_ext = ext) languages with
    | Some (language, _) ->
      (* Count lines in the file *)
      let ic = open_in file_path in
      let rec count_lines acc =
        match input_line ic with
        | _ -> count_lines (acc + 1)
        | exception End_of_file -> acc
      in
      let line_count = count_lines 0 in
      close_in ic;
      Some (language, line_count)
    | None -> None
  with _ ->
    eprintf "Warning: Could not process %s\n" file_path;
    None

(* Check if a path should be ignored *)
let is_ignored path =
  List.exists (fun dir -> Filename.basename path = dir) ignored_dirs

(* Recursively collect all files in a directory *)
let rec get_files dir =
  Array.fold_left (fun acc entry ->
    let full_path = Filename.concat dir entry in
    if Sys.is_directory full_path && not (is_ignored full_path) then
      acc @ get_files full_path
    else if Sys.file_exists full_path && not (is_ignored full_path) then
      full_path :: acc
    else
      acc
  ) [] (Sys.readdir dir)

(* Aggregate file analysis results into statistics *)
let aggregate_results file_analyses =
  let stats = Hashtbl.create (List.length languages) in
  let total_files = ref 0 in
  let total_lines = ref 0 in

  List.iter (fun (language, line_count) ->
    let current =
      if Hashtbl.mem stats language then Hashtbl.find stats language
      else { files = 0; lines = 0 }
    in
    current.files <- current.files + 1;
    current.lines <- current.lines + line_count;
    Hashtbl.replace stats language current;
    incr total_files;
    total_lines := !total_lines + line_count;
  ) file_analyses;

  (stats, !total_files, !total_lines)

(* Print a table border *)
let print_border (left, mid, right) =
  let left_segment = left ^ String.concat "" (List.init 15 (fun _ -> "─")) in
  let mid_segments = List.init 4 (fun _ -> mid ^ String.concat "" (List.init 10 (fun _ -> "─"))) in

  let border = String.concat "" (left_segment :: mid_segments @ [right]) in
  Printf.printf "%s\n" border

(* Display the results in a formatted table *)
let display_results stats total_files total_lines =
  print_border ("┌", "┬", "┐");
  printf "│%-15s│%10s│%10s│%10s│%10s│\n" "Language" "Files" "Lines" "File %" "Line %";
  print_border ("├", "┼", "┤");

  Hashtbl.iter (fun language stat ->
    let file_pct = if total_files > 0 then (float_of_int stat.files /. float_of_int total_files) *. 100.0 else 0.0 in
    let line_pct = if total_lines > 0 then (float_of_int stat.lines /. float_of_int total_lines) *. 100.0 else 0.0 in
    printf "│%-15s│%10d│%10d│%9.1f%%│%9.1f%%│\n"
      language stat.files stat.lines file_pct line_pct
  ) stats;

  print_border ("├", "┼", "┤");
  printf "│%-15s│%10d│%10d│%9.1f%%│%9.1f%%│\n"
    "Total" total_files total_lines 100.0 100.0;
  print_border ("└", "┴", "┘")

(* Main program *)
let () =
  let directory = if Array.length Sys.argv > 1 then Sys.argv.(1) else "." in

  if not (Sys.is_directory directory) then (
    eprintf "Error: '%s' is not a valid directory.\n" directory;
    exit 1
  );

  let files = get_files directory in
  let file_analyses = List.filter_map analyze_file files in
  let stats, total_files, total_lines = aggregate_results file_analyses in
  display_results stats total_files total_lines
