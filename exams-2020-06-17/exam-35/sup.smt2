(declare-sort A 0)
(declare-const b A)
(declare-fun f (A) A)
(declare-const a A)
(declare-fun g (A) A)
(assert (or (= (f (g b)) a) (= (f (g a)) a)))
(assert (or (not (= (g b) (g b))) (= (g b) a)))
(assert (= (g a) a))
(assert (not (= (f a) a)))