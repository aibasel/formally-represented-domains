; source => https://github.com/AI-Planning/pddl-generators/blob/main/spanner/domain.pddl
(define (domain spanner)
(:requirements :typing :strips)
(:types
	location locatable - object
	man nut spanner - locatable
)

(:predicates
	(at ?m - locatable ?l - location)
	(carrying ?m - man ?s - spanner)
	(usable ?s - spanner)
	(link ?l1 - location ?l2 - location)
	(tightened ?n - nut)
	(loose ?n - nut)
  (legal)
  (illegal)
  (matching-nut-spanner ?n - nut ?s - spanner)
  (shed ?l - location)
  (gate ?l - location))

(:legality-predicate legal)

(:domain-goal (forall (?n - nut) (tightened ?n)))

(:action walk
        :parameters (?start - location ?end - location ?m - man)
        :precondition (and (at ?m ?start)
                           (link ?start ?end))
        :effect (and (not (at ?m ?start)) (at ?m ?end)))

(:action pickup_spanner
        :parameters (?l - location ?s - spanner ?m - man)
        :precondition (and (at ?m ?l)
                           (at ?s ?l))
        :effect (and (not (at ?s ?l))
                     (carrying ?m ?s)))

(:action tighten_nut
        :parameters (?l - location ?s - spanner ?m - man ?n - nut)
        :precondition (and (at ?m ?l)
		      	   (at ?n ?l)
			   (carrying ?m ?s)
			   (usable ?s)
			   (loose ?n))
        :effect (and (not (loose ?n))(not (usable ?s)) (tightened ?n)))

(:axiom (legal) (not (illegal)))

;; there is at least one spanner (and at least one location)
(:axiom (illegal) (not (exists (?s - spanner ?l - location) (at ?s ?l))))

;; there is exactly one man
(:axiom (illegal) (not (exists (?m) (man ?m))))
(:axiom (illegal) (exists (?m1 ?m2 - man) (not (= ?m1 ?m2))))

;; the man is at the shed
(:axiom (illegal)
  (exists (?m - man ?l - location) (and (at ?m ?l) (not (shed ?l)))))

;; the number of nuts is at least one and at most the number of spanners
(:axiom (illegal) (not (exists (?n - nut ?l - location) (at ?n ?l))))
(:axiom (matching-nut-spanner ?n - nut ?s - spanner)
   (and (forall (?nx - nut) (or (= ?n ?nx) (< ?n ?nx)))
        (forall (?sx - spanner) (or (= ?s ?sx) (< ?s ?sx)))))
(:axiom (matching-nut-spanner ?n - nut ?s - spanner)
  (exists (?nx - nut ?sx - spanner)
          (and (matching-nut-spanner ?nx ?sx)
               (< ?nx ?n)
               (< ?sx ?s)
               (not (exists (?ny - nut) (and (< ?nx ?ny) (< ?ny ?n))))
               (not (exists (?sy - spanner) (and (< ?sx ?sy) (< ?sy ?s)))))))
(:axiom (illegal)
  (exists (?n - nut)
          (not (exists (?s - spanner)
                       (matching-nut-spanner ?n ?s)))))

;; each locatable is at exactly one location
(:axiom (illegal) (exists (?m - locatable)
  (not (exists (?l - location) (at ?m ?l)))))
(:axiom (illegal) (exists (?m - locatable ?l1 ?l2 - location)
  (and (at ?m ?l1) (at ?m ?l2) (not (= ?l1 ?l2)))))

;; a location cannot be linked to itself
(:axiom (illegal) (exists (?l - location) (link ?l ?l)))

;; each location has at most one incoming link and at most one outgoing link
(:axiom (illegal)
  (exists (?l ?lx ?ly - location)
          (and (not (= ?l1 ?l2)) (link ?l1 ?l) (link ?l2 ?l))))
(:axiom (illegal)
  (exists (?l ?lx ?ly - location)
          (and (not (= ?l1 ?l2)) (link ?l ?l1) (link ?l ?l2))))

;; the shed is the only location with no incoming links (together with previous
;; axioms this ensures that each other location has exactly one incoming link)
(:axiom (shed ?l - location)
  (forall (?lx - location) (or (= ?l ?lx) (not (link ?lx ?l)))))
(:axiom (illegal) (not (exists (?l - location) (shed ?l))))
(:axiom (illegal)
  (exists (?l1 ?l2 - location) (and (shed ?l1) (shed ?l2) (not (= ?l1 ?l2)))))

;; the gate is the only location with no outgoing links (together with previous
;; axioms this ensures that each other location has exactly one outgoing link)
(:axiom (gate ?l - location)
  (forall (?lx - location) (or (= ?l ?lx) (not (link ?l ?lx)))))
(:axiom (illegal) (not (exists (?l - location) (gate ?l))))
(:axiom (illegal)
  (exists (?l1 ?l2 - location) (and (gate ?l1) (gate ?l2) (not (= ?l1 ?l2)))))

;; there is at least one location between the shed and the gate
(:axiom (illegal)
  (not (exists (?s ?l - location)
               (and (shed ?s) (link ?s ?l) (not (gate ?l))))))
(:axiom (illegal)
  (not (exists (?g ?l - location)
               (and (gate ?g) (link ?l ?g) (not (shed ?l))))))

;; all spanners are at locations other than the shed and the gate
(:axiom (illegal)
  (exists (?s - spanner ?l - location) (and (at ?s ?l) (shed ?l))))
(:axiom (illegal)
  (exists (?s - spanner ?l - location) (and (at ?s ?l) (gate ?l))))

;; all nuts are at the gate
(:axiom (illegal)
  (exists (?n - nut ?l - location) (and (at ?n ?l) (not (gate ?l)))))

;; all spanners are usable
(:axiom (illegal) (exists (?s - spanner) (not (usable ?s))))

;; all nuts are loose
(:axiom (illegal) (exists (?n - nut) (not (loose ?n))))

)

