/* h-pkpartner.p
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

/* h-pkpartner.p  ПотребКредиты
   Список предприятий-партнеров

   05.03.2003 nadejda
*/
{global.i}
{pk.i}

def var v-intext as logical format "да/нет".

find first codfr where codfr.codfr = "pkpartn" and codfr.code <> "msc" and codfr.name[5] = s-credtype no-lock no-error.

if not avail codfr then do:
  message skip " Нет доступных партнеров в списке!" skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

{itemlist.i 
       &file = "codfr"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &findadd = " v-intext = (codfr.name[4] = ''). "
       &where = " codfr.codfr = 'pkpartn' and codfr.code <> 'msc' and codfr.name[5] = s-credtype "
       &flddisp = "codfr.code FORMAT 'x(10)' LABEL 'СЧЕТ'
                   codfr.name[1] FORMAT 'x(45)' LABEL 'НАИМЕНОВАНИЕ ПРЕДПРИЯТИЯ-ПАРТНЕРА'
                   v-intext label 'ВНУТР?' " 
       &chkey = "code"
       &chtype = "string"
       &index  = "main" }

