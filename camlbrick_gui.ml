(* #directory "+labltk";;
#load "labltk.cma";;

#mod_use "camlbrick.ml";; *)

(* https://who.rocq.inria.fr/Francois.Thomasset/Labltk/Tutoriel_FT/ *)


open Tk
open Printf

open Camlbrick

type t_camlbrick_gui = {
  top : Widget.toplevel Widget.widget;
  sc_speed : Widget.scale Widget.widget;
  canvas : Widget.canvas Widget.widget;
  paddle_gui : tagOrId;
  mutable paddle_prevx : int;
  mutable balls_gui : tagOrId list ;
  world_gui : tagOrId array array;
  world_prev : t_brick_kind array array;
  mutable tktimer : Timer.t option;

  lv_gamestate : Textvariable.textVariable;

  (* l_custom1 : Widget.label Widget.widget;
  l_custom2 : Widget.label Widget.widget; *)

  lb_custom1 : Textvariable.textVariable;
  lb_custom2 : Textvariable.textVariable;
}

let cbg_convert_color(color) = 
  match color with
  | WHITE -> `White
  | BLACK -> `Black
  | BLUE -> `Blue
  | RED -> `Red
  | GREEN -> `Green
  | YELLOW -> `Yellow
  | CYAN -> `Color("#00ffff")
  | MAGENTA -> `Color("#ff00ff")
  | ORANGE -> `Color("#ff9100")
  | LIME -> `Color("#b3ff00")
  | PURPLE -> `Color("#dd00ff")
  | GRAY -> `Color("#808080")
  | LIGHTGRAY -> `Color("#b5b5b5")
  | DARKGRAY -> `Color("#616161")
;;


let cbg_brick_update(param, game, cbgui, i, j) =
  let brick = brick_get(game, i,j) in
  let brick_gui = cbgui.world_gui.(i).(j) in
  let brick_prev = cbgui.world_prev.(i).(j) in
  if brick != brick_prev then
    begin
      (Canvas.delete (cbgui.canvas) [brick_gui]);
      let color = brick_color(game, i,j) in
      let tkcolor = cbg_convert_color(color) in
      let c_BRICK_WIDTH = param.brick_width
      and c_BRICK_HEIGHT= param.brick_height
      in
      (* and outline = if brick = make_empty_brick() then  else `Yellow *)
      let x1 = (i*c_BRICK_WIDTH) and x2 = ((i+1) * c_BRICK_WIDTH) - 1
      and y1 = (j*c_BRICK_HEIGHT) and y2 = ((j+1) * c_BRICK_HEIGHT) - 1
      in
      if brick = make_empty_brick() then
        cbgui.world_gui.(i).(j) <- (Canvas.create_rectangle ~outline:(`Color("#313131")) ~x1:x1 ~y1:y1 ~x2:x2 ~y2:y2 cbgui.canvas)
      else
        cbgui.world_gui.(i).(j) <- (Canvas.create_rectangle ~fill:(tkcolor) ~outline:`Yellow ~x1:x1 ~y1:y1 ~x2:x2 ~y2:y2 cbgui.canvas)
      ;
      cbgui.world_prev.(i).(j) <- brick
    end
  else
    ()
;;

let cbg_delete_others(cbgui, l) =
  (Canvas.delete (cbgui.canvas) l)
;;

let rec cbg_create_ball_gui(param,game,cbgui,bl) =
  match bl with
  | [] -> []
  | ball::sl -> 
    let size = ball_size_pixel(game,ball) in
    let x = ball_x(game,ball) and y = ball_y(game,ball) in
    let x1 = x - (size) and y1 = y - (size)
    and x2 = x + (size) and y2 = y + (size)
    and cfill = (cbg_convert_color(ball_color(game,ball)))
    in
    (* let id = Canvas.create_rectangle ~x1:x1 ~y1:y1 ~x2:x2 ~y2:y2 ~fill:cfill ~outline:`White cbgui.canvas in *)
    let id = Canvas.create_oval ~x1:x1 ~y1:y1 ~x2:x2 ~y2:y2 ~fill:cfill ~outline:`White cbgui.canvas in
    id::(cbg_create_ball_gui(param,game,cbgui,sl))
;;

let rec cbg_ball_update(param,game, cbgui, balls, balls_gui : t_camlbrick_param * t_camlbrick * t_camlbrick_gui * t_ball list * tagOrId list) =
  match (balls,balls_gui) with
  | ([],[]) -> []
  | ([],l) -> cbg_delete_others(cbgui,l);[]
  | (bl, []) -> cbg_create_ball_gui(param,game,cbgui,bl)
  | (a::al, b::bl) -> 
    let size = ball_size_pixel(game, a) in
    let x = ball_x(game, a) and y = ball_y(game, a) in
    let x1 = x - (size) and y1 = y - (size)
    and x2 = x + (size) and y2 = y + (size)
    and cfill = (cbg_convert_color(ball_color(game,a)))
    in
    (Canvas.coords_set (cbgui.canvas) b ~xys:[ (x1,y1) ; (x2,y2) ]);
    (Canvas.configure_oval ~fill:cfill (cbgui.canvas) b);
    b::(cbg_ball_update(param,game,cbgui,al,bl))
  ;;


    (* let id = (Canvas.create_oval ~fill:cfill ~outline:`White x1 y1 x2 y2 canvas) in *)




