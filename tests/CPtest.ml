(**
  Ce fichier decrit l'ensemble des fonctions pour pouvoir réaliser des tests logiciels simplement sous OCaml
  dans le cadre du module Complément de Programmation du L1 Informatique de l'Université de Poitiers.

  La documentation peut-être générée avec la commande:
  <code>
  ocamldoc -d doc -html -charset utf8 CPtest.ml
  </code>
  
  @author Hakim Ferrier-Belhaouari.
*)

open Printf;;


(** 
  Ce type definit les differents etats d'un test dans notre bibliotheque de test.    
*)
type t_test_callresult = 
    Test_exec_success (** Indique si le test est execute avec succes *)
  | Test_exec_failure of string (** Indique si le test a produit un <b>failwith</b> *)
  | Test_exec_error of exn (** Indique si le test a produit une erreur inattendue  *)
  | Test_fail_success of string (** Indique si le test a provoque un <b>failwith</b> attendu *)
  | Test_fail_failure (** Indique que le test n'a pas leve de <b>failwith</b>*)
  | Test_fail_error of exn (** Indique que le test a provoque une erreur inattendue *)
  | Test_assert_violation of string (** Indique une violation d'une assertion *)
;;

(**
  Ce type definit le resultat d'un test. Ainsi, on enregistre l'etat du test et la valeur calculee durant 
  l'appel si cette derniere existe.
*)
type 'a t_test_result = 'a option * t_test_callresult ;;

(**
  Ce type represente un cas de test. Il est utilise en interne dans la bibliotheque.    
*)
type t_test_step = 
  {
  fname : string; (** Indique le nom du test *)
  mutable cassert : int; (** memorise le nombre d'assertion execute pour le test *)
  mutable cassert_ignored : int; (** memorise le nombre d'assertion qui a ete inhibe suite a une erreur quelconque *)
  mutable error : t_test_callresult option (** enregistre l'etat du test en cours *)
  }
;;


(** Type interne pour enregistrer toute une campagne de test. Ainsi ce type contiendra l'ensemble des tests qui
    ont ete executes ainsi que leur etat. *)
type t_test_status =
  {
    mutable seq :  t_test_step list;
  }
;;

(** 
  Cette fonction permet d'initialiser une campagne de test. Elle est utilisee en interne dans notre bibliotheque.
  @return Renvoie une nouvelle campagne de test avec aucun test execute.
    *)
let create_test_status() : t_test_status =
  {
  seq = []
  }
;;

(** Variable globale contenant la campagne de test par defaut. Cette variable est utilisee en interne 
    dans notre bibliotheque *)
let global_test_status = create_test_status();;


(**
  Demarre un cas de test pour la campagne donnee en argument. Cette fonction est utilisee en interne.

  @param status campagne de test
  @param name nom du cas de test
  @return cree un cas de test dans notre bibliotheque
    *)
let test_start(status, name : t_test_status * string) : t_test_step =
  let step = { 
    fname = name; 
    cassert = 0; 
    cassert_ignored = 0; 
    error = None 
  } 
  in
    (
    status.seq <- step::(status.seq);
    step
    )
;;

(** Demarre un nouveau cas de test dans la campagne globale. Cette fonction peut etre utilise dans la fenetre
    d'interaction.
    @param name nom du cas de test
    @return cree un cas de test 
    @deprecated utilisation en interne 
    *)
let test_new(name : string) : t_test_step = 
  test_start(global_test_status,name)
;;


(**
  Cette fonction permet de nettoyer le rapport de test, afin d'obtenir un nouveau rapport.
  Cela "oubli" tous les tests qui ont été effectué précédemment.
*)
let test_reset_report() : unit = 
  global_test_status.seq <- []
;;

(**
  Cette fonction permet d'ajouter une espace dans le rapport de test. Cela vous permet de découper 
  votre rapport en section afin de lire plus facilement les informations présentes.
*)
let test_report_space() = 
  ignore(test_start(global_test_status,"-"))
;;


(** 
  Cette fonction affiche l'etat de la campagne de test par defaut. Le rapport de test affiche l'etat des tests 
  executes en donnant des statistiques sur le nombre d'assertions executees ou ignorees. Si un message d'erreur
  existait, il sera aussi affiche. Attention, l'affichage peut etre long donc n'hesitez a faire un retour a vos enseignants
    *)
let test_report() : unit =
  let rec calc_size_fname(l) =
    match l with 
    | [] -> 5
    | step::sl -> (max (String.length(step.fname)) (calc_size_fname sl))
  in
  let size = calc_size_fname(global_test_status.seq) in
  print_endline("Rapport de test: ");
  let rec print_line_report(l) = 
    match l with
    | [] -> ()
    | step::sl -> 
      begin
        print_line_report(sl);
        let err : t_test_callresult option = (step.error) in
        let (str,serr) = 
          (
          match err with
            None -> "OK",""
            | Some(e) -> 
              (
              match e with
                Test_exec_success -> "OK",""
                | Test_exec_failure(serr) -> ">KO",Printf.sprintf "failwith = '%s'" serr
                | Test_exec_error(ex) -> ">KO",Printf.sprintf "error = '%s'" (Printexc.to_string ex)
                | Test_fail_success(serr) -> "OK",""
                | Test_fail_failure -> ">KO","no failwith detected !"
                | Test_fail_error(ex) -> ">KO", Printf.sprintf "error = '%s'" (Printexc.to_string ex)
                | Test_assert_violation(serr) -> ">KO",Printf.sprintf "assert violation on '%s'" serr
              )
          ) 
        in
        if step.fname = "-" then
          (Printf.printf " ----- \n")
        else
          (Printf.printf "  %3s - %-*s :\t(stats: executed = %3d; ignored = %3d) - %s\n" 
            str size step.fname  (step.cassert) (step.cassert_ignored) serr)
      end
    in
    print_line_report(global_test_status.seq)
;;



(**
  Cet assesseur permet d'extraire la valeur d'un resultat de test si cette valeur existe. Attention, si votre test
  n'a pas de valeur (en raison d'une erreur ou d'un failwith) alors un failwith est leve.
  @param result represente le resultat d'un test.
  @return renvoie le resultat de la fonction sous test.
    *)
let test_get(result : 'a t_test_result) : 'a =
  let (r,t) = result in
  match r with
  | None -> failwith("Aucune valeur dans le resultat")
  | Some(x) -> x
;;

(**
  Ce predicat indique si un resultat de test donne en argument contient une valeur exploitable. Cette fonction
  devrait etre appelee avant de faire un {!val:test_get} pour eviter des erreurs.
*)
let test_has_value(result : 'a t_test_result) : bool = 
  let (r,t) = result in 
  r <> None
;;

(**
    Ce predicat indique si le resultat d'un test est un succes ou non. La notion de success est dependant
    du type de test. Si vous utilisez {!val:test_exec} alors le success consiste au fait que votre fonction 
    sous test n'a pas leve d'erreur et si vous utilisez {!val:test_fail_exec} alors un success correspond a 
    avoir un {b failwith}.
    @param result variable resultant d'un cas de test.
    @return True si le test est un succes et False sinon.
*)
let test_is_success(result) =
  let (r,t) = result in
  match t with
  | Test_exec_success -> true  
  | Test_fail_success(_) -> true
  | _ -> false
;;

(**
  Utilisation interne de cette fonction
  @deprecated Utilisation interne
    *)
let is_current_test_valid(step) =
  match step.error with
  | None -> true
  | Some(Test_exec_success) -> true
  | Some(Test_fail_success(_)) -> true
  | _ -> false
;;

(**
  Cette fonction permet d'executer une fonction sous test (FST). Son execution suit la philosophie de test a savoir 
  que l'execution de la FST est dans un environnement controle afin de ne pas arreter l'execution de votre programme
  en cas d'erreur quelconque. Concretement, la fonction cree un nouveau de cas de test dans la campagne de test
  globale et realise l'appel de la fonction <code>fct</code> sur l'argument <code>arg</code> et construit un resultat
  de ce test. L'exemple suivant montre une utilisation de la fonction [test_exec] et l'adéquation du type retour de la fonction a tester
  et du retour de la fonction de test:
{[
let foo(a,b : int * int) : float = ... ;;

let res : float t_test_result = test_exec(foo,"test",(10,3));;
  ]}
  @param fct represente la fonction sous test 
  @param title indique le titre et la descritpion du test realise
  @param arg represente l'argument de la fonction sous la forme d'un tuple.
  @return Renvoie un resultat de test qui est manipulable avec les fonctions de notre bibliotheque.
    *)
let test_exec(fct, title, arg : ('a -> 'b) * string * 'a) : 'b t_test_result =
  let step = test_start(global_test_status, title) in
  try 
    (
      let res = (fct arg) in
        step.error <- Some(Test_exec_success);
        (* step.cassert <- step.cassert + 1; *)
      (Some(res), Test_exec_success)
    )
  with
    Failure(msg) -> (let r = Test_exec_failure(msg) in (step.error <- Some(r); (None, r)))
    | e -> (let r = Test_exec_error(e) in (step.error <- Some(r); (None, r))) 
;;


(**
  Cette fonction execute une fonction sous test (FST) pour determiner si un failwith est bien leve quelquepart 
  dans la FST. Plus précisément, la fonction cree un nouveau cas de test dans la campagne de test globale
  et realise l'appel de la fonction <code>fct</code> sur l'argument <code>arg</code> pour verifier si cet appel
  aboutit a un <b>failwith</b>.
  Le code suivant montre la déclaration d'une fonction qui lève un [failwith] et qui récupère l'information 
  sans stopper la fonction de test:
  {[
let foofail() : int = 
  failwith("volontaire")
;;
let res : int t_test_result = test_fail_exec(foofail,"test erreur", ());;
  ]}
  @param fct represente la fonction sous test.
  @param title indique le titre et la description du test realise.
  @param arg represente l'argument de la fonction sous la forme d'un tuple.
  @return Renvoie un resultat de test qui est manipulable avec les fonctions de notre bibliotheque.
*)
let test_fail_exec(fct, title, arg : ('a -> 'b) * string * 'a) : 'b t_test_result =
  let step = test_start(global_test_status, title) in
  try (
    let res = (fct arg) in
    (Some(res), Test_fail_failure)
  )
  with
    Failure(msg) -> (let r = Test_fail_success(msg) in  (None, r)) 
  | e -> (let r = Test_fail_error(e) in (step.error <- Some(r);  (None, r)))
;;

(**
Cette assertion vérifie qu'un résultat d'un test s'est terminé sur un [failwith]. L'argument doit être
le résultat d'un driver de test et vérifie si le test s'est terminé sur un [failwith]. 
{b ATTENTION: } une exception peut être levée que cela soit prévu ou non prévu. Il est donc important
que vous compreniez si c'était bien le comportement souhaité ou non.
@param res résultat d'un test    
*)
let assert_failwith(res : 'a t_test_result) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    begin 
      step.cassert <- step.cassert + 1;
      let (r,t) = res in
      match t with
      | Test_fail_success(_) -> ()
      | _ -> step.error <- Some(Test_assert_violation(""))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
Cette assertion vérifie qu'un résultat d'un test s'est terminé sur un [failwith]. 
Le premier argument est le message attendu levé par le [failwith], ainsi vous pouvez vérifier que c'est la bonne erreur qui a été remontée.
Le second argument doit être
le résultat d'un driver de test et vérifie si le test s'est terminé sur un [failwith]. 
{b ATTENTION: } une exception peut être levée que cela soit prévu ou non prévu. Il est donc important
que vous compreniez si c'était bien le comportement souhaité ou non.
@param text texte utilisé au moment de l'appel du failwith.
@param res résultat d'un test    
*)
let assert_failwith_text(text, res : string * 'a t_test_result) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    begin 
      step.cassert <- step.cassert + 1;
      let (r,t) = res in
      match t with
      | Test_fail_success(m) -> (
        if m = text then
          ()
        else
          step.error <- Some(Test_assert_violation(text^" <> "^m))
      )
      | _ -> step.error <- Some(Test_assert_violation(text))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;


(**
Cette fonction enregistre si le booléen donné en argument s'évalue à [true]. 
   *)
let assert_true( b  : bool ) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      step.cassert <- step.cassert + 1;
      if b
      then ()
      else step.error <- Some(Test_assert_violation(""))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
Cette fonction est la version qui offre un message personnalisé dans le rapport de test si le booléen n'est pas évalué à [true]
@param msg message qui apparaitra dans le rapport si erreur
@param b booléen qui doit s'évalué à [true]
*)
let assert_true_m(msg, b  : string * bool ) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      step.cassert <- step.cassert + 1;
      if b
      then ()
      else step.error <- Some(Test_assert_violation(msg))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;


(**
  Cette fonction permet d'extraire le résultat booléen d'un résultat de test et de vérifier si ce dernier est évalué à [true].
  {[
    let foo() : bool = true ;;
    let res : bool t_test_result = test_exec(foo,"foo()",()) in
      assert_true_result(res)
    ;;
    test_report();;
  ]}
*)
let assert_true_result(r : bool t_test_result) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_true(test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction enregistre dans le rapport, si la valeur resultat d'un test s'évalue à true et offre la possibilité de mettre un message personnalisé. Il fusionne les traitements des fonctions suivantes {!val:assert_true_m} et {!val:assert_true_result}.
@param msg message qui apparaitra dans le rapport si erreur
@param r résultat de la fonction sous test qui renvoie un booléen.
*)
let assert_true_result_m(msg, r : string * bool t_test_result) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_true_m(msg,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction enregistre si le booléen passé en argument s'évalue à [false].    
*)
let assert_false( b) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    begin
      step.cassert <- (step.cassert) + 1;
      if (not b) 
      then ()
      else step.error <- Some(Test_assert_violation(""))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
Cette fonction enregistre si le booléen passé en argument s'évalue à [false] et offre la possibilité de mettre un message personnalisé dans le rapport.
@param msg message qui apparaitra dans le rapport si erreur
@param b booléen qui doit s'évalué à [false]
   *)
let assert_false_m(msg, b) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    begin
      step.cassert <- (step.cassert) + 1;
      if (not b) 
      then ()
      else step.error <- Some(Test_assert_violation(msg))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction permet d'extraire le résultat booléen d'un résultat de test et de vérifier si ce dernier est évalué à [false].
  {[
    let foofalse() : bool = false ;;
    let res : bool t_test_result = test_exec(foofalse,"foofalse()",()) in
      assert_false_result(res)
    ;;
    test_report();;
  ]}
*)
let assert_false_result(r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_false(test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction enregistre dans le rapport, si la valeur resultat d'un test s'évalue à [false] et offre la possibilité de mettre un message personnalisé. Il fusionne les traitements des fonctions suivantes {!val:assert_false_m} et {!val:assert_false_result}.
@param msg message qui apparaitra dans le rapport si erreur
@param r résultat de la fonction sous test qui renvoie un booléen.
*)
let assert_false_result_m(msg, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_false_m(msg,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;


(**
  Cette fonction vérifie si les deux arguments sont égaux structurellement. Concrètement cela appel l'opérateur d'égalité sur les deux arguments.
  @param a valeur attendue par votre test
  @param b valeur observée dans votre test.    
*)
let assert_equals(a, b) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    begin
      step.cassert <- (step.cassert) + 1;
      if a = b 
      then ()
      else step.error <- Some(Test_assert_violation(""))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction vérifie si les deux arguments sont égaux structurellement. Concrètement cela appel l'opérateur d'égalité sur les deux arguments.
  @param msg message qui apparaitra dans le rapport si erreur
  @param a valeur attendue par votre test
  @param b valeur observée dans votre test.    
*)
let assert_equals_m(msg, a, b) : unit =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    begin
      step.cassert <- (step.cassert) + 1;
      if a = b 
      then ()
      else step.error <- Some(Test_assert_violation(msg))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction vérifie si le premier argument est égal au résultat du test.
  @param a valeur attendue par votre test
  @param r résultat obtenu par le test.
*)
let assert_equals_result(a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_equals(a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

(**
  Cette fonction vérifie si le premier argument est égal au résultat du test.
  @param msg message qui apparaitra dans le rapport si erreur
  @param a valeur attendue par votre test
  @param r résultat obtenu par le test.
*)
let assert_equals_result_m(msg,a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_equals_m(msg,a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;



let assert_notequals(a, b) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    (step.cassert <- (step.cassert) + 1;
    if a <> b 
    then ()
    else step.error <- Some(Test_assert_violation("")))
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_notequals_result(a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_notequals(a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_notequals_m(msg, a, b) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    (step.cassert <- (step.cassert) + 1;
    if a <> b 
    then ()
    else step.error <- Some(Test_assert_violation(msg)))
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_notequals_result_m(msg,a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_notequals_m(msg,a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;


let assert_value_in_list(a, l) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    (step.cassert <- (step.cassert) + 1;
    if List.exists ((=) a)  l 
    then ()
    else step.error <- Some(Test_assert_violation("")))
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_value_in_list_result(a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_value_in_list(a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_value_in_list_m(msg, a, l) : unit = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then 
    (step.cassert <- (step.cassert) + 1;
    if List.exists ((=) a)  l 
    then ()
    else step.error <- Some(Test_assert_violation(msg)))
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_value_in_list_result_m(msg,a, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_value_in_list_m(msg,a,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_value_result_in_list(r, l) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_value_in_list(test_get(r),l)
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_value_result_in_list_m(msg,r, l) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_value_in_list_m(msg,test_get(r),l)
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

 
(* Les listes ne doivent pas avoir de doublon !!
  exemple: [1;1;2;2;2] et [1;1;1;2;2] indique qu'elles sont similaire alors que cela pourrait poser souci.   
*)
let assert_similar_list(l1, l2) =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    (step.cassert <- step.cassert + 1;
    let s1 = List.length l1
    and s2 = List.length l2 in
      if s1 <> s2 then
        begin
          step.error <- Some(Test_assert_violation(""))
        end
      else
        begin
          let f l acc e = acc && (List.exists ((=) e) l) in
          let fl1 = List.fold_left (f l2) true l1 in
          let fl2 = List.fold_left (f l1) true l2 in
          if not(fl1 && fl2) then
            step.error <- Some(Test_assert_violation(""))
        end)
  else
    step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_similar_list_result(l, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_similar_list(l,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_similar_list_m(msg, l1, l2) =
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    (step.cassert <- step.cassert + 1;
    let s1 = List.length l1
    and s2 = List.length l2 in
      if s1 <> s2 then
        begin
          step.error <- Some(Test_assert_violation(msg))
        end
      else
        begin
          let f l acc e = acc && (List.exists ((=) e) l) in
          let fl1 = List.fold_left (f l2) true l1 in
          let fl2 = List.fold_left (f l1) true l2 in
          if not(fl1 && fl2) then
            step.error <- Some(Test_assert_violation(msg))
        end)
  else
    step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_similar_list_result_m(msg,l, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_similar_list_m(msg,l,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_list_in_list(small_list, big_list) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    begin
      step.cassert <- step.cassert + 1;
      let f l acc e = acc && (List.exists ((=) e) l) in
      let fl1 = List.fold_left (f big_list) true small_list in
      if not(fl1) then
        step.error <- Some(Test_assert_violation(""))
    end
  else
    step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_list_in_list_m(msg,small_list, big_list) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step) then
    begin
      step.cassert <- step.cassert + 1;
      let f l acc e = acc && (List.exists ((=) e) l) in
      let fl1 = List.fold_left (f big_list) true small_list in
      if not(fl1) then
        step.error <- Some(Test_assert_violation(msg))
    end
  else
    step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_list_in_result(l, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_list_in_list(l,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_list_in_result_m(msg,l, r) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_list_in_list_m(msg,l,test_get(r))
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;



let assert_result_in_list(r,l) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_list_in_list(test_get(r),l)
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

let assert_result_in_list_m(msg,r,l) = 
  let step = List.hd(global_test_status.seq) in
  if is_current_test_valid(step)
  then
    begin
      assert_list_in_list_m(msg,test_get(r),l)
    end
  else step.cassert_ignored <- (step.cassert_ignored) + 1
;;

