/* debset.p
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
        24/12/03 sasco добавил редактирование РНН, страны, номера св-ва постановки на учет по НДС
        06/01/04 sasco Добавил ввод остатков по периодам
        06/01/04 sasco Добавил усовершенствованный ввод остатков по периодам
        08/01/04 sasco Исправил время добавления суммы debop
        13/01/04 sasco ПЕРЕКОМПИЛЯЦИЯ
        14/01/04 sasco Добавил редактирование остатков по срокам
        12/03/04 sasco Добавил редактирование названия дебитора
        31/03/04 sasco исправил ввод страны нерезидента
        20/04/04 sasco Исправил удаление карточки дебитора (чтобы менялось debop и debmon)
        01/06/06 u00600 занесение дебитора в архив
        15/08/06 u00600 оптимизация
        18/09/06 u00600 вывод полей iik bik kbe gl code-R code-dep np - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
        27/11/06 u00600 ТЗ ї225
        13.12.07 marinav - увеличила формы .
        04.12.09   marinav - добавились поля debls.acc bic
        29.04.2011 marinav - проверка на ИИН БИН
        04/04/2013 Luiza - ТЗ 1743 добавление поля БИН головной организации
        07/10/2013 Luiza - *ТЗ 1956
        08/10/2013 Luiza - перекомпиляция
*/



{comm-rnn.i}
/* для использования BIN */
{chk12_innbin.i}
{chbin.i}


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


{comm-txb.i}
{yes-no.i}
{debls.f}

def var help_l1 as char init "<F1> - создать дебитора"  label "" format "x(24)".
def var help_l2 as char init "<F8> - удалить дебитора" label "" format "x(24)".
def var help_l3 as char init "<TAB> - перейти к другому окну <ENTER> - редактировать <F2>-сроки <DEL>-архив" label "" format "x(78)".

def var help_g1 as char init "<F1> - создать группу  " label "" format "x(24)".
def var help_g2 as char init "<F8> - удалить группу  " label "" format "x(24)".
def var help_g3 as char init "<TAB> - перейти к другому окну  <СТРЕЛКА ВПРАВО> - обновить список" label "" format "x(78)".

define variable v-countnum as character format 'x(3)' label "Код страны".

def shared var g-today as date.
def shared var g-ofc as char.

def var cnt as int.

def var lastgrp as int init 1.
def var lastls as int.

def query  q1 for debgrp.
def browse b1 query q1
           displ debgrp.grp format ">>9"
                 debgrp.des format "x(32)"
           with 15 down no-label title "Группы".


def query  q2 for debls.
def browse b2 query q2
           displ debls.ls
                 debls.name
           with 27 down no-label title "Дебиторы".

def frame fmain
          b1   at x 1   y 1 help " "
          b2   at x 340 y 1 help " "
          debgrp.arp        at x 8 y  142 label "АРП" view-as text    /*y 74*/
          debls.created     at x 8 y  150 label "Создан" view-as text /*y 82*/
          debls.last_opened at x 8 y  158 label "Открыт" view-as text /*y 90*/
          debls.last_closed at x 8 y  166 label "Закрыт" view-as text /*y 98*/
          debls.amt         at x 8 y  174 label "Сумма"  view-as text /*y 106*/
          debls.rnn         at x 8 y 182 label "РНН/БИН"  view-as text   /*y 114*/
          debls.acc         at x 8 y 190 label "ИИК"  view-as text   /*y 122*/
/*u00600 23/06/06*/
          debls.bic         at x 8 y 198 label "БИК" view-as text    /*y 130*/
          debls.kbe         at x 8 y 206 label "КБЕ" view-as text /*y 138*/

          /*"_________________________" at x 8 y 130 view-as text*/
          "_________________________" at x 8 y 214 view-as text

          with row 2 column 2 side-labels no-box with size 90 by 35 .

