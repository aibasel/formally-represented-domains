(define (domain satellite)
  (:requirements :strips :typing :negative-preconditions)
  (:types satellite direction instrument mode)
  (:predicates
	(on_board ?i - instrument ?s - satellite)
	(supports ?i - instrument ?m - mode)
	(pointing ?s - satellite ?d - direction)
	(pointing_g ?s - satellite ?d - direction)
	(power_avail ?s - satellite)
	(power_on ?i - instrument)
	(calibrated ?i - instrument)
	(have_image ?d - direction ?m - mode)
	(have_image_g ?d - direction ?m - mode)
	(calibration_target ?i - instrument ?d - direction)
    (legal)
    (illegal)
  )
  (:legality-predicate legal)
  
  (:domain-goal
    (and
      (forall (?s - satellite ?d - direction)
              (imply (pointing_g ?s ?d) (pointing ?s ?d)))
      (forall (?d - direction ?m - mode)
              (imply (have_image_g ?d ?m) (have_image ?d ?m)))))

  (:action turn_to
   :parameters (?s - satellite ?d_new - direction ?d_prev - direction)
   :precondition (and
        (pointing ?s ?d_prev)
        (not (pointing ?s ?d_new)))
   :effect (and
        (pointing ?s ?d_new)
        (not (pointing ?s ?d_prev))))

  (:action switch_on
   :parameters (?i - instrument ?s - satellite)
   :precondition (and
        (on_board ?i ?s)
        (power_avail ?s))
   :effect (and
        (power_on ?i)
        (not (calibrated ?i))
        (not (power_avail ?s))))

  (:action switch_off
   :parameters (?i - instrument ?s - satellite)
   :precondition (and (on_board ?i ?s)
                      (power_on ?i))
   :effect (and (not (power_on ?i))
                (power_avail ?s)))

  (:action calibrate
   :parameters (?s - satellite ?i - instrument ?d - direction)
   :precondition (and (on_board ?i ?s)
		      (calibration_target ?i ?d)
                      (pointing ?s ?d)
                      (power_on ?i))
   :effect (calibrated ?i))

  (:action take_image
   :parameters (?s - satellite ?d - direction ?i - instrument ?m - mode)
   :precondition (and (calibrated ?i)
                      (on_board ?i ?s)
                      (supports ?i ?m)
                      (power_on ?i)
                      (pointing ?s ?d))
   :effect (have_image ?d ?m))
  
  (:legality-axiom (legal) (not (illegal)))

  ;; there is at least one satellite (as a side effect, the following axiom
  ;; also ensures that there is at least one direction)
  (:legality-axiom (illegal) (not (exists (?s - satellite ?d - direction) (pointing ?s ?d))))

  ;; there are at least two directions (the following axiom relies on the
  ;; previous axiom that ensures there exists at least one direction)
  (:legality-axiom (illegal) (forall (?d1 ?d2 - direction) (= ?d1 ?d2)))
 
  ;; every satellite must point to exactly one direction 
  (:legality-axiom (illegal) (exists (?s - satellite) (not (exists (?d - direction) (pointing ?s ?d)))))
  (:legality-axiom (illegal) (exists (?s - satellite ?d1 ?d2 - direction)
    (and (pointing ?s ?d1) (pointing ?s ?d2) (not (= ?d1 ?d2)))))

  ;; all satellites have power available
  (:legality-axiom (illegal) (exists (?s - satellite) (not (power_avail ?s))))

  ;; every instrument has exactly one calibration target
  (:legality-axiom (illegal) (exists (?i - instrument) (not (exists (?d - direction) (calibration_target ?i ?d)))))
  (:legality-axiom (illegal) (exists (?i - instrument ?d1 ?d2 - direction)
    (and (calibration_target ?i ?d1) (calibration_target ?i ?d2) (not (= ?d1 ?d2)))))

  ;; every instrument is on exactly one satellite
  (:legality-axiom (illegal) (exists (?i - instrument) (not (exists (?s - satellite) (on_board ?i ?s)))))
  (:legality-axiom (illegal) (exists (?i - instrument ?s1 ?s2 - satellite)
    (and (on_board ?i ?s1) (on_board ?i ?s2) (not (= ?s1 ?s2)))))

  ;; every satellite has at least one instrument
  (:legality-axiom (illegal) (exists (?s - satellite) (not (exists (?i - instrument) (on_board ?i ?s)))))

  ;; every instrument has at least one mode
  (:legality-axiom (illegal) (exists (?i - instrument) (not (exists (?m - mode) (supports ?i ?m)))))

  ;; every mode supported by at least one instrument
  (:legality-axiom (illegal) (exists (?m - mode) (not (exists (?i - instrument) (supports ?i ?m)))))

  ;; have_image_g is true for at least one pair of direction, mode
  (:legality-axiom (illegal) (not (exists (?d - direction ?m - mode) (have_image_g ?d ?m))))
)
