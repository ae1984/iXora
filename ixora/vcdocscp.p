/* vcdocscp.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        12.01.2012 damir - корректировки.
*/

{global.i}
def shared var s-docs as inte.

define shared temp-table menu
    field num as int
    field contract as int
    field ctnum as char
    field ctdate as date
    field ctvalpl as char
    field crc as integer.

/*message "s-docs=" s-docs view-as alert-box.*/

def var v-max as inte init 0.
def var v-numobyaz   as inte.

v-numobyaz = 0.
def buffer b-bufdocs for vcdocs.

find first menu no-lock no-error.
if avail menu then do:
    find first b-bufdocs where b-bufdocs.contract = menu.contract and (b-bufdocs.dntype = "02" or b-bufdocs.dntype = "03") no-lock no-error.
    if avail b-bufdocs then v-max = b-bufdocs.numobyaz.
    for each b-bufdocs where b-bufdocs.contract = menu.contract and (b-bufdocs.dntype = "02" or b-bufdocs.dntype = "03") no-lock break by b-bufdocs.dndate:
        if b-bufdocs.numobyaz > v-max then v-max = b-bufdocs.numobyaz.
        else v-max = v-max.
    end.
    v-numobyaz = v-max + 1.
    find first vcdocs where vcdocs.docs = s-docs exclusive-lock no-error.
    if avail vcdocs then vcdocs.numobyaz = v-numobyaz.
end.
/*message "v-numobyaz=" v-numobyaz view-as alert-box.*/

for each menu no-lock break by menu.contract:
    if first-of(menu.contract) then do:
        for each vcdocs where vcdocs.contract = menu.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") no-lock:
            find first vcdocshismt where vcdocshismt.contract = vcdocs.contract and vcdocshismt.docs = vcdocs.docs and
            vcdocshismt.stsnewold = "old" no-lock no-error.
            if not avail vcdocshismt then do:
                create vcdocshismt.
                assign
                vcdocshismt.docs = vcdocs.docs
                vcdocshismt.dntype = vcdocs.dntype
                vcdocshismt.dnnum = vcdocs.dnnum
                vcdocshismt.dndate = vcdocs.dndate
                vcdocshismt.pcrc = vcdocs.pcrc
                vcdocshismt.sum = vcdocs.sum
                vcdocshismt.knp = vcdocs.knp
                vcdocshismt.kod14 = vcdocs.kod14
                vcdocshismt.info[1] = vcdocs.info[1]
                vcdocshismt.info[4] = vcdocs.info[4]
                vcdocshismt.rdt = vcdocs.rdt
                vcdocshismt.rwho = vcdocs.rwho
                vcdocshismt.cdt = vcdocs.cdt
                vcdocshismt.cwho = vcdocs.cwho
                vcdocshismt.udt = vcdocs.udt
                vcdocshismt.uwho = vcdocs.uwho
                vcdocshismt.contract = vcdocs.contract
                vcdocshismt.payret = vcdocs.payret
                vcdocshismt.cursdoc-con = vcdocs.cursdoc-con
                vcdocshismt.cursdoc-usd = vcdocs.cursdoc-usd
                vcdocshismt.remtrz = vcdocs.remtrz
                vcdocshismt.sumpercent = vcdocs.sumpercent
                vcdocshismt.numnewps = vcdocs.numnewps
                vcdocshismt.datenewps = vcdocs.datenewps
                vcdocshismt.numdc = vcdocs.numdc
                vcdocshismt.datedc = vcdocs.datedc
                vcdocshismt.numob = string(vcdocs.numobyaz)
                vcdocshismt.zachet = vcdocs.zachet
                vcdocshismt.ustupka = vcdocs.ustupka
                vcdocshismt.perdolga = vcdocs.perdolga
                vcdocshismt.newofc = g-ofc
                vcdocshismt.newdate = g-today
                vcdocshismt.stsnewold = "old".
            end.
        end.
    end.
end.

