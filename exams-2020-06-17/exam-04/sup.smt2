(declare-sort A 0)
(declare-fun f (A) A)
(declare-fun g (A) A)
(declare-const b A)
(declare-const a A)
(assert (or (= (g (f a)) a) (= (g (g b)) a)))
(assert (= (f a) a))
(assert (or (not (= (f b) (f b))) (= (g b) a)))
(assert (not (= (g a) a)))