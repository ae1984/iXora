/* splist.p

 * MODULE

 * DESCRIPTION
        список СП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK
 * AUTHOR
        26.09.2011 evseev
 * CHANGES

*/
def input param alloff as int.

function GetCifProfC return char (input tcif as char):
    find first cif where cif.cif = tcif no-lock no-error.
    if avail cif then do:
        find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = tcif and sub-cod.d-cod = 'sproftcn' no-lock no-error.
        if avail sub-cod then do:
           find first codfr where codfr.codfr = "sproftcn" and codfr.code = sub-cod.ccode no-lock no-error.
           if avail codfr then do:
               if codfr.code <> "" then return codfr.name[1].
               else return "-".
           end.
        end.
        else return "-".
    end.
    else return "-".
end function.


  define temp-table wrk
    field name as char
    field code as char.
  def buffer b-wrk for wrk.

 if alloff = 0 then
 do:
  create wrk.
  wrk.name = "Все".
  wrk.code = "ALL".
 end.


/*
def var s as char.
for each cif no-lock:
   s = GetCifProfC(cif.cif).
   find first b-wrk where b-wrk.name = s no-lock no-error.
   if not avail b-wrk then do:
      create wrk.
         wrk.name = GetCifProfC(cif.cif).
         wrk.code = GetCifProfC(cif.cif).
   end.
end.
*/
for each codfr where codfr.codfr = "sproftcn" no-lock:
  find first sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = 'sproftcn' and sub-cod.ccode = codfr.code no-lock no-error.
  if avail sub-cod then do:
      create wrk.
         wrk.name = codfr.name[1].
         wrk.code = codfr.name[1].
  end.
end.


   define query q_list for wrk.
   define browse b_list query q_list no-lock
   display wrk.name format "x(30)" no-label with title "Выбор СП" 10 down centered overlay  /*NO-ASSIGN SEPARATORS*/ no-row-markers.

   define frame f1 b_list with no-labels centered overlay view-as dialog-box.

    /******************************************************************************/
    on return of b_list in frame f1
    do:
        apply "endkey" to frame f1.
        return string(wrk.code).
    end.
    ON END-ERROR OF b_list in  frame f1
    DO:
        return string("EXIT").
    END.
    /******************************************************************************/

    open query q_list for each wrk.

    enable all with frame f1.
    apply "value-changed" to b_list in frame f1.
    WAIT-FOR endkey of frame f1.
    hide frame f1.



