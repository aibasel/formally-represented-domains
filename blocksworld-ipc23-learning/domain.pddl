;; source: https://github.com/AI-Planning/pddl-generators/blob/main/blocksworld/domain.pddl
;;
(define (domain blocksworld)

(:requirements :strips)

(:predicates (clear ?x)
             (on-table ?x)
             (arm-empty)
             (holding ?x)
             (on ?x ?y)
             (clear_g ?x)
             (on-table_g ?x)
             (on_g ?x ?y)
             (above ?x ?y)
             (above_g ?x ?y)
             (legal)
             (illegal))

(:legality-predicate legal)

(:domain-goal
  (and (forall (?b) (and (imply (clear_g ?b) (clear ?b))
                         (imply (on-table_g ?b) (on-table ?b))))
       (forall (?b1 ?b2) (imply (on_g ?b1 ?b2) (on ?b1 ?b2)))))

(:action pickup
  :parameters (?ob)
  :precondition (and (clear ?ob) (on-table ?ob) (arm-empty))
  :effect (and (holding ?ob) (not (clear ?ob)) (not (on-table ?ob)) 
               (not (arm-empty))))

(:action putdown
  :parameters  (?ob)
  :precondition (holding ?ob)
  :effect (and (clear ?ob) (arm-empty) (on-table ?ob) 
               (not (holding ?ob))))

(:action stack
  :parameters  (?ob ?underob)
  :precondition (and (clear ?underob) (holding ?ob))
  :effect (and (arm-empty) (clear ?ob) (on ?ob ?underob)
               (not (clear ?underob)) (not (holding ?ob))))

(:action unstack
  :parameters  (?ob ?underob)
  :precondition (and (on ?ob ?underob) (clear ?ob) (arm-empty))
  :effect (and (holding ?ob) (clear ?underob)
               (not (on ?ob ?underob)) (not (clear ?ob)) (not (arm-empty))))

(:legality-axiom (legal) (not (illegal)))

(:legality-axiom (above ?x ?y)
  (or (on ?x ?y)
      (exists (?z) (and (on ?x ?z) (above ?z ?y)))))

(:legality-axiom (illegal) (exists (?b) (above ?b ?b)))

(:legality-axiom (illegal)
  (exists (?x ?y ?z) (and (on ?x ?y) (on ?x ?z) (not (= ?y ?z)))))

(:legality-axiom (illegal)
  (exists (?x ?y ?z) (and (on ?y ?x) (on ?z ?x) (not (= ?y ?z)))))

(:legality-axiom (illegal)
  (or (not (arm-empty)) (exists (?x) (holding ?x))))

(:legality-axiom (illegal)
  (not (forall (?x) (or (on-table ?x) (exists (?y) (on ?x ?y))))))

(:legality-axiom (illegal)
  (exists (?x ?y) (and (on-table ?x) (on ?x ?y))))

(:legality-axiom (illegal)
  (not (forall (?x) (or (clear ?x) (exists (?y) (on ?y ?x))))))

(:legality-axiom (illegal)
  (exists (?x ?y) (and (clear ?x) (on ?y ?x))))

;; at least one block lies on the table (preventing empty initial states)
(:legality-axiom (illegal)
  (forall (?x) (not (on-table ?x))))

;; legality axioms to characterise instance-specific goals

(:legality-axiom (above_g ?x ?y)
  (or (on_g ?x ?y)
      (exists (?z) (and (on_g ?x ?z) (above_g ?z ?y)))))

(:legality-axiom (illegal) (exists (?b) (above_g ?b ?b)))

(:legality-axiom (illegal)
  (exists (?x ?y ?z) (and (on_g ?x ?y) (on_g ?x ?z) (not (= ?y ?z)))))

(:legality-axiom (illegal)
  (exists (?x ?y ?z) (and (on_g ?y ?x) (on_g ?z ?x) (not (= ?y ?z)))))

(:legality-axiom (illegal)
  (exists (?x ?y) (and (on-table_g ?x) (on_g ?x ?y))))

(:legality-axiom (illegal)
  (exists (?x ?y) (and (clear_g ?x) (on_g ?y ?x))))

;; in the goal at least one block is on the table (preventing empty goals)
(:legality-axiom (illegal)
  (forall (?x) (not (on-table_g ?x))))

)

