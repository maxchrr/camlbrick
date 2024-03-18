open Camlbrick;;
open Camlbrick_gui;;


let game = make_camlbrick();;
let param = param_get(game);;

(*
  Chargez votre niveau par defaut ici   
  
*)


(* fonction qui lance le jeu *)
launch_camlbrick(param,game);;