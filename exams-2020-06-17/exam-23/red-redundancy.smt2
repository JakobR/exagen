(declare-sort A 0)
(declare-const a A)
(declare-const b A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (not (P (g a (f y)))) (not (= (h (h x)) (g a x))))))
(assert (or (not (P (h (h a)))) (not (= (h (h a)) (g a a)))))
(assert (not (or (P (g a (f (g b d)))) (not (P (h (h a)))) (not (= (h (h a)) (g a a))))))
(check-sat)
