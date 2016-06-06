/* trx-debcheck.i
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
        07/01/04 sasco проверка на то, чтобы не вводить счет-фактуру два раза на одного дебитора
        08/01/04 sasco проверка на существование всех таблиц
        08/01/04 sasco запрос на ввод счета-фактуры
        12/01/04 sasco коррекция запроса на ввод счета-фактуры
        13/01/04 sasco добавил обработку ссылки на время в таблице debc
        05/02/04 sasco переделал вызов debmon.p
        05/03/04 recompile
        11/03/04 sasco - добавил обработку профит-центра
        02/06/04 suchkov - добавил цифровые коды для срока дебитора
        16/08/2005 marinav добавлен фактический срок
        18.09.2006 u00600 - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
        27.11.2006 u00600 - по ТЗ ї 225 if vsub = 'ujo' and trxcode = 'vnb0002' then
*/

/* временные таблицы и переменные для обмена данными между процедурами */
define variable is-debetor as logical.
define variable v-grp like debls.grp init 0.
define variable v-ls like debls.ls init ?.
define variable v-refwhn like debop.refwhn.
define variable v-refjh like debop.refjh.
define variable v-reftime as integer.
define variable v-refost as decimal.
define variable v-ost like debop.ost.
define variable v-debfakt as logical.
define variable v-code as integer.

def var deb-f as logi init false no-undo.
def var l as integer init 0 no-undo.
def var c as integer init 1 no-undo.
def var m as integer init 0 no-undo.
def var sum as char no-undo. def var gl as char no-undo. def var arp as char no-undo.

/* ------------------------------------------- */

define frame getperiod
       month3.name   format 'x(40)' view-as text label "Дебитор" skip
       month3.period label "Cрок" 
                     validate (can-find (codfr where codfr.codfr = "debsrok" and codfr.code = month3.period)
                     or can-find (codfr where codfr.codfr = "debsrok" and codfr.name[2] = month3.period), 
                               "Неверный срок! Выберите из справочника (F2)")
       month3.attn label "Профит-центр" 
                     validate (can-find (codfr where codfr.codfr = "sproftcn" 
                               and codfr.code = month3.attn), 
                               "Неверный Профит-центр! Выберите из справочника (F2)") skip
       month3.fsrok label "Факт. срок " view-as editor size 50 by 3 skip(1)
       with row 5 centered overlay side-labels .

/* suchkov - Triggers */
on "return" of month3.period in frame getperiod do:
    v-code = integer (month3.period:screen-value) no-error .

    if v-code > 0 then do:
        find codfr where codfr.codfr = 'debsrok' and codfr.name[2] = string(v-code,"9") no-lock no-error .
        if available codfr then assign
            month3.period = codfr.code
            month3.period:screen-value = codfr.code.
        else do:
            message "Ошибочный код!!!".
            pause 2.
            month3.period:screen-value = month3.period.
        end.
    end.
end.

/* =========================================== */
is-debetor = no.
v-debfakt = yes.

/* ------------------------------------------- */

for each tmpl no-lock where tmpl.amt > 0:

