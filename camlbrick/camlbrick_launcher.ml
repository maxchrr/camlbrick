open Camlbrick;;
open Camlbrick_gui;;

let game : t_camlbrick = make_camlbrick ();;
let param : t_camlbrick_param = param_get game;;

(* Charger le niveau par défaut ici *)


(* fonction qui lance le jeu *)
launch_camlbrick (param, game);;
