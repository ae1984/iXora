/* obm_edit.p
 * MODULE
        Обменные операции
 * DESCRIPTION
        Настройка реестра купли-продажи валюты
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-11
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        21.08.2003 marinav - Добавилась кнопка для ввода номера распоряжения. (по просьбе Уральска)
        14/04/2008 madiyar - Не выбирались СП и валюта, исправил
        27/03/2009 madiyar - увеличил формат поля для ввода номера распоряжения
        30/04/2009 madiyar - ввод номера распоряжения - fill-in
        16.02.2012 Lyubov - увеличила размеры полей "Кассиры", "АДРЕС", уменьшила поле "КОД"
        20.02.2012 Lyubov - еще немного увеличила ширину, т.к. программа не откомпилировалась
        21.02.2012 Lyubov - программа снова не откомпилилась, поэтому указала ширишу фрейма f1
        07.03.2013 Lyubov - ТЗ 1756, увеличила формат поля page_num
*/

define variable t_depart like ppoint.depart.
define variable t_crc like crc.crc.
define variable t_numb as integer.
define variable t_numr like exch_lst.numr.

define query q1 for exch_lst, ppoint, crc scrolling.
define query q2 for ppoint scrolling.
define query q3 for crc scrolling.

define browse b1 query q1
       display name format 'x(25)' label 'Наименование'
               code  format 'x(3)' label 'Валюта'
               ofc_list format 'x(47)' label 'Кассиры'
               acc_list format 'x(1)' label 'N'
               page_num format '>>>>z' label 'Стр'

       enable ofc_list help "Для перемещения используйте CTRL+G CTRL+U" acc_list page_num with 10 down width 92 no-row-markers.

define browse bpoint query q2
       display ppoint.depart format '>>99' label 'КОД'
               ppoint.name label 'АДРЕС' format 'x(40)'  with 10 down width 51.

define browse bcrc query q3
       display crc.des crc.code with 10 down.

define button bt1 label "Добавить запись".
define button bt2 label "Выход".
define button bt3 label "Править суммы".
define button bt4 label "Удалить запись".
define button bt5 label "Номер распоряж".

define frame f1
       b1 skip
       bt1
       bt3
       bt4
       bt5
       bt2 with width 95.

define frame f2
       bpoint.

define frame f3
       exch_lst.bamt label "Сумма на начало дня"
       exch_lst.camt label "Текущая сумма"
       exch_lst.crc.


define frame f4
       bcrc.

define frame f5
       t_numr format "x(1000)" view-as fill-in size 78 by 1 label "Внесите номер распоряжения".


on leave of b1
do:
 /*  message "leaving las-vegas" view-as alert-box.*/
end.

on default-action of bpoint
do:
    t_depart = ppoint.depart.
    hide frame f2.
    apply -2 to bpoint.
    enable all with frame f4.
    wait-for endkey of bcrc focus bcrc in frame f4.
end.

on default-action of bcrc
do:
   t_crc = crc.crc.
   hide frame f4.
   apply -2 to bcrc.
   find exch_lst where exch_lst.depart = t_depart and exch_lst.crc = t_crc no-lock no-error.
   if avail(exch_lst)
      then
         do transaction:
             t_numb = integer(exch_lst.acc_list) + 1.
             create exch_lst.
             exch_lst.depart = t_depart.
             exch_lst.crc    = t_crc.
             exch_lst.acc_list = string(t_numb).
            /* message "Ошибка! Запись для данной валюты уже существует"
                   skip "Попробуйте отредактировать" view-as alert-box.*/
         end.
      else
        do transaction:
           create exch_lst.
           exch_lst.depart = t_depart.
           exch_lst.crc    = t_crc.
           exch_lst.acc_list = '1'.
        end.
   open query q1 for each exch_lst,
            each ppoint,
            each crc where exch_lst.depart = ppoint.depart and crc.crc = exch_lst.crc.

end.

on choose of bt1
do:
   open query q2 for each ppoint.
   enable all with frame f2.
   wait-for endkey of bpoint focus bpoint in frame f2.
end.

on choose of bt3
do:
  view frame f3.
  find current exch_lst exclusive-lock.
  update exch_lst.bamt exch_lst.camt exch_lst.crc with frame f3.
  find current exch_lst no-lock.
end.

on choose of bt5
do:
  view frame f5.
  find first exch_lst.
  t_numr = exch_lst.numr.
  update t_numr with frame f5.
  for each exch_lst.
     exch_lst.numr = t_numr.
  end.
end.

on choose of bt4
do:
  find current exch_lst exclusive-lock.
  delete exch_lst. /*message "vot te raz" view-as alert-box.*/
/*  find current exch_lst no-lock.*/
  open query q1 for each exch_lst,
            each ppoint,
            each crc where exch_lst.depart = ppoint.depart and crc.crc = exch_lst.crc.
end.

open query q1 for each exch_lst, each ppoint, each crc where exch_lst.depart = ppoint.depart and crc.crc = exch_lst.crc.

open query q2 for each ppoint.

open query q3 for each crc.

enable all with frame f1.

wait-for choose of bt2 or window-close of current-window.


