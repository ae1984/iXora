/* vc2hisrslc.p
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
  запись сообщения в таблицу истории регсв/лицензий

  06.11.2002 nadejda создан

*/

{vc.i}

def input parameter v-id like vcrslc.rslc.
def input parameter v-msghis as char.

{vc-2his.i 
 &head = "vcrslchis"
 &head0 = "vcrslc"
 &headkey = "rslc"
 &uplevel = "contract"
}