for each debgrp no-lock:

    if debgrp.arp = tmpl.dracc or debgrp.arp = tmpl.cracc then
    do:

       find arp where arp.arp = debgrp.arp no-lock no-error.
       if avail arp then
       do:

            v-grp = debgrp.grp.
            is-debetor = yes.

            /* проверим, был ли уже такой счет АРП (группа дебиторов) */
            find first dtmp where dtmp.grp = v-grp no-error.
            if not available dtmp then 
            do:

               v-ls = ?.
               /*u00600 11/07/2006*/
                  find first remdeb where remdeb.remtrz = vhref no-lock no-error.
                  if avail remdeb and (remdeb.grp <> 0 and remdeb.ls <> 0) then do: deb-f = true. v-ls = integer(remdeb.ls). end.

               /*u00600 01/08/2006 по автоматич.списанию дебиторов по расходам будущих периодов TZ 225*/
               if vsub = 'ujo' and trxcode = 'vnb0002' then do:
                 do l = 1 to LENGTH(vparam):
                   if SUBSTRING(vparam,l,1) = '|' then do:
                     m = m + 1.
                     if m = 1 then sum = trim(substring(vparam,c,l - 1)) .
                     if m = 3 then gl = substring(vparam,c,6) .
                     if m = 4 then arp = substring(vparam,c,9) .
                     c = l + 1.
                   end.
                 end.
               end. 

               if sum <> ""  and gl <> "" and arp <> "" then do:
                 find first debujo where debujo.gl = integer(gl) and debujo.arp = arp and debujo.amt-m = decimal(sum) no-lock no-error.
                 if avail debujo then do: deb-f = true. v-ls = debujo.ls. end.
               end. /*закрыла до подписания акта*/

               if is-debetor and deb-f = false then run trx-debcheck (input v-grp, output v-ls).

               if v-ls = ? or v-ls = 0 or not (can-find (debls where debls.grp = v-grp and debls.ls = v-ls))
                             then do: message "Отмена проводки!" view-as alert-box title "".
                                 rcode = 1.
                                 rdes = "Ошибка! Не выбран дебитор!".
                                 return.
                             end.

            end.
  
            find debls where debls.grp = v-grp and debls.ls = v-ls no-lock.

            /* таблица - был ли запрос на срок дебитора */
            find month3 where month3.grp = v-grp and month3.ls = v-ls no-lock no-error.
            if not avail month3 then do:
               create month3.
               assign month3.grp = v-grp
                      month3.ls = v-ls
                      month3.period = ""
                      month3.asked = no
                      month3.name = debls.name
                      month3.attn = "".
            end.

            create dtmp.
            assign dtmp.grp = v-grp
                   dtmp.ls = v-ls
                   dtmp.name = debls.name
                   dtmp.ost = debls.amt
                   dtmp.rem[1] = trim(tmpl.rem[1]) + trim(tmpl.rem[2])
                   dtmp.rem[2] = trim(tmpl.rem[3]) + trim(tmpl.rem[4])
                   dtmp.rem[3] = trim(tmpl.rem[5]).

            if debls.state <> 1 then dtmp.re-open = yes.
                                else dtmp.re-open = no.

            find first gl where gl.gl = arp.gl no-lock no-error.
            if gl.type = "A" or gl.type = "E" then dtmp.active = yes.
                                              else dtmp.active = no.

            /* ДЕБЕТ */
            if debgrp.arp = tmpl.dracc then do:
               if dtmp.active then assign dtmp.dam = 0 dtmp.cam = tmpl.amt.                
                              else assign dtmp.dam = tmpl.amt dtmp.cam = 0.
            end.

            /* КРЕДИТ */
            if debgrp.arp = tmpl.cracc then do:
               if dtmp.active then assign dtmp.dam = tmpl.amt dtmp.cam = 0.
                              else assign dtmp.dam = 0 dtmp.cam = tmpl.amt.
            end.

            /* увеличим итоговую сумму для списания, если есть */
            find deb-dam where deb-dam.grp = v-grp and deb-dam.ls = v-ls no-error.
            if not available deb-dam then do:
               create deb-dam.
               deb-dam.grp = v-grp.
               deb-dam.ls = v-ls.
            end.

            deb-dam.dam = deb-dam.dam + dtmp.dam.
            if dtmp.ost - deb-dam.dam < 0 then do:
               message "Не могу списать сумму " deb-dam.dam "~nС дебитора " month3.grp " : " month3.ls 
                       "~n(" + month3.name + ")" view-as alert-box title ' '.
               rcode = 1.
               rdes = "Не могу списать с " + debgrp.arp + "! Остаток уйдет в минус!".
               return.
            end.

            /* Обработка списания - выбор незакрытой суммы прихода */
            if deb-dam.dam > 0 then do:
               
               run trx-deblist (v-grp, v-ls, output v-refwhn, output v-refjh, output v-reftime, output v-refost).

               if v-refwhn = ? or v-refjh = ? or v-refjh = 0 then do:
                  message "Ошибка выбора суммы для списания!" v-refwhn v-refjh view-as alert-box title ''.
                  rcode = 2.
                  rdes = "Ошибка выбора суммы для списания из списка приходов!".
                  return.
               end.
                    /* обработаем ссылку на приход */
               else do:

                    assign dtmp.refwhn = v-refwhn
                           dtmp.refjh = v-refjh.
                    
                    /* остаток несписанной суммы за выбранный приход */
                    find debc where debc.grp = v-grp and
                                    debc.ls = v-ls and
                                    debc.date = v-refwhn and
                                    debc.jh = v-refjh and
                                    debc.ctime = v-reftime
                                    no-error.
                    if not available debc then do:
                       find debop where debop.grp = v-grp and 
                                        debop.ls = v-ls and
                                        debop.type = 1 and
                                        debop.closed = no and
                                        debop.date = v-refwhn and
                                        debop.jh = v-refjh and
                                        debop.ctime = v-reftime and
                                        debop.ost = v-refost
                                        no-lock no-error.
                       if not available debop then do:
                          message "Не нашел debop для " v-refwhn v-refjh v-refost v-reftime.
                          message "Не могу списать сумму с~n" + month3.name + "~nне найдена запись в debop!" view-as alert-box title ''.
                          rcode = 5.
                          rdes = "Не найдена запись в debop!".
                          return.
                       end.
                       /* создадим запись со списываемой суммой с прихода */
                       create debc.
                       assign debc.grp = v-grp
                              debc.ls = v-ls
                              debc.date = v-refwhn
                              debc.ctime = v-reftime
                              debc.cdt = ?
                              debc.jh = v-refjh
                              debc.ost = debop.ost
                              debc.closed = no
                              debc.period = debop.period.
                    end.
                    debc.ost = debc.ost - dtmp.dam.
                    /* проверим остаток суммы (за выбранный приход) */
                    if debc.ost < 0 then do:
                       message "Не могу списать сумму " dtmp.dam "~nза дату " + string (debc.date) + "~nС дебитора " month3.grp " : " month3.ls 
                       "~n(" + month3.name + ")" view-as alert-box title ' '.
                       rcode = 3.
                       rdes = "Ошибка выбора суммы для списания! Недостаточно денег".
                       return.
                    end.

                    /* статус "закрытой" суммы */
                    if debc.ost = 0 then assign debc.closed = yes
                                                debc.cdt = g-today.


               end. /* обработка ссылки на приход */
       
            end. /* обработка списания */

            /* проставим признак для срока 3 месяцев для прихода */
            if dtmp.cam > 0 then do:

