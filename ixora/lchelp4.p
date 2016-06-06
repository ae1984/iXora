/* lchelp4.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        поиск аккредитива с определенным признаком
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
        27/06/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{mainhead.i}
def input parameter p-sts   as char.
def input parameter p-code  as char.
def input parameter p-value as char.

def shared var s-lc like LC.LC.
def shared var s-lcprod  as char.
def var v-crc as char.

{itemlist.i
 &file = "lc"
 &frame = "row 6 centered scroll 1 10 down width 70 overlay "
 &where = " lc.lc begins s-lcprod and lookup(lc.lcsts,p-sts) > 0 and can-find(lch where lch.lc = lc.lc and lch.kritcode = p-code and lch.value1 = p-value)"
 &findadd = "find first lch where lch.lc = lc.lc and lch.kritcode = 'lccrc' no-lock no-error. if avail lch then find first crc where crc.crc = int(lch.value1) no-lock no-error.
            if avail crc then v-crc = crc.code. "

 &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Applicant Code' format 'x(6)' v-crc label 'Currency' format 'x(3)'"
 &chkey = "LC"
 &index  = "LC"
 &end = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = lc.lc.
