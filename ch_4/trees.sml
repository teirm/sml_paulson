(*
    binary tree library
*)

datatype 'a tree = Lf
                 | Br of 'a * 'a tree * 'a tree;

datatype 'a list = End
                 | Node of 'a * 'a list;

datatype ('a,'b)ltree = LLf of 'b
                      | LBr of 'a * ('a,'b)ltree * ('a,'b)ltree;

datatype 'a mtree = MLf
                  | MBr of 'a * 'a mtree list;

(* return the number of labels in a tree *)
fun size Lf                 = 0
  | size (Br(v,t1,t2))      = 1 + size(t1) + size(t2);

(* depth of the tree *)
fun depth Lf                = 0
  | depth (Br(v,t1,t2))     = 1 + Int.max(depth(t1), depth(t2));

(* construct a balanced tree of labels 1 to 2^n *)
fun comptree(k,n)  = 
    if n = 0 then Lf
             else Br(k, comptree(2*k, n-1),
                        comptree(2*k+1, n-1));

(* construct a balanced tree of depth n containing only x *)
fun compsame(x,n) = 
    if n = 0 then Lf
    else let val t = compsame(x, n-1) in
             Br(x, t, t) end;

(* reflect a tree by constructing a new tree *)
fun reflect Lf            = Lf
  | reflect (Br(v,t1,t2)) = Br(v, reflect(t2), reflect(t1));

(* determine if a binary tree is balanced based on
   balanced = | sizeof(t1) - sizeof(t2)| <= 1
*)
fun balanced Lf             = true
  | balanced(Br(v,t1,t2))   = if abs(size(t1)-size(t2)) <= 1 then 
                                 if balanced(t1) then balanced(t2)
                                 else false
                              else false;

(* Check if two trees satisfy
     t = reflect(u)
*)
fun check_reflect(Lf, Lf)   = true
  | check_reflect(Br(v1,t1,t2),Br(v2,s1,s2)) = 
        if v1=v2 then check_reflect(t1,s2) andalso check_reflect(t2,s1)
        else false
  | check_reflect(_,_) = false;
