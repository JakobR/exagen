(declare-sort A 0)
(declare-const a A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (or (not (P (g a (h a)))) (P (f d)) (= (h a) (h (g d d)))))
(assert (forall ((x A) (y A)) (or (P (g a x)) (= (h a) (h (g y y))))))
(assert (not (or (P (f d)) (= (h a) (h (g d d))))))
(check-sat)
