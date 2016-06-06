/* cif-ref.p
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
 * BASES
        BANK COMM
 * CHANGES
        21.12.2004 saltanat - Полностью изменила по новому требованию ТЗ ї1223.
        13.07.2011 id00004 - Увеличил длинуполя во фрейме
        04.08.2011 id00004 - Исправил ошибку при компиляции
        06/10/2011 evseev - увеличил длину поля для счета
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        31.08.2012 evseev - иин/бин
*/

{global.i}
{yes-no.i}

def var yn as log initial false format "да/нет".
def shared var s-cif like cif.cif.
def var v-aaa like aaa.aaa.
def var v-fio    as char.
def var v-idcard as char.
def var v-jss    as char.
def var id       as inte.
def buffer buff_heir for cif-heir.

def temp-table waaa
    field aaa as char
    field lgr as char
    field midd as char
index main is primary unique lgr midd aaa.

def temp-table wupl
    field id     as   inte
    field fio    as   char
    field idcard as   char
    field jss    as   char
index main fio.

DEFINE QUERY q1 FOR cif-heir.
def browse b1
query q1
displ
    cif-heir.aaa       label 'Счет' format 'x(20)'
    cif-heir.fio       label 'ФИО'  format 'x(30)'
    cif-heir.idcard    label 'удов' format 'x(12)'
    cif-heir.jss       label 'ИИН' format 'x(12)'
    cif-heir.will-date label 'Дата завещ' format '99/99/99'
    cif-heir.ratio     label 'Соотнош' format 'x(8)'
with 12 down title ' Наследуемые лица '.

DEFINE BUTTON bloo LABEL "LOOK".
DEFINE BUTTON bedt LABEL "EDIT".
DEFINE BUTTON badd LABEL "ADD".
DEFINE BUTTON bdel LABEL "DELETE".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 skip
     bloo
     bedt
     badd
     bdel
     bext with width 105 centered overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bloo IN FRAME fr1
do:
   find current cif-heir no-lock no-error.
   if not avail cif-heir then do: message 'Нет текущей записи!'. pause 3. return. end.
displ
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with frame fr row 3 overlay top-only side-label col 5 title ' Наследуемое лицо '.
end.

ON CHOOSE OF bedt IN FRAME fr1
do:
find current cif-heir exclusive-lock no-error.
if not avail cif-heir then do: message 'Нет текущей записи!'. pause 3. return. end.
def frame fr
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with row 3 overlay top-only side-label col 5 title ' Наследуемое лицо '.

on help of cif-heir.aaa in frame fr do:
   run choise_aaa.
   if v-aaa <> '' then cif-heir.aaa = v-aaa.
   displ cif-heir.aaa with frame fr.
end.

on help of cif-heir.fio in frame fr do:
  id = 0.
  run choise_upl.
  if v-fio    <> '' then cif-heir.fio    = v-fio.
  if v-idcard <> '' then cif-heir.idcard = v-idcard.
  if v-jss    <> '' then cif-heir.jss    = v-jss.
  displ cif-heir.fio cif-heir.idcard cif-heir.jss with frame fr.
end.

update
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with frame fr.
    cif-heir.who = g-ofc.
    cif-heir.whn = g-today.
    cif-heir.tim = time.
find current cif-heir no-lock.
open query q1 for each cif-heir where cif-heir.cif = s-cif.
end.

ON CHOOSE OF badd IN FRAME fr1
do:
def frame fr
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with frame fr row 3 overlay top-only side-label col 5 title ' Наследуемое лицо '.

on help of cif-heir.aaa in frame fr do:
   run choise_aaa.
   if v-aaa <> '' then cif-heir.aaa = v-aaa.
   displ cif-heir.aaa with frame fr.
end.

on help of cif-heir.fio in frame fr do:
  id = 0.
  run choise_upl.
  if v-fio    <> '' then cif-heir.fio    = v-fio.
  if v-idcard <> '' then cif-heir.idcard = v-idcard.
  if v-jss    <> '' then cif-heir.jss    = v-jss.
  displ cif-heir.fio cif-heir.idcard cif-heir.jss with frame fr.
end.

create cif-heir.
assign cif-heir.cif = s-cif
       cif-heir.who = g-ofc
       cif-heir.whn = g-today
       cif-heir.tim = time.
update
    cif-heir.aaa       label '                  Счет' format 'x(20)' skip
    cif-heir.fio       label '                   ФИО' format 'x(40)' skip
    cif-heir.idcard    label '      Пасп/удов N/дата' format 'x(40)' skip
    cif-heir.jss       label '                   ИИН' format 'x(12)' skip
    cif-heir.will-date label '       Дата выд.завещ.' format '99/99/99' skip
    cif-heir.ratio     label 'Соотношение насл.имущ.' format 'x(40)' skip
with frame fr.
open query q1 for each cif-heir where cif-heir.cif = s-cif.
end.

ON CHOOSE OF bdel IN FRAME fr1
do:
find current cif-heir exclusive-lock no-error.
if not avail cif-heir then do: message 'Нет текущей записи!'. pause 3. return. end.
if yes-no ('', 'Вы действительно хотите удалить запись?') then do:
  delete cif-heir.
  open query q1 for each cif-heir where cif-heir.cif = s-cif.
end.
end.

open query q1 for each cif-heir where cif-heir.cif = s-cif.


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

procedure choise_aaa.
for each waaa.
delete waaa.
end.
v-aaa = ''.
for each aaa where aaa.cif = s-cif no-lock break by aaa.aaa:
find lgr where lgr.lgr = aaa.lgr no-lock.
if lgr.led = 'ODA' then next.
if aaa.sta <> "c" then do:
create waaa.
waaa.aaa = aaa.aaa.
waaa.lgr = aaa.lgr.
waaa.midd = substr(aaa.aaa, 4, 3).
end.
end.
find first waaa no-error.
if not avail waaa then do:
   message skip " У клиента нет действующих счетов ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "waaa"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " waaa.aaa label 'Счет'
                 waaa.lgr label 'Группа счета'
                 waaa.midd label 'Статус'
               "
    &chkey = "lgr"
    &chtype = "string"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
 v-aaa = waaa.aaa.
end procedure.

procedure choise_upl.
for each wupl.
delete wupl.
end.
v-fio = ''. v-idcard = ''. v-jss = ''.
upper:
for each buff_heir where buff_heir.cif = s-cif.
  for each wupl.
  if (wupl.fio    = buff_heir.fio) and
     (wupl.idcard = buff_heir.idcard) and
     (wupl.jss    = buff_heir.jss) then next upper.
  end.
  if buff_heir.fio <> '' then do:
  id = id + 1.
  create wupl.
  assign wupl.id     = id
         wupl.fio    = buff_heir.fio
         wupl.idcard = buff_heir.idcard
         wupl.jss    = buff_heir.jss.
  end.
end.
find first wupl no-error.
if not avail wupl then do:
   message skip " У клиента нет уполномоченных лиц ! " skip(1) view-as
   alert-box button ok title "".
   return.
end.
   {itemlist.i
    &file = "wupl"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " wupl.id    label 'N'
                 wupl.fio label 'Ф.И.О.'
                 wupl.idcard label 'Удостоверение'
                 wupl.jss label 'ИИН'
               "
    &chkey = "id"
    &chtype = "integer"
    &index  = "main"
    &end = "if keyfunction(lastkey) eq 'end-error' then return."
   }
  v-fio    = wupl.fio.
  v-idcard = wupl.idcard.
  v-jss    = wupl.jss.
end procedure.


