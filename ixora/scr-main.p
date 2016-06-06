/*
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 k.gitalov
 * BASES
        BANK
 * CHANGES
        10/07/2012 dmitriy - Добавление пункта "Курсы валют"
*/

{classes.i}




def var rez as log.
def var pos as int.
def var tmpl as char.
def var phand AS handle.
def var v-Cif as char.
def var v-Acc as char.
def var t-res as char.
def var i as int.
def var v-sel as int.

def temp-table wrk no-undo
  field ind as int
  field name as char
  field tmpl as char.



pos = 1.

run CreateNames.

  REPEAT on ENDKEY UNDO  , leave :
   message "".
   CASE pos:
     WHEN 1 THEN
     DO:
        run List(output tmpl).
        if tmpl = "" then
        do:
           run yn("","Выйти из программы?","","", output rez).
           if rez then do: run to_screen( "default",""). leave. end.
           else do: undo. end.
        end.
        else do:
           pos = 2.
        end.
     END.
     WHEN 2 THEN
     DO:
        case tmpl:
          when "stateaaa" then  do:
            run FindCifAcc.
            if v-Cif <> "" then do:
                run sel_screen("stateaaa", v-cif, v-acc, output t-res).
                run to_screen("stateaaa", t-res).
                run sel2 ("Экран клиента","Закрыть экран клиента" , output v-sel).
                if v-sel = 1 then run to_screen( "default","").
            end.
          end.

          when "extract" then do:
            run FindCifAcc.
            /*if v-Cif <> "" and v-Acc <> "" then run sel_scrgrp(4).*/
            run scr-extract(v-cif, v-acc).
          end.

          when "statedepo" then run sel_scrgrp(5).

          when "newcred" then do:
            run FindCif.
            if v-Cif <> "" then do:
                run sel_screen("newcred", v-Cif, "", output t-res).
                run to_screen("newcred", t-res).
                run sel2 ("Экран клиента","Закрыть экран клиента" , output v-sel).
                if v-sel = 1 then run to_screen( "default","").
            end.
          end.

          when "payacc" then run sel_scrgrp(7).

          when "convdoc" then do:
            run FindCif.
            if v-Cif <> "" then run sel_screen("convdoc", v-Cif, "", output t-res).
            run to_screen("convdoc", t-res).
            run sel2 ("Экран клиента","Закрыть экран клиента" , output v-sel).
            if v-sel = 1 then run to_screen( "default","").
          end.
          when "transfer" then  run sel_scrgrp(8).

          when "cifacc" then do:
            run FindCif.
            if v-Cif <> "" then run sel_screen(9, "", "").
          end.

          when "rates" then do:
                run sel_screen("rates", "", "", output t-res).
                run to_screen("rates", t-res).
                run sel2 ("Экран клиента","Закрыть экран клиента" , output v-sel).
                if v-sel = 1 then run to_screen( "default","").
          end.
        end case.

       v-cif = "".
       v-acc = "".
       pos = 1.
     END.


   END CASE.

  END.

/*****************************************************************************************************/
procedure List:
    def output param v-tmpl as char.

    define query q_list for wrk.
    define browse b_list query q_list no-lock
    display string(wrk.ind) format "x(2)" label "№" wrk.name format "x(30)" label "Операция"
    with title "Экран клиента" 8 down centered overlay  no-row-markers.

    define frame f1 b_list skip space(7) "Для выхода нажмите 'F4'" with no-labels centered overlay view-as dialog-box.

    on return of b_list in frame f1
    do:
        if avail wrk then v-tmpl = wrk.tmpl.
        apply "endkey" to frame f1.
    end.

    on END-ERROR of b_list in frame f1
    do:
        v-tmpl = "".
        apply "endkey" to frame f1.
    end.


   open query q_list for each wrk BY ind.

    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.

    WAIT-FOR endkey of frame f1.
    hide frame f1.

end procedure.
/*****************************************************************************************************/
procedure FindCifAcc:
  define frame Frame1
  v-Cif label  "ID клиента" skip v-Acc label "Счет"  format "x(20)"
  with side-labels row 13 centered.

  DISPLAY v-Cif v-Acc  WITH FRAME Frame1.

  on help of v-Cif in frame Frame1 do:
    run h-cif PERSISTENT SET phand.
    hide frame xf.
    v-Cif = frame-value.
    displ  v-Cif with frame Frame1.
    DELETE PROCEDURE phand.
  end.


  v-Acc = ''.
  repeat while v-Acc = '' :
    update v-Cif validate(can-find(first cif where cif.cif = v-Cif no-lock),"Нет такого ID клиента! F2-помощь") WITH FRAME Frame1.
    def var Usr as class ClientClass.
    Usr = NEW ClientClass().
    if Usr:FindClientNo(v-Cif) then
    do:
      def var listacc as char.
      def var listacc2 as char.
      def var v-sel as int.
      listacc =  Usr:FindAcc().
      if INDEX(listacc,"|") > 0 then
      do:
        /*-------------------*/
        listacc2 = "".
        do i = 1 to INDEX(listacc,"|"):
            find first aaa where aaa.aaa = entry(i, listacc, "|") no-lock no-error.
            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail aaa then do:
                listacc2 = listacc2 + aaa.aaa + "  -  " + crc.code + "|".
            end.
        end.

        run sel2 ('Выберите счет',listacc2 , output v-sel).
        v-Acc = entry(v-sel, listacc, '|').
        /*-------------------*/

        /*run sel1("Выберите счет", Usr:FindAcc()).
        v-Acc = return-value.--------*/

       /* DISPLAY v-Acc WITH FRAME Frame1.*/
      end.
      else v-Acc = listacc.
    end.
    if VALID-OBJECT(Usr)  then DELETE OBJECT Usr NO-ERROR .
   end.

   hide frame Frame1.
end procedure.
/*****************************************************************************************************/
procedure FindCif:
  define frame Frame2
  v-Cif label  "ID клиента"
  with side-labels row 13 centered.

  DISPLAY v-Cif WITH FRAME Frame2.

  on help of v-Cif in frame Frame2 do:
    run h-cif PERSISTENT SET phand.
    hide frame xf.
    v-Cif = frame-value.
    displ  v-Cif with frame Frame2.
    DELETE PROCEDURE phand.
  end.

  update v-Cif validate(can-find(first cif where cif.cif = v-Cif no-lock),"Нет такого ID клиента! F2-помощь") WITH FRAME Frame2.
  hide frame Frame2.
end procedure.
/*****************************************************************************************************/
procedure CreateNames:
   create wrk.
          wrk.ind = 1.
          wrk.name = "Остатки по счетам".
          wrk.tmpl = "stateaaa".
    create wrk.
          wrk.ind = 2.
          wrk.name = "Движения по счету".
          wrk.tmpl = "extract".
    create wrk.
          wrk.ind = 3.
          wrk.name = "Состояние депозита".
          wrk.tmpl = "statedepo".
    create wrk.
          wrk.ind = 4.
          wrk.name = "Кредит".
          wrk.tmpl = "newcred".
    create wrk.
          wrk.ind = 5.
          wrk.name = "Платежи со счета".
          wrk.tmpl = "payacc".
    create wrk.
          wrk.ind = 6.
          wrk.name = "Покупка/Продажа валюты".
          wrk.tmpl = "convdoc".
    create wrk.
          wrk.ind = 7.
          wrk.name = "Перевод без открытия счета".
          wrk.tmpl = "transfer".
    create wrk.
          wrk.ind = 8.
          wrk.name = "Курсы валют".
          wrk.tmpl = "rates".
end procedure.
/*****************************************************************************************************/