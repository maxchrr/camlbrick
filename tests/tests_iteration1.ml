#load "../cambrick/camlbrick.cmo"
#mod_use "CPtest.ml"
open CPtest;;

let test_fonc_brick_color_empty () : unit =
  let res : t_camlbrick_color t_test_result = test_exec (brick_color, "brick_color_empty", ([| [| BK_empty |] |], 0, 0) in

    assert_equals (BLACK, test_get res)
;;
