; source: https://github.com/AI-Planning/pddl-generators/blob/main/ferry/domain.pddl
; updates: typing car and locations; sail precs have now (not (at-ferry ?to)) so (not-eq ?from ?to) can be removed
(define (domain ferry)
   (:requirements :typing :strips :negative-preconditions)
   (:types
        car - object
        location - object )

   (:predicates
		(at-ferry ?l - location)
		(at ?c - car ?l - location)
    (at_g ?c - car ?l - location)
		(empty-ferry)
		(on ?c - car)
    (legal)
    (illegal))

   (:legality-predicate legal)

   (:domain-goal
       (forall (?c - car ?l - location) (imply (at_g ?c ?l) (at ?c ?l))))

   (:action sail
       :parameters  (?from - location ?to - location)
       :precondition (and (at-ferry ?from) (not (at-ferry ?to)))
       :effect (and  (at-ferry ?to) (not (at-ferry ?from))))


   (:action board
       :parameters (?car - car ?loc - location)
       :precondition  (and  (at ?car ?loc) (at-ferry ?loc) (empty-ferry))
       :effect (and
            (on ?car)
		    (not (at ?car ?loc)) 
		    (not (empty-ferry))))

   (:action debark
       :parameters  (?car - car  ?loc - location)
       :precondition  (and (on ?car) (at-ferry ?loc))
       :effect (and
            (at ?car ?loc)
		    (empty-ferry)
		    (not (on ?car))))

   (:legality-axiom (legal) (not (illegal)))

   ;; the ferry is at exactly one location
   (:legality-axiom (illegal) (not (exists (?l - location) (at-ferry ?l))))
   (:legality-axiom (illegal)
       (exists (?l1 ?l2 - location)
               (and (at-ferry ?l1) (at-ferry ?l2) (not (= ?l1 ?l2)))))

   ;; no car is on the ferry
   (:legality-axiom (illegal) (not (empty-ferry)))
   (:legality-axiom (illegal) (exists (?c - car) (on ?c)))

   ;; there is at least one car (as a side effect, the following axiom also
   ;; ensures that there is at least one location)
   (:legality-axiom (illegal) (not (exists (?c - car ?l - location) (at ?c ?l))))

   ;; each car is at exactly one location
   (:legality-axiom (illegal) (exists (?c - car)
     (not (exists (?l - location) (at ?c ?l)))))
   (:legality-axiom (illegal) (exists (?c - car ?l1 ?l2 - location)
     (and (at ?c ?l1) (at ?c ?l2) (not (= ?l1 ?l2)))))

   ;; there are at least two locations (the following axiom relies on a
   ;; previous axiom ensuring there is at least one location)
   (:legality-axiom (illegal) (forall (?x ?y - location) (= ?x ?y)))

   ;; each car has exactly one goal location (i.e., at_g is true for exactly
   ;; one location for each car)
   (:legality-axiom (illegal) (exists (?c - car)
     (not (exists (?l - location) (at_g ?c ?l)))))
   (:legality-axiom (illegal) (exists (?c - car ?l1 ?l2 - location)
     (and (at_g ?c ?l1) (at_g ?c ?l2) (not (= ?l1 ?l2)))))

   ;; for each car, its goal location differs from its original location
   (:legality-axiom (illegal)
       (exists (?c - car ?l - location) (and (at ?c ?l) (at_g ?c ?l))))

)

