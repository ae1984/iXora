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

def input parameter v_fid as int.

def var g-ofc as char.
def var g-lang as char.

def var v-title as char no-undo.
v-title = 'Планы по ссудному портфелю'.

def var v-ofc as char no-undo.

{jabrw.i
   &start     = " "
   &head      = "lnpsp"
   &headkey   = "fid"
   &index     = "lnpspfid"
   &formname  = "lnpspr"
   &framename = "longr"
   &where     = " lnpsp.fid = v_fid "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnpsp.fid = v_fid.
                  update lnpsp.pdt lnpsp.nsum with frame longr. "
   &prechoose = " message ' <F4> - выход,  <INS> - вставка '. "
   &postdisplay = " "
   &display   = "  lnpsp.pdt lnpsp.nsum "
   &highlight = " lnpsp.pdt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnpsp.pdt lnpsp.nsum with frame longr.
                end.
                "
   &end = "hide frame longr."
}
