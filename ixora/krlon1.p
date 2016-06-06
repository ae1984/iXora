/* krlon1.p
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
        28/12/2010 evseev - передача имени филиала
        17.10.2011 damir - заменил на r-brfilial.i
*/

def input parameter datums as date.
{r-brfilial.i &proc = "krlon2(input datums, comm.txb.info)"}
