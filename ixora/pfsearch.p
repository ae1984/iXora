/* pfsearch.p
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
     14/04/2006 u00600 - в соответствии ТЗ ї240 от 10.02.06
*/

/* ---------------------------------- */
/* sasco - search of pension payments */
/* 23.10.2002                         */
/* ---------------------------------- */
{yes-no.i}
{comm-txb.i}

def shared var g-today as date.

def var v-rnn as char format 'x(12)' no-undo.
def var v-d1 as date no-undo.
def var v-d2 as date no-undo.
def var v-s1 as decimal format "z,zzz,zzz,zz9.99" no-undo.
def var v-s2 as decimal format "z,zzz,zzz,zz9.99" no-undo.
def var seltxb as int no-undo.

def temp-table dates no-undo field dat as date index dates is primary dat.
def var v-d as date no-undo.

seltxb = comm-cod().

v-rnn = ?.
v-d1 = g-today.
v-d2 = g-today.
v-s1 = 0.
v-s2 = 999999999.

def temp-table wrk like p_f_payment
                   field rid as char
                   field pf as char
                   index ind is primary date dnum.

update v-rnn label "Введите РНН" skip
       v-d1 label "Период с..." 
       v-d2 label "по..." 
/*       validate (v-d1 <= v-d2, "Конец периода не может быть раньше начала!") */ skip
       v-s1 label "Сумма с..." v-s2 label "по..." 
       with row 5 centered side-labels 
       title "Поиск пенсионных платежей"
       frame getrnnfr.
       
hide frame getrnnfr.

if v-rnn <> ? then
   for each p_f_payment where p_f_payment.rnn = v-rnn no-lock use-index rnn:
       if p_f_payment.date ge v-d1 and p_f_payment.date le v-d2 then
       if p_f_payment.amt ge v-s1 and p_f_payment.amt le v-s2 then 
       do:
find first p_f_list where p_f_list.rnn = p_f_payment.distr no-lock no-error. 
           create wrk.
           buffer-copy p_f_payment to wrk.
           assign  
           wrk.rid = string ( rowid (p_f_payment) ).
           wrk.pf  = p_f_list.name.   /*24/03/06 u00600 - Пенсионный фонд*/
       end.
   end.
else do:
   do v-d = v-d1 to v-d2:
      for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-d no-lock use-index datenum:
          if p_f_payment.amt ge v-s1 and p_f_payment.amt le v-s2 then 
          do:
find first p_f_list where p_f_list.rnn = p_f_payment.distr no-lock no-error.
              create wrk.
              buffer-copy p_f_payment to wrk.
              assign 
              wrk.rid = string ( rowid (p_f_payment) ).
              wrk.pf  = p_f_list.name.  /*24/03/06 u00600 - Пенсионный фонд*/
          end.
      end.
   end.
end.
 
define query q1 for wrk.
define browse b1 query q1 
              displ wrk.dnum format "zzzzzzz9" label "N док"
                    wrk.rnn format "x(8)" label "РНН"
                    wrk.name format "x(6)" label "Ф.И.О."  /*24/03/06 u00600*/ 
                    wrk.cod format "zz9" label "Код"
                    wrk.amt format "zzz,zzz,zz9.99" label "Сумма"   /*"zzz,zzz,zz9.99"*/
                    wrk.comis format "zz,zz9.99" column-label "Ком." /*24/03/06 u00600*/ 
                 /*   wrk.date format "99/99/99" label "Дата"*/
                    wrk.qty format "z9" label "Кол" column-label "Кол"
                    wrk.uid format "x(5)" label "Кассир"
                    wrk.pf format "x(5)" label "Наим.ПФ" /*24/03/06 u00600*/
              with 14 down.
 
define frame f1 b1 help "Нажмите ENTER для распечатки квитанции"
       with row 1 centered no-label title "Пенсионные платежи с " + string (v-d1) + " по " + string (v-d2).  

on value-changed of b1
do:                          
  DISPLAY wrk.dnum format "zzzzzzz9" wrk.rnn format "x(12)" wrk.name format "x(30)" wrk.cod format "zz9" wrk.amt format "zzz,zzz,zz9.99" wrk.comis format "zz,zz9.99" wrk.date format "99/99/99" wrk.qty format "z9" wrk.uid format "x(6)" wrk.pf format "x(45)" WITH FRAME f1.
end. 

on "return" of browse b1
do:
 if avail wrk then if yes-no ("", "Распечатать квитанцию?") then run p_f_kvit (input wrk.rid).
end.
              
open query q1 for each wrk no-lock.
apply "value-changed" to browse b1.
enable all with frame f1.

wait-for window-close of current-window.

                                     