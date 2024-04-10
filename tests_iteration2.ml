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
  balls = [{
    position = ref (make_vec2 (0, 0));
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  }];
  speed = ref 0
};;

(**
  Test structurel de `make_paddle`.

 Création d'une raquette par défaut au milieu de l'écran et de taille normal.

  @author Matéo Abrane
  @author Max Charrier
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

(**
  Test structurel de `paddle_x`.

  Renvoie la position selon l'axe horizontale de la raquette.

  @author Matéo Abrane
  @author Max Charrier
*)
let test_struct_paddle_x () : unit =
  let res : int t_test_result = test_exec (
    paddle_x,
    "Structurel -> paddle_x",
    game
  )
  in

  assert_equals (0, test_get res)
;;

(**
  Test structurel de `paddle_size_pixel`.

  Renvoie la taille en pixel de la raquette.

  @author Matéo Abrane
  @author Max Charrier
*)
let test_struct_paddle_size_pixel () : unit =
  let res : int t_test_result = test_exec (
    paddle_size_pixel,
    "Structurel -> paddle_size_pixel",
    game
  )
  in

  assert_equals (200, test_get res)
;;

(**
  Test fonctionnel de la spécification de `has_ball`.

  Indique si la partie en cours possèdes des balles.

  @author Paul Ourliac
*)
let test_fonc_has_ball () : unit =
  let res : bool t_test_result = test_exec (
    has_ball,
    "Fonctionnel -> has_ball",
    game
  )
  in

  assert_true (test_get res)
;;

(**
  Test fonctionnel de la spécification de `balls_count`.

  Renvoie le nombre de balle présente dans une partie.

  @author Paul Ourliac
*)
let test_fonc_balls_count () : unit =
  let res : int t_test_result = test_exec (
    balls_count,
    "Fonctionnel -> balls_count",
    game
  )
  in

  assert_equals (test_get res, 1)
;;

(**
  Test fonctionnel de la spécification de `balls_get`.

  Récupérer la liste de toutes les balles de la partie en cours.

  @author Ourliac Paul
*)
let test_fonc_balls_get () : unit =
  let res : t_ball list t_test_result = test_exec (
    balls_get,
    "Fonctionnel -> balls_get",
    game
  )
  in

  assert_equals (test_get res,
  [{
    position = ref (make_vec2 (0, 0));
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  }])
;;

(**
  Test fonctionnel de la spécification de `ball_get`.

  Récupère la i-ième balle d'une partie, i compris entre 0 et n, avec n le nombre de balles.

  @author Paul Ourliac
*)
let test_fonc_ball_get () : unit =
  let res : t_ball t_test_result = test_exec (
    ball_get,
    "Fonctionnel -> ball_get",
    (game, 0)
  )
  in

  assert_equals (test_get res,
  {
    position = ref (make_vec2 (0, 0));
    speed = ref (make_vec2 (0, 0));
    size = BS_MEDIUM
  })
;;

(**
  Test fonctionnel de la spécification de `ball_x`.

  Renvoie l'abscisse du centre d'une balle.

  @author Paul Ourliac
*)
let test_fonc_ball_x () : unit =
  let res : int t_test_result = test_exec (
    ball_x,
    "Fonctionnel -> ball_x",
    (game, {
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    })
  )
  in

  assert_equals (test_get res, 0)
;;

(**
  Test fonctionnel de la spécification de `ball_y`.

  Renvoie l'ordonnée du centre d'une balle.

  @author Paul Ourliac
*)
let test_fonc_ball_y () : unit =
  let res : int t_test_result = test_exec (
    ball_y,
    "Fonctionnel -> ball_y",
    (game, {
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    })
  )
  in

  assert_equals (test_get res, 0)
;;

(**
  Test fonctionnel de la spécification de `ball_size_pixel`.

  Indique le diamètre du cercle représentant la balle en fonction de sa taille.

  @author Paul Ourliac
*)
let test_fonc_ball_size_pixel () : unit =
  let res : int t_test_result = test_exec (
    ball_size_pixel,
    "Fonctionnel -> ball_size_pixel",
    (game, {
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    })
  )
  in

  assert_equals (test_get res, 10)
;;

(**
  Test fonctionnel de la spécification de `ball_color`.

  Donne une couleur différentes pour chaque taille de balle.

  @author Paul Ourliac
*)
let test_fonc_ball_color () : unit =
  let res : t_camlbrick_color t_test_result = test_exec (
    ball_color,
    "Fonctionnel -> ball_color",
    (game, {
      position = ref (make_vec2 (0, 0));
      speed = ref (make_vec2 (0, 0));
      size = BS_MEDIUM
    })
  )
  in

  assert_equals (test_get res, LIGHTGRAY)
;;

test_reset_report ();;

test_struct_make_paddle ();;
test_struct_paddle_x ();;
test_struct_paddle_size_pixel ();;
test_fonc_has_ball ();;
test_fonc_balls_count ();;
test_fonc_balls_get ();;
test_fonc_ball_get ();;
test_fonc_balls_get ();;
test_fonc_ball_x ();;
test_fonc_ball_y ();;
test_fonc_ball_size_pixel ();;
test_fonc_ball_color ();;
test_report ();;