def frame get_ls
          b-ls.grp  view-as text
          v-dat at x 224 y 1
                validate (v-dat le g-today, "Дата не может быть больше опердня!")
                label "Дата открытия"
                skip
          b-ls.ls   view-as text skip
          b-ls.name validate (trim(b-ls.name) <> "", "Введите не пустую строку!")
                    label "Назв. дебитора"
          b-ls.amt  validate (b-ls.amt > 0, "Не верная сумма!")
          with row 7 centered overlay side-labels 1 column color messages.

define frame getsernum
       debls.name format "x(50)" label "Наименование" validate (debls.name <> "", "Введите наименование!")
       debls.rnn format "x(12)" label "РНН/БИН"
                 validate (debls.rnn = "" or (debls.rnn <> "" and not checkRNN (debls.rnn)), "Неправильный номер !")
       debls.ser format "x(5)" label "Серия св-ва"
                 validate (debls.ser = '' or length(debls.ser) = 5, "Длина серии св-ва должна быть 5 символов!")
       debls.num format "x(7)" label "Номер св-ва"
                 validate (debls.num = '' or length(debls.num) = 7, "Длина номера св-ва должна быть 7 символов!")

/*u00600 23/06/06*/

       debls.acc  label "ИИК"
       debls.bic  label "БИК"
       debls.bingo  label "БИН головной орг"
       debls.kbe format "x(4)" label "КБЕ"
       debls.gl  format "zzzzz9" label "счет ГК"
       debls.code-R format "x(8)" label "код расходов"
       debls.code-dep format "x(8)" label "код деп-та"
       debls.np format "x(8)" label "назнач. платежа"

       with row 3 centered 1 column side-labels overlay title "Постановка на учет по НДС".

define frame getsernum2
       debls.name format "x(50)" label "Наименование" validate (debls.name <> "", "Введите наименование!")
       v-countnum
       with row 3 centered 1 column side-labels overlay title "Дебитор - нерезидент".


def frame get_grp
          b-grp.grp  view-as text
          b-grp.des validate (trim(b-grp.des) <> "", "Введите не пустую строку!")
          b-grp.arp validate (can-find (arp where arp.arp = b-grp.arp), "Не найден счет АРП!")
          with row 7 centered overlay side-labels 1 column color messages.


/* обновление списка дебиторов на правой панели */
on "cursor-right" of browse b1 do:
   close query q2.
   open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0 and debls.sts ne 'C' no-lock   /*debls.sts ne 'C' u00600*/
                 use-index ls.
   if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
   browse b2:refresh().
   lastgrp = debgrp.grp.
end.


/* переход на панель дебиторов */
on "tab" of browse b1 do:
   if avail debgrp then do:
   if lastgrp <> debgrp.grp then do:
      lastgrp = debgrp.grp.
      close query q2.
      open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0 and debls.sts ne 'C' no-lock /*debls.sts ne 'C' u00600*/
                    use-index ls.
      if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
      browse b2:refresh().
   end.
   if avail debls then displ debls.amt debls.created debls.last_opened debls.last_closed
                             debls.rnn debls.acc  debls.bic debls.kbe with frame fmain. else
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc ? @ debls.bic ? @ debls.kbe with frame fmain.
   displ help_l1 at x 8 y 222 view-as text no-label  /*y 138*/
         help_l2 at x 8 y 230 view-as text no-label  /*y 146*/
         help_l3 at x 8 y 238 view-as text no-label  /*y 152*/
         with frame fmain.
   end.
end.

/* переход на панель групп */
on "tab" of browse b2 do:
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc ? @ debls.bic ? @ debls.kbe
         help_g1 at x 8 y 222 view-as text no-label /*y 138*/
         help_g2 at x 8 y 230 view-as text no-label /*y 146*/
         help_g3 at x 8 y 238 view-as text no-label /*y 152*/
         with frame fmain.
end.

