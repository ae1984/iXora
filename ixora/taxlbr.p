/* taxlbr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{taxlbr.f}
   

ON "help" of browse bc
DO:
 /* for each wcur. message  wcur.taxrate wcur.val view-as alert-box . pause 50.         end. */
    if rcol = 0 then
    do:
       do transaction:
          release wcur.
          create wcur.
          wcur.taxrate = no.
          wcur.regdt = g-today.
          wcur.prd = 000.
          update  wcur.regdt with frame uptax2. 
          find taxrate where taxrate.regdt = wcur.regdt  and 
          taxrate.taxrate = 'rfn' no-lock no-error  .
      if available taxrate then do:
         wcur.val = taxrate.val[12].
          displ wcur.val with frame uptax2.
          end.
         displ  wcur.taxrate with frame uptax2.
          update wcur.val with frame uptax2.
       end.
       rcol = rcol + 1.
       hide frame uptax2.
       close query qc.
       open query qc for each wcur.
       if can-find(first wcur no-lock) then
          browse bc:refresh().
    end.
    else message "Ставка с рефином уже существует!"
         view-as alert-box.
END.

ON "go" of browse bc /*F1*/
DO:
   /* for each wcur where taxrate no-lock:
      i = i + 1.
       message wcur.regdt wcur.val wcur.prd. pause 40.
    end.  */
    if i < 12 then
    do:
       i = i + 1.
       do transaction:
       release wcur.
       create wcur.
       wcur.taxrate = yes.
       wcur.regdt = g-today.
       wcur.prd = i /*string(i)*/ .
       update wcur.regdt with frame uptax.
       find taxrate where taxrate.regdt = wcur.regdt  and
       taxrate.taxrate = 'lbr' /*and taxrate.prd = wcur.prd*/ no-lock no-error.
       if available taxrate then do:
        wcur.val = taxrate.val[i].
        displ wcur.val with frame uptax.
       end.
       displ  wcur.prd wcur.taxrate with frame uptax.
       update wcur.val with frame uptax.
       end.
       hide frame uptax.

       close query qc.
       open query qc for each wcur.
       if can-find(first wcur no-lock) then
          browse bc:refresh().
    end.   
    else message "Уже заданы все ставки по периодам (от 1 до 12)!"
         view-as alert-box.
END.

/* ------------------------------- редактирование ставки ------------ */
ON "return" of browse bc
DO:
    if avail wcur then
    do:
    yesno = yes-no ("Ставка уже существует", "Изменить?").
    if yesno then
    do:
       displ wcur with frame uptax.
       update wcur.val with frame uptax.
       release wcur.
       hide frame uptax.
       close query qc.
       open query qc for each wcur by wcur.taxrate by wcur.prd.
       if can-find(first wcur no-lock) then
          browse bc:refresh().
    end.
    end.
    else message "Сначала создайте ставку!"
                 view-as alert-box.
END.

on end-error of browse bc hide frame fc.

ASSIGN CURRENT-WINDOW:MENUBAR = MENU mbar:HANDLE.
WAIT-FOR CHOOSE OF MENU-ITEM mmext.               /* выход */
   
close query qc.

/*--------------------- открыть окно в свет -------------------------- */
procedure stavki.
open query qc for each wcur by wcur.taxrate by wcur.prd .
enable all with frame fc.
wait-for window-close of frame fc focus browse bc.
release wcur.
end procedure.
