(declare-sort A 0)
(declare-const b A)
(declare-fun g (A) A)
(declare-const a A)
(declare-fun f (A) A)
(assert (or (= (f (f b)) a) (= (f (g a)) a)))
(assert (or (not (= (g b) (g b))) (= (f b) a)))
(assert (= (g a) a))
(assert (not (= (f a) a)))