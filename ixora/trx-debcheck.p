/* trx-debcheck.p
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
        07/01/04 sasco исправил проверку на резидента/нерезидента
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        05/03/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        01/06/06 u00600 проверка нового дебитора по РНН с введенными ранее
        01/06/06 u00600 проверка введенного дебитора на архив
        04.12.09   marinav - добавились поля debls.acc bic
        18/11/2011 evseev  - переход на ИИН/БИН
        05/03/2012 Luiza  - если нерезидент в РНН проставляем "-" (добавила условие v-rnn = "-" or)
*/

{chbin.i}
{comm-rnn.i}

{chk12_innbin.i}

function checkRNN returns logical (cRNN as char).
    define variable cc as character.
    define variable ii as int.

    cc = trim (cRNN).
    do ii = 1 to length (cc):
       /* любое число, чтобы была ошибка */
       if lookup (substring(cc, ii, 1), "0,1,2,3,4,5,6,7,8,9") = 0 then return true.
    end.

    if v-bin = yes then return not chk12_innbin(cRNN).
                   else return comm-rnn (cRNN).
end function.

/* check for debetors` ARP */
define input parameter v-grp as int.
define output parameter v-ls as int.

define shared var g-today as date.

define var v-descr like debls.name label "Наименование".
define button dbut1 label "Выбрать".
define button dbut2 label "Новый".
define button dbut3 label "Отмена".
define var old-ls like debls.ls.
define var v-name like debls.name.
define variable v-rnn as character format 'x(12)' /*label "РНН"*/.
define variable v-countnum as character format 'x(3)' label "Код страны".

define frame get-debls
             v-ls label "Введите номер дебитора (F2 - выбор)"
             validate (can-find(debls where debls.grp = v-grp and debls.ls = v-ls
                       and v-ls ne 0 no-lock) or v-ls = ?, "Дебитор не найден! Создайте нового или повторите ввод!")
             skip
             v-descr view-as text skip
             dbut1 dbut2 dbut3
             with row 5 centered side-labels overlay.

on help of v-ls in frame get-debls do: run help-debls (v-grp, false).
                                       v-ls:screen-value = return-value.
                                       v-ls = int(v-ls:screen-value).
                                   end.

on value-changed of v-ls in frame get-debls do:
   find debls where debls.grp = v-grp and debls.ls = integer(v-ls:screen-value) no-lock no-error.

   if avail debls and debls.ls ne 0 and debls.sts = 'C' then do:
     message "Дебитор неактивен!" view-as alert-box buttons ok title "" . v-descr = "". end.
   if avail debls and debls.ls ne 0 and debls.sts = "" then v-descr = debls.name.
   else v-descr = "".

 /*было -   if avail debls and debls.ls ne 0 then v-descr = debls.name.
   else v-descr = "". */

   displ v-descr with frame get-debls.

end.

v-ls = ?.

/* выбрать дебитора */
on choose of dbut1 in frame get-debls do:
   v-ls = integer (v-ls:screen-value).
   apply "go" to frame get-debls.
end.


/* создать нового дебитора */
on choose of dbut2 in frame get-debls do:

   define frame get-debR
       v-ls label "ID" view-as text skip
       v-name label "Наименование" validate (trim(v-name) <> "", "Название не может быть пустой строкой!") skip
       v-rnn label "РНН" validate (v-rnn = "-" or (v-rnn <> "" and not checkRNN (v-rnn)), "Неправильный код РНН!")
       with side-labels centered row 5 overlay title "Дебитор - резидент".
   define frame get-debR1
       v-ls label "ID" view-as text skip
       v-name label "Наименование" validate (trim(v-name) <> "", "Название не может быть пустой строкой!") skip
       v-rnn label "ИИН/БИН" validate (v-rnn = "-" or (v-rnn <> "" and not checkRNN (v-rnn)), "Неправильный код ИИН/БИН!")
       with side-labels centered row 5 overlay title "Дебитор - резидент".

   define frame get-debN
       v-ls label "ID" view-as text skip
       v-name label "Наименование" validate (trim(v-name) <> "", "Название не может быть пустой строкой!") skip
       v-countnum
       with side-labels centered row 5 overlay title "Дебитор - нерезидент".

   find last debls where debls.grp = v-grp no-lock no-error.
   if not avail debls then old-ls = 0.
                      else old-ls = debls.ls.

   find debgrp where debgrp.grp = v-grp no-lock no-error.
   find arp where arp.arp = debgrp.arp no-lock no-error.

   v-ls = old-ls + 1.

   if arp.crc = 1 then do:
                 if v-bin then update v-ls v-name v-rnn with frame get-debR1.
                 else update v-ls v-name v-rnn with frame get-debR. /* РЕЗИДЕНТ */
                          find first debls where debls.grp = v-grp and debls.rnn = v-rnn no-lock no-error. /*u00600 проверка на существующего с аналогичным РНН дебитора*/
                          if avail debls then do:
                             if v-bin then message 'Дебитор с ИИН/БИН ' + v-rnn + ' в группе ' + string(v-grp) + ' существует. Номер - ' + string(debls.ls) VIEW-AS ALERT-BOX.
                             else message 'Дебитор с РНН ' + v-rnn + ' в группе ' + string(v-grp) + ' существует. Номер - ' + string(debls.ls) VIEW-AS ALERT-BOX.
                          end.

                           hide frame get-debR.
                           hide frame get-debR1.
                       end.
                  else do: update v-ls v-name v-countnum with frame get-debN. /* НЕРЕЗИДЕНТ */
                           hide frame get-debN.
                       end.

   create debls.
   assign debls.grp = v-grp
          debls.ls = v-ls
          debls.name = v-name
          debls.bic = ""
          debls.state = 0
          debls.created = g-today
          debls.last_opened = ?
          debls.last_closed = ?
          debls.amt = 0.0
          debls.estimated_date = ?
          debls.profit = ?
          debls.rnn = v-rnn
          debls.country = v-countnum.
    release debls.

    v-ls:screen-value in frame get-debls = string(v-ls).
    apply "value-changed" to v-ls in frame get-debls.

end.

/* отменить и выйти из редактирования */
on choose of dbut3 in frame get-debls do:
   v-ls:screen-value = ?.
   v-ls = ?.
   displ v-ls with frame get-debls.
   apply "go" to frame get-debls.
end.


/* - - - - - - - ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ - - - - - -*/

enable all with frame get-debls.
pause 0.

update v-ls with frame get-debls
editing:
        readkey.
        apply lastkey.
        if frame-field = "v-ls" then apply "value-changed" to v-ls in frame get-debls.
end.

hide frame get-debls.

/* - - - - - - - - - - - КОНЕЦ - - - - - - - - - - -*/

