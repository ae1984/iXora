/* a_mescif.p
 * MODULE
        ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА
 * DESCRIPTION
        Дополнительная информация по клиентам
 * BASES

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        10/04/2013 Luiza ТЗ № 1515
 * CHANGES

*/

def shared var g-ofc as char.
define input parameter s-cif as char.

def var v-dt  as date no-undo.
def var v-rem  as char no-undo.
def var v-remold  as char no-undo.
def var v-ofc1 as char no-undo.
def var v-ofc2 as char no-undo.
def var v-rem1 as char no-undo.
def var v-rem2 as char no-undo.
def var v-rem3 as char no-undo.
def var v-rem4 as char no-undo.
def var v-rem5 as char no-undo.
def var v-rem6 as char no-undo.
def var v-rem7 as char no-undo.
def var vname as char no-undo.

def var v-dt2  as date no-undo.
def var vrem  as char no-undo.
def var vremold  as char no-undo.
def var v-rem21 as char no-undo.
def var v-rem22 as char no-undo.
def var v-rem23 as char no-undo.
def var v-rem24 as char no-undo.
def var v-rem25 as char no-undo.
def var v-rem26 as char no-undo.
def var v-rem27 as char no-undo.
def var v_title as char no-undo. /*наименование */
v_title = "ИНФОРМАЦИЯ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА ПРИ СЛЕДУЮЩЕЙ ВСТРЕЧЕ".

     Form
                      "                           ПОСТОЯННЫЕ ДАННЫЕ "   skip
        v-dt       label " Дата заполнения " format "99/99/99" skip
        v-ofc1     label " ФИО менеджера   " format "X(30)" skip(1)
        v-rem1     no-label colon 3 format "X(80)" skip
        v-rem2     no-label colon 3 format "X(80)" skip
        v-rem3     no-label colon 3 format "X(80)" skip
        v-rem4     no-label colon 3 format "X(80)" skip
        v-rem5     no-label colon 3 format "X(80)" skip
        v-rem6     no-label colon 3 format "X(80)" skip
        v-rem7     no-label colon 3 format "X(80)" skip(1)
                     "                            ПЕРЕМЕННЫЕ ДАННЫЕ "   skip
        v-dt2      label " Дата заполнения " format "99/99/99" skip
        v-ofc2      label " ФИО менеджера   " format "X(30)" skip(1)
        v-rem21     no-label colon 3 format "X(80)" skip
        v-rem22     no-label colon 3 format "X(80)" skip
        v-rem23     no-label colon 3 format "X(80)" skip
        v-rem24     no-label colon 3 format "X(80)" skip
        v-rem25     no-label colon 3 format "X(80)" skip
        v-rem26     no-label colon 3 format "X(80)" skip
        v-rem27     no-label colon 3 format "X(80)" skip(1)
    WITH  SIDE-LABELS  ROW 10 column 13 TITLE v_title overlay width 90 FRAME f_main.

find first cif where cif.cif = s-cif no-lock no-error.
v-rem = trim(cif.reschar[20]).
vname = trim(cif.prefix) + " " + trim(cif.name).
v-ofc1 = "".
v-dt = date(trim(cif.reschar[19])).
find first ofc where ofc.ofc = cif.reschar[18] no-lock no-error.
if available ofc then v-ofc1 = ofc.name.
v-rem1 = substring(v-rem,1,80).
v-rem2 = substring(v-rem,81,80).
v-rem3 = substring(v-rem,161,80).
v-rem4 = substring(v-rem,241,80).
v-rem5 = substring(v-rem,321,80).
v-rem6 = substring(v-rem,401,80).
v-rem7 = substring(v-rem,481,80).
displ v-dt v-ofc1 v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7 with frame f_main.
pause 0.

/* переменные данные */
vrem = trim(cif.reschar[17]).
vremold = trim(cif.reschar[17]).
v-ofc2 = "".
find first ofc where ofc.ofc = cif.reschar[15] no-lock no-error.
if available ofc then v-ofc2 = ofc.name.
v-rem21 = substring(vrem,1,80).
v-rem22 = substring(vrem,81,80).
v-rem23 = substring(vrem,161,80).
v-rem24 = substring(vrem,241,80).
v-rem25 = substring(vrem,321,80).
v-rem26 = substring(vrem,401,80).
v-rem27 = substring(vrem,481,80).
displ v-dt2 v-ofc2 v-rem21 v-rem22 v-rem23 v-rem24 v-rem25 v-rem26 v-rem27 with frame f_main.
pause .
hide frame f_main.

run mail(g-ofc + "@metrocombank.kz", g-ofc + "@metrocombank.kz", "Обновление информации о клиенте в закладке «Сообщение» в п.м.1.1.1.",
"Добрый день!\n\n Сегодня Вы обслуживали  " + vname  + " cif-код №  " + s-cif +
"\n необходимо обновить данные в закладке «Сообщение» в п.м.1.1.1.", "1", "","" ).
