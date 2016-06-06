/* depst_rep1.p
 * MODULE
        Депозиты с измененными ставками
 * DESCRIPTION
        Отчет по депозитам физ. лиц и юр. лиц. по которым изменилась ставка вознаграждения за период.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-brfilial
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-3-1-17
 * AUTHOR
        26/09/2011 lyubov
 * BASES
        BANK, TXB
 * CHANGES
        27/12/2011 lyubov - исправила ошибки
*/

def shared var dt1 as date.
def shared var dt2 as date.

define var t-amt as decimal.
define var sm as decimal.
define var m-aaa as char.
define var m-rt as deci.
define var m-gr as char.
define var qwe like txb.acvolt.x3.

def buffer b-jl for txb.jl.
def buffer b-accr for txb.accr.
def buffer b1-accr for txb.accr.

def shared temp-table wrk no-undo
field npp as int
field sch_vk as char format "x(20)"
field nd as char format "x(20)"
field grp as char
field name as char format "x(60)"
field val as char
field sumdepcrd as deci format "z,zzz,zzz,zz9.99"
field cdt as date format "99/99/9999"
field stn as deci
field stk as deci
field prolong like txb.acvolt.x3
field bank as char format "x(20)"
index bank is primary bank.

def var city as char.
def var m-sch like txb.accr.aaa.
def var m-acr like txb.accr.rate.

find first txb.cmp no-lock no-error.
if avail txb.cmp then city = txb.cmp.name /*entry(1,txb.cmp.addr[1])*/.

def var s-ourbank as char no-undo.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

m-acr = 0.

for each txb.accr no-lock:

    if txb.accr.fdt >= dt1 and txb.accr.fdt <= dt2 and txb.accr.aaa = m-sch and txb.accr.rate <> m-acr then do:

        find first b-accr where b-accr.fdt >= dt1 and b-accr.fdt <= dt2 and b-accr.aaa = m-sch and b-accr.rate <> m-acr no-lock no-error.
        if avail b-accr then do:

            find first txb.aaa where txb.aaa.aaa = txb.accr.aaa and txb.aaa.sta <> "C" and lookup(txb.aaa.lgr, "A13,A14,A15,A19,A20,A21,A25,A26,A27,A28,A29,A30,A01,A02,A03,A04,A05,A06,A34,A35,A36,A31,A32,A33,484,485,486,487,488,489,478,479,480,481,482,483") <> 0 no-lock no-error.
            if avail txb.aaa then do:

                find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif then do:

                    find first txb.crc where  txb.crc.crc = txb.aaa.crc no-lock no-error.
                    if avail txb.crc then do:

                        find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
                        if avail txb.lgr then do:

                            create wrk.
                            wrk.sch_vk = txb.aaa.aaa.
                            wrk.grp = txb.aaa.lgr.
                            qwe = string (txb.aaa.expdt).
                            wrk.name = txb.cif.name.

                            wrk.nd = txb.lgr.des.
                            wrk.val = txb.crc.code.

                            wrk.sumdepcrd = txb.accr.bal.
                            wrk.bank = city.
                            wrk.stn = m-acr.
                            wrk.stk = b-accr.rate.
                            wrk.cdt = b-accr.fdt.


                            find first txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa and txb.acvolt.x3 <> qwe no-lock no-error.
                            if avail txb.acvolt then wrk.prolong = txb.acvolt.x3.

                        end.
                    end.
                end.
            end.
        end.
    end.

    m-acr = txb.accr.rate. m-sch = txb.accr.aaa.
end.