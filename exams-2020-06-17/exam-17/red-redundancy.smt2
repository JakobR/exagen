(declare-sort A 0)
(declare-const a A)
(declare-const b A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (P (g (g y c) a)) (not (= (h (f x)) (h (g b x)))))))
(assert (or (P (g a d)) (not (= (h (f d)) (h (g b d))))))
(assert (not (or (not (P (g (g (h b) c) a))) (P (g a d)) (not (= (h (f d)) (h (g b d)))))))
(check-sat)
