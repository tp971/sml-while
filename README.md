Write and simulate WHILE programs in Standard ML. Basic statements are:

    x_i := x_j + x_k
    x_i := x_j - x_k
    x_i := c
    while x_i != 0 do stmt od
    stmt_1 ; stmt_2

sml-while also supports some syntactic sugar:

    x_i := x_j
    x_i := x_j + c
    x_i := x_j - c
    x_i++
    x_i--
    x_i := f(x_j, x_k, ...)

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
