(declare-sort A 0)
(declare-const a A)
(declare-const b A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (P (f x)) (= (f d) (g c (g y y))))))
(assert (or (not (P (h (h c)))) (= (f d) (g c (g b b)))))
(assert (not (or (not (P (f (g a b)))) (not (P (h (h c)))) (= (f d) (g c (g b b))))))
(check-sat)