/* обновление сведений о карточке дебитора - даты и суммы */
on value-changed of browse b2 do:
   if avail debls then displ debls.amt debls.created debls.last_opened debls.last_closed
                             debls.rnn debls.acc debls.rnn debls.acc debls.bic debls.kbe with frame fmain.
   else
   displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed
         ? @ debls.rnn ? @ debls.acc ? @ debls.bic ? @ debls.kbe with frame fmain.
end.


/* обновление сведений о группе дебиторов - АРП */
on value-changed of browse b1 do:
   if avail debgrp then displ debgrp.arp with frame fmain.
   else displ ? @ debgrp.arp with frame fmain.
end.


define variable v-maxost as decimal. /* максимальный остаток */
define variable v-ost as decimal. /* текущий остаток */
define variable v-dtost as date. /* дата прихода */
define variable v-period like debop.period.

v-dtost = g-today.

define frame fost
             v-ost format "z,zzz,zzz,zz9.99" label "Введите остаток" validate (v-ost > 0 and v-ost <= v-maxost, "Неправильный остаток!")
             v-dtost label "Дата прихода" validate (v-dtost <= today, "Введите правильную дату!")
             v-period label "Введите период" validate (v-period <> 'msc' and
                      can-find(codfr where codfr.codfr = "debsrok" and codfr.code = v-period), "Введите период!" )
             with row 5 centered overlay 1 column title "Ввод нового остатка".

/* сроки дебиторов */
on "help" of browse b2 do:
   if not available debls then leave.

/*
   v-maxost = debls.amt.
   v-ost = debls.amt.

   for each debop where debop.grp = debls.grp and
                        debop.ls = debls.ls and
                        debop.type = 1 and
                        debop.closed = no and
                        debop.ost > 0
                        no-lock:
       v-ost = v-ost - debop.ost.
       v-maxost = v-maxost - debop.ost.
   end.

   if v-ost <= 0 then do:
      message "Нет сумм для ввода остатков по периодам!" view-as alert-box title ''.
      leave.
   end.

   if not yes-no ("", "Добавить остаток?") then leave.

   update v-ost v-dtost v-period with frame fost.

   find first debhis where debhis.grp = debls.grp and debhis.ls = debls.ls and debhis.date = v-dtost and
                           debhis.amt >= v-ost and debhis.type < 3 no-lock no-error.

   if not available debhis then do:
      message "Нет могу найти приход по дебитору за " v-dtost view-as alert-box title ''.
      leave.
   end.

   if not yes-no ("", "Добавить сумму " + trim(string(v-ost, "zzz,zzz,zz9.99")) + "?") then leave.

   create debop.
   assign debop.date = v-dtost
          debop.ctime = debhis.ctime
          debop.grp = debls.grp
          debop.ls = debls.ls
          debop.amt = v-ost
          debop.ost = v-ost
          debop.closed = no
          debop.who = debhis.ofc
          debop.cdt = ?
          debop.type = 1
          debop.period = v-period
          debop.jh = debhis.jh
          .
*/

    for each debop where debop.grp = debls.grp and debop.ls = debls.ls and not debop.closed and debop.date < 01/14/04 no-lock break by debop.jh:

        if first-of (debop.jh) then do:
        find codfr where codfr.codfr = "debsrok" and codfr.code = debop.period no-lock no-error.
        find last debhis where debhis.grp = debop.grp and debhis.ls = debop.ls and
                  debhis.jh = debop.jh and debhis.date < 01/14/04 no-error.
             if debhis.dactive <> ? then next.
             displ debhis.date label "Дата проводки"
                   debhis.jh label "Номер проводки"
                   debhis.amt label "Сумма проводки"
                   debop.type label "1-прих,2-спис"
                   debhis.ost label "Остаток на карточке"
                   codfr.name [1] label "Срок"
                   with row 3 centered overlay 1 column title "Операция" frame ddd.
             message "Корректировать остаток?" update ch as logical.
             if ch then do:
                update debhis.djh = debop.jh.
                update debhis.dost format "zzzzzzzzzz9.99" label "Остаток" with frame ddd1.
                if debhis.dost = 0.0 then debhis.dactive = no.
                                     else debhis.dactive = yes.
                debhis.dwhn = debhis.date.
                debhis.dtime = debop.ctime.
             end.
        end.
    end.
    hide frame ddd.
    hide frame ddd1.

