/* aasall.p
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
        15.08.2011 ruslan - добавил поля в waas для отображения специнструкций по тз 1039
        17.08.2011 ruslan - добавил aas_hist.chgoper = "O" для удаленных
*/

{global.i }

DEFINE buffer b-aas FOR aas.
DEFINE NEW SHARED var p-ln LIKE aas_hist.ln.
DEFINE NEW SHARED VAR p-aaa LIKE aas_hist.aaa.
DEFINE SHARED VAR s-aaa LIKE aas_hist.aaa.
DEFINE WORK-TABLE waas
            FIELD aas_h_recid AS RECID
            FIELD deleted as LOGICAL
            FIELD ttype as char
            field num as char format "x(10)"
            FIELD sum as deci.
p-aaa = ''.
p-ln = 0.
FOR EACH aas_hist WHERE aas_hist.aaa = s-aaa NO-LOCK USE-INDEX aasprep:
  IF (aas_hist.aaa <> p-aaa) OR (aas_hist.ln <> p-ln) THEN
  DO TRANSACTION:
    p-aaa = aas_hist.aaa.
    p-ln = aas_hist.ln.
    CREATE waas.
    waas.aas_h_recid= RECID(aas_hist).
    if aas_hist.chgoper = "D" or aas_hist.chgoper = "O" then waas.deleted = TRUE.
    else waas.deleted = FALSE.
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
END.

{jabre.i
  &start     = " "
  &head      = "waas"
  &headkey   = "aas_h_recid"
  &formname  = "aas2"
  &framename = "aas2"
&prechoose =
" if waas.deleted = TRUE then
     message '[Удалена]    RETURN - история, TAB - вернуться'.
  else
     message '             RETURN - история, TAB - вернуться'. "

  &predisplay =
  " find aas_hist where recid(aas_hist) = waas.aas_h_recid no-lock."
  &display=
  " waas.num     label 'Номер'
    waas.ttype    label 'Тип'
    aas_hist.regdt  label 'Дата'
    waas.sum format '->>>,>>>,>>>,>>9.99' label 'Сумма'
    aas_hist.payee  label 'Основание'  "
  &highlight =
  " waas.num waas.ttype aas_hist.regdt
       waas.sum aas_hist.payee"
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
  " else if keyfunction(lastkey) = 'RETURN' then
     do:
       find first aas_hist where recid(aas_hist) = waas.aas_h_recid no-lock.
       p-ln = aas_hist.ln.
       p-aaa = aas_hist.aaa.

       RUN aasvest.
       view frame aas2.
    end.

    else if keyfunction(lastkey) = 'TAB' then
     DO:
        leave upper.
     end.
"
  &end = "hide frame aas2."
  }
HIDE MESSAGE.
