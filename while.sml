signature WHILE =
sig
    type state = int list
    type whilestmt = state -> state

    (* 
        Documentation note:
            int parameters are named i, j, k, l
            whilestmt parameters are named stmt
    *)

    (* State manipulation *)
    val Empty : int -> state
    val Expand : state -> int -> state
    val Set : state -> int -> int -> state
    val Get : state -> int -> int

    (* Basic while Statements *)
    val Nop : whilestmt                         (* do nothing *)
    val Add : int -> int -> int -> whilestmt    (* x_i := x_j + x_k *)
    val Sub : int -> int -> int -> whilestmt    (* x_i := x_j - x_k *)
    val Const : int -> int -> whilestmt         (* x_i := j *)
    val While : int -> whilestmt -> whilestmt   (* While x_i != 0 do stmt od *)
    val \\ : whilestmt * whilestmt -> whilestmt (* stmt_1; stmt_2 *)

    (* While program *)
    (*
        Program : int -> int -> whilestmt -> (int list -> int)
        Returns a procedure "executes" stmt with the given input vector:
        The procedure takes an int list of k entries and expands the list up to
        n elements as the state. Then stmt gets called with the state and the
        procedure returns the first element in resulting state.
    *)
    val Program : int -> int -> whilestmt -> int list -> int

    (* Syntactic sugar *)
    val Assign : int -> int -> whilestmt        (* x_i := x_j *)
    val AddC : int -> int -> int -> whilestmt   (* x_i := x_j + c *)
    val SubC : int -> int -> int -> whilestmt   (* x_i := x_j - c *)
    val Inc : int -> whilestmt                  (* x_i++ *)
    val Dec : int -> whilestmt                  (* x_i-- *)

    val For : int -> whilestmt -> whilestmt     (* For x_i do stmt od *)

    (* Execute stmt with x_i -> x_{i+j} *)
    val Embed : whilestmt -> int -> whilestmt

    (*
        Simulate function call:
        Copy input parameters p_1, p_2, ..., p_n to x_j, x_{j+1}, ..., x_{j+n-1}
            x_j := p_1; x_{j+1} := p_2; ...; x_{j+n-1} := p_n
        Call stmt:
            Embed j stmt
        Copy result from x_j to x_k:
            x_i := x_j
    *)
    val Call : int -> whilestmt -> int list -> int -> whilestmt
end

structure While :> WHILE =
struct
    type state = int list
    type whilestmt = state -> state

    fun Empty n = List.tabulate (n, fn _ => 0)
    fun Expand state n =
        if List.length state > n then
            raise Subscript
        else
            state @ (Empty (n - List.length state))

    fun Get xs n = List.nth (xs, n)
    fun Set xs n x = (List.take (xs, n)) @ (x :: (List.drop (xs, n + 1)))

    fun Nop state = state

    fun Add i j k state =
        Set state i (Get state j + Get state k)

    fun Sub i j k state =
        let
            val d' = Get state j - Get state k
            val d = if d' < 0 then 0 else d'
        in
            Set state i d
        end

    fun Const i x state =
        Set state i x

    fun While i f state =
        if Get state i = 0 then state
        else While i f (f state)

    infix \\
    fun f \\ g = g o f

    fun Program npar nvar e =
        if npar > nvar then
            raise Domain
        else
            fn input =>
                if List.length input <> npar then
                    raise Domain
                else if List.exists (fn x => x < 0) input then
                    raise Domain
                else
                    Get (e (Expand input nvar)) 0

    fun Assign i j =
        Const i 0 \\
        Add i i j

    fun AddC i j k state =
        Set state i (Get state j + k)

    fun SubC i j k state =
        Set state i (Get state j - k)

    fun Inc i =
        AddC i i 1

    fun Dec i =
        SubC i i 1

    fun For i f state =
        let
            fun For' n f state =
                if n = 0 then state
                else For' (n - 1) f (f state)
        in
            For' (Get state i) f state
        end

    fun Embed e n state =
        (List.take (state, n)) @ (e (List.drop (state, n)))

    fun Call i e ps j =
        (#1 (foldl
            (fn (p, (a, k)) =>
                (a \\ Assign (j + k) p, k + 1))
            (Nop, 0) ps)) \\
        Embed e j \\
        Assign i j
end
