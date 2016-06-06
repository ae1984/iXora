/* sel_scrgrp.p
 * MODULE
        Экран клинета
 * DESCRIPTION
        Вызов экранов, в которых больше 1 шаблона
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15.5
 * AUTHOR
        10/07/2012 dmitriy
 * BASES
        BANK
 * CHANGES
*/

{classes.i}

def input parameter t-screen as int.

def var list2 as char initial
    "484,485,486,487,488,489,478,479,480,481,482,483,518,519,520,A01,A02,A03,A04,A05,A06,A13,A14,A15,A19,A20,A21,A22,A23,A24,A25,A26,A27,A28,A29,A30,A31,A32,A33,A34,A35,A36".
def var v-list as char.
def var v-sel as int.

def button prev-button label "Предыдущая".
def button next-button label "Следующая".
def button close-button label "Закрыть".
def var CurPage as int.
def var PosPage as int.
def var MaxPage as int.

def var tmpl as char.
def var v-cif as char.
def var t-res as char.
def var v-acc as char.
def var phand AS handle.
def var Mask as char label "шаблон".
def var TDOCNO as char.
def var dt1 as date.
def var dt2 as date.

def var i as int.

def var Pages as char label "страница".

define frame Form1
    Mask format "x(25)" skip
    Pages skip
    "----------------------------------" skip
    prev-button next-button close-button
    WITH SIDE-LABELS centered overlay row 20 TITLE "Экран клиента".

define frame fmask7
    TDOCNO format "x(10)" label "Введите номер документа"
with side-labels centered row 15.

define frame fmask9
    TDOCNO format "x(10)" label "Введите номер документа"
with side-labels centered row 15.

define frame MainFrame
    dt1 label ' Период с ' format '99/99/9999'
    dt2 label ' по ' format '99/99/9999'
with side-labels row 13 centered.


case t-screen:
    when 1 then do:
        tmpl = "newaaa1,aaadepo2".
        Mask = "Открытие  текущего счета".
        MaxPage = 2.
        run FindCifAcc.
    end.
    when 2 then do:
        tmpl = "newdepo1,aaadepo2".
        Mask = "Открытие сберегательного счета".
        MaxPage = 2.
        run FindCifAcc.
    end.
    when 3 then do:
        tmpl = "stateaaa".
        Mask = "Остатки по счету".
        MaxPage = 1.
        run FindCifAcc.
    end.
    when 4 then do:
        tmpl = "extract1,extract2".
        Mask = "Движение по счету".
        MaxPage = 2.
        run FindCifAcc.

        dt1 = g-today.
        dt2 = g-today.
        DISPLAY dt1 dt2  WITH FRAME MainFrame.
        update dt1 dt2 WITH FRAME MainFrame.
        hide frame MainFrame.

        v-acc = v-acc + "|" + string(dt1, "99.99.9999") + "|" + string(dt2, "99.99.9999").
    end.
    when 5 then do:
        tmpl = "statedepo1,statedepo2,statedepo3".
        Mask = "Состояние депозита".
        MaxPage = 3.
        run FindCif.

        v-list = "".
        for each aaa where aaa.cif = v-cif and aaa.sta <> "C" no-lock:
            if lookup (string(aaa.lgr), list2) > 0 then do:
                v-list = v-list + aaa.aaa + '|'.
            end.
        end.
        if v-list <> "" then
            run sel2 ('Сберегательные счета клиента',v-list , output v-sel).
        else do:
            message "У клиента нет сберегательных счетов!".
            pause 10.
            return.
        end.
        find first aaa where aaa.aaa = entry(v-sel, v-list,'|') no-lock no-error.
        if not avail aaa then message "Счет не найден".
        else v-acc = entry(v-sel, v-list,'|').
    end.
    when 6 then do:
        tmpl = "newcred".
        Mask = "Кредит".
        MaxPage = 1.
    end.
    when 7 then do:
        tmpl = "payacc1,paytrans2".
        Mask = "Платежи со счета (в тенге и  ин. валюте)".
        MaxPage = 2.
        v-cif = "".
        update TDOCNO with frame fmask7.
        v-acc = TDOCNO.
    end.
    when 8 then do:
        tmpl = "transfer,paytrans2".
        Mask = "Банковский перевод без открытия счета".
        MaxPage = 2.
        update TDOCNO with frame fmask9.
        v-acc = TDOCNO.
    end.
    when 9 then do:
        tmpl = "qtransfer1,qtransfer2".
        Mask = "Быстрый перевод".
        MaxPage = 2.
    end.

end case.

CurPage = 1.
PosPage = 1.

Pages = "1 из " + string(MaxPage).
DISPLAY Pages Mask WITH FRAME Form1.

run sel_screen(entry(1, tmpl, ","), v-cif, v-acc, output t-res).
run to_screen(entry(1, tmpl, ","), t-res).


ON CHOOSE OF next-button
DO:
    PosPage = PosPage + 1.
    if PosPage > MaxPage then PosPage = MaxPage.
    Pages = string(PosPage) + " из " + string(MaxPage).

    if PosPage = 1 then do:
        run sel_screen(entry(1, tmpl, ","), v-cif, v-acc, output t-res).
        run to_screen(entry(1, tmpl, ","), t-res).
    end.
    else do:
        run sel_screen(entry(PosPage, tmpl, ","), v-cif, v-acc, output t-res).
        run to_screen(entry(PosPage, tmpl, ","), t-res).
    end.
    DISPLAY Pages Mask WITH FRAME Form1.
END.

ON CHOOSE OF prev-button
DO:
    PosPage = PosPage - 1.
    if PosPage <= 0 then PosPage = 1.
    Pages = string(PosPage) + " из " + string(MaxPage).

    if PosPage = 1 then do:
        run sel_screen(entry(1, tmpl, ","), v-cif, v-acc, output t-res).
        run to_screen(entry(1, tmpl, ","), t-res).
    end.
    else do:
        run sel_screen(entry(PosPage, tmpl, ","), v-cif, v-acc, output t-res).
        run to_screen(entry(PosPage, tmpl, ","), t-res).
    end.
    DISPLAY Pages Mask WITH FRAME Form1.
END.

ON CHOOSE OF close-button
DO:
    run to_screen( "default","").
    apply "endkey" to frame Form1.
    hide frame Form1.
    return.
END.

/*Pages = string(PosPage) + " из " + string(MaxPage).*/

    DISPLAY Pages prev-button next-button close-button WITH FRAME Form1.
    ENABLE next-button  prev-button  close-button WITH FRAME Form1.

WAIT-FOR endkey of frame Form1.
hide frame Form1.


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