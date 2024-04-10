open Camlbrick;;
open Camlbrick_gui;;

let game : t_camlbrick = make_camlbrick ();;
let param : t_camlbrick_param = param_get game;;

(* Charger le niveau par défaut ici *)

let tab : t_brick_kind array = [| BK_simple; BK_double; BK_bonus |] in
for x = 0 to Array.length game.matrix - 1 do
  for y = 0 to Array.length game.matrix.(x) - 1 do
    game.matrix.(x).(y) <- tab.(Random.int (Array.length tab))
  done;
done;

(* fonction qui lance le jeu *)
launch_camlbrick (param, game);;
