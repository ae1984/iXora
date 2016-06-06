/* chk_clnd.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Формирование календарей-графиков проведения проверок фин-хоз деятельности заемщиков и залогового обеспечения
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
       09/07/2004 madiyar
 * CHANGES
       23/12/2005 Natalya D. - добавила пункт "Проверка целевого использования кредита"
       28/12/2005 Natalya D. - добавила пункт "Проверка сроков действия страховки"
       13/01/2006 Natalya D. - добавила отображение даты открытия кредита для некоторых групп кредитов в
                               пункте "Проверка целевого использования кредита"
       16/05/2006 Natalya D. - добавила пункты 5,6,7 (комиссии)
       12/09/2006 Natalya D. - добавила пункт "Проверка сроков действия депозита"
       26/01/2011 madiyar - убрал три проверки, добавил проверку решения КК, расширенный мониторинг
       29/01/2011 madiyar - явно указал ширину фрейма
       14/02/2011 madiyar - в lnmoncln.pwho пишется id ответственного менеджера и не редактируется
       03/03/2011 madiyar - добавил первичный мониторинг, сделал разветвления
       04/03/2011 madiyar - исправления
       18/07/2011 kapar - ТЗ 948
       14/06/2013 galina - ТЗ1552
       14/06/2013 yerganat - tz1804, добавил заметки с типом remarkdmo
       04/10/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" отключение мониторинга залогов через пункт верхнего меню
*/

{global.i}

def shared var s-lon like lon.lon.

def var v-sel as char.
def var mcode as char.
def var v-title as char.


/*find first lon where lon.lon = s-lon no-lock.*/


/*run sel2 (" Выбор: ", " 1. Первичный мониторинг | 2. Текущий мониторинг | 3. Расширенный мониторинг | 4. Проверка залогового обеспечения | 5. Проверка целевого использования кредита | 6. Проверка сроков действия страховки | 7. Проверка сроков действия депозита | 8. Проверка решения КК | 9. Заметки ДМО | 10.Выход ", output v-sel).*/
run sel2 (" Выбор: ", " 1. Первичный мониторинг | 2. Текущий мониторинг | 3. Расширенный мониторинг | 4. Проверка целевого использования кредита | 5. Проверка сроков действия страховки | 6. Проверка сроков действия депозита | 7. Проверка решения КК | 8. Заметки ДМО | 9.Выход ", output v-sel).
case v-sel:
  when '1' then do:
    mcode   = 'mon1'.
    v-title = " Первичный мониторинг ".
  end.
  when '2' then do:
    mcode   = 'fin-hoz'.
    v-title = " Текущий мониторинг ".
  end.
  when '3' then do:
    mcode   = 'extmon'.
    v-title = " Расширенный мониторинг ".
  end.
  /*
  when '4' then do:
    mcode   = 'zalog'.
    v-title = " Проверка залогового обеспечения ".
  end.
  */
  when '4' then do:
    mcode   = 'purpose'.
    v-title = " Проверка целевого использования кредита ".
  end.
  when '5' then do:
    mcode   = 'insur'.
    v-title = " Проверка сроков действия страховки ".
  end.
  when '6' then do:
    mcode   = 'deposit'.
    v-title = " Комиссия за предоставление бизнес-кредитов ".
  end.
  when '7' then do:
    mcode   = 'kkres'.
    v-title = " Проверка решения КК ".
  end.
  when '8' then do:
    mcode   = 'remarkdmo'.
    v-title = " Заметки ДМО ".
  end.
  otherwise return.
end case.

if (mcode = "mon1") then run chk-clnd_mon1(mcode,v-title).
else
if (mcode = "fin-hoz") or (mcode = "extmon") then run chk-clnd_fhmon(mcode,v-title).
else
if (mcode = "purpose") then run chk-clnd_purp(mcode,v-title).
else
if (mcode = "zalog") then run chk-clnd_zlg(mcode,v-title).
else run chk-clnd_std(mcode,v-title).

hide message.