let rec cbg_animate_action param game cbgui () = 
  Scale.set (cbgui.sc_speed) (float_of_int (speed_get(game)));
  let state = (string_of_gamestate(game)) in
  Textvariable.set (cbgui.lv_gamestate) state;
  let text1 = custom1_text() in 
  Textvariable.set (cbgui.lb_custom1) text1;
  let text2 = custom2_text() in
  Textvariable.set (cbgui.lb_custom2) text2;
  (* on dessine les briques *)
  for i=0 to Array.length(cbgui.world_gui) - 1
  do
    for j=0 to Array.length(cbgui.world_gui.(i)) - 1
    do
      cbg_brick_update(param,game,cbgui,i,j)
    done
  done;
  (* on dessine la raquette *)
  let paddle_dx = paddle_x(game) - cbgui.paddle_prevx in
  (Canvas.move (cbgui.canvas) (cbgui.paddle_gui) ~x:(paddle_dx) ~y:0);
  cbgui.paddle_prevx <- paddle_x(game);
  (* on dessine les balles *)
  let balls : t_ball list = balls_get(game) in 
  cbgui.balls_gui <- cbg_ball_update(param,game,cbgui, balls ,cbgui.balls_gui );
  (* on prepare la prochaine frame et on anime le jeu *);
  (* Printf.printf "Rearmement timer: %d\n%!" (param.time_speed.contents); *)
  cbgui.tktimer <- Some(Timer.add ~ms:(param.time_speed.contents) ~callback:(cbg_animate_action param game cbgui));
  animate_action(game) 
;;

let cbg_canvas_key_press game (event_info : Tk.eventInfo) =
  (* print_string ("Key: "^(event_info.ev_KeySymString)^" : ");
  print_endline("KeyCode: "^(string_of_int (event_info.ev_KeySymInt))); *)
  canvas_keypressed(game, (event_info.ev_KeySymString),(event_info.ev_KeySymInt))
;;

let cbg_canvas_key_release game (event_info : Tk.eventInfo) =
  (* print_string ("Key: "^(event_info.ev_KeySymString)^" : ");
  print_endline("KeyCode: "^(string_of_int (event_info.ev_KeySymInt))); *)
  canvas_keyreleased(game, (event_info.ev_KeySymString),(event_info.ev_KeySymInt))
;;


let cbg_canvas_mouse_move game (event_info : Tk.eventInfo) =
  (* Printf.printf "Mouse(%d ; %d)\n%!" (event_info.ev_MouseX) (event_info.ev_MouseY); *)
  canvas_mouse_move(game, (event_info.ev_MouseX),(event_info.ev_MouseY));
;;

let cbg_canvas_mouse_click_press game (event_info : Tk.eventInfo) =
  (* Printf.printf "Mouse click press button=%d ; X:%d Y:%d Type:%d \n%!" (event_info.ev_ButtonNumber) (event_info.ev_MouseX) (event_info.ev_MouseY) (event_info.ev_Type); *)
  canvas_mouse_click_press(game, (event_info.ev_ButtonNumber),(event_info.ev_MouseX),(event_info.ev_MouseY))
;;

let cbg_canvas_mouse_click_release game (event_info : Tk.eventInfo) =
  (* Printf.printf "Mouse click release button=%d ; X:%d Y:%d Type:%d \n%!" (event_info.ev_ButtonNumber) (event_info.ev_MouseX) (event_info.ev_MouseY) (event_info.ev_Type); *)
  canvas_mouse_click_release(game, (event_info.ev_ButtonNumber),(event_info.ev_MouseX),(event_info.ev_MouseY))
;;


