; Source: https://github.com/AI-Planning/pddl-generators/tree/main/miconic
; Fix: prevent the elevator from boarding served passengers => (not (origin ?p ?f)) effect added to board action
(define (domain miconic)
  (:requirements :strips :typing)
  (:types passenger - object
          floor - object
         )

(:predicates
(origin ?person - passenger ?floor - floor)
;; entry of ?person is ?floor
;; inertia

(destin ?person - passenger ?floor - floor)
;; exit of ?person is ?floor
;; inertia

(above ?floor1 - floor  ?floor2 - floor)
;; ?floor2 is located above of ?floor1

(boarded ?person - passenger)
;; true if ?person has boarded the lift

(served ?person - passenger)
;; true if ?person has alighted as her destination

(lift-at ?floor - floor)
;; current position of the lift is at ?floor

(legal)
(illegal)
)

(:legality-predicate legal)

;(:domain-goal (forall (?p - passenger) (served ?p)))
(:domain-goal (forall (?p - passenger) (imply (served_g ?p) (served ?p))))

;;stop and allow boarding

(:action board
  :parameters (?f - floor ?p - passenger)
  :precondition (and (lift-at ?f) (origin ?p ?f))
  :effect (and (boarded ?p) (not (origin ?p ?f))))

(:action depart
  :parameters (?f - floor ?p - passenger)
  :precondition (and (lift-at ?f) (destin ?p ?f)
		     (boarded ?p))
  :effect (and (not (boarded ?p))
	       (served ?p)))
;;drive up

(:action up
  :parameters (?f1 - floor ?f2 - floor)
  :precondition (and (lift-at ?f1) (above ?f1 ?f2))
  :effect (and (lift-at ?f2) (not (lift-at ?f1))))


;;drive down

(:action down
  :parameters (?f1 - floor ?f2 - floor)
  :precondition (and (lift-at ?f1) (above ?f2 ?f1))
  :effect (and (lift-at ?f2) (not (lift-at ?f1))))

(:legality-axiom (legal) (not (illegal)))

;; there is at least one passenger
(:legality-axiom (illegal) (not (exists (?p - passenger ?f - floor) (origin ?p ?f))))

;; each passenger has exactly one origin
(:legality-axiom (illegal) (exists (?p - passenger)
  (not (exists (?f - floor) (origin ?p ?f)))))
(:legality-axiom (illegal) (exists (?p - passenger ?f1 ?f2 - floor)
  (and (origin ?p ?f1) (origin ?p ?f2) (not (= ?f1 ?f2)))))

;; each passenger has exactly one destination
(:legality-axiom (illegal) (exists (?p - passenger)
  (not (exists (?f - floor) (destin ?p ?f)))))
(:legality-axiom (illegal) (exists (?p - passenger ?f1 ?f2 - floor)
  (and (destin ?p ?f1) (destin ?p ?f2) (not (= ?f1 ?f2)))))

;; the predicate above defines a strict total order (irreflexive, transitive,
;; connected) over all floors
(:legality-axiom (illegal) (exists (?f - floor) (above ?f ?f)))
(:legality-axiom (illegal) (exists (?f1 ?f2 ?f3 - floor)
                          (and (above ?f1 ?f2)
                               (above ?f2 ?f3)
                               (not (above ?f1 ?f3)))))
(:legality-axiom (illegal) (exists (?f1 ?f2 - floor)
                          (and (not (= ?f1 ?f2))
                               (not (above ?f1 ?f2))
                               (not (above ?f2 ?f1)))))

;; no passenger is boarded (yet)
(:legality-axiom (illegal) (exists (?p - passenger) (boarded ?p)))

;; the destination of each passenger is different from their origin
(:legality-axiom (illegal) (exists (?p - passenger ?f - floor)
                          (and (origin ?p ?f) (destin ?p ?f))))

;; no passenger is served (yet)
(:legality-axiom (illegal) (exists (?p - passenger) (served ?p)))

;; lift-at is true for exactly one floor (the following axioms, together with
;; the axiom that ensures differing floors for origin and destin for each
;; passenger, ensure that there are at least two floors)
(:legality-axiom (illegal) (not (exists (?f - floor) (lift-at ?f))))
(:legality-axiom (illegal) (exists (?f1 ?f2 - floor) (and (not (= ?f1 ?f2))
                                                 (lift-at ?f1)
                                                 (lift-at ?f2))))

;; in the goal all passengers are served
(:legality-axiom (illegal) (exists (?p - passenger) (not (served_g ?p))))

)

