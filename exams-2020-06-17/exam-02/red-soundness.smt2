(declare-sort A 0)
(declare-const b A)
(declare-const d A)
(declare-fun f (A) A)
(declare-fun g (A A) A)
(declare-fun h (A) A)
(declare-fun P (A) Bool)
(assert (or (not (P (h (h b)))) (not (P (h (f d)))) (= (g d d) (h (h d)))))
(assert (forall ((x A) (y A)) (or (P (h x)) (= (g d y) (h (h y))))))
(assert (not (or (not (P (h (f d)))) (= (g d d) (h (h d))))))
(check-sat)
