open CPtest;;
open Camlbrick;;

let test_fonc_brick_color_empty () : unit =
  let res : t_camlbrick_color t_test_result = test_exec (brick_color, "brick_color_empty", ([| [| BK_empty |] |], 0, 0)) in

    assert_equals (BLACK, test_get res)
;;

@author Matéo Abrane

let test_fonc_make_vec2 () : unit =
  let res : t_vec2 t_test_result = test_exec (make_vec2, "make_vec2" (1, 1)) in

  assert_equals ({ x = 1; y = 1 }, test_get res)
;;

let test_fonc_vec2_add () : unit =
  let res : t_vec2 t_test_result = test_exec (vec2_add, "vec2_add" ({ x = 1; y = 1 }, { x = 2; y = 2 })) in

  assert_equals ({ x = 3; y = 3 }, test_get res)
;;

let test_fonc_vec2_mult () : unit =
  let res : t_vec2 t_test_result = test_exec (vec2_mult, "vec2_mult" ({ x = 1; y = 1 }, { x = 2; y = 2 })) in

  assert_equal({ x = 2; y = 2 }, test_get res)
;;

test_reset_report ();;

test_fonc_brick_color_empty ();;

test_report ();;
