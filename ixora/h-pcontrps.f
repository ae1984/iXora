/* h-pcontrps.f
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
        26.01.2011 aigul - вывод ПС
*/

/* h-pcontrps.f Валютный контроль
   Форма к списку контрактов с поиском по паспорту сделки

   18.10.2002 nadejda создан
*/

def var v-cifname1 as char.
def var ps as char.
form
     ps format "x(15)"   label "ПАСПОРТ СДЕЛКИ"
     vccontrs.cif format "x(6)" label "КОДКЛ"
     v-cifname1 format "x(14)" label "КЛИЕНТ"
     vccontrs.ctnum format "x(17)" label "НОМЕР КОНТРАКТА"
     vccontrs.ctdate format "99/99/99"
     vccontrs.expimp label "EI"
     vccontrs.sts label "СТ" format "xx"
  with row 5 centered scroll 1 down overlay frame pcontract.





