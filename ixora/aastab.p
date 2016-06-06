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
        suchkov - Оптимизировал поиск специнструкций
        15.08.2011 - ruslan изменил параметры вывода, разделил на удаленные и текущие
        17.08.2011 ruslan - добавил aas_hist.chgoper = "O" для удаленных
        25/08/2011 evseev - прописал статус Х
        02/02/2012 evseev - в list1 добавил 5
*/

{global.i }



define frame frbud
   aas_hist.aaa label     "Номер счета.           " skip
   aas_hist.regdt label   "Дата регистрации       " skip
   aas_hist.docprim format "x(20)" label  "Сумма                  " validate(decimal(aas.docprim) <> 0, "Введите сумму оплаты ") skip
   aas_hist.fnum  format "x(21)"  label    "Номер инк. распоряжения" skip
   aas_hist.docdat label  "Дата инк. распоряжения." skip
   aas_hist.bnf    format "x(50)"label  "Налог комитет(F2-поиск)" validate(aas.bnf <> "", "Введите название налогового комитета (F2-поиск)") skip
   aas_hist.dpname format "x(12)" label  "РНН налогового комитета" validate(aas.dpname <> "", "Введите РНН налогового комитета ") skip
   aas_hist.docnum format "x(2)" label   "Вид операции           " skip
   aas_hist.payee  /*aas.docprim*/ label "Примечание             " skip
   aas_hist.kbk label     "КБК" validate(aas.kbk <> "", "Введите КБК ")
   aas_hist.knp label     "      КНП" validate(aas.knp <> "", "Введите КНП ")
with side-labels centered row 6.

define frame frproch
   aas_hist.aaa label     "Номер счета.           " skip
   aas_hist.regdt label   "Дата регистрации       " skip
   aas_hist.docprim format "x(15)" label  "Сумма                  "  validate(decimal(aas.docprim) <> 0, "Введите сумму ") skip
   aas_hist.fnum format "x(30)"  label    "Номер инк. распоряжения" skip
   aas_hist.docdat label  "Дата инк. распоряжения."                  skip
   aas_hist.bnfname format "x(30)" label  "Бенефициар             "  skip
   aas_hist.rnnben  format "x(12)" label  "РНН  бенефициара       "  skip
   aas_hist.bicben   format "x(20)" label "БИК  бенефициара       "  skip
   aas_hist.bankben  format "x(20)" label "Банк бенефициара       "  skip
   aas_hist.iikben  format "x(20)" label  "ИИК  бенефициара       "  skip
   aas_hist.knp label                     "КНП                    " validate(aas.knp <> "", "Введите КНП ")
   aas_hist.payee                 label   "Примечание             "  skip
with side-labels centered row 6.

define var pr as logi.
    message 'O - действующие С - удаленные'.
    readkey.
    if keyfunction(lastkey) = 'O' then
     do:
       pr = false.
     end.
    else if keyfunction(lastkey) = 'C' then
     DO:
        pr = true.
     end.

DEFINE buffer b-aas FOR aas.
define buffer b-aas-hist for aas_hist.
DEFINE NEW SHARED var p-ln LIKE aas_hist.ln.
DEFINE NEW SHARED VAR p-aaa LIKE aas_hist.aaa.
DEFINE SHARED VAR s-aaa LIKE aas_hist.aaa.
define var list1 as char init "4,5,9".

DEFINE WORK-TABLE waas
            FIELD aas_h_recid AS RECID
            FIELD deleted as LOGICAL
            FIELD ttype as char
            field ln like aas_hist.ln
            field num as char format "x(10)"
            FIELD sum as deci.
