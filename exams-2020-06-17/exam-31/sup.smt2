(declare-sort A 0)
(declare-fun f (A) A)
(declare-fun g (A) A)
(declare-const b A)
(declare-const a A)
(assert (or (= (f (g b)) a) (= (f (f b)) a)))
(assert (= (g b) a))
(assert (or (not (= (g b) (g b))) (= (f b) a)))
(assert (not (= (f a) a)))