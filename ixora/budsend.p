/* budsend.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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

 * BASES
        BANK COMM
 * CHANGES
        14/07/2012 Luiza
*/

{yes-no.i}
{global.i}
def var str_p as char.
DEFINE QUERY q2 FOR budofc .

define buffer buf for budofc.

def browse b2
     query q2
     displ
     budofc.ofc label "Логин офицера  " format "x(9)"
     budofc.dop label "     ФИО       " format "x(25)"
     budofc.txb label "Код департамент" format "x(5)"
     with 20 down title "Настройка доступа сотрудников" overlay.

define frame getlist1
budofc.ofc label "Логин офицера    " help " F2 - Поиск логина" validate(can-find(first buf where buf.ofc = budofc.ofc no-lock),"сотрудник уже заведен!")  skip
budofc.txb label "Код департамента " format "x(5)"
with side-labels centered row 8.

define frame getlist2
buf.ofc label "Логин офицера    " help " F2 - Поиск логина"  skip
buf.txb label "Код департамента " format "x(5)"
with side-labels centered row 8.

DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bupd LABEL "Редакт.".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bext LABEL "Выход".

DEFINE QUERY qofc FOR ofc.

DEFINE BROWSE b-ofc QUERY qofc
    DISPLAY ofc.ofc label "логин сотр" format "x(9)" ofc.name label "ФИО" format "x(30)" WITH  15 DOWN.
DEFINE FRAME f-ofc b-ofc  WITH overlay row 5 COLUMN 25 width 50 title "Список сотрудников".

DEFINE QUERY qcodfr FOR codfr.

DEFINE BROWSE b-codfr QUERY qcodfr
    DISPLAY codfr.code label "департ" format "x(3)" codfr.name[1] label "Наименование" format "x(50)" WITH  15 DOWN.
DEFINE FRAME f-codfr b-codfr  WITH overlay row 5 COLUMN 25 width 70 title "Список департаментов".

def frame fr2
     b2
     skip
     bnew
     bupd
     bdel
     bext with centered overlay row 5 top-only.

on help of buf.ofc in frame getlist2 do:
    OPEN QUERY  qofc FOR EACH ofc use-index name where ofc.ofc begins "id" no-lock.
    ENABLE ALL WITH FRAME f-ofc.
    wait-for return of frame f-ofc
    FOCUS b-ofc IN FRAME f-ofc.
    buf.ofc = ofc.ofc.
    hide frame f-ofc.
    displ buf.ofc with frame getlist2.
end.
on help of budofc.ofc in frame getlist1 do:
    OPEN QUERY  qofc FOR EACH ofc use-index name where ofc.ofc begins "id" no-lock.
    ENABLE ALL WITH FRAME f-ofc.
    wait-for return of frame f-ofc
    FOCUS b-ofc IN FRAME f-ofc.
    budofc.ofc = ofc.ofc.
    hide frame f-ofc.
    displ budofc.ofc with frame getlist1.
end.
on help of buf.txb in frame getlist2 do:
    OPEN QUERY  qcodfr FOR EACH codfr where codfr.codfr = "sproftcn" and codfr.child = false
              and codfr.code <> 'msc' and codfr.code matches '...' and substring(codfr.code,1,1) <> '0'  no-lock.
    ENABLE ALL WITH FRAME f-codfr.
    wait-for return of frame f-codfr
    FOCUS b-codfr IN FRAME f-codfr.
    buf.txb = codfr.code.
    hide frame f-codfr.
    displ buf.txb with frame getlist2.
end.

on help of budofc.txb in frame getlist1 do:
    OPEN QUERY  qcodfr FOR EACH codfr where codfr.codfr = "sproftcn" and codfr.child = false
              and codfr.code <> 'msc' and codfr.code matches '...' and substring(codfr.code,1,1) <> '0' no-lock.
    ENABLE ALL WITH FRAME f-codfr.
    wait-for return of frame f-codfr
    FOCUS b-codfr IN FRAME f-codfr.
    budofc.txb = codfr.code.
    hide frame f-codfr.
    displ budofc.txb with frame getlist1.
end.
on "END-ERROR" of frame getlist2 do:
  hide frame getlist2 no-pause.
end.
on "END-ERROR" of frame getlist1 do:
  hide frame getlist1 no-pause.
end.
on "END-ERROR" of frame f-ofc do:
  hide frame f-ofc no-pause.
end.
on "END-ERROR" of frame f-codfr do:
  hide frame f-codfr no-pause.
end.


ON CHOOSE OF bext IN FRAME fr2
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b2.
end.

ON CHOOSE OF bdel IN FRAME fr2
do:
   if yes-no ("Внимание!", "Вы действительно хотите удалить запись?")
   then do:
      find buf where rowid (buf) = rowid (budofc) exclusive-lock.
      delete buf.
      close query q2.
      open query q2 for each budofc where budofc.snd.
      browse b2:refresh().
   end.
end.

   ON CHOOSE OF bupd IN FRAME fr2
do:
   find buf where rowid (buf) = rowid (budofc) exclusive-lock.
   buf.snd = true.
   buf.who = g-ofc.
   buf.whn = g-today.
   update buf.ofc  buf.txb label "код департамента" format "x(5)" with frame getlist2.
   find first ofc where ofc.ofc = buf.ofc no-lock no-error.
   if available ofc then buf.dop = ofc.name.

   close query q2.
   open query q2 for each budofc where budofc.snd.
   browse b2:refresh().
end.

   ON CHOOSE OF bnew IN FRAME fr2
do:
   create budofc.
   budofc.snd = true.
   budofc.who = g-ofc.
   budofc.whn = g-today.
   update budofc.ofc budofc.txb with frame getlist1.
   find first ofc where ofc.ofc = budofc.ofc no-lock no-error.
   if available ofc then budofc.dop = ofc.name.

   close query q2.
   open query q2 for each budofc where budofc.snd.
   browse b2:refresh().
end.

open query q2 for each budofc where budofc.snd.

b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr2 centered overlay top-only.

apply "value-changed" to b2 in frame fr2.

WAIT-FOR WINDOW-CLOSE of frame fr2.

hide frame fr2.


