/* filials.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Закладка в п.м. 1.1 "Филиалы" для внесения данных по филиалам клиента
 * RUN
        Вверхнее меню CIFSUB
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.1
 * AUTHOR
        16.06.2005 saltanat
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        11.12.2012 evseev - tz625
*/
{global.i}
{yes-no.i}

def var yn as log initial false format "да/нет".
def shared var s-cif like cif.cif.
def var v-aaa like aaa.aaa.
def var v-badd1 as char.
def var v-badd2 as char.
def var v-badd3 as char.
def var id as inte.
def var v-rnn as logical.

DEFINE QUERY q1 FOR clfilials.
def browse b1
query q1
displ
    clfilials.namefil     label 'Найменование филиала     ' format 'x(25)'
    clfilials.forma_sobst label 'Орган.форма собственности' format 'x(25)'
    clfilials.rnn         label 'БИН                      ' format 'x(12)'
with 12 down title ' Филиалы '.

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
     bext with centered overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bloo IN FRAME fr1
do:
displ
    skip
    clfilials.namefil     label 'Найменование филиала     ' format 'x(45)' skip
    clfilials.forma_sobst label 'Орган.форма собственности' format 'x(45)' skip
    clfilials.rnn         label 'БИН                      ' format 'x(12)' skip(1)
with frame fr centered row 5 overlay top-only side-label col 5 title ' Филиалы '.
end.

ON CHOOSE OF bedt IN FRAME fr1
do:
find current clfilials exclusive-lock.
def frame fr
    skip
    clfilials.namefil     label 'Найменование филиала     ' format 'x(45)' skip
    clfilials.forma_sobst label 'Орган.форма собственности' format 'x(45)' skip
    clfilials.rnn         label 'БИН                      ' format 'x(12)' skip(1)
with frame fr centered row 5 overlay top-only side-label col 5 title ' Филиалы '.

update
    clfilials.namefil
    clfilials.forma_sobst
with frame fr.

do on error undo,retry :
      update clfilials.rnn validate(length(clfilials.rnn) eq 12 , "Введите 12 цифр БИН !")
             with frame fr.
      run rnnchk( input clfilials.rnn,output v-rnn).
      if v-rnn then do :
        message "Введите БИН верно ! ". pause .
      end.
end.

    clfilials.who = g-ofc.
    clfilials.whn = g-today.
find current clfilials no-lock.
open query q1 for each clfilials where clfilials.cif = s-cif.
end.

ON CHOOSE OF badd IN FRAME fr1
do:
def frame fr
    skip
    clfilials.namefil     label 'Найменование филиала     ' format 'x(45)' skip
    clfilials.forma_sobst label 'Орган.форма собственности' format 'x(45)' skip
    clfilials.rnn         label 'БИН                      ' format 'x(12)' skip(1)
with frame fr centered row 5 overlay top-only side-label col 5 title ' Филиалы '.


find last clfilials no-lock no-error.
if not avail clfilials then id = 1.
else id = clfilials.id + 1.

create clfilials.
assign clfilials.id = id
       clfilials.cif = s-cif
       clfilials.who = g-ofc
       clfilials.whn = g-today.

update
    clfilials.namefil
    clfilials.forma_sobst
with frame fr.

do on error undo,retry :
      update clfilials.rnn validate(length(clfilials.rnn) eq 12 , "Введите 12 цифр БИН !")
             with frame fr.
      run rnnchk( input clfilials.rnn,output v-rnn).
      if v-rnn then do :
        message "Введите БИН верно ! ". pause .
      end.
end.

open query q1 for each clfilials where clfilials.cif = s-cif.
end.

ON CHOOSE OF bdel IN FRAME fr1
do:
if yes-no ('', 'Вы действительно хотите удалить запись?') then do:
  find current clfilials exclusive-lock.
  delete clfilials.
  open query q1 for each clfilials where clfilials.cif = s-cif.
end.
end.

open query q1 for each clfilials where clfilials.cif = s-cif.


b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").

ENABLE all with frame fr1 centered overlay top-only.

apply "value-changed" to b1 in frame fr1.

WAIT-FOR WINDOW-CLOSE of frame fr1.

hide frame fr1.

