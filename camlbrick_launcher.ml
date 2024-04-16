open Camlbrick;;
open Camlbrick_gui;;

let game : t_camlbrick = make_camlbrick ();;
let param : t_camlbrick_param = param_get game;;

(* Charger le niveau par défaut ici *)
Random.self_init ();

let tab : t_brick_kind array = [| BK_empty; BK_simple; BK_double |] in

let count : int ref = ref 0 in
let max_bonus : int ref = ref (Random.int 30)
and max_block : int ref = ref (Random.int 15)
in

for x = 0 to Array.length game.matrix - 1 do
  for y = 0 to Array.length game.matrix.(x) - 1 do
    if !count = !max_bonus then begin
      game.matrix.(x).(y) <- BK_bonus;
      count := 0;
      max_bonus := Random.int 30
    end else if !count = !max_block then begin
      game.matrix.(x).(y) <- BK_block;
      max_block := Random.int 15
    end else
      game.matrix.(x).(y) <- tab.(Random.int (Array.length tab));

    count := !count + 1
  done;
done;

(* fonction qui lance le jeu *)
launch_camlbrick (param, game);;
