;; source: https://github.com/AI-Planning/pddl-generators/blob/main/childsnack/domain.pddl
;; updates:
;;   - :equality removed
;;   - :negative-preconditions added
;;   - action move_tray has a new precondition: (not (at ?t ?p2))

(define (domain childsnack)
(:requirements :typing :negative-preconditions)
(:types child bread-portion content-portion sandwich tray place)
(:constants kitchen - place)

(:predicates
    (at_kitchen_bread ?b - bread-portion)
    (at_kitchen_content ?c - content-portion)
    (at_kitchen_sandwich ?s - sandwich)
    (no_gluten_bread ?b - bread-portion)
    (no_gluten_content ?c - content-portion)
    (ontray ?s - sandwich ?t - tray)
    (no_gluten_sandwich ?s - sandwich)
    (allergic_gluten ?c - child)
    (not_allergic_gluten ?c - child)
    (served ?c - child)
    (waiting ?c - child ?p - place)
    (at ?t - tray ?p - place)
    (notexist ?s - sandwich)
    (legal)
    (illegal)
    (matching-child-sandwich ?c - child ?s - sandwich)
    (matching-sandwich-bread ?s - sandwich ?b - bread-portion)
    (matching-sandwich-content ?s - sandwich ?c - content-portion)

    (matching-no-gluten-child-bread ?ch - child
                                ?br - bread-portion)
    (matching-no-gluten-child-content ?ch - child
                                ?co - content-portion)
)

(:legality-predicate legal)

(:domain-goal (forall (?c - child) (served ?c)))

(:action make_sandwich_no_gluten
	 :parameters (?s - sandwich ?b - bread-portion ?c - content-portion)
	 :precondition (and
        (at_kitchen_bread ?b)
        (at_kitchen_content ?c)
        (no_gluten_bread ?b)
        (no_gluten_content ?c)
        (notexist ?s))
	 :effect (and
        (not (at_kitchen_bread ?b))
        (not (at_kitchen_content ?c))
        (at_kitchen_sandwich ?s)
        (no_gluten_sandwich ?s)
        (not (notexist ?s)))
)

(:action make_sandwich
	 :parameters (?s - sandwich ?b - bread-portion ?c - content-portion)
	 :precondition (and
        (at_kitchen_bread ?b)
        (at_kitchen_content ?c)
        (notexist ?s))
	 :effect (and
        (not (at_kitchen_bread ?b))
        (not (at_kitchen_content ?c))
        (at_kitchen_sandwich ?s)
        (not (notexist ?s)))
)

(:action put_on_tray
	 :parameters (?s - sandwich ?t - tray)
	 :precondition (and
        (at_kitchen_sandwich ?s)
        (at ?t kitchen))
	 :effect (and
        (not (at_kitchen_sandwich ?s))
        (ontray ?s ?t))
)

(:action serve_sandwich_no_gluten
 	:parameters (?s - sandwich ?c - child ?t - tray ?p - place)
	:precondition (and
        (allergic_gluten ?c)
        (ontray ?s ?t)
        (waiting ?c ?p)
        (no_gluten_sandwich ?s)
        (at ?t ?p))
	:effect (and
        (not (ontray ?s ?t))
        (served ?c))
)

(:action serve_sandwich
	:parameters (?s - sandwich ?c - child ?t - tray ?p - place)
	:precondition (and
        (not_allergic_gluten ?c)
        (waiting ?c ?p)
        (ontray ?s ?t)
        (at ?t ?p))
	:effect (and
        (not (ontray ?s ?t))
        (served ?c))
)

(:action move_tray
	 :parameters (?t - tray ?p1 ?p2 - place)
	 :precondition (and
        (at ?t ?p1)
        (not (at ?t ?p2)))
	 :effect (and
        (not (at ?t ?p1))
        (at ?t ?p2))
)

(:axiom (legal) (not (illegal)))

;; there is at least one child (as a side effect, the following axiom also
;; requires that there is at least one place)
(:axiom (illegal) (not (exists (?ch - child ?pl - place) (waiting ?ch ?pl))))

;; there is at least one tray (as a side effect, the following axiom also
;; requires that there is at least one place)
(:axiom (illegal) (not (exists (?t - tray ?p - place) (at ?t ?p))))

;; all trays are in the kitchen (and nowhere else)
(:axiom (illegal) (exists (?t - tray) (not (at ?t kitchen))))
(:axiom (illegal) (exists (?t - tray ?p - place) (and (at ?t ?p)
                                                      (not (= ?p kitchen)))))

;; there are at least as many sandwiches as children
(:axiom (matching-child-sandwich ?c - child ?s - sandwich)
  (and (forall (?cx - child) (or (= ?c ?cx) (< ?c ?cx)))
       (forall (?sx - sandwich) (or (= ?s ?sx) (< ?s ?sx)))))
(:axiom (matching-child-sandwich ?c - child ?s - sandwich)
  (exists (?cx - child ?sx - sandwich)
          (and (matching-child-sandwich ?cx ?sx)
               (< ?cx ?c)
               (< ?sx ?s)
               (not (exists (?cy - child) (and (< ?cx ?cy) (< ?cy ?c))))
               (not (exists (?sy - sandwich) (and (< ?sx ?sy) (< ?sy ?s)))))))
(:axiom (illegal)
  (exists (?c - child)
          (not (exists (?s - sandwich)
                       (matching-child-sandwich ?c ?s)))))

;; the number of sandwiches, bread portions, and content portions is the same
(:axiom (matching-sandwich-bread ?s - sandwich ?b - bread-portion)
  (and (forall (?sx - sandwich) (or (= ?s ?sx) (< ?s ?sx)))
       (forall (?bx - bread-portion) (or (= ?b ?bx) (< ?b ?bx)))))
(:axiom (matching-sandwich-bread ?s - sandwich ?b - bread-portion)
  (exists (?sx - sandwich ?bx - bread-portion)
          (and (matching-sandwich-bread ?sx ?bx)
               (< ?sx ?s)
               (< ?bx ?b)
               (not (exists (?sy - sandwich) (and (< ?sx ?sy) (< ?sy ?s))))
               (not (exists (?by - bread-portion) (and (< ?bx ?by) (< ?by ?b)))))))
(:axiom (matching-sandwich-content ?s - sandwich ?c - content-portion)
  (and (forall (?sx - sandwich) (or (= ?s ?sx) (< ?s ?sx)))
       (forall (?cx - content-portion) (or (= ?c ?cx) (< ?c ?cx)))))
(:axiom (matching-sandwich-content ?s - sandwich ?c - content-portion)
  (exists (?sx - sandwich ?cx - content-portion)
          (and (matching-sandwich-content ?sx ?cx)
               (< ?sx ?s)
               (< ?cx ?c)
               (not (exists (?sy - sandwich) (and (< ?sx ?sy) (< ?sy ?s))))
               (not (exists (?cy - content-portion) (and (< ?cx ?cy) (< ?cy ?c)))))))
(:axiom (illegal)
  (exists (?s - sandwich)
          (not (exists (?b - bread-portion)
                       (matching-sandwich-bread ?s ?b)))))
(:axiom (illegal)
  (exists (?s - sandwich)
          (not (exists (?c - content-portion)
                       (matching-sandwich-content ?s ?c)))))
(:axiom (illegal)
  (exists (?b - bread-portion)
          (not (exists (?s - sandwich)
                       (matching-sandwich-bread ?s ?b)))))
(:axiom (illegal)
  (exists (?c - content-portion)
          (not (exists (?s - sandwich)
                       (matching-sandwich-content ?s ?c)))))

;; all bread-portions and content-portions are at the kitchen
(:axiom (illegal) (exists (?b - bread-portion) (not (at_kitchen_bread ?b))))
(:axiom (illegal) (exists (?c - content-portion) (not (at_kitchen_content ?c))))

; all children are either allergic to gluten, or not allergic to gluten
(:axiom (illegal) (exists (?c - child) (and (allergic_gluten ?c)
                                            (not_allergic_gluten ?c))))
(:axiom (illegal) (exists (?c - child) (and (not (allergic_gluten ?c))
                                            (not (not_allergic_gluten ?c)))))

;; the number of bread-portions with no gluten, the number of
;; content-portions with no gluten and the number of children that
;; are allergic to gluten are the same
(:axiom (matching-no-gluten-child-bread ?ch - child ?br - bread-portion)
  (and (allergic_gluten ?ch)
       (no_gluten_bread ?br)
       (forall (?chx - child) (or (not (allergic_gluten ?chx)) (= ?ch ?chx) (< ?ch ?chx)))
       (forall (?brx - bread-portion) (or (not (no_gluten_bread ?brx)) (= ?br ?brx) (< ?br ?brx)))))

(:axiom (matching-no-gluten-child-content ?ch - child ?co - content-portion)
  (and (allergic_gluten ?ch)
       (no_gluten_content ?co)
       (forall (?chx - child) (or (not (allergic_gluten ?chx)) (= ?ch ?chx) (< ?ch ?chx)))
       (forall (?cox - content-portion) (or (not (no_gluten_content ?cox)) (= ?co ?cox) (< ?co ?cox)))))

(:axiom (matching-no-gluten-child-bread ?ch - child
                                    ?br - bread-portion)
  (exists (?chx - child ?brx - bread-portion)
          (and (matching-no-gluten-child-bread ?chx ?brx)
               (allergic_gluten ?ch)
               (no_gluten_bread ?br)
               (< ?chx ?ch)
               (< ?brx ?br)
               (not (exists (?chy - child) (and (allergic_gluten ?chy) (< ?chx ?chy) (< ?chy ?ch))))
               (not (exists (?bry - bread-portion) (and (no_gluten_bread ?bry) (< ?brx ?bry) (< ?bry ?br)))))))

(:axiom (matching-no-gluten-child-content ?ch - child ?co - content-portion)
  (exists (?chx - child ?cox - content-portion)
          (and (matching-no-gluten-child-content ?chx ?cox)
               (allergic_gluten ?ch)
               (no_gluten_content ?co)
               (< ?chx ?ch)
               (< ?cox ?co)
               (not (exists (?chy - child) (and (allergic_gluten ?chy) (< ?chx ?chy) (< ?chy ?ch))))
               (not (exists (?coy - content-portion) (and (no_gluten_content ?coy) (< ?cox ?coy) (< ?coy ?co)))))))
(:axiom (illegal)
  (exists (?ch - child)
          (and (allergic_gluten ?ch) (not (exists (?br - bread-portion)
                       (matching-no-gluten-child-bread ?ch ?br))))))
(:axiom (illegal)
  (exists (?ch - child)
          (and (allergic_gluten ?ch) (not (exists (?co - content-portion)
                       (matching-no-gluten-child-content ?ch ?co))))))
(:axiom (illegal)
  (exists (?br - bread-portion)
          (and (no_gluten_content ?br) (not (exists (?ch - child)
                       (matching-no-gluten-child-bread ?ch ?br))))))
(:axiom (illegal)
  (exists (?co - content-portion)
          (and (no_gluten_content ?co) (not (exists (?ch - child)
                       (matching-no-gluten-child-content ?ch ?co))))))

;; there are at most three tables
(:axiom
  (illegal)
  (exists (?t1 ?t2 ?t3 ?t4 - place)
          (and (not (= ?t1 ?t2)) (not (= ?t1 ?t3)) (not (= ?t1 ?t4))
               (not (= ?t2 ?t3)) (not (= ?t2 ?t4)) (not (= ?t3 ?t4))
               (not (= ?t1 kitchen)) (not (= ?t2 kitchen))
               (not (= ?t3 kitchen)) (not (= ?t4 kitchen)))))

;; each child is waiting at exactly one place other than the kitchen
(:axiom (illegal)
  (exists (?c - child) (not (exists (?p - place) (waiting ?c ?p)))))
(:axiom (illegal)
  (exists (?c - child ?p1 ?p2 - place)
          (and (waiting ?c ?p1) (waiting ?c ?p2) (not (= ?p1 ?p2)))))
(:axiom (illegal) (exists (?c - child) (waiting ?c kitchen)))

;; no child is served (yet)
(:axiom (illegal) (exists (?c - child) (served ?c)))

;; no sandwiches exist (the predicate notexist is true for all sandwiches and
;; all other predicates mentioning sandwiches are false)
(:axiom (illegal) (exists (?s - sandwich) (not (notexist ?s))))
(:axiom (illegal) (exists (?s - sandwich) (at_kitchen_sandwich ?s)))
(:axiom (illegal) (exists (?s - sandwich) (no_gluten_sandwich ?s)))
(:axiom (illegal) (exists (?s - sandwich ?t - tray) (ontray ?s ?t)))

)
