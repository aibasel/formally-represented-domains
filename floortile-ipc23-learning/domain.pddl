;; source: https://github.com/AI-Planning/pddl-generators/blob/main/floortile/domain.pddl
;; updates:
;;   - :action-costs removed
;;   - movements updated to move_* to avoid repeating action and predicate names, e.g., up pred. with up act.
;;   - all action names use underscore

(define (domain floortile)
(:requirements :typing)
(:types robot tile color - object)

(:predicates
    (robot-at ?r - robot ?x - tile)
    (up ?x - tile ?y - tile)
    (down ?x - tile ?y - tile)
    (right ?x - tile ?y - tile)
    (left ?x - tile ?y - tile)
    (clear ?x - tile)
    (painted ?x - tile ?c - color)
    (robot-has ?r - robot ?c - color)
    (available-color ?c - color)
    (free-color ?r - robot)
    (painted_g ?x - tile ?c - color)
    (legal)
    (illegal)
    (tl ?x - tile)
    (col ?x - tile)
    (colOf ?x ?y - tile)
    (row ?x - tile)
    (rowOf ?x ?y - tile)
    (one-col-grid))

(:legality-predicate legal)

(:domain-goal
  (forall (?x - tile ?c - color)
          (imply (painted_g ?x ?c) (painted ?x ?c))))

(:action change_color
  :parameters (?r - robot ?c - color ?c2 - color)
  :precondition (and (robot-has ?r ?c) (available-color ?c2))
  :effect (and (not (robot-has ?r ?c)) (robot-has ?r ?c2))
)

(:action paint_up
  :parameters (?r - robot ?y - tile ?x - tile ?c - color)
  :precondition (and (robot-has ?r ?c) (robot-at ?r ?x) (up ?y ?x) (clear ?y))
  :effect (and (not (clear ?y)) (painted ?y ?c))
)

(:action paint_down
  :parameters (?r - robot ?y - tile ?x - tile ?c - color)
  :precondition (and (robot-has ?r ?c) (robot-at ?r ?x) (down ?y ?x) (clear ?y))
  :effect (and (not (clear ?y)) (painted ?y ?c))
)

; Robot movements
(:action move_up
  :parameters (?r - robot ?x - tile ?y - tile)
  :precondition (and (robot-at ?r ?x) (up ?y ?x) (clear ?y))
  :effect (and (robot-at ?r ?y) (not (robot-at ?r ?x))
               (clear ?x) (not (clear ?y)))
)

(:action move_down
  :parameters (?r - robot ?x - tile ?y - tile)
  :precondition (and (robot-at ?r ?x) (down ?y ?x) (clear ?y))
  :effect (and (robot-at ?r ?y) (not (robot-at ?r ?x))
               (clear ?x) (not (clear ?y)))
)

(:action move_right
  :parameters (?r - robot ?x - tile ?y - tile)
  :precondition (and (robot-at ?r ?x) (right ?y ?x) (clear ?y))
  :effect (and (robot-at ?r ?y) (not (robot-at ?r ?x))
               (clear ?x) (not (clear ?y)))
)

(:action move_left
  :parameters (?r - robot ?x - tile ?y - tile)
  :precondition (and (robot-at ?r ?x) (left ?y ?x) (clear ?y))
  :effect (and (robot-at ?r ?y) (not (robot-at ?r ?x))
               (clear ?x) (not (clear ?y)))
)

(:axiom (legal) (not (illegal)))

;; each robot is on exactly one tile
(:axiom (illegal) (exists (?r - robot)
  (not (exists (?t - tile) (robot-at ?r ?t)))))
(:axiom (illegal) (exists (?r - robot ?t1 ?t2 - tile)
  (and (robot-at ?r ?t1) (robot-at ?r ?t2) (not (= ?t1 ?t2)))))

;; a tile is clear iff it is not painted and there is no robot on
(:axiom (illegal) (exists (?t - tile ?r - robot ?c - color)
  (and (clear ?t) (or (robot-at ?r ?t) (painted ?t ?c)))))
(:axiom (illegal) (exists (?t - tile)
  (and (not (clear ?t))
       (not (exists (?r) (robot-at ?r ?t)))
       (not (exists (?c) (painted ?t ?c))))))

;; no tile is painted in the initial state
(:axiom (illegal) (exists (?t - tile ?c - color) (painted ?t ?c)))

;; there is at least one robot
(:axiom (illegal) (forall (?t - tile)
  (not (exists (?r - robot) (robot-at ?r ?t)))))

;; there are exactly two colors
(:axiom (illegal) (forall (?x ?y - color) (= ?x ?y)))
(:axiom (illegal) (exists (?x ?y ?z - color)
  (and (not (= ?x ?y)) (not (= ?x ?z)) (not (= ?y ?z)))))

;; each robot has exactly one color
(:axiom (illegal) (exists (?r - robot) (forall (?c - color)
  (not (robot-has ?r ?c)))))

;; all colors are available
(:axiom (illegal) (exists (?c - color) (not (available-color ?c))))

;; the direction predicates form inverse pairs
(:axiom (illegal) (exists (?x ?y - tile) (and (up ?x ?y) (not (down ?y ?x)))))
(:axiom (illegal) (exists (?x ?y - tile) (and (down ?x ?y) (not (up ?y ?x)))))
(:axiom (illegal) (exists (?x ?y - tile) (and (left ?x ?y) (not (right ?y ?x)))))
(:axiom (illegal) (exists (?x ?y - tile) (and (right ?x ?y) (not (left ?y ?x)))))

;; the direction predicates are irreflexive
(:axiom (illegal) (exists (?x - tile) (up ?x ?x)))
(:axiom (illegal) (exists (?x - tile) (down ?x ?x)))
(:axiom (illegal) (exists (?x - tile) (left ?x ?x)))
(:axiom (illegal) (exists (?x - tile) (right ?x ?x)))

;; there is at most one tile in each direction
(:axiom (illegal) (exists (?x ?y ?z - tile)
  (and (up ?x ?y) (up ?x ?z) (not (= ?y ?z)))))
(:axiom (illegal) (exists (?x ?y ?z - tile)
  (and (down ?x ?y) (down ?x ?z) (not (= ?y ?z)))))
(:axiom (illegal) (exists (?x ?y ?z - tile)
  (and (left ?x ?y) (left ?x ?z) (not (= ?y ?z)))))
(:axiom (illegal) (exists (?x ?y ?z - tile)
  (and (right ?x ?y) (right ?x ?z) (not (= ?y ?z)))))

;; there is exactly one top-left corner tile
(:axiom (tl ?x - tile) (not (exists (?y - tile) (or (up ?y ?x) (left ?y ?x)))))
(:axiom (illegal) (not (exists (?x - tile) (tl ?x))))
(:axiom (illegal) (exists (?x ?y - tile) (and (tl ?x) (tl ?y) (not (= ?x ?y)))))

;; columns of the grid
(:axiom (col ?x - tile) (tl ?x))
(:axiom (col ?x - tile) (exists (?y - tile) (and (col ?y) (right ?x ?y))))
(:axiom (colOf ?x ?c - tile) (and (col ?c) (= ?x ?c)))
(:axiom (colOf ?x ?c - tile) (exists (?y - tile)
  (and (colOf ?y ?c) (down ?x ?y))))

;; rows of the grid
(:axiom (row ?x - tile) (tl ?x))
(:axiom (row ?x - tile) (exists (?y - tile) (and (row ?y) (down ?x ?y))))
(:axiom (rowOf ?x ?r - tile) (and (row ?r) (= ?x ?r)))
(:axiom (rowOf ?x ?r - tile) (exists (?y - tile)
  (and (rowOf ?y ?r) (right ?x ?y))))

;; the mapping from col, row pairs to tiles is a function
(:axiom (illegal) (exists (?c ?r - tile)
  (and (col ?c) (row ?r)
       (not (exists (?x) (and (colOf ?x ?c) (rowOf ?x ?r)))))))
(:axiom (illegal) (exists (?x ?y ?c ?r - tile)
  (and (colOf ?x ?c) (rowOf ?x ?r)
       (colOf ?y ?c) (rowOf ?y ?r)
       (not (= ?x ?y)))))

;; the mapping is surjective
(:axiom (illegal) (exists (?x - tile)
  (or (not (exists (?c - tile) (colOf ?x ?c)))
      (not (exists (?r - tile) (rowOf ?x ?r))))))

;; the mapping is injective
(:axiom (illegal) (exists (?x ?c1 ?c2 - tile)
  (and (not (= ?c1 ?c2)) (colOf ?x ?c1) (colOf ?x ?c2))))
(:axiom (illegal) (exists (?x ?r1 ?r2 - tile)
  (and (not (= ?r1 ?r2)) (rowOf ?x ?r1) (rowOf ?x ?r2))))

;; grids consisting of a single row are not allowed
(:axiom (illegal)
        (not (exists (?t1 ?t2 - tile) (or (down ?t1 ?t2) (up ?t1 ?t2)))))

;; helper predicate to check if the grid consists of a single column
;; NOTE: the generator for floortile from the IPC 2023 learning track implies
;; that grids have a size of at least 3x2 (of which a 2x2 grid is to be painted)
;; but the provided base cases include 2x1 grids (of which 1x1 grids are to be
;; painted)
(:axiom (one-col-grid)
        (and (exists (?t1 ?t2 - tile) (or (down ?t1 ?t2) (up ?t1 ?t2)))
             (forall (?t1 ?t2 - tile) (not (or (right ?t1 ?t2) (left ?t1 ?t2))))))

;; grid structure
(:axiom (illegal)
        (and (not (one-col-grid))
             (exists (?x ?y1 ?z - tile)
                     (and (right ?y1 ?x) (down ?z ?y1)
                          (not (exists (?y2 - tile)
                                       (and (down ?y2 ?x) (right ?z ?y2))))))))
(:axiom (illegal) 
        (and (not (one-col-grid))
             (exists (?x ?y1 ?z - tile)
                     (and (down ?y1 ?x) (right ?z ?y1)
                          (not (exists (?y2 - tile)
                                       (and (right ?y2 ?x) (down ?z ?y2))))))))

;; all tiles are part of the grid (the axiom for this relies on the existence
;; of at least one tile)
(:axiom (illegal) (exists (?x - tile)
  (not (exists (?y - tile) (or (left ?x ?y) (right ?x ?y)
                               (down ?x ?y) (up ?x ?y))))))

;; there is at most one robot in each column
(:axiom (illegal)
        (exists (?r1 ?r2 - robot ?t1 ?t2 ?c - tile)
                (and (not (= ?r1 ?r2)) (colOf ?t1 ?c) (colOf ?t2 ?c)
                     (robot-at ?r1 ?t1) (robot-at ?r2 ?t2))))

;; each tile is painted with at most one color in the goal
(:axiom (illegal)
        (exists (?t - tile ?c1 ?c2 - color)
                (and (not (= ?c1 ?c2)) (painted_g ?t ?c1) (painted_g ?t ?c2))))

;; all tiles except the first row are painted in the goal
(:axiom (illegal) (exists (?x ?y - tile)
  (and (down ?x ?y) (not (exists (?c - color) (painted_g ?x ?c))))))
(:axiom (illegal) (exists (?x - tile ?c - color)
  (and (not (exists (?y - tile) (down ?x ?y))) (painted_g ?x ?c))))

;; chessboard pattern (neighboring tiles do not share a color; the axiom relies
;; on there being only two colors)
(:axiom (illegal) (exists (?x ?y - tile ?c - color)
  (and (painted_g ?x ?c) (painted_g ?y ?c)
       (or (up ?x ?y) (down ?x ?y) (left ?x ?y) (right ?x ?y)))))

)
