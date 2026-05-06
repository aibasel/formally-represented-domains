; source: https://github.com/AI-Planning/pddl-generators/blob/main/transport/domain.pddl
; updates:
;  - removed :action-costs and :functions
;  - capacity type now is size
;  - capacity-number predicate now is capacity
(define (domain transport)
  (:requirements :typing)
  (:types
        size location locatable - object
        vehicle package - locatable
  )

  (:predicates
     (road ?l1 ?l2 - location)
     (at ?x - locatable ?v - location)
     (in ?x - package ?v - vehicle)
     (capacity ?v - vehicle ?s1 - size)
     (capacity-predecessor ?s1 ?s2 - size)
     (at_g ?x - package ?v - location)
     (legal)
     (illegal)
     (less-than ?s1 ?s2 - size)
     (reachable ?x ?y - location)
  )

  (:legality-predicate legal)

  (:domain-goal
    (forall (?x - locatable ?v - location)
            (imply (at_g ?x ?v) (at ?x ?v))))

  (:action drive
    :parameters (?v - vehicle ?l1 ?l2 - location)
    :precondition (and
        (at ?v ?l1)
        (road ?l1 ?l2)
      )
    :effect (and
        (not (at ?v ?l1))
        (at ?v ?l2)
      )
  )

 (:action pick-up
    :parameters (?v - vehicle ?l - location ?p - package ?s1 ?s2 - size)
    :precondition (and
        (at ?v ?l)
        (at ?p ?l)
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s2)
      )
    :effect (and
        (not (at ?p ?l))
        (in ?p ?v)
        (capacity ?v ?s1)
        (not (capacity ?v ?s2))
      )
  )

  (:action drop
    :parameters (?v - vehicle ?l - location ?p - package ?s1 ?s2 - size)
    :precondition (and
        (at ?v ?l)
        (in ?p ?v)
        (capacity-predecessor ?s1 ?s2)
        (capacity ?v ?s1)
      )
    :effect (and
        (not (in ?p ?v))
        (at ?p ?l)
        (capacity ?v ?s2)
        (not (capacity ?v ?s1))
      )
  )

  (:legality-axiom (legal) (not (illegal)))

  ;; there is at least one package (as a side effect, the following axiom also
  ;; ensures there is at least one location)
  (:legality-axiom (illegal) (not (exists (?p - package ?l - location) (at ?p ?l))))

  ;; there is at least one vehicle
  (:legality-axiom (illegal) (not (exists (?v - vehicle ?l - location) (at ?v ?l))))

  ;; the predicate road is symmetric
  (:legality-axiom (illegal) (exists (?x ?y - location)
                            (and (road ?x ?y) (not (road ?y ?x)))))

  ;; the predicate road is irreflexive
  (:legality-axiom (illegal) (exists (?x - location) (road ?x ?x)))

  ;; for each locatable, predicate at is true for exactly one location
  (:legality-axiom (illegal)
    (exists (?l - locatable) (not (exists (?x - location) (at ?l ?x)))))
  (:legality-axiom (illegal)
    (exists (?l - locatable ?x ?y - location)
            (and (at ?l ?x) (at ?l ?y) (not (= ?x ?y)))))

  ;; for each package, at_g is true for exactly one location
  (:legality-axiom (illegal)
    (exists (?p - package) (not (exists (?x - location) (at_g ?p ?x)))))
  (:legality-axiom (illegal)
    (exists (?p - package ?x ?y - location)
            (and (at_g ?p ?x) (at_g ?p ?y) (not (= ?x ?y)))))
  
  ;; the starting location and goal location of each package differ
  (:legality-axiom (illegal) (exists (?p - package ?l - location) (and (at ?p ?l)
                                                              (at_g ?p ?l))))

  ;; for each vehicle, the predicate capacity is true for exactly one size
  (:legality-axiom (illegal)
    (exists (?v - vehicle)
            (not (exists (?c - size) (capacity ?v ?c)))))
  (:legality-axiom (illegal)
    (exists (?v - vehicle ?c1 ?c2 - size)
            (and (capacity ?v ?c1) (capacity ?v ?c2) (not (= ?c1 ?c2)))))

  ;; the transitive closure of predicate capacity-predecessor is a strict total
  ;; order (irreflexive, transitive, connected) over the sizes 
  (:legality-axiom (less-than ?c1 ?c2 - size)
    (or (capacity-predecessor ?c1 ?c2)
        (exists (?c3 - size)
                (and (capacity-predecessor ?c1 ?c3) (less-than ?c3 ?c2)))))
  (:legality-axiom (illegal) (exists (?c - size) (less-than ?c ?c)))
  (:legality-axiom (illegal) (exists (?c1 ?c2 ?c3 - size)
                            (and (less-than ?c1 ?c2)
                                 (less-than ?c2 ?c3)
                                 (not (less-than ?c1 ?c3)))))
  (:legality-axiom (illegal) (exists (?c1 ?c2 - size)
                            (and (not (= ?c1 ?c2))
                                 (not (less-than ?c1 ?c2))
                                 (not (less-than ?c2 ?c1)))))
                
  ;; the predicate in is never true in the initial state
  (:legality-axiom (illegal) (exists (?p - package ?v - vehicle) (in ?p ?v)))

  ;; the road-graph is connected
  (:legality-axiom (reachable ?x ?y - location)
    (or (road ?x ?y) (exists (?z - location)
                             (and (reachable ?x ?z) (road ?z ?y)))))
  (:legality-axiom (illegal) (exists (?l1 ?l2 - location) (not (reachable ?l1 ?l2))))

  ;; each vehicle has a capacity of at least one
  (:legality-axiom (illegal)
          (exists (?v - vehicle ?c - size)
                  (and (capacity ?v ?c)
                       (not (exists (?cp - size) (capacity-predecessor ?cp ?c))))))
)