p-aaa = ''.
p-ln = 0.
FOR EACH aas_hist WHERE aas_hist.aaa = s-aaa and (aas_hist.chgoper = "D" or aas_hist.chgoper = "O" or aas_hist.chgoper = "X") NO-LOCK break by aas_hist.regdt descending : /*USE-INDEX aasprep    - suchkov - закомментировал для скорости */
  IF (aas_hist.aaa <> p-aaa) OR (aas_hist.ln <> p-ln) THEN
  DO TRANSACTION:
    p-aaa = aas_hist.aaa.
    p-ln = aas_hist.ln.
    CREATE waas.
    waas.aas_h_recid= RECID(aas_hist).
                waas.deleted = TRUE.
                waas.ln = aas_hist.ln.
                if aas_hist.who <> "bankadm" and aas_hist.who <> "superman" then do:
                        waas.ttype = "M".
                end.
                else do:
                    waas.ttype = "A".
                end.
                if lookup(string(aas_hist.sta),list1) <> 0 then do:
                    waas.sum = aas_hist.fsum.
                end.
                else do:
                    waas.sum = aas_hist.chkamt.
                end.
                if aas_hist.fnum <> "" then waas.num = aas_hist.fnum.
                if aas_hist.fnum <> "" then waas.num = aas_hist.fnum.
                else waas.num = aas_hist.docnum.
  END.
END.
FOR EACH aas_hist WHERE aas_hist.aaa = s-aaa and (aas_hist.chgoper <> "D" or aas_hist.chgoper <> "O" or aas_hist.chgoper <> "X") NO-LOCK break by aas_hist.regdt descending : /*USE-INDEX aasprep    - suchkov - закомментировал для скорости */
  IF (aas_hist.aaa <> p-aaa) OR (aas_hist.ln <> p-ln) THEN
  DO TRANSACTION:
    p-aaa = aas_hist.aaa.
    p-ln = aas_hist.ln.
    find first waas where waas.ln = aas_hist.ln no-lock no-error.
        if avail waas then next.
        else do:
        CREATE waas.
        waas.aas_h_recid= RECID(aas_hist).
                    waas.deleted = FALSE.
                    waas.ln = aas_hist.ln.
                    if aas_hist.who <> "bankadm" and aas_hist.who <> "superman" then do:
                            waas.ttype = "M".
                    end.
                    else do:
                        waas.ttype = "A".
                    end.
                    if lookup(string(aas_hist.sta),list1) <> 0 then do:
                        waas.sum = aas_hist.fsum.
                    end.
                    else do:
                        waas.sum = aas_hist.chkamt.
                    end.
                 if aas_hist.fnum <> "" then waas.num = aas_hist.fnum.
                else waas.num = aas_hist.docnum.
    end.
  END.
END.


{jabre.i
  &start     = " "
  &head      = "waas"
  &where     = "waas.deleted = pr"
  &headkey   = "aas_h_recid"
  &formname  = "aas2"
  &framename = "aas2"
&prechoose =
" if waas.deleted = TRUE then
     message '[Удалена]    RETURN - история, TAB - вернуться F-Доп Инфо(для ИнкРаспоряжений)'.
  else
     message '             RETURN - история, TAB - вернуться F-Доп Инфо(для ИнкРаспоряжений)'. "

  &predisplay =
  " find aas_hist where recid(aas_hist) = waas.aas_h_recid and waas.deleted = pr no-lock no-error."
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
       find first aas_hist where recid(aas_hist) = waas.aas_h_recid  no-lock no-error.
       p-ln = aas_hist.ln.
       p-aaa = aas_hist.aaa.

       RUN aasvest.
       view frame aas2.
    end.
    else if keyfunction(lastkey) = 'TAB' then
     DO:
        leave upper.
     end.
    else if keyfunction(lastkey) = 'F' then
    do:
       find first aas_hist where recid(aas_hist) = waas.aas_h_recid no-lock no-error.
       if avail aas_hist then do:
          if lookup(string(aas_hist.sta),'4,5,6,8') <> 0 then do:
             displ aas_hist.aaa aas_hist.payee aas_hist.regdt aas_hist.docprim aas_hist.fnum aas_hist.docdat aas_hist.bnf aas_hist.dpname aas_hist.docnum aas_hist.payee aas_hist.kbk aas_hist.knp with frame frbud.
             hide frame frbud.
             view frame aas2.
          end.
          if lookup(string(aas_hist.sta),'9,15') <> 0 then do:
             displ aas_hist.aaa aas_hist.regdt aas_hist.docprim aas_hist.fnum aas_hist.docdat aas_hist.bnfname aas_hist.rnnben aas_hist.bicben aas_hist.bankben aas_hist.iikben aas_hist.knp aas_hist.payee with frame frproch.
             hide frame frbud.
             view frame aas2.
          end.

       end.
       view frame aas2.
    end.
"
  &end = "hide frame aas2."
  }
HIDE MESSAGE.