end.

/* создание нового дебитора */
on "go" of browse b2 do:
/* if comm-cod() <> 1 and comm-cod() <> 2 then */
message "Нельзя создать дебитора!~nКарточка создается во время проводки " view-as alert-box title "".
/*
if not avail debgrp then message "Не могу создать карточку для пустой группы!" view-as alert-box title "".
else do:
   cnt = 0.
   for each b-ls where b-ls.grp = debgrp.grp and b-ls.ls ne 0 no-lock:
      cnt = cnt + 1.
   end.

   v-dat = g-today.
   update v-dat with frame get_ls.

   create b-ls.
   assign b-ls.grp = debgrp.grp
          b-ls.ls = cnt + 1
          b-ls.created = v-dat
          b-ls.last_closed = ?
          b-ls.last_opened = v-dat
          b-ls.state = 1.

   update b-ls.grp b-ls.ls b-ls.name b-ls.amt b-ls.rnn b-ls.iik with frame get_ls.
   hide frame get_ls.

   update v-rem with frame get-rem.

   hide frame get-rem.

   create debhis.
   assign debhis.grp   = b-ls.grp
          debhis.ls    = b-ls.ls
          debhis.date  = v-dat
          debhis.ofc   = g-ofc
          debhis.type  = 1
          debhis.amt   = b-ls.amt
          debhis.ost   = b-ls.amt
          debhis.iik    = b-ls.iik
          debhis.rem[1] = v-rem[1]
          debhis.rem[2] = v-rem[2]
          debhis.rem[3] = v-rem[3].

   find first debls where debls.grp = debgr.grp and debls.ls ne 0 no-lock no-error.
   if avail debls then displ debls.amt debls.created debls.last_opened debls.last_closed
                             debls.rnn debls.iik with frame fmain.

   close query q2.
   open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0 no-lock
                 use-index ls.
   if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
   browse b2:refresh().
end.
*/
end.

/* редактирование карточки дебитора */
on "return" of browse b2 do:
    if not available debls then leave.
    find arp where arp.arp = debgrp.arp no-lock no-error.
    find current debls no-error.
    v-countnum = debls.country.
    /* редактируем только резидентов */
    if arp.crc = 1 then do:
       update debls.name
              debls.rnn
              debls.ser
              debls.num

/*u00600 23/06/06*/
              debls.acc
              debls.bic
              debls.bingo
              debls.kbe
/*u00600 26/07/06*/
              debls.gl
              debls.code-R
              debls.code-dep
              debls.np

              with frame getsernum.
       hide frame getsernum.
    end.
    else do:
       update debls.name
              v-countnum
              with frame getsernum2.
       hide frame getsernum2.
       debls.country = v-countnum.
    end.
    find current debls no-lock no-error.
    v-countnum = ''.
end.

/* создание новой группы */
on "go" of browse b1 do:
   cnt = 0.
   /*for each b-grp where b-grp.grp > 0 no-lock use-index grp.
      cnt = cnt + 1.
   end.*/
   find last b-grp no-lock use-index grp.
   if available b-grp then cnt = b-grp.grp + 1.
   create b-grp.
   assign b-grp.grp = cnt + 1.

   create debls.
   assign debls.grp = b-grp.grp
          debls.ls = 0
          debls.state = 0
          debls.name = "<ВСЕ ДЕБИТОРЫ>".

   update b-grp.grp b-grp.des b-grp.arp with frame get_grp.
   hide frame get_grp.

   close query q1.
   open query q1 for each debgrp where debgrp.grp ne 0 no-lock.
   if can-find (first debls where debls.grp = b-grp.grp and debls.ls ne 0) then
   browse b2:refresh().
end.

