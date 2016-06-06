/* pkdoginf-5.p
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

/* pkdoginf-5.p ПотребКредит
   Дополнительные сведений для договоров по Путешествиям (s-credtype = "5")
   копия "Быстрых кредитов"

   10.06.2003 nadejda
*/


{global.i}
{pk.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln exclusive-lock no-error.

if not avail pkanketa then return.


{pk-sysc.i}

/* номера договоров и приложений
   1) договор банковского займа (кредитный)
   2) залоговый договор
   3) допсоглашение к кредитному договору по пене и штрафам
   4) номер приложения/допсоглашения - графика погашения
*/
pkanketa.rescha[1] = string(day(pkanketa.docdt), "99") + "/" + string(month(pkanketa.docdt), "99") + "-" + get-pksysc-char ("dogsym") + "/" + string(s-pkankln) + "," +
                     string(day(pkanketa.docdt), "99") + "/" + string(month(pkanketa.docdt), "99") + "-" + string(s-pkankln) + "/" + get-pksysc-char ("dogsym") + "," +
                     get-pksysc-char("dogsym") + "/" + string(s-pkankln) + "," +
                     "1".

find current pkanketa no-lock.
