(set-logic QF_AUFLIA)
(set-info :latex-linebreak-after-clause "3")

(declare-fun b () Int)
(declare-fun c () Int)
(declare-fun f (Int) Int)
(declare-fun A () (Array Int Int))

(assert (= (- b 1) c))
(assert (not (= (f b) (+ b 1))))
(assert (= (select A (f (+ c 1)))  c ))
(assert
   (or
     (= (select A (f b))  (+ b 2))
     (= (select (store A (+ b 1) (f c))    (f (+ c 1)) )  (+ c 2))
   )
)
(check-sat)
