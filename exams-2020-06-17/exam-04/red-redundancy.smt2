(declare-sort A 0)
(declare-const a A)
(declare-const b A)
(declare-const c A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (not (P (f (g x b)))) (= (g (h b) (h y)) (h y)))))
(assert (or (P (h d)) (= (g (h b) (h c)) (h c))))
(assert (not (or (P (f (g (f a) b))) (P (h d)) (= (g (h b) (h c)) (h c)))))
(check-sat)
