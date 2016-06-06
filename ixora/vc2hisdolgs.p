/* vc2hisdolgs.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        запись сообщения в таблицу истории документов
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
        24/06/04 saltanat
 * CHANGES
*/

{vc.i}

def input parameter v-id like vcdolgs.dolgs.
def input parameter v-msghis as char.


{vc-2his.i 
 &head = "vcdolgshis"
 &head0 = "vcdolgs"
 &headkey = "dolgs"
 &uplevel = "contract"
}
