open While
infix \\

(* Plain WHILE *)
val fib = Program 1 4 (
    Const 1 0 \\        (* x_1 := 0 *)
    Const 2 1 \\        (* x_2 := 1 *)
    While 0 (           (* while x_0 != 0 do *)
        Add 3 1 2 \\    (*     x_3 := x_1 + x_2 *)
        Const 1 0 \\    (*     x_1 := 0 *)
        Add 1 1 2 \\    (*     x_1 := x_1 + x_2 *)
        Const 2 0 \\    (*     x_2 := 0 *)
        Add 2 2 3 \\    (*     x_2 := x_2 + x_3 *)
        Const 3 1 \\    (*     x_3 := 1 *)
        Sub 0 0 3       (*     x_0 := x_0 - x_3 *)
    ) \\                (* od *)
    Const 0 0 \\        (* x_0 := 0 *)
    Add 0 0 1           (* x_0 := x_0 + x_1 *)
)

(* WHILE with syntactic sugar *)
val fibfor =
    Const 1 0 \\        (* x_1 := 0 *)
    Const 2 1 \\        (* x_2 := 1 *)
    For 0 (             (* for x_0 do *)
        Add 0 1 2 \\    (*     x_0 := x_1 + x_2 *)
        Assign 1 2 \\   (*     x_1 := x_2 *)
        Assign 2 0      (*     x_2 := x_0 *)
    ) \\                (* od *)
    Assign 0 1          (* x_0 := x_1 *)

val fib' = Program 1 3 fibfor

val fibfind = Program 1 10 (
    Assign 1 0 \\               (* x_1 := x_0 *)
    Const 0 0 \\                (* x_0 := 0 *)
    Const 2 1 \\                (* x_2 := 1 *)
    While 2 (                   (* while x_2 != 0 do *)
        Call 3 5 fibfor 0 1 \\  (*     x_3 := fibfor(x_0, x_1) *)
        Sub 2 1 3 \\            (*     x_2 := x_1 - x_3 *)
        Inc 0                   (*     x_0++ *)
    ) \\                        (* od *)
    Dec 0 \\                    (*     x_0-- *)
    Embed 0 fibfor              (* execute fibfor: "x_0 := fibfor(x_0, x_1)" *)
)
