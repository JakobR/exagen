(declare-sort A 0)
(declare-const b A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (forall ((x A) (y A)) (or (not (P (f y))) (= (g x (h b)) (h (h x))))))
(assert (or (not (P (f (g d d)))) (= (g d (h b)) (h (h d)))))
(assert (not (or (P (f (f b))) (not (P (f (g d d)))) (= (g d (h b)) (h (h d))))))
(check-sat)
