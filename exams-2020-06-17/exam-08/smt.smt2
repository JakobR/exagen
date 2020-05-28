;; Random number generator seed: Just 123
;; Index: 8
(define-sort A () (Array Int Int))
(declare-fun b () Int)
(declare-fun c () Int)
(declare-fun f (Int) Int)
(declare-fun a () A)
(assert (= (- b 1) (+ c 0)))
(assert (not (= (f (+ b 0)) (+ b 1))))
(assert (= (select a (f (+ c 1))) (+ c 0)))
(assert (or (= (select a (f (+ b 0))) (+ b 2)) (= (select (store a (+ b 1) (f (+ c 0))) (f (+ c 1))) (+ c 2))))
(check-sat)
