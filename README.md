Write and simulate WHILE programs in Standard ML. Basic statements are:

    Add i j k               (* x_i := x_j + x_k *)
    Sub i j k               (* x_i := x_j - x_k *)
    Const i j               (* x_i := c *)
    While i stmt            (* while x_i != 0 do stmt od *)
    stmt_1 \\ stmt_2        (* stmt_1 ; stmt_2 *)

sml-while also supports some syntactic sugar:

    Assign i j              (* x_i := x_j *)
    AddC i j c              (* x_i := x_j + c *)
    SubC i j c              (* x_i := x_j - c *)
    Inc i                   (* x_i++ *)
    Dec i                   (* x_i-- *)
    Call i f [a, b, ...] j  (* x_i := f(x_a, x_b, ...) *)
    (* "Calling" executes statement f by shifting x_i to x_{i+j} *)

Example: This program calculates "x * y":

    open While
    infix \\
    val mul = Program 2 3 (     (* WHILE program gets 2 inputs,
                                   state contains 3 variables *)
        Assign 2 0 \\           (* x_2 := 0 *)
        Const 0 0 \\            (* x_0 := 0 *)
        For 2 (                 (* for x_2 do *)
            Add 0 0 1           (*     x_0 := x_0 + x_1 *)
        )                       (* od *)
    )
    val it = mul [42, 7]
    (* it = 294 *)
