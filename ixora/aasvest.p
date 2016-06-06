/* aasvest.p
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
        15.08.2011 ruslan - изменил форму
        17.08.2011 ruslan - Добавил сообщение по отозванным спец инструкциям
*/

{mainhead.i}

DEFINE SHARED var p-ln LIKE aas_hist.ln.
DEFINE SHARED var p-aaa LIKE aas_hist.aaa.
DEFINE WORK-TABLE waas
            FIELD ttype as char
            field num as char format "x(10)"
            FIELD sum as deci.

FOR EACH aas_hist WHERE aas_hist.aaa = p-aaa and aas_hist.ln = p-ln NO-LOCK USE-INDEX aasprep:
    CREATE waas.
    if aas_hist.who <> "bankadm" and aas_hist.who <> "superman" then do:
            waas.ttype = "M".
        end.
        else do:
            waas.ttype = "A".
        end.
        if aas_hist.sta = 4 then do:
            waas.sum = aas_hist.fsum.
        end.
        else do:
            waas.sum = aas_hist.chkamt.
        end.
        if aas_hist.fnum <> "" then waas.num = aas_hist.fnum.
        else waas.num = aas_hist.docnum.
END.

{jabrw.i

&start     = " "
&head      = "aas_hist"
&headkey   = "aaa"
&index     = "aasview"

&formname  = "aasvest"
&framename = "aasvest"
&where     = "aas_hist.ln = p-ln AND aas_hist.aaa = p-aaa"

&prechoose =
" find first ofc where ofc.ofc = aas_hist.who no-lock no-error.
  if aas_hist.chgoper = 'A' then
     message 'Введена  [' ofc.name ',' aas_hist.chgdat ','
        STRING(aas_hist.chgtime, 'hh:mm:ss') ']   F4 - выход.'.
  else
  if aas_hist.chgoper = 'E' then
     message 'Изменена  [' ofc.name ',' aas_hist.chgdat ','
        STRING(aas_hist.chgtime, 'hh:mm:ss') ']   F4 - выход.'.
  else
  if aas_hist.chgoper = 'D' then
     message 'Удалена [' ofc.name ',' aas_hist.chgdat ','
        STRING(aas_hist.chgtime, 'hh:mm:ss') ']   F4 - Выход.'.
  if aas_hist.chgoper = 'O' then
     message 'Отозвана [' ofc.name ',' aas_hist.chgdat ','
        STRING(aas_hist.chgtime, 'hh:mm:ss') ']   F4 - Выход.'.

"

&predisplay =
" "

&display=
" waas.num waas.ttype aas_hist.regdt
     waas.sum aas_hist.payee
"


&highlight =
" waas.num waas.ttype aas_hist.regdt
     waas.sum aas_hist.payee
"




&addcon    = "false"
&deletecon = "false"



&precreate =
" "

&postadd =
" "


&predelete=
" "


&prevdelete=
" "



&postkey =
" "


&end = "hide frame aasvest."
}

hide message.
RELEASE aas.
