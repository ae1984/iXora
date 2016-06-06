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
        18/07/2011 kapar - ТЗ 948
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def input parameter mpdt as date no-undo.
def var v-title as char no-undo.
v-title = 'Стоимость в результате переоценки'.

def var v-ofc as char no-undo.

find first loncon where loncon.lon = s-lon no-lock no-error.
if avail loncon then v-ofc = loncon.pase-pier.
else v-ofc = g-ofc.

{jabrw.i
   &start     = " "
   &head      = "lnmonsrp"
   &headkey   = "num"
   &index     = "lncodespr"
   &formname  = "chk-clnd_zlg1"
   &framename = "longr1"
   &where     = " lnmonsrp.lon = s-lon and lnmonsrp.pdt = mpdt "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnmonsrp.lon = s-lon. lnmonsrp.pdt = mpdt.
                update lnmonsrp.num lnmonsrp.zname lnmonsrp.crc lnmonsrp.nsum with frame longr1.
                "
   &prechoose = " message ' F4 - Выход '. "
   &postdisplay = " "
   &display   = "lnmonsrp.num lnmonsrp.zname lnmonsrp.crc lnmonsrp.nsum "
   &highlight = " lnmonsrp.num "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmonsrp.num lnmonsrp.zname lnmonsrp.crc lnmonsrp.nsum with frame longr1.
                end."
   &end = "hide frame longr1."
}
