/* pkdefdtstr.p
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
        23.04.2008 alex - добавил параметр для казахского языка.
        19/01/2010 galina - поправила месяц январь на каз.языке
        20/01/2010 madiyar - переделал html-кодировку в нормальную
*/

/* pkdefadres.p   ПотребКРЕДИТ
   Определение строковой даты

   14.03.2003 nadejda
*/

def input parameter p-dt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz as char init
   "ќаѕтар,аќпан,наурыз,сјуiр,мамыр,маусым,шiлде,тамыз,ќыркїйек,ќазан,ќараша,желтоќсан".

p-datastr = trim(string(day(p-dt), ">9")) + " " +
                 entry(month(p-dt), v-monthname) + " " +
                 string(year(p-dt), "9999").

p-datastrkz = trim(string(day(p-dt), ">9")) + " " +
                 entry(month(p-dt), v-monthnamekz) + " " +
                 string(year(p-dt), "9999").