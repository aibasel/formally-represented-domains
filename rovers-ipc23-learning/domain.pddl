;; source: https://github.com/AI-Planning/pddl-generators/blob/main/rovers/domain.pddl
;; updates:
;;   - since actions are performed sequentially and immediately
;;     'channel_free' and 'available' predicates are removed
;;   -

(define (domain rover)
(:requirements :strips :typing)
(:types rover waypoint store camera mode lander objective - object)

(:predicates
    (at ?x - rover ?y - waypoint)
    (at_lander ?x - lander ?y - waypoint)
    (can_traverse ?r - rover ?x - waypoint ?y - waypoint)
	(equipped_for_soil_analysis ?r - rover)
    (equipped_for_rock_analysis ?r - rover)
    (equipped_for_imaging ?r - rover)
    (empty ?s - store)
    (have_rock_analysis ?r - rover ?w - waypoint)
    (have_soil_analysis ?r - rover ?w - waypoint)
    (full ?s - store)
	(calibrated ?c - camera ?r - rover)
	(supports ?c - camera ?m - mode)
    (visible ?w - waypoint ?p - waypoint)
    (have_image ?r - rover ?o - objective ?m - mode)
    (communicated_soil_data ?w - waypoint)
    (communicated_soil_data_g ?w - waypoint)
    (communicated_rock_data ?w - waypoint)
    (communicated_rock_data_g ?w - waypoint)
    (communicated_image_data ?o - objective ?m - mode)
    (communicated_image_data_g ?o - objective ?m - mode)
	(at_soil_sample ?w - waypoint)
	(at_rock_sample ?w - waypoint)
    (visible_from ?o - objective ?w - waypoint)
	(store_of ?s - store ?r - rover)
	(calibration_target ?i - camera ?o - objective)
	(on_board ?i - camera ?r - rover)
  (legal)
  (illegal)
  (tc_visible ?x ?y - waypoint)
  (tc_can_traverse ?r - rover ?x ?y - waypoint)
)

(:legality-predicate legal)

(:domain-goal
  (and (forall (?w - waypoint)
               (imply (communicated_soil_data_g ?w)
                      (communicated_soil_data ?w)))
       (forall (?w - waypoint)
               (imply (communicated_rock_data_g ?w)
                      (communicated_rock_data ?w)))
       (forall (?o - objective ?m - mode)
               (imply (communicated_image_data_g ?o ?m)
                      (communicated_image_data ?o ?m)))))

(:action navigate
:parameters (?x - rover ?y - waypoint ?z - waypoint)
:precondition (and
    (can_traverse ?x ?y ?z)
    (at ?x ?y)
    (visible ?y ?z))
:effect (and
    (not (at ?x ?y))
    (at ?x ?z))
)

(:action sample_soil
:parameters (?x - rover ?s - store ?p - waypoint)
:precondition (and
    (at ?x ?p)
    (at_soil_sample ?p)
	(equipped_for_soil_analysis ?x)
	(store_of ?s ?x)
	(empty ?s))
:effect (and
    (not (empty ?s))
    (full ?s)
    (have_soil_analysis ?x ?p)
    (not (at_soil_sample ?p)))
)

(:action sample_rock
:parameters (?x - rover ?s - store ?p - waypoint)
:precondition (and
    (at ?x ?p)
    (at_rock_sample ?p)
	(equipped_for_rock_analysis ?x)
	(store_of ?s ?x)
	(empty ?s))
:effect (and
    (not (empty ?s))
    (full ?s)
    (have_rock_analysis ?x ?p)
	(not (at_rock_sample ?p)))
)

(:action drop
:parameters (?x - rover ?y - store)
:precondition (and
    (store_of ?y ?x)
    (full ?y))
:effect (and
    (not (full ?y))
    (empty ?y))
)

(:action calibrate
 :parameters (?r - rover ?i - camera ?t - objective ?w - waypoint)
 :precondition (and
    (equipped_for_imaging ?r)
    (calibration_target ?i ?t)
    (at ?r ?w)
    (visible_from ?t ?w)
    (on_board ?i ?r))
 :effect (and
    (calibrated ?i ?r))
)

(:action take_image
 :parameters (?r - rover ?p - waypoint ?o - objective ?i - camera ?m - mode)
 :precondition (and
    (calibrated ?i ?r)
    (on_board ?i ?r)
    (equipped_for_imaging ?r)
    (supports ?i ?m)
    (visible_from ?o ?p)
    (at ?r ?p))
 :effect (and
    (have_image ?r ?o ?m)
    (not (calibrated ?i ?r)))
)

(:action communicate_soil_data
 :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
 :precondition (and
    (at ?r ?x)
    (at_lander ?l ?y)
    (have_soil_analysis ?r ?p)
    (visible ?x ?y))
 :effect (and
    (communicated_soil_data ?p))
)

(:action communicate_rock_data
 :parameters (?r - rover ?l - lander ?p - waypoint ?x - waypoint ?y - waypoint)
 :precondition (and
    (at ?r ?x)
    (at_lander ?l ?y)
    (have_rock_analysis ?r ?p)
    (visible ?x ?y))
 :effect (and
    (communicated_rock_data ?p))
)

(:action communicate_image_data
 :parameters (?r - rover ?l - lander ?o - objective ?m - mode
	      ?x - waypoint ?y - waypoint)
 :precondition (and
    (at ?r ?x)
    (at_lander ?l ?y)
    (have_image ?r ?o ?m)
    (visible ?x ?y))
 :effect (and
    (communicated_image_data ?o ?m)))

(:legality-axiom (legal) (not (illegal)))

;; there is at least one rover (and at least one waypoint)
(:legality-axiom (illegal) (not (exists (?r - rover ?w - waypoint) (at ?r ?w))))

;; there are at least two waypoints (the following axiom relies on the previous
;; one ensuring there is at least one waypoint)
(:legality-axiom (illegal) (forall (?w1 ?w2 - waypoint) (= ?w1 ?w2)))

;; there is at least one camera and at least one objective
(:legality-axiom (illegal)
  (not (exists (?c - camera ?o - objective) (calibration_target ?c ?o))))

;; there is exactly one lander
(:legality-axiom (illegal) (not (exists (?l - lander ?w - waypoint) (at_lander ?l ?w))))
(:legality-axiom (illegal) (exists (?l1 ?l2 - lander) (not (= ?l1 ?l2))))

;; there are exactly three modes (the following axioms rely on the axiom
;; ensuring each camera supports at least one mode, as this ensures there
;; exists at least one mode)
(:legality-axiom (illegal)
  (not (exists (?m1 ?m2 ?m3 - mode)
               (and (not (= ?m1 ?m2)) (not (= ?m1 ?m3)) (not (= ?m2 ?m3))))))
(:legality-axiom (illegal)
  (exists (?m1 ?m2 ?m3 ?m4 - mode)
          (and (not (= ?m1 ?m2)) (not (= ?m1 ?m3)) (not (= ?m1 ?m4))
               (not (= ?m2 ?m3)) (not (= ?m2 ?m4)) (not (= ?m3 ?m4)))))

;; each rover has exactly one store and each store is on exactly one rover
(:legality-axiom (illegal)
  (exists (?r - rover) (not (exists (?s - store) (store_of ?s ?r)))))
(:legality-axiom (illegal)
  (exists (?s - store) (not (exists (?r - rover) (store_of ?s ?r)))))
(:legality-axiom (illegal)
  (exists (?s1 ?s2 - store ?r - rover)
          (and (store_of ?s1 ?r) (store_of ?s2 ?r) (not (= ?s1 ?s2)))))
(:legality-axiom (illegal)
  (exists (?s - store ?r1 ?r2 - rover)
          (and (store_of ?s ?r1) (store_of ?s ?r2) (not (= ?r1 ?r2)))))

;; each lander (the single one that exists) is at exactly one waypoint
(:legality-axiom (illegal)
  (exists (?l - lander) (not (exists (?w - waypoint) (at_lander ?l ?w)))))
(:legality-axiom (illegal)
  (exists (?l - lander ?w1 ?w2 - waypoint)
          (and (at_lander ?l ?w1) (at_lander ?l ?w2) (not (= ?w1 ?w2)))))

;; each rover is at exactly one waypoint
(:legality-axiom (illegal)
  (exists (?r - rover) (not (exists (?w - waypoint) (at ?r ?w)))))
(:legality-axiom (illegal)
  (exists (?r - rover ?w1 ?w2 - waypoint)
          (and (at ?r ?w1) (at ?r ?w2) (not (= ?w1 ?w2)))))

;; for each of soil analysis, rock analysis, and imaging, there is at least one
;; rover equipped for
(:legality-axiom (illegal) (not (exists (?r - rover) (equipped_for_soil_analysis ?r))))
(:legality-axiom (illegal) (not (exists (?r - rover) (equipped_for_rock_analysis ?r))))
(:legality-axiom (illegal) (not (exists (?r - rover) (equipped_for_imaging ?r))))

;; all stores are empty (i. e., also not full)
(:legality-axiom (illegal) (exists (?s - store) (not (empty ?s))))
(:legality-axiom (illegal) (exists (?s - store) (full ?s)))

;; the predicate visible forms an undirected and connected (i. e., all nodes
;; are in the transitive closure of visible) graph over all waypoints
(:legality-axiom (illegal)
  (exists (?x ?y - waypoint) (and (visible ?x ?y) (not (visible ?y ?x)))))
(:legality-axiom (tc_visible ?x ?y - waypoint) (visible ?x ?y))
(:legality-axiom (tc_visible ?x ?y - waypoint)
  (exists (?z - waypoint) (and (tc_visible ?x ?z) (visible ?z ?y))))
(:legality-axiom (illegal) (exists (?x ?y - waypoint) (not (tc_visible ?x ?y))))

;; for each rover, the predicate can_traverse forms an undirected and connected
;; graph over all waypoints that is a subgraph of the visible-graph
(:legality-axiom (illegal)
  (exists (?r - rover ?x ?y - waypoint)
          (and (can_traverse ?r ?x ?y) (not (can_traverse ?r ?y ?x)))))
(:legality-axiom (tc_can_traverse ?r - rover ?x ?y - waypoint) (can_traverse ?r ?x ?y))
(:legality-axiom (tc_can_traverse ?r - rover ?x ?y - waypoint)
  (exists (?z - waypoint)
          (and (tc_can_traverse ?r ?x ?z) (can_traverse ?r ?z ?y))))
(:legality-axiom (illegal)
  (exists (?r - rover ?x ?y - waypoint) (not (tc_can_traverse ?r ?x ?y))))
(:legality-axiom (illegal)
  (exists (?r - rover ?x ?y - waypoint)
          (and (not (visible ?x ?y)) (can_traverse ?r ?x ?y))))

;; each camera has exactly one calibration target
(:legality-axiom (illegal)
  (exists (?c - camera)
          (not (exists (?o - objective) (calibration_target ?c ?o)))))
(:legality-axiom (illegal)
  (exists (?c - camera ?o1 ?o2 - objective)
          (and (calibration_target ?c ?o1) (calibration_target ?c ?o2)
               (not (= ?o1 ?o2)))))

;; each camera is on exactly one rover that is equipped for imaging
(:legality-axiom (illegal)
  (exists (?c - camera)
          (not (exists (?r - rover)
                       (and (on_board ?c ?r) (equipped_for_imaging ?r))))))
(:legality-axiom (illegal)
  (exists (?c - camera ?r1 ?r2 - rover)
          (and (on_board ?c ?r1) (on_board ?c ?r2) (not (= ?r1 ?r2)))))

;; each camera supports at least one mode
(:legality-axiom (illegal)
  (exists (?c - camera) (not (exists (?m - mode) (supports ?c ?m)))))

;; each mode is supported by at least one camera
(:legality-axiom (illegal)
  (exists (?m - mode) (not (exists (?c - camera) (supports ?c ?m)))))

;; each objective is visible from at least one waypoint
(:legality-axiom (illegal)
  (exists (?o - objective) (not (exists (?w - waypoint) (visible_from ?o ?w)))))

;; communicating soil / rock data for a waypoint cannot be part of the goal if
;; that waypoint has no soil / rock sample
(:legality-axiom (illegal)
  (exists (?w - waypoint)
          (and (not (at_soil_sample ?w)) (communicated_soil_data_g ?w))))
(:legality-axiom (illegal)
  (exists (?w - waypoint)
          (and (not (at_rock_sample ?w)) (communicated_rock_data_g ?w))))
)

