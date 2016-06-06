/* vc2hisct.p
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
        12/03/2008 galina - перекомпиляция в связи с изменением vccontrs.f
        09.01.2009 galina - перекомпиляция в связи с изменением vccontrs.f                                                                 
        30.12.2009 galina - перекомпиляция в связи с изменением vccontrs.f              
*/

/* vc2hisct.p Валютный контроль
  запись сообщения в таблицу истории контрактов
  06.11.2002 nadejda создан

*/

{vc.i}

def input parameter v-id like vccontrs.contract.
def input parameter v-msghis as char.

{vc-2his.i 
 &head = "vccthis"
 &head0 = "vccontrs"
 &headkey = "contract"
 &uplevel = "cif"
}


