/* cif-nnr.p
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

def var v-taxpay as log.
def shared var s-cif like cif.cif.
find cif where cif.cif = s-cif.
v-taxpay =
substring(cif.lgr,1,1) eq "Y" .
display
"Клиент платит налоги как нерезидент ? "
v-taxpay
    with frame a row 12 centered no-label .
pause.
/*
if keyfunction(lastkey) eq "END-ERROR" then return.
if v-taxpay then substring(cif.lgr,1,1) = "Y" .
            else substring(cif.lgr,1,1) = "N" .
*/
