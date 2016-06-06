/* crc-to-kzt1.p
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
*/

/* =============================================================== */
/*   KONVERTACIA VALUT V KZT, by Alexander Muhovikov, 18/09/2001   */
/* =============================================================== */
/* Comment:       c-from      - currency number "from"             */
/*                c-date      - convert date                       */
/*                v-from      - amount "from" value                */
/*                v-to        - output amount "to" value           */
/* Возьмет валюту с номером c-from, и пересчитает ее на теньге по  */
/* курсу на дату c-date; результат пересчета: v-to = v-from * курс */
/* =============================================================== */
/* 24.01.2003 nadejda 
              поставлен выбор - поиск по средневзвешенному или по НБ РК
              в истории курсов - поиск по дате whn заменен на ПРАВИЛЬНЫЙ поиск по rdt 
   06.08.2003 nadejda - поставлена выдача суммы после 01.08.2003 по нацбанковскому курсу вместо ср/взв, т.к. курсы теперь совпадают - для исправления косяка с неверным ср/взв курсом по евро за 01.08.2003
   08.04.2004 nadejda - увеличен формат сумм до 10 после запятой для избежания ошибок округления
   06.01.2005 u00121  - отменил изменения от 06.08.2003 nadejda
*/

def input parameter  i-kind as integer.
def input parameter        c-from    like ncrc.crc.
def input parameter        c-date    as date.
def input parameter        v-from    as decimal decimals 10 
                                     format "->>,>>>,>>>,>>>,>>9.99".
def output parameter       v-to      as decimal decimals 10
                                     format "->>,>>>,>>>,>>>,>>9.99".


def var v-dtequal as date init 08/01/2003.


/* Find crc for c-from */
case i-kind:
  when 1 then do:
/*    if c-date < v-dtequal then do:*/
      find last crchis where crchis.rdt <= c-date and crchis.crc = c-from no-lock no-error.
      if avail crchis then v-to = v-from * crchis.rate[1].
                      else v-to = 0.
/*    end.
    else do:
      find last ncrchis where ncrchis.rdt <= c-date and ncrchis.crc = c-from no-lock no-error.
      if avail ncrchis then v-to = v-from * ncrchis.rate[1].
                       else v-to = 0.
    end.
*/
  end.
  when 2 then do:
    find last ncrchis where ncrchis.rdt <= c-date and ncrchis.crc = c-from no-lock no-error.
    if avail ncrchis then v-to = v-from * ncrchis.rate[1].
                     else v-to = 0.
  end.
end case.


