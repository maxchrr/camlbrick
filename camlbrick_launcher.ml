open Camlbrick;;
open Camlbrick_gui;;

let game : t_camlbrick = make_camlbrick ();;
let param : t_camlbrick_param = param_get game;;

(* Charger le niveau par défaut ici *)
let tab : t_brick_kind array = [| BK_simple; BK_double; BK_block; BK_bonus |] in
let map : t_brick_kind array array = Array.make_matrix 20 31 BK_empty in

for x = 0 to Array.length map - 1 do
  for y = 0 to Array.length map.(x) - 1 do
    map.(x).(y) <- tab.(Random.int (Array.length tab))
  done;
done;

game.matrix = map;;

(* fonction qui lance le jeu *)
launch_camlbrick (param, game);;
