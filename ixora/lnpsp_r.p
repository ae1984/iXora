/* chk-clnd_zlg1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Первичный мониторинг
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        02/03/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        01/09/2011 kapar - ТЗ 1125
*/

def var g-ofc as char.
def var g-lang as char.

def var v-title as char no-undo.
v-title = 'Филиалы по ссудному портфелю'.

def var v-ofc as char no-undo.


{jabrw.i
   &start     = " "
   &head      = "comm.txb"
   &headkey   = "txb"
   &index     = "txb"
   &formname  = "lnpsp_r"
   &framename = "long_r"
   &where     = " comm.txb.consolid = true "
   &addcon    = "false"
   &deletecon = "false"
   &prechoose = " message ' <F4> - выход,  <F5> - планы '. "
   &display   = " comm.txb.txb comm.txb.name "
   &highlight = " comm.txb.name "
   &postkey   = "if lastkey = keycode('F5') then run lnpspr(comm.txb.txb)."
   &end = "hide frame long_r."
}
