(declare-sort A 0)
(declare-const a A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (or (P (h (f (f c)))) (not (P (g c d))) (= (g (f a) (h a)) (g (h c) a))))
(assert (forall ((x A) (y A)) (or (not (P (h (f y)))) (= (g (f x) (h x)) (g (h c) x)))))
(assert (not (or (not (P (g c d))) (= (g (f a) (h a)) (g (h c) a)))))
(check-sat)
