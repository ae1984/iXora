/* find-rate1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Выводит курс валюты в теньге на заданный день
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
        19/09/2001 Alexander Mukhovikov
 * CHANGES
	24.01.2003 nadejda поставлен выбор - поиск по средневзвешенному или по НБ РК в истории курсов - поиск по дате whn заменен на ПРАВИЛЬНЫЙ поиск по rdt 
	06.08.2003 nadejda - поставлена после 01.08.2003 нацбанковского курсу вместо ср/взв, т.к. курсы теперь совпадают - для исправления косяка с неверным ср/взв курсом по евро за 01.08.2003
	06.01.2005 u00121  - отменил изменения от 06.08.2003 nadejda
*/


def input parameter  i-kind as integer.
def input parameter  i-crc  like ncrc.crc.
def input parameter  i-date as date.
def output parameter o-rate like ncrc.rate[1].

def var v-dtequal as date init 08/01/2003.

case i-kind:
  when 1 then do:
/*    if i-date < v-dtequal then do:*/
      find last crchis where crchis.crc = i-crc and crchis.rdt <= i-date no-lock no-error.
      if avail crchis then o-rate = crchis.rate[1]. 
                      else o-rate = 0.
/*
    end.
    else do:
      find last ncrchis where ncrchis.crc = i-crc and ncrchis.rdt <= i-date no-lock no-error.
      if avail ncrchis then o-rate = ncrchis.rate[1]. 
                       else o-rate = 0.
    end.
*/
  end.
  when 2 then do:
      find last ncrchis where ncrchis.crc = i-crc and ncrchis.rdt <= i-date no-lock no-error.
      if avail ncrchis then o-rate = ncrchis.rate[1]. 
                       else o-rate = 0.
  end.
end case.
