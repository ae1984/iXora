/* vc2hisdocs.p
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

/* vc2hisct.p Валютный контроль
  запись сообщения в таблицу истории документов

  06.11.2002 nadejda создан

*/

{vc.i}

def input parameter v-id like vcdocs.docs.
def input parameter v-msghis as char.

{vc-2his.i 
 &head = "vcdocshis"
 &head0 = "vcdocs"
 &headkey = "docs"
 &uplevel = "contract"
}


