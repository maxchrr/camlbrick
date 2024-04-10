#load "CPtest.cmo";;
#load "camlbrick.cmo";;

open CPtest;;
open Camlbrick;;

let canvas_height : int = 20;;
let canvas_width : int = 31;;

let game : t_camlbrick = {
  param = make_camlbrick_param ();
  matrix = Array.make_matrix canvas_height canvas_width BK_empty;
  paddle =  {
    size = PS_MEDIUM;
    position = (ref 0, 0)
  };
  balls = [{
    position = ref (make_vec2 (0, 0));
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  }];
  speed = ref 0
};;

(**
  Test fonctionnel de la spécification de `ball_hit_remove_out_of_border`.

  Renvoie une nouvelle liste sans les balles qui dépassent la zone de rebond.

  @author Axel De Les Champs--Vieira
*)
let test_fonc_ball_remove_out_of_border () : unit =
  let res : t_ball list t_test_result = test_exec (
    ball_remove_out_of_border,
    "Fonctionnel -> ball_remove_out_of_border",
    (
      game,
      [{
        position = ref (make_vec2 (900, 900)); (* Position en dehors *)
        speed = ref (make_vec2 (0, 0));
        size = BS_MEDIUM
      }]
    )
  )
  in

  assert_equals ([], test_get res)
;;

(**
  Test fonctionnel de la spécification de `ball_hit_corner_brick`.

  Vérifie si une balle touche un des sommets des briques.

  @author Axel De Les Champs--Vieira
*)
let test_fonc_ball_hit_corner_brick () : unit =
  let res : bool t_test_result = test_exec (
    ball_hit_corner_brick,
    "Fonctionnel -> ball_hit_corner_brick",
    (game, List.hd game.balls, 0, 0)
  )
  in

  assert_true (test_get res)
;;

(**
  Test fonctionnel de la spécification de `ball_hit_side_brick`.

  Vérifie si une balle touche un des sommets des briques.

  @author Axel De Les Champs--Vieira
*)
let test_fonc_ball_hit_side_brick () : unit =
  let res : bool t_test_result = test_exec (
    ball_hit_side_brick,
    "Fonctionnel -> ball_hit_side_brick",
    (game, List.hd game.balls, 0, 0)
  )
  in

  assert_true (test_get res)
;;

test_reset_report ();;

test_fonc_ball_remove_out_of_border ();;
test_fonc_ball_hit_corner_brick ();;
test_fonc_ball_hit_side_brick ();;

test_report ();;
