(declare-sort A 0)
(declare-const a A)
(declare-const b A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (not (P (h x))) (not (= (h a) (h (g y y)))))))
(assert (or (not (P (g (g b d) (f c)))) (not (= (h a) (h (g a a))))))
(assert (not (or (P (h (f b))) (not (P (g (g b d) (f c)))) (not (= (h a) (h (g a a)))))))
(check-sat)
