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
  ball = [{
    position = (0, 0);
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  }]
};;

(**
  Cette suite de tests temoignent du fonctionement de notre raquette

  @author Matéo Abrane
*)
let test_struct_make_paddle () : unit =
  let res : t_paddle t_test_result = test_exec (
    make_paddle,
    "Structurel -> make_paddle",
    ()
  )
  in

  assert_equals_result (
    { size = PS_MEDIUM ; position = (ref 0, 0)},
    res
  )
;;
let test_struct_paddle_x () : unit =
  let res : int t_test_result = test_exec (
    paddle_x,
    "Structurel -> paddle_x",
    game
  )
  in

  assert_equals (0, test_get res)
;;
let test_struct_paddle_size_pixel () : unit =
  let res : int t_test_result = test_exec (
    paddle_size_pixel,
    "Structurel -> paddle_size_pixel",
    game
  )
  in

  assert_equals (200, test_get res)
;;

test_reset_report ();;

test_struct_make_paddle ();;
test_struct_paddle_x ();;
test_struct_paddle_size_pixel ();;

test_report ();;
