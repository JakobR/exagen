(declare-sort A 0)
(declare-const a A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (or (P (h (f c))) (P (g (g a d) (f d))) (not (= (f c) (g c (f c))))))
(assert (forall ((x A) (y A)) (or (not (P (h x))) (not (= (f y) (g y (f y)))))))
(assert (not (or (P (g (g a d) (f d))) (not (= (f c) (g c (f c)))))))
(check-sat)