let make_camlbrick_gui(param,game : t_camlbrick_param *t_camlbrick) :  t_camlbrick_gui = 
  let top = openTk () in
  Wm.title_set top "L1 CompProg - Camlbricks";

  let c_WIN_WIDTH = param.world_width 
  and c_WIN_BRICKS_HEIGHT = param.world_bricks_height
  and c_WIN_EMPTY_HEIGHT= param.world_empty_height
  and c_WIN_HEIGHT =  param.world_bricks_height + param.world_empty_height
  and c_BRICK_WIDTH = param.brick_width
  and c_BRICK_HEIGHT= param.brick_height
  and c_PAD_INIT_WIDTH = param.paddle_init_width
  and c_PAD_INIT_HEIGHT = param.paddle_init_height in
  let c_PAD_X1 = (c_WIN_WIDTH - c_PAD_INIT_WIDTH) / 2 
  and c_PAD_X2 = (c_WIN_WIDTH + c_PAD_INIT_WIDTH) / 2 
  and c_PAD_Y1 = (c_WIN_HEIGHT - c_PAD_INIT_HEIGHT - 10)
  and c_PAD_Y2 = (c_WIN_HEIGHT - 10)
  and dx = c_WIN_WIDTH / c_BRICK_WIDTH
  and dy = c_WIN_BRICKS_HEIGHT / c_BRICK_HEIGHT
  in

  let f_game = Frame.create ~relief:`Raised ~borderwidth:2 top in
  let canvas = Canvas.create ~takefocus:true ~width:c_WIN_WIDTH ~height:(c_WIN_BRICKS_HEIGHT + c_WIN_EMPTY_HEIGHT) ~background:`Black f_game in
  let paddle_gui = (Canvas.create_rectangle ~fill:`Red ~outline:`Green ~x1:c_PAD_X1 ~y1:c_PAD_Y1 ~x2:c_PAD_X2 ~y2:c_PAD_Y2
 canvas) in
  let world_gui = Array.make_matrix dx dy (`Id(-1)) in
  let world_prev = Array.make_matrix dx dy (make_empty_brick()) in

  let f_menu = Frame.create top in
  let lbl_gamestate= Label.create ~text:"Gamestate:" f_menu in
  let lv_gamestate = Textvariable.create ()  in
  let tv_custom1 = Textvariable.create() in
  let tv_custom2 = Textvariable.create() in
  let lb_custom1 = Label.create ~textvariable:tv_custom1 f_menu in
  let lb_custom2 = Label.create ~textvariable:tv_custom2 f_menu in
  let l_custom1 = Label.create ~text:"Custom1:" f_menu in
  let l_custom2 = Label.create ~text:"Custom2:" f_menu in
  
  let bv_startstop = Textvariable.create () in
  let lb_gamestate = Label.create ~textvariable:lv_gamestate f_menu  in
  let b_hof = Button.create ~text:"Highscores"  f_menu in
  let b_startstop = Button.create ~textvariable:bv_startstop  f_menu in
  let f_option = Frame.create ~relief:`Groove ~borderwidth:2 f_menu in
  let l_option = Label.create ~text:"Options:" f_option in
  (* let mylist = Listbox.create ~selectmode:`Single f_option in  *)
  let sc_speed = Scale.create ~min:5. ~max:100. ~resolution:5. ~tickinterval:50. ~label:"Speed:" ~orient:`Horizontal f_option in
  Scale.set sc_speed (float_of_int (speed_get(game)));
  Textvariable.set lv_gamestate "Game Over";
  Textvariable.set bv_startstop "Start";
  
  pack  [coe l_option];
  pack ~fill:`X [ coe sc_speed];
  pack [coe canvas] ;
  pack [coe f_option; coe b_startstop; coe lbl_gamestate; coe lb_gamestate; coe l_custom1;coe lb_custom1; coe l_custom2; coe lb_custom2] ~side:`Top;
  pack [coe f_game; coe f_menu] ~side:`Left;

  let cbg_b_startstop_onclick game () : unit=
    if (Textvariable.get bv_startstop) = "Start"
    then ( (Textvariable.set bv_startstop "Stop"); start_onclick(game))
    else ( (Textvariable.set bv_startstop "Start"); stop_onclick(game))
  in
  let cbg_b_hof_onclick game () = 
    ()
  in
  let cbg_speed_change game (xspeed) = 
    speed_change(game, (int_of_float xspeed))
  in 
  Button.configure ~command:(cbg_b_hof_onclick game) b_hof;
  Button.configure ~command:(cbg_b_startstop_onclick game) b_startstop;
  Scale.configure ~command:(cbg_speed_change game) sc_speed;
  bind ~action:(cbg_canvas_key_press game) ~fields:[`KeySymString ; `KeySymInt] ~events:[`KeyPress] top;
  bind ~action:(cbg_canvas_key_release game) ~fields:[`KeySymString ; `KeySymInt] ~events:[`KeyRelease] top;
  bind ~action:(cbg_canvas_mouse_move game) ~fields:[`MouseX; `MouseY] ~events:[`Motion] canvas;
  bind ~action:(cbg_canvas_mouse_click_press game) ~fields:[`ButtonNumber ; `MouseX; `MouseY; `Type ] ~events:[ `ButtonPress] canvas;
  bind ~action:(cbg_canvas_mouse_click_release game) ~fields:[`ButtonNumber ; `MouseX; `MouseY; `Type ] ~events:[`ButtonRelease ] canvas;
  {
    top = top;
    canvas = canvas;
    sc_speed = sc_speed;
    paddle_gui = paddle_gui;
    paddle_prevx = paddle_x(game);
    balls_gui = [];
    world_gui = world_gui;
    world_prev = world_prev;
    tktimer = None;

    lv_gamestate = lv_gamestate;

    (* l_custom1 = l_custom1;
    l_custom2 = l_custom2; *)
    lb_custom1 = tv_custom1;
    lb_custom2 = tv_custom2;
  }
;;


let launch_camlbrick(param, game) =
  let cbgui = make_camlbrick_gui(param,game) in
  cbgui.tktimer <- Some(Timer.add ~ms:(param.time_speed.contents) ~callback:(cbg_animate_action param game cbgui));
  Printexc.print mainLoop ()
;;

(* let _ = Printexc.print mainLoop ();; *)


