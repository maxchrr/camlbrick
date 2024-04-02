(**
  Ce module CamlBrick représente le noyau fonctionnel du jeu de casse-brique.

  Le noyau fonctionnel consiste à réaliser l'ensemble des structures et autres fonctions capables d'être utilisées par une interface graphique.
  Par conséquent, dans ce module il n'y a aucun aspect visuel.
  Vous pouvez cependant utiliser le mode console.

  Le principe du jeu de casse-brique consiste à faire disparaître toutes les briques d'un niveau en utilisant les rebonds d'une balle depuis une raquette contrôlée par l'utilisateur.

  @author Max Charrier
  @author Paul Ourliac
  @author Mateo Abrane
  @author Axel De Les Champs--Vieira

  @version 1
*)


(**
  Compteur utilisé en interne pour afficher le numéro de la frame du jeu vidéo.
  A utiliser uniquement en lecture.

  NE PAS MODIFIER SA VALEUR !

  @deprecated Ne pas modifier cette valuer !
*)
let frames = ref 0;;

(**
  Attributs globaux pour paramétrer le casse-brique

  <b>Attention:</b> Il doit y avoir des cohérences entre les différents paramètres:
  <ul>
  <li>la hauteur totale de la fenêtre est égale à la somme des hauteurs de la zone de briques du monde et de la hauteur de la zone libre.</li>
  <li>la hauteur de la zone des briques du monde est un multiple de la hauteur d'une seule brique.</li>
  <li>la largeur du monde est un multiple de la largeur d'une seule brique.</li>
  <li>initialement la largeur de la raquette doit correspondre à la taille moyenne.</li>
  <li>la hauteur initiale de la raquette doit être raisonnable et ne pas toucher un bord de la fenêtre.</li>
  <li>La variable <u>time_speed</u> doit être strictement positive, elle représente l'écoulement du temps.</li>
  </ul>
*)
type t_camlbrick_param = {
  world_width : int;          (** largeur de la zone de dessin des briques *)
  world_bricks_height : int;  (** hauteur de la zone de dessin des briques *)
  world_empty_height : int;   (** hauteur de la zone vide pour que la bille puisse évoluer un petit peu *)

  brick_width : int;          (** largeur d'une brique *)
  brick_height : int;         (** hauteur d'une brique *)

  paddle_init_width : int;    (** largeur initiale de la raquette *)
  paddle_init_height : int;   (** hauteur initiale de la raquette *)

  time_speed : int ref;       (** indique l'écoulement du temps en millisecondes (c'est une durée approximative) *)
};;

(**
  Représentation des différents états du jeu.

  Les trois états de base sont :
  <ul>
  <li>[GAMEOVER]: qui indique si une partie est finie typiquement lors du lancement du jeu</li>
  <li>[PLAYING]: qui indique qu'une partie est en cours d'exécution</li>
  <li>[PAUSING]: indique qu'une partie en cours d'exécution est actuellement en pause</li>
  </ul>

  Dans le cadre des extensions, possibilité de modifier ce type pour adopter d'autres états du jeu selon le besoin.
*)
type t_gamestate = GAMEOVER | PLAYING | PAUSING;;

(**
  Représentation des différentes couleurs prise en charge par notre moteur de jeu.

  NE PAS MODIFIER CE TYPE !

  @deprecated Ne pas modifier ce type !
*)
type t_camlbrick_color = WHITE | BLACK | GRAY | LIGHTGRAY | DARKGRAY | BLUE | RED | GREEN | YELLOW | CYAN | MAGENTA | ORANGE | LIME | PURPLE;;

(**
  Représentation des différents types de briques.

  NE PAS MODIFIER CE TYPE !

  @deprecated Ne pas modifier ce type !
*)
type t_brick_kind = BK_empty | BK_simple | BK_double | BK_block | BK_bonus;;

(**
  Retourne le type de brique pour représenter les briques de vide.
  C'est à dire, l'information qui encode l'absence de brique à un emplacement sur la grille du monde.

  @return Renvoie le type correspondant à la notion de vide.
  @deprecated Cette fonction est utilisé en interne.
*)
let make_empty_brick () : t_brick_kind =
  BK_empty
;;

(**
  Représeantion des différentes tailles des billes.
  La taille par défaut d'une bille est [BS_MEDIUM].

  Possibilité d'ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_ball_size = BS_SMALL | BS_MEDIUM | BS_BIG;;

(**
  Représenation des différentes taille de la raquette.
  La taille par défaut d'une raquette est [PS_SMALL].

  Possibilité d'ajouter d'autres valeurs sans modifier les valeurs existantes.
*)
type t_paddle_size = PS_SMALL | PS_MEDIUM | PS_BIG;;

(**
  Définition des composantes d'un vecteur.
*)
type t_vec2 = {
  x : int;
  y : int
};;

(**
  Création un vecteur 2D à partir de deux entiers.
  Les entiers représentent la composante en X et en Y du vecteur.

  @author Paul Ourliac
  @param x première composante du vecteur
  @param y seconde composante du vecteur
  @return vecteur dont les composantes sont (x,y).
*)
let make_vec2 (x, y : int * int) : t_vec2 =
  {
    x = x;
    y = y
  }
;;

(**
  Somme des composantes de deux vecteurs.

  @author Paul Ourliac
  @param a premier vecteur
  @param b second vecteur
  @return vecteur égale à la somme des vecteurs.
*)
let vec2_add (a, b : t_vec2 * t_vec2) : t_vec2 =
  {
    x = a.x + b.x;
    y = a.y + b.y
  }
;;

(**
  Somme des composantes d'un vecteur et d'un vecteur construit à partir de (x,y).

  Il s'agit d'une optimisation du code suivant :
  {[
    let vec2_add_scalar(a,x,y : t_vec2 * int * int) : t_vec2 =
      vec2_add(a, make_vec2(x,y))
    ;;
  ]}

  @author Paul Ourliac
  @param a premier vecteur
  @param x composante en x du second vecteur
  @param y composante en y du second vecteur
  @return vecteur égale à la somme du vecteur et du vecteur construit.
*)
let vec2_add_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
  {
    x = a.x + x;
    y = a.y + y
  }
;;

(**
  Multiplication des composantes de deux vecteurs.

  @author Max Charrier
  @param a premier vecteur
  @param b second vecteur
  @return vecteur égale à la multiplication des vecteurs.
*)
let vec2_mult (a, b : t_vec2 * t_vec2) : t_vec2 =
  {
    x = a.x * b.x;
    y = a.y * b.y
  }
;;

(**
  Multiplication des composantes d'un vecteur et d'un vecteur construit à partir de (x,y).

  Il s'agit d'une optimisation du code suivant :
  {[
    let vec2_mult_scalar(a,x,y : t_vec2 * int * int) : t_vec2 =
      vec2_mult(a, make_vec2(x,y))
    ;;
  ]}

  @author Max Charrier
  @param a premier vecteur
  @param x composante en x du second vecteur
  @param y composante en y du second vecteur
  @return vecteur égale à la multiplication du vecteur et du vecteur construit.
*)
let vec2_mult_scalar (a, x, y : t_vec2 * int * int) : t_vec2 =
  {
    x = a.x * x;
    y = a.y * y
  }
;;

(**
  Définition de la balle par sa posiiton, son vecteur vitesse et sa taille.

  D'un point de vue de l'affichage, une balle se représente par un cercle.
*)
type t_ball  =
  {
    position : int * int;
    speed : t_vec2;
    size : t_ball_size
  }
;;

(**
  Définition de la raquette par sa taille et sa position en mouvement sur l'axe X.
*)
type t_paddle =
  {
    position : (int ref) * int;
    size : t_paddle_size
  }
;;

(**
  Représentation du jeu de manière fonctionnel, avec tout les composants affichés à l'écran.
*)
type t_camlbrick =
  {
    param: t_camlbrick_param;
    matrix : t_brick_kind array array;
    paddle : t_paddle;
    ball : t_ball list
  }
;;

(**
  Paramètres du casse-brique via des informations personnalisables selon les contraintes du sujet.

  Aucune vérification n'est réalisé, s'assurer que les valeurs données en argument soient cohérentes.

  @return paramétrage de jeu par défaut.
*)
let make_camlbrick_param () : t_camlbrick_param = {
    world_width = 800;
    world_bricks_height = 600;
    world_empty_height = 200;

    brick_width = 40;
    brick_height = 20;

    paddle_init_width = 100;
    paddle_init_height = 20;

    time_speed = ref 20;
};;

(**
  Extraction des paramètres du casse-brique à partir de la partie du jeu.

  @param game partie en cours d'exécution
  @return paramétrage actuel.
*)
let param_get (game : t_camlbrick) : t_camlbrick_param =
  make_camlbrick_param ()
;;

(**
  Création d'une nouvelle structure qui initialise le monde avec aucune brique visible, une raquette et une balle par défaut dans la zone libre.

  @author Max Charrier
  @return partie correctement initialisé.
*)
let make_camlbrick () : t_camlbrick =
  {
    param = make_camlbrick_param ();
    matrix = Array.make_matrix 20 31 (make_empty_brick ());
    paddle =  {
      size = PS_MEDIUM;
      position = (ref 1, 1)
    };
    ball = [{
      position = (1, 1);
      speed = make_vec2 (0, 0);
      size = BS_MEDIUM
    }]
  }
;;

(**
  Création d'une raquette par défaut au milieu de l'écran et de taille normal.

  @author Paul Ourliac
  @deprecated Cette fonction est là juste pour le debug ou pour débuter certains traitements de test.
*)
let make_paddle () : t_paddle =
  {
    size = PS_MEDIUM;
    position = (ref 0 ,0)
  }
;;

(**
  Création d'un balle par défaut.

  @author Max Charrier
*)
let make_ball (x, y, size : int * int * t_ball_size) : t_ball =
  {
    position = (x, y);
    speed = make_vec2 (0, 0);
    size = size
  }
;;

(**
  Traduction de l'état du jeu sous la forme d'une chaîne de caractère.
  Cette fonction est appelée à chaque frame, et est affichée directement dans l'interface graphique.

  TODO : modifier cette fonction.

  @param game la partie en cours d'exécution.
  @return chaîne de caractère représentant l'état de la partie.
*)
let string_of_gamestate (game : t_camlbrick) : string =
  (* Itération 1,2,3 et 4 *)
  "INCONNU"
;;

(**
  Renvoie le type de la brick en fonction des coordonnées.

  @author Paul Ourliac
*)
let brick_get (game, i, j : t_camlbrick * int * int) : t_brick_kind =
  game.matrix.(i).(j)
;;

(**
  Cette fonction retrace grâce au coordonnées de i et j le type dans le tableau game et change son type en fonction de son type précedemment.

  @author Axel De Les Champs--Vieira
*)
let brick_hit (game, i, j : t_camlbrick * int * int)  : unit =
  let brick : t_brick_kind = brick_get (game, i, j) in

  if brick = BK_bonus then
    game.matrix.(i).(j) <- BK_empty
  else if brick = BK_simple then
    game.matrix.(i).(j) <- BK_empty
  else if brick = BK_double then
    game.matrix.(i).(j) <- BK_simple
  else if brick = BK_block then
    game.matrix.(i).(j) <- BK_block
  else ()
;;

(**
  Renvoie la couleur de la bricque en fonction des coordonnées.

  @author Paul Ourliac
*)
let brick_color (game, i, j : t_camlbrick * int * int) : t_camlbrick_color =
  let brick : t_brick_kind = brick_get (game, i, j) in

  if brick = BK_empty then
    BLACK
  else if brick = BK_simple then
    GREEN
  else if brick = BK_double then
    RED
  else if brick = BK_block then
    ORANGE
  else
    BLUE
;;

(**
  Renvoie la position selon l'axe horizontale de la raquette.

  @author Paul Ourliac
*)
let paddle_x (game : t_camlbrick) : int =
  !(fst game.paddle.position)
;;

(**
  Renvoie la taille en pixel de la raquette

  @author Paul Ourliac
*)
let paddle_size_pixel (game : t_camlbrick) : int =
  let param : t_camlbrick_param = param_get game in

  if game.paddle.size = PS_SMALL then
    param.paddle_init_width
  else if game.paddle.size = PS_MEDIUM then
    param.paddle_init_width * 2
  else
    param.paddle_init_width * 4
;;

(**
  Déplace la raquette vers la gauche.

  @author Paul Ourliac
*)
let paddle_move_left (game : t_camlbrick) : unit =
  if paddle_x (game) < 0 then
    fst game.paddle.position := !(fst game.paddle.position) - 1
  else
    ()
;;

(**
  Déplace la raquette vers la droite.

  @author Paul Ourliac
*)
let paddle_move_right (game : t_camlbrick) : unit =
  let l_param : t_camlbrick_param = param_get game in

  if
    (paddle_x game * l_param.paddle_init_width) + l_param.paddle_init_width < l_param.world_width
  then
    fst game.paddle.position := !(fst game.paddle.position) + 1
  else
    ()
;;

(**
  Indique si la partie en cours possèdes des balles.

  @author Axel De Les Champs--Vieira
*)
let has_ball (game : t_camlbrick) : bool =
  game.ball = []
;;

(**
  Renvoie le nombre de balle présente dans une partie.

  @author Axel De Les Champs--Vieira
*)
let balls_count (game : t_camlbrick) : int =
  if game.ball = [] then
    0
  else
    List.length game.ball
;;

(**
  Récupérer la liste de toutes les balles de la partie en cours.

  @author Axel De Les Champs--Vieira
*)
let balls_get (game : t_camlbrick) : t_ball list =
  game.ball
;;

(**
  Récupère la i-ième balle d'une partie, i compris entre 0 et n, avec n le nombre de balles.

  @author Axel De Les Champs--Vieira
*)
let ball_get (game, i : t_camlbrick * int) : t_ball =
  (*
    Il s'agit d'une optimisation du code suivant :
    {[
      let eol : t_ball list ref = ref game.ball in
      let incr : int ref = ref 0 in

      while !incr != i do
        eol := List.tl !eol;
        incr := !incr + 1
      done;

      List.hd !eol
    ]}
  *)

  List.nth game.ball i
;;

(**
  Renvoie l'abscisse du centre d'une balle.

  @author Axel De Les Champs--Vieira
*)
let ball_x (game, ball : t_camlbrick * t_ball) : int =
  fst ball.position
;;

(**
  Renvoie l'ordonnée du centre d'une balle.

  @author Axel De Les Champs--Vieira
*)
let ball_y (game, ball : t_camlbrick * t_ball) : int =
  snd ball.position
;;

(**
  Indique le diamètre du cercle représentant la balle en fonction de sa taille.

  @author Axel De Les Champs--Vieira
*)
let ball_size_pixel (game, ball : t_camlbrick * t_ball) : int =
  if ball.size = BS_SMALL then
    10
  else if ball.size = BS_MEDIUM then
    20
  else
    30
;;

(**
  Donne une couleur différentes pour chaque taille de balle.

  @author Axel De Les Champs--Vieira
*)
let ball_color (game, ball : t_camlbrick * t_ball) : t_camlbrick_color =
  if ball.size = BS_SMALL then
    LIME
  else if ball.size = BS_MEDIUM then
    LIGHTGRAY
  else
    GRAY
;;

(**
    Modifie la vitesse d'une balle par accumulation avec un vecteur.

    On peut alors augmenter ou diminuer la vitesse de la balle.

    TODO : coder la fonction

    @author ...
*)
let ball_modif_speed (game, ball, dv : t_camlbrick * t_ball * t_vec2) : unit =
  ()
;;

(**
    Modifie la vitesse d'une balle par multiplication avec un vecteur.

    On peut alors augmenter ou diminuer la vitesse de la balle.

    TODO : coder la fonction

    @author ...
*)
let ball_modif_speed_sign (game, ball, sv : t_camlbrick * t_ball * t_vec2) : unit =
  ()
;;

(**
  Détecte si un point (x,y) se trouve à l'intérieur d'un disque de centre (cx,cy) et de raydon rad.

  TODO : coder la fonction

  @author ...
*)
let is_inside_circle (cx, cy, rad, x, y : int * int * int * int * int) : bool =
  (* Itération 3 *)
  false
;;

(**
  Détecte si un point (x,y) se trouve à l'intérieur d'un rectangle formé.

  TODO : coder la fonction

  @author ...
*)
let is_inside_quad (x1, y1, x2, y2, x, y : int * int * int * int * int * int) : bool =
  (* Itération 3 *)
  false
;;

let ball_remove_out_of_border (game, balls : t_camlbrick * t_ball list ) : t_ball list =
  (* Itération 3 *)
  balls
;;

let ball_hit_paddle (game, ball, paddle : t_camlbrick * t_ball * t_paddle) : unit =
  (* Itération 3 *)
  ()
;;

(* lire l'énoncé choix à faire *)
let ball_hit_corner_brick (game, ball, i, j : t_camlbrick * t_ball * int * int) : bool =
  (* Itération 3 *)
  false
;;

(* lire l'énoncé choix à faire *)
let ball_hit_side_brick (game, ball, i, j : t_camlbrick * t_ball * int * int) : bool =
  (* Itération 3 *)
  false
;;

let game_test_hit_balls (game, balls : t_camlbrick * t_ball list) : unit =
  (* Itération 3 *)
  ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position de la souris dans la fenêtre lorsqu'elle se déplace.
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris
*)
let canvas_mouse_move (game, x, y : t_camlbrick * int * int) : unit =
  ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est enfoncé.
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
  @param button numero du bouton de la souris enfoncé
  @param x l'abscisse de la position de la souris
  @param y l'ordonnée de la position de la souris
*)
let canvas_mouse_click_press (game, button, x, y : t_camlbrick * int * int * int) : unit =
  ()
;;

(**
  Appelée par l'interface graphique avec le jeu en argument et la position
  de la souris dans la fenêtre lorsqu'un bouton est relaché.
  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
  @param button numero du bouton de la souris relaché
  @param x l'abscisse de la position du relachement
  @param y l'ordonnée de la position du relachement
*)
let canvas_mouse_click_release (game, button, x, y : t_camlbrick * int * int * int) : unit =
  ()
;;

(**
  Appelée par l'interface graphique lorsqu'une touche du clavier est appuyée.
  Les arguments sont le jeu en cours, la touche enfoncé sous la forme d'une chaine et sous forme d'un code spécifique à labltk.

  Le code fourni initialement permet juste d'afficher les touches appuyées au clavier afin de pouvoir les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
  @param keyString nom de la touche appuyée
  @param keyCode code entier de la touche appuyée
*)
let canvas_keypressed (game, key_string, key_code : t_camlbrick * string * int) : unit =
  (*
  print_string "Key pressed: ";
  print_string key_string;
  print_string " code=";
  print_int key_code;
  print_newline ()
  *)
  (*
  Key pressed: z code=122
  Key released: z code=122
  Key pressed: q code=113
  Key released: q code=113
  Key pressed: s code=115
  Key released: s code=115
  Key pressed: d code=100
  Key released: d code=100
  Key pressed: Up code=65362
  Key released: Up code=65362
  Key pressed: Left code=65361
  Key released: Left code=65361
  Key pressed: Down code=65364
  Key released: Down code=65364
  Key pressed: Right code=65363
  Key released: Right code=65363
  *)
  let left_key_code : int = 65361 in
  let q_key_code : int = 113 in
  let right_key_code : int = 65363 in
  let d_right_code : int = 100 in

  if key_code = left_key_code || key_code = q_key_code then
    paddle_move_left game
  else if key_code = right_key_code || key_code = d_right_code then
    paddle_move_right game
  else
    ()
;;

(**
  Appelée par l'interface graphique lorsqu'une touche du clavier est relachée.
  Les arguments sont le jeu en cours, la touche relachée sous la forme d'une chaine et sous forme d'un code spécifique à labltk.

  Le code fourni initialement permet juste d'afficher les touches appuyées au clavier afin de pouvoir les identifiées facilement dans nos traitements.

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
  @param keyString nom de la touche relachée
  @param keyCode code entier de la touche relachée
*)
let canvas_keyreleased (game, key_string, key_code : t_camlbrick * string * int) =
  print_string "Key released: ";
  print_string key_string;
  print_string " code=";
  print_int key_code;
  print_newline ()
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre l'information à afficher dans la zone Custom1 de la zone du menu.
*)
let custom1_text () : string =
  (* Iteration 4 *)
  "<Rien1>"
;;

(**
  Cette fonction est utilisée par l'interface graphique pour connaitre l'information à afficher dans la zone Custom2 de la zone du menu.
*)
let custom2_text () : string =
  (* Iteration 4 *)
  "<Rien2>"
;;

(**
  Cette fonction est appelée par l'interface graphique lorsqu'on clique sur le bouton de la zone de menu et que ce bouton affiche "Start".


  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
*)
let start_onclick (game : t_camlbrick) : unit=
  ()
;;

(**
  Appelée par l'interface graphique lorsqu'on clique sur le bouton
  de la zone de menu et que ce bouton affiche "Stop".

  Vous pouvez réaliser des traitements spécifiques, mais comprenez bien que cela aura un impact sur les performances si vous dosez mal les temps de calcul.

  @param game la partie en cours
*)
let stop_onclick(game : t_camlbrick) : unit =
  ()
;;

(**
  Appelée par l'interface graphique pour connaitre la valeur
  du slider Speed dans la zone du menu.

  Vous pouvez donc renvoyer une valeur selon votre désir afin d'offrir la possibilité d'interagir avec le joueur.
*)
let speed_get (game : t_camlbrick) : int =
  0
;;

(**
  Appelée par l'interface graphique pour indiquer que le slide Speed dans la zone de menu a été modifiée.

  Ainsi, vous pourrez réagir selon le joueur.
*)
let speed_change (game,xspeed : t_camlbrick * int) : unit=
  print_endline ("Change speed : " ^ string_of_int xspeed);
;;

let animate_action (game : t_camlbrick) : unit =
  (* Iteration 1,2,3 et 4
    Appelée par l'interface graphique à chaque frame
    du jeu vidéo.
    Vous devez mettre tout le code qui permet de montrer l'évolution du jeu vidéo.
  *)
  ()
;;
