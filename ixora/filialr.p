/* filialr.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Закладка в п.м. 1.2 "Филиалы" для внесения данных по филиалам клиента
 * RUN
        Вверхнее меню CIFSUBOT
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2
 * AUTHOR
        16.06.2005 saltanat
 * BASES
        BANK COMM
 * CHANGES
        22/08/08 marinav - по физикам записыватся старая фамилия при изменении, поэтому - другие лейблы
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

find first cif where cif.cif = s-cif no-lock no-error.

DEFINE QUERY q1 FOR clfilials.
DEFINE QUERY q2 FOR clfilials.


    def browse b1
    query q1
    displ
        clfilials.namefil     label 'Внесенные изменения      ' format 'x(25)'
        clfilials.forma_sobst label 'Логин                    ' format 'x(25)'
        clfilials.rnn         label 'Дата                     ' format 'x(12)'
    with 12 down title ' История изменений реквизитов '.

    def browse b2
    query q2
    displ
        clfilials.namefil     label 'Найменование филиала     ' format 'x(25)'
        clfilials.forma_sobst label 'Орган.форма собственности' format 'x(25)'
        clfilials.rnn         label 'БИН                      ' format 'x(12)'
    with 12 down title ' Филиалы '.




DEFINE BUTTON bloo LABEL "LOOK".
DEFINE BUTTON bext LABEL "Выход".

def frame fr1
     b1 skip
     bloo
     bext with centered overlay row 1 top-only.

def frame fr2
     b2 skip
     bloo
     bext with centered overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

ON CHOOSE OF bext IN FRAME fr2
do:
   hide frame getlist1.
   APPLY "WINDOW-CLOSE" TO BROWSE b2.
end.

ON CHOOSE OF bloo IN FRAME fr1
do:
     displ
         skip(1)
         clfilials.namefil     label 'Внесенные изменения      ' format 'x(45)' skip
         clfilials.forma_sobst label 'Логин                    ' format 'x(45)' skip
         clfilials.rnn         label 'Дата                     ' format 'x(12)' skip(1)
     with frame fr centered row 5 overlay top-only side-label col 5 title ' История изменений реквизитов '.
end.

ON CHOOSE OF bloo IN FRAME fr2
do:
     displ
         skip(1)
         clfilials.namefil     label 'Найменование филиала     ' format 'x(45)' skip
         clfilials.forma_sobst label 'Орган.форма собственности' format 'x(45)' skip
         clfilials.rnn         label 'БИН                      ' format 'x(12)' skip(1)
     with frame fr centered row 5 overlay top-only side-label col 5 title ' Филиалы '.
end.

if avail cif and cif.type = 'P' then do:
   open query q1 for each clfilials where clfilials.cif = s-cif.
   b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
   ENABLE all with frame fr1 centered overlay top-only.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR WINDOW-CLOSE of frame fr1.
   hide frame fr1.
end.
else do:
   open query q2 for each clfilials where clfilials.cif = s-cif.
   b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
   ENABLE all with frame fr2 centered overlay top-only.
   apply "value-changed" to b2 in frame fr2.
   WAIT-FOR WINDOW-CLOSE of frame fr2.
   hide frame fr2.
end.