/*16/08/2005 marinav - факт срок*/
               if avail month3 and not month3.asked then do:

                  update month3.name 
                         month3.period 
                         month3.attn
                         month3.fsrok
                         with frame getperiod.
                  hide frame getperiod.
               end.

            end. /* признак 3 месяцев */

       end. /* avail ARP */
    end. /* DRacc or CRacc */
end. /* debGrp */
end. /* tmpl */


dt-time = time.

/* пересмотр сумм - дебет/кредит - чтобы был ТОЛЬКО дебет или ТОЛЬКО кредит */
for each dtmp:
    if dtmp.dam > dtmp.cam then  assign dtmp.dam = dtmp.dam - dtmp.cam   dtmp.cam = 0.0.
    if dtmp.cam > dtmp.dam then  assign dtmp.cam = dtmp.cam - dtmp.dam   dtmp.dam = 0.0.
end.

v-debfakt = no.
IF is-debetor then do:

find first dtmp where dtmp.dam > 0 no-error.
if avail dtmp then message "Будем вводить данные по счету-фактуре?" update v-debfakt view-as alert-box message buttons yes-no title "".

/* заполним список по счету-фактуре для списания */
for each dtmp:
   if dtmp.dam > 0 and v-debfakt then do:
      /* поищем уже существующую счет-фактуру... */
      find first tmon where tmon.grp = dtmp.grp and tmon.ls = dtmp.ls no-lock no-error.
      /* если не нашли, то введем данные по счету-фактуре */
      if not available tmon then 
      do:
         run debmon (v-grp, v-ls, ?, ?, 0, g-today, dt-time, (if arp.crc = 1 then yes else no), dtmp.dam).
         if return-value <> "yes" then do:
            message "Ошибка ввода данных по счету-фактуре!" view-as alert-box title ''.
            rcode = 4.
            rdes = "Ошибка ввода данных по счету-фактуре!".
            return.
         end.
         v-debfakt = no. /* если уже ввели данные по счету-фактуре, то больше вводить на надо */
      end.
   end.
end.

end.


