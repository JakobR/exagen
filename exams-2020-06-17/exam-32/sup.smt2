(declare-sort A 0)
(declare-const b A)
(declare-fun g (A) A)
(declare-const a A)
(declare-fun f (A) A)
(assert (or (= (f (g b)) a) (= (f (f b)) a)))
(assert (or (not (= (g b) (g b))) (= (g b) a)))
(assert (= (f b) a))
(assert (not (= (f a) a)))