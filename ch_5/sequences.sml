(* Sequences of infinite lists *)


use "../ch_3/list_ops.sml";
use "../ch_5/functions.sml";

(* Signature and data types for Sequence Structure *)

datatype 'a seq = Nil
                | Cons of 'a * (unit -> 'a seq);

signature SEQUENCE =
  sig 
  exception Empty
  val cons          : 'a * 'a seq -> 'a seq
  val null          : 'a seq -> bool
  val hd            : 'a seq -> 'a
  val tl            : 'a seq -> 'a seq
  val fromList      : 'a list -> 'a seq
  val toList        : 'a seq  -> 'a list
  val take          : 'a seq * int -> 'a list
  val drop          : 'a seq * int -> 'a seq
  val @             : 'a seq * 'a seq -> 'a seq
  val interleave    : 'a seq * 'a seq -> 'a seq
  val map           : ('a -> 'b) -> 'a seq -> 'b seq
  val filter        : ('a -> bool) -> 'a seq -> 'a seq
  val iterates      : ('a -> 'a) -> 'a -> 'a seq
  val from          : int -> int seq
  end;

structure Seq : SEQUENCE =
    struct 
    exception Empty
    
    fun cons (x,xq) = Cons(x, fn()=>xq);
    
    fun null Nil = true
      | null _   = false;

    fun hd (Cons(x,xf)) = x
      | hd Nil          = raise Empty;

    fun tl (Cons(x,xf)) = xf()
      | tl Nil          = raise Empty;
    
    fun fromList l = List.foldr cons Nil l;
    
    fun toList Nil              = []
      | toList (Cons(x,xf))   = x::toList(xf());

    fun take (xq, 0)        = [] 
      | take (Nil,n)        = raise Subscript
      | take (Cons(x,xf),n) = x::take(xf(),n-1);

    fun drop (xq, 0)        = xq
      | drop (Nil,n)        = raise Subscript
      | drop (Cons(x,xf),n) = drop(xf(),n-1);

    fun Nil             @ yq    = yq
      | (Cons(x,xf))    @ yq    = Cons(x,fn() => (xf()) @ yq);
    
    fun interleave (Nil, yq)        = yq
      | interleave(Cons(x,xf),yq)   = 
            Cons(x,fn()=>interleave(yq, xf()));

    fun map f Nil                   = Nil
      | map f (Cons(x, xf))          = Cons(f x, fn() => map f (xf()));

    fun filter pred Nil             = Nil
      | filter pred (Cons(x,xf))    =
            if pred x then Cons(x, fn() => filter pred (xf()))
                      else filter pred (xf());

    fun iterates f x = Cons(x, fn() => iterates f (f x));


    fun from k = Cons(k, fn()=>from(k+1));
    end;

datatype 'a seq2  = Nil2
                  | Cons2 of unit -> 'a * 'a seq2;

fun from2 k = (k, Cons2(fn()=>from2(k+1)));

fun take2 (xq, 0)       = []
  | take2 (Nil2, n)     = raise Subscript
  | take2 (Cons2(xf),n)  = 
        let val (v,xq) = xf()
        in v :: take2(xq, n-1)
        end;

datatype 'a seqnode = Nil3
                    | Cons3 of 'a * 'a seq2
and      'a seq2     = Seq of unit -> 'a seqnode;

fun from3 k = Cons3(k, Seq(fn()=>from3(k+1)));

fun take3 (xq, 0)                = []
  | take3 (Nil3, n)              = raise Subscript
  | take3 (Cons3(x,Seq(xf)),n)   = x::take3(xf(),n-1);

fun squares Nil : int seq       = Nil
  | squares (Cons(x,xf))        = Cons(x*x, fn()=>squares(xf()));

fun add (Cons(x,xf), Cons(y, yf))   = Cons(x+y, fn()=>add(xf(), yf()))
  | add _                           = Nil;

fun seq_repeat k Nil            = Nil
  | seq_repeat k (Cons(x, xf))  = 
    let fun rp 0 = seq_repeat k (xf())
          | rp k = Cons(x, fn() => rp(k-1))
    in rp k end;

fun repeat_mult (k, n, Nil)             = Nil
  | repeat_mult (k, n, (Cons(x, xf)))   = 
    let fun rp_m (0, n) = repeat_mult(k, n, (xf()))
          | rp_m (k, n) = Cons(x*n, fn() => rp_m(k, n))
    in rp_m(k,n) end;

fun add_pairs Nil : int seq            = Nil
  | add_pairs (Cons(x,xf))             =
        (case xf() of
            Nil             => Cons(x+0, fn()=> add_pairs(Nil))
          | (Cons(y,yf))    => Cons(x+y, fn()=> add_pairs(yf())));

fun take_while (_, Nil)                    = Nil
  | take_while (p, (Cons(x,xf)))           = if p(x) then Cons(x, fn()=> take_while(p, (xf())))
                                                     else Nil;

fun drop_while (_, Nil)                    = Nil
  | drop_while (p, (Cons(x,xf)))           = if p(x) then drop_while(p, (xf()))
                                                     else Cons(x, fn()=>drop_while(p, (xf())));

fun seqChange (coins, coinvals, 0, coinsf)          = Cons(coins, coinsf)
  | seqChange (coins, [], amount, coinsf)           = coinsf()
  | seqChange (coins, c::coinvals, amount, coinsf)  = 
    if amount<0 then coinsf()
    else seqChange(c::coins, c::coinvals, amount-c, 
                   fn()=>seqChange(coins, coinvals, amount, coinsf));

fun sift p = Seq.filter (fn n => n mod p <> 0);

fun sieve (Cons(p,nf)) = Cons(p, fn()=>sieve(sift p (nf())));

(* Newton-Raphson Method *)
fun nextApprox a x = (a/x + x) / 2.0;

fun within (eps:real) (Cons(x,xf)) = 
    let val Cons(y,yf)  = xf()
    in  if Real.abs(x-y) < eps then y
        else within eps (Cons(y,yf))
    end;

fun sum_from Nil            = Nil
  | sum_from (Cons(x,xf))   = 
    (case xf() of 
        Nil             => Cons(x+0,fn()=>sum_from(Nil))
      | (Cons(y,yf))    => Cons(x+y,fn()=>sum_from(Cons(x+y,yf)))); 

fun fact_from Nil           = Nil
  | fact_from (Cons(x,xf))  = 
    (case xf() of
        Nil             => Cons(x*1, fn()=>fact_from(Nil))
      | (Cons(y,yf))    => Cons(x*y, fn()=>fact_from(Cons(x*y,yf))));

fun exp_from (term, num, den, a, Nil)            = Nil
  | exp_from (term, num, den, a, (Cons(x,xf)))   = 
            let val next_d = if term=0 then 1 else den*term 
                val next_pow = if term=0 then 1 else num*a 
                val next_term = x+(real(next_pow)/real(next_d))
            in  Cons(next_term, fn()=>exp_from(term+1,next_pow,next_d,a,Cons(next_term,xf))) 
            end;

fun seqSummation n = sum_from(Seq.from n);
fun seqFactorial n = fact_from(Seq.from n);
fun seqExponential n = exp_from(0,1,1,n,Cons(0.0,fn()=>Nil));

fun pair x y = (x,y);

fun makeqq (xq, yq)     = Seq.map (fn x=> Seq.map (pair x) yq) xq;
fun takeqq (xqq, (m,n)) = List.map ((secr Seq.take) n) (Seq.take(xqq,m));

fun enumerate Nil                       = Nil
  | enumerate (Cons(Nil,xqf))           = enumerate(xqf())
  | enumerate (Cons(Cons(x,xf), xqf))   =
        Cons(x, fn()=>Seq.interleave(enumerate(xqf()), xf()));

fun powerof2 n = repeat (fn(x)=>x*2) n 1
fun pack(i,j) = powerof2(i-1)*(2*j-1);
