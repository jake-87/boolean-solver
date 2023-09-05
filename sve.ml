type bf =
    | V of string
    | Hard of bool
    | A of bf * bf
    | Or of bf * bf
    | X of bf * bf
    | N of bf

let rec eval bf =
    match bf with
    | V(_) -> raise Not_found
    | Hard(n) -> n
    | X(a,b) -> (eval a) <> (eval b)
    | A(a,b) -> (eval a) && (eval b)
    | Or(a,b) -> (eval a) || (eval b)
    | N(a) -> not (eval a)

let rec show_bf bf =
    match bf with
    | V s -> s
    | Hard b -> string_of_bool b
    | X(a,b) -> "(" ^ show_bf a ^ " ^ " ^ show_bf b ^ ")"
    | A(a,b) -> "(" ^ show_bf a ^ " & " ^ show_bf b ^ ")"
    | Or(a,b) -> "(" ^ show_bf a ^ " | " ^ show_bf b ^ ")"
    | N(a) -> "(~" ^ show_bf a ^ ")"

let print_bf x = print_endline (show_bf x)

let rec subs bf old new' =
    match bf with
    | Hard _ -> bf
    | V(i) ->
        if i = old then new' else bf
    | X(a,b) -> X(subs a old new', subs b old new')
    | A(a,b) -> A(subs a old new', subs b old new')
    | Or(a,b) -> Or(subs a old new', subs b old new')
    | N(a) -> N(subs a old new')

let rec find_V bf =
    match bf with
    | V s -> Some(s)
    | Hard b -> None
    | N(a) -> find_V a
    | X(a,b)
    | A(a,b)
    | Or(a,b) ->
        match find_V a with
        | Some n -> Some n
        | None -> find_V b

let rec sve bf =
    match find_V bf with
    | None -> bf
    | Some v ->
        let a = subs bf v (Hard(true)) in
        let b = subs bf v (Hard(false)) in
        let a' = sve a in
        match eval a' with
        | false -> sve b
        | true -> a'

let rec get_equiv solv orig =
    match solv,orig with
    | Hard _, Hard _ -> []
    | Hard n, V a -> [(a,n)]
    | X(a,b),X(c,d)
    | A(a,b),A(c,d)
    | Or(a,b), Or(c,d) ->
        (get_equiv a c) @ (get_equiv b d)
    | N(a), N(b) -> get_equiv a b
    | _,_ -> raise Not_found

let rec get_solns_h l =
    match l with
    | [] -> ""
    | (v,s) :: xs ->
      begin
        match List.mem_assoc v xs with
        | true -> ""
        | false ->v ^ " = " ^ string_of_bool s ^ "\n"
      end ^
      get_solns_h xs

let simpl (a,b) (c,d) =
  String.compare a c

let get_solns l =
  get_solns_h (List.sort simpl l)

let simpl (a,b) (c,d) =
  String.compare a c

let solver bf =
  let tm = sve bf in
  let equiv = get_equiv tm bf in
  match eval tm with
  | true -> Ok(get_solns equiv)
  | false -> Error("No solution.")


(*
   End of SVE process, start of parsing/lexing and main
*)

let explode s = List.init (String.length s) (String.get s)

let join chars = 
  let buf = Buffer.create 16 in
  List.iter (Buffer.add_char buf) chars;
  Buffer.contents buf

let remove_whitespace =
  List.filter (
    fun c ->
      match c with
      | ' ' -> false
      | '\t' -> false
      | '\n' -> false
      | _ -> true
  )

exception ParseErr

let expected c s =
  print_endline "error:";
  print_endline s;
  print_endline (join c);
  raise ParseErr

let rec parser_base c =
  match c with
  | '~' :: xs ->
    begin
      let got, c = parser xs  in
      N got, c
    end
  | '(' :: xs ->
    begin 
      let rhs, c = parser xs in
      match c with
      | ')' :: ys -> rhs, ys
      | _ -> expected c "right paren"
    end 
  | x :: xs when (Char.code x >= 65 && Char.code x <= (65 + 26))
        || (Char.code x >= 97 && Char.code x <= (97 + 26)) ->
    V (join [x]), xs
  | _ -> expected c "var or negation"

and parser c =
  let lhs, c = parser_base c in
  match c with
  | '&' :: xs ->
    let rhs, c = parser xs in
    A (lhs, rhs), c
  | '|' :: xs ->
    let rhs, c = parser xs  in
    Or (lhs, rhs), c
  | '^' :: xs ->
    let rhs, c = parser xs  in
    X (lhs, rhs), c
  | _ -> lhs, c

(*
   main drivers
*)

let main () =
  print_endline "Please input a boolean expr (empty/CTRL-D for quit):";
  let s = remove_whitespace @@ explode @@ read_line () in
  if s = []
  then
    true
  else
    let expr, _ = parser s in
    print_endline "Interpreted as:";
    print_bf expr;
    begin
      match solver expr with
      | Ok(res) ->
        print_endline "One possible solution:";
        print_endline res
      | Error(s) ->
        print_endline s
    end; false
    
let rec mainloop () =
  match main () with
  | true -> raise End_of_file
  | false ->
    print_endline "----------";
    mainloop ()

let () =
  print_endline "Example input expr, for reference:";
  print_endline "(~a) & b | (c ^ a)\n";
  try
    mainloop()
  with End_of_file ->
    print_endline "Bye.";
    ()
