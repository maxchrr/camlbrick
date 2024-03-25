open CPtest;;
open Camlbrick;;

(**
  Cette suite de tests temoignent du fonctionement de nos raquettes 
  @author Matéo Abrane
*)

let test_fonc_paddle_size_pixel () : unit =
  let res_paddle_size_pixel t_test_result = text_exec (paddle_size_pixel, "paddle_size_pixel", 
   matrix = [| [|BK_simple|] |]; paddle = {taille = PS_BIG,  position = (ref 10 , 3)}) in
  
    assert_equals (200, test_get res_paddle_size_pixel)
;;

let test_fonc_paddle_x () : unit =
  let res_paddle_x t_test_result = text_exec (paddle_x, "paddle_x", {taille = PS_BIG,  position = (ref 10 , 3)}) in

    assert_equals(10, test_get res_paddle_x)
;;

test_reset_report ();;

test_fonc_t_paddle ();;
test_fonc_paddle_size_pixel ();;
test_fonc_paddle_x ();;

test_report ();;
