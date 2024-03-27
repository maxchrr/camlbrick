#load "CPtest.cmo";;
#load "camlbrick.cmo";;

open CPtest;;
open Camlbrick;;

let paddle : t_paddle = {taille = PS_BIG; position = (ref 10, 3)};;

let camlbrick : t_camlbrick = {
  param = {
    world_width = 800;
    world_bricks_height = 600;
    world_empty_height = 200;

    brick_width = 40;
    brick_height = 20;

    paddle_init_width = 100;
    paddle_init_height = 20;

    time_speed = ref 20;
  };
  matrix = Array.make_matrix 8 30 BK_empty;
  paddle = paddle
};;

(**
  Cette suite de tests temoignent du fonctionement de nos raquettes 
  @author Matéo Abrane
*)

let test_fonc_make_paddle () : unit =
  let res_make_paddle : t_paddle t_test_result = test_exec (make_paddle, "make_paddle", ()) in

  assert_equals ({taille = PS_MEDIUM; position = (ref 0, 0)}, test_get res_make_paddle)
;;

let test_fonc_paddle_size_pixel () : unit =
  let res_paddle_size_pixel : int t_test_result = test_exec (paddle_size_pixel, "paddle_size_pixel", camlbrick) in
  
  assert_equals (200, test_get res_paddle_size_pixel)
;;

let test_fonc_paddle_x () : unit =
  let res_paddle_x : int t_test_result = test_exec (paddle_x, "paddle_x", camlbrick) in

    assert_equals(10, test_get res_paddle_x)
;;

let test_fonc_paddle_move_left () : unit =
  let res_paddle_move_left : t_paddle t_test_result = test_exec (paddle_move_left, "paddle_move_left"

test_reset_report ();;

test_fonc_make_paddle ();;
test_fonc_paddle_size_pixel ();;
test_fonc_paddle_x ();;

test_report ();;
