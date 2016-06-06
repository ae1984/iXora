/* vc-vhis.i
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
        05/09/2006 u00600 - оптимизация, убрала явное прописание индекса main. для каждой из таблиц цепляется свой идекс
*/

/* vccthis.p Валютный контроль
   История контракта и документов

   08.11.2002 nadejda создан

*/

{global.i}

def shared var s-cif like cif.cif.
def shared var v-cifname as char.
def shared var s-{&headkey} like {&head}.{&headkey}.
def shared var s-viewcommand as char.

def var v-imgfile as char init "tmp-vchis.img".


{{&frame}.f}

output to value(v-imgfile).

find first cmp no-lock no-error.
find first ofc where ofc.ofc = g-ofc no-lock no-error.

put 
  trim(cmp.name) + " " + string(today, "99/99/9999") + " " + string(time, "HH:MM:SS") 
      format "x(60)" skip
  "Исполнитель :  " + ofc.name format "x(60)" skip(1).

displ "ИСТОРИЯ " + "{&header}" skip.

find {&head} where {&head}.{&headkey} = s-{&headkey} no-lock no-error.

{&predisplay}

if {&displcif} then
  displ "КЛИЕНТ : " + v-cifname format "x(70)" skip.

displ {&display} with frame {&frame}.

put unformatted skip(3).

for each {&headhis} where {&headhis}.{&headkey} = s-{&headkey} no-lock: /* use-index main:*/
  put unformatted 
     {&headhis}.whn " " 
     string({&headhis}.tim, "HH:MM:SS") " " 
     {&headhis}.ourbnk " "
     {&headhis}.fname " "
     {&headhis}.who " "
     {&headhis}.info " "
     skip.
end.

output close.

if s-viewcommand = "prit" then
  unix silent value(s-viewcommand + " " + v-imgfile).
else
  unix value(s-viewcommand + " " + v-imgfile).

pause 0.

hide frame www no-pause.


