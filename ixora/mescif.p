/* mescif.p
 * MODULE
        вкладка сообщение в карточке клиента
 * DESCRIPTION
        Дополнительная информация по клиентам
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        10/04/2013 Luiza ТЗ № 1515
 * CHANGES
            18/04/2013 - Luiza перекомпиляция из-за размеров формы detpay
*/


{mainhead.i}

def shared var s-cif like cif.cif.
def var v-dt   as date no-undo.
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
def var v-ja as logic  no-undo format "Да/Нет" init yes.
def var v-ja2 as logic  no-undo format "Да/Нет" init yes.
def var v_title as char no-undo. /*наименование */
def  var vj-label as char no-undo.
v_title = "ЗАПОЛНИТЕ ИНФОРМАЦИЮ О КЛИЕНТЕ ДЛЯ УСТАНОВЛЕНИЯ КОНТАКТА ПРИ СЛЕДУЮЩЕЙ ВСТРЕЧЕ".

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
        v-rem7     no-label colon 3 format "X(80)" skip
        v-ja       label "Сохранить?........." skip(1)
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
        v-ja2       label "Сохранить?........."  skip

    WITH  SIDE-LABELS  ROW 10 column 13 TITLE v_title overlay width 90 FRAME f_main.

form
     v-rem no-label VIEW-AS EDITOR SIZE 60 by 6
     with frame detpay width 80 row 15 overlay centered title "Информация" .
form
     vrem no-label VIEW-AS EDITOR SIZE 60 by 6
     with frame detpay2 width 80 row 28 overlay centered title "Информация" .

on "END-ERROR" of frame f_main do:
    hide frame f_main.
    hide frame detpay.
    hide frame detpay2.
    return.
end.

find first cif where cif.cif = s-cif no-lock no-error.
v-rem = trim(cif.reschar[20]).
v-remold = trim(cif.reschar[20]).
v-ofc1 = "".
if trim(cif.reschar[19]) = "" then v-dt = today.
else v-dt = date(trim(cif.reschar[19])).
if trim(cif.reschar[18]) = "" then do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.  /*cif.reschar[18].*/
    if available ofc then v-ofc1 = ofc.name.
end.
else do:
    find first ofc where ofc.ofc = cif.reschar[18]no-lock no-error.
    if available ofc then v-ofc1 = ofc.name.
end.
displ v-dt v-ofc1 with frame f_main.
pause 0.
repeat:
    update v-rem go-on("return") with frame detpay.
    if length(v-rem) > 480 then message 'Примечание превышает 480 символов!'.
    else leave.
end.
if keyfunction (lastkey) = "end-error" then do:
    hide frame f_main.
    hide frame detpay.
    hide frame detpay2.
    return.
end.
v-rem1 = substring(v-rem,1,80).
v-rem2 = substring(v-rem,81,80).
v-rem3 = substring(v-rem,161,80).
v-rem4 = substring(v-rem,241,80).
v-rem5 = substring(v-rem,321,80).
v-rem6 = substring(v-rem,401,80).
v-rem7 = substring(v-rem,481,80).
displ  v-rem1 v-rem2 v-rem3 v-rem4 v-rem5 v-rem6 v-rem7 with frame f_main.
pause 0.
if trim(v-rem) <> trim(v-remold) then do:
    v-ja = yes.
    update v-ja with frame f_main.
    if v-ja then do:
        find first cif where cif.cif = s-cif exclusive-lock no-error.
        cif.reschar[20] = v-rem.
        cif.reschar[19] = string(today).
        cif.reschar[18] = g-ofc.
        find first cif where cif.cif = s-cif no-lock no-error.
    end.
end.
hide frame detpay.

/* переменные данные */
vrem = trim(cif.reschar[17]).
vremold = trim(cif.reschar[17]).
v-ofc2 = "".
if trim(cif.reschar[16]) = "" then v-dt2 = today.
else v-dt2 = date(trim(cif.reschar[16])).
if trim(cif.reschar[15]) = "" then do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if available ofc then v-ofc2 = ofc.name.
end.
else do:
    find first ofc where ofc.ofc = cif.reschar[15] no-lock no-error.
    if available ofc then v-ofc2 = ofc.name.
end.
displ v-dt2 v-ofc2 with frame f_main.
pause 0.
repeat:
    update vrem go-on("return") with frame detpay2.
    if length(vrem) > 480 then message 'Примечание превышает 480 символов!'.
    else leave.
end.
if keyfunction (lastkey) = "end-error" then do:
    hide frame f_main.
    hide frame detpay.
    hide frame detpay2.
    return.
end.
v-rem21 = substring(vrem,1,80).
v-rem22 = substring(vrem,81,80).
v-rem23 = substring(vrem,161,80).
v-rem24 = substring(vrem,241,80).
v-rem25 = substring(vrem,321,80).
v-rem26 = substring(vrem,401,80).
v-rem27 = substring(vrem,481,80).
displ  v-rem21 v-rem22 v-rem23 v-rem24 v-rem25 v-rem26 v-rem27 with frame f_main.
pause 0.
if trim(vrem) <> trim(vremold) then do:
    v-ja2 = yes.
    update v-ja2 with frame f_main.
    if v-ja2 then do:
        find first cif where cif.cif = s-cif exclusive-lock no-error.
        cif.reschar[17] = vrem.
        cif.reschar[16] = string(today).
        cif.reschar[15] = g-ofc.
        find first cif where cif.cif = s-cif no-lock no-error.
    end.
end.
hide frame detpay.
hide frame detpay2.
hide frame f_main.


