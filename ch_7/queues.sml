(* Three representations of a Queue in SML *)

use "../ch_5/sequences.sml";
use "../ch_7/queues.sml";

structure Queue1 = 
    struct 

    type 'a t = 'a list;
    exception E;

    val empty = [];

    fun enq(q,x)    = q @ [x];
    
    fun null(x::q)  = false
      | null _      = true;

    fun hd(x::q)    = x
      | hd []       = raise E;

    fun deq(x::q)   = q
      | deq []      = raise E;

    fun length(q)   = List.length(q);

    fun equal(q1,q2) = (q1=q2); 
    end;

structure Queue2 = 
    struct 

    datatype 'a t = empty
                  | enq of 'a t * 'a;

    exception E;

    fun null (enq _)   = false
      | null empty     = true;

    fun hd (enq(empty,x))   = x
      | hd (enq(q,x))       = hd q
      | hd empty            = raise E;

    fun deq (enq(empty,x))  = empty
      | deq (enq(q,x))      = enq(deq q, x)
      | deq empty           = raise E;

    fun length empty        = 0
      | length (enq(q,x))   = 1+length(q);

    fun equal(empty, empty)     = true
      | equal(empty, _)         = false
      | equal(_, empty)         = false
      | equal((enq(q1,x1)), (enq(q2,x2))) =
        if x1=x2 then equal(q1,q2) else false;
    end;


(* store a queue as a reversed list
   so [x1,x2,...,xn] represents queue 
   xn,...,x2,x1
*)
structure Queue2a = 
    struct
    type 'a t = 'a list;
    exception E;
    
    val empty = [];

    fun enq(q,x)    = x::q;

    fun null(x::q)  = false
      | null _      = true;

    fun hd([x])     = x
      | hd(x::q)    = hd(q)
      | hd([])      = raise E;
    
    fun deq([])     = raise E
      | deq(q)      = 
        let fun deq_int(accum,[])   = raise E
              | deq_int(accum,[x])  = rev accum
              | deq_int(accum,x::q) = deq_int(x::accum, q)
        in deq_int([], q) end;

    fun length q    = List.length q

    fun equal(q1,q2) = q1=q2;
    end;

(* Burton, 1982 - Store a queue as a a pair of lists 
   ([x1,x2,....,xN],[y1,y2,...,yM])
  is the quque 
    x1x2....xNyM.....,y1,y2
*)
structure Queue3 =
    struct 
    datatype 'a t = Queue of ('a list * 'a list);
    exception E;

    val empty = Queue([],[]);

    fun norm (Queue([], tails)) = Queue(rev tails, [])
      | norm q                  = q;

    fun enq(Queue(heads,tails), x) = norm(Queue(heads, x::tails));

    fun null(Queue([],[]))  = true
      | null _              = false;

    fun hd(Queue(x::_,_))   = x
      | hd(Queue([],_))      = raise E;
    
    fun deq(Queue(x::heads,tails)) = norm(Queue(heads,tails))
      | deq(Queue([],_))           = raise E;


    fun length(Queue(heads,tails)) = List.length(heads) + List.length(tails);

    fun equal((Queue(h1,t1)),(Queue(h2,t2))) = (h1=h2 andalso t1=t2);

    end;

(* transparent signature constraints *)
structure S1 : QUEUE = Queue1;
structure S2 : QUEUE = Queue2;
structure S3 : QUEUE = Queue3;

(* Opaque constraints *)
structure AbsQueue1 :> QUEUE = Queue1;
structure AbsQueue2 :> QUEUE = Queue2;
structure AbsQueue3 :> QUEUE = Queue3;

(* Queues as abstract types *)
abstype 'a queue1 = Q1 of 'a list
    with 
    val empty = Q1 [];
    
    fun enq(Q1 q, x)    = Q1(q@[x]);
    
    fun qnull(Q1(x::q)) = false
      | qnull _         = true;
    
    fun qhd(Q1(x::q))     = x;
    
    fun deq(Q1(x::q))     = Q1 q;
    end;

abstype 'a queue2 = Empty
                  | Enq of 'a queue2 * 'a
    with 
    val empty = Empty
    and enq   = Enq;

    fun qnull (Enq _)   = false
      | qnull Empty     = true;

    fun qhd (Enq(Empty,x))  = x
      | qhd (Enq(q,x))      = qhd q;

    fun deq (Enq(Empty,x))  = Empty
      | deq (Enq(q, x))     = Enq(deq q, x);
    end;

(* Functors to test the Queue structures *)
functor TestQueue (Q : QUEUE) =
    struct
    fun fromList l = foldl (fn (x,q) => Q.enq(q,x)) Q.empty l;

    fun toList q   = if Q.null q then []
                     else Q.hd q :: toList(Q.deq q);
    end;

functor BreadthFirst (Q: QUEUE) =
    struct
    fun enqlist q xs = foldl(fn (x,q) => Q.enq(q,x)) q xs;
    fun search next x = 
        let fun bfs q =
            if Q.null q then Nil else
                let val y = Q.hd q
                in Cons(y, fn()=>bfs (enqlist (Q.deq q) (next y)))
                end
        in bfs(Q.enq(Q.empty, x)) end;
    end;
