/* r-cliAll.p
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

{mainhead.i}

find sysc where sysc.sysc matches 'clecod' no-lock no-error.
if sysc.chval matches '190501914' then run r-cli.  /*отчет по клиентам ГО*/
  else run r-cli2.  ./*отчет по клиентам филиала г.Астана */
                            /*п.п.8-12-3*/