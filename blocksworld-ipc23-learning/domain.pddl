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

(:axiom (legal) (not (illegal)))

(:axiom (above ?x ?y)
  (or (on ?x ?y)
      (exists (?z) (and (on ?x ?z) (above ?z ?y)))))

(:axiom (illegal) (exists (?b) (above ?b ?b)))

(:axiom (illegal)
  (exists (?x ?y ?z) (and (on ?x ?y) (on ?x ?z) (not (= ?y ?z)))))

(:axiom (illegal)
  (exists (?x ?y ?z) (and (on ?y ?x) (on ?z ?x) (not (= ?y ?z)))))

(:axiom (illegal)
  (or (not (arm-empty)) (exists (?x) (holding ?x))))

(:axiom (illegal)
  (not (forall (?x) (or (on-table ?x) (exists (?y) (on ?x ?y))))))

(:axiom (illegal) 
  (exists (?x ?y) (and (on-table ?x) (on ?x ?y))))

(:axiom (illegal)
  (not (forall (?x) (or (clear ?x) (exists (?y) (on ?y ?x))))))

(:axiom (illegal)
  (exists (?x ?y) (and (clear ?x) (on ?y ?x))))

;; axioms to encode task-specific goal information into the initial state

(:axiom (above_g ?x ?y)
  (or (on_g ?x ?y)
      (exists (?z) (and (on_g ?x ?z) (above_g ?z ?y)))))

(:axiom (illegal) (exists (?b) (above_g ?b ?b)))

(:axiom (illegal)
  (exists (?x ?y ?z) (and (on_g ?x ?y) (on_g ?x ?z) (not (= ?y ?z)))))

(:axiom (illegal)
  (exists (?x ?y ?z) (and (on_g ?y ?x) (on_g ?z ?x) (not (= ?y ?z)))))

(:axiom (illegal)
  (not (forall (?x) (or (on-table_g ?x) (exists (?y) (on_g ?x ?y))))))

(:axiom (illegal) 
  (exists (?x ?y) (and (on-table_g ?x) (on_g ?x ?y))))

(:axiom (illegal)
  (not (forall (?x) (or (clear_g ?x) (exists (?y) (on_g ?y ?x))))))

(:axiom (illegal)
  (exists (?x ?y) (and (clear_g ?x) (on_g ?y ?x))))

)