/*u00600 - занесение дебитора в архив, клавиша DELETE*/
on "DELETE-CHARACTER" of browse b2 do:

find current debls no-error.
  if avail debls then do:
    if yes-no ("Занесение в архив","Вы уверены?") then debls.sts = 'C'.
    /*debls.sts = 'C'. занесение в поле sts признака С (Closed) если в архивe*/
    release debls.
  end.
close query q2.
open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0  and debls.sts ne 'C' no-lock    /*debls.sts ne 'C'*/
     use-index ls.
if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
browse b2:refresh().
end.

/* удаление группы, если нет дебиторов */
on "clear" of browse b1 do:
   if not avail debgrp then message "Не могу удалить пустую запись!"
                           view-as alert-box.
   else
   if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
               message "Не могу удалить! В этой группе есть дебиторы!"
               view-as alert-box.
   else if yes-no ("Удаление записи","Вы уверены?") then do:
        find current debgrp.
        delete debgrp.
        close query q1.
        open query q1 for each debgrp where debgrp.grp ne 0 no-lock.
        if can-find (first debgrp) then browse b1:refresh().
   end.

end.


/* удаление дебитора, если не было движений */
on "clear" of browse b2 do:
   if not avail debls then message "Не могу удалить пустую запись!"
                           view-as alert-box.
   else
   if can-find (first debhis where debhis.grp = debls.grp and
                                   debhis.ls = debls.ls and
                                   debhis.type <> 1) then
               message "Не могу удалить! По этому дебитору уже были движения!"
               view-as alert-box.
   else if yes-no ("Удаление записи","Вы уверены?") then do:
       /* удалим дебитора */
       find current debls no-error.
            lastls = debls.ls.
            delete debls.
       /* удалим историю (т.е. 1 запись об его создании) */
       find debhis where debhis.grp = debgrp.grp and debhis.ls = lastls no-error.
       if avail debhis then delete debhis.
       /* перенумеруем всех последователей */
       /* (1) debls   */
       for each b-ls where b-ls.grp = debgrp.grp and b-ls.ls >= lastls:
           b-ls.ls = b-ls.ls - 1.
           end.
       /* (2) debhis  */
       for each debhis where debhis.grp = debgrp.grp and debhis.ls >= lastls:
           debhis.ls = debhis.ls - 1.
           end.
       /* (3) debtemp */
       for each debtemp where debtemp.grp = debgrp.grp and debtemp.ls >= lastls:
           debtemp.ls = debtemp.ls - 1.
           end.
       /* (4) debop */
       for each debop where debop.grp = debgrp.grp and debop.ls >= lastls:
           debop.ls = debop.ls - 1.
           end.
       /* (5) debmon */
       for each debmon where debmon.grp = debgrp.grp and debmon.ls >= lastls:
           debmon.ls = debmon.ls - 1.
           end.

       close query q2.
       open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0  no-lock
                     use-index ls.
       if can-find (first debls where debls.grp = debgrp.grp and debls.ls ne 0) then
       browse b2:refresh().

   end.
end.

open query q1 for each debgrp where debgrp.grp ne 0 no-lock.
open query q2 for each debls where debls.grp = debgrp.grp and debls.ls ne 0 and debls.sts ne 'C' no-lock   /*debls.sts ne 'C' u00600*/
                  use-index ls.
enable all with frame fmain.

if avail debgrp then displ debgrp.arp with frame fmain.
                else displ ? @ debgrp.arp with frame fmain.

displ ? @ debls.amt ? @ debls.created ? @ debls.last_opened ? @ debls.last_closed ? @ debls.rnn ? @ debls.acc ? @ debls.bic
      ? @ debls.kbe
      help_g1 at x 8 y 222 view-as text no-label  /*y 138*/
      help_g2 at x 8 y 230 view-as text no-label  /*y 146*/
      help_g3 at x 8 y 238 view-as text no-label  /*y 152*/
      with frame fmain.

{wait.i}
