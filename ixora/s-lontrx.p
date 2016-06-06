/* s-lontrx.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Оплата кредита
 * RUN
        4-1-1 Погашен
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        s-lontrx1
 * MENU
        4-1-1  Погашен
 * AUTHOR
        26.02.2004 marinav
 * CHANGES
        13/10/2004 madiyar - комиссия за неисп. кред. линии теперь начисляется в валюте кредита. Для погашения ранее начисленной комиссии (в тенге)
                             в trxbal временно ищется запись только в тенге, после погашения всех тенговых комиссий программа и соотв. шаблон
                             будут изменены
        15/10/2004 madiyar - По комиссии за неисп. кред. линию в trxbal теперь ищется запись в валюте кредита
                             Добавились три новые комиссии
        03/12/2004 madiyar - для номера проводки по погашению индексации - своя переменная s-jhind
                             добавил в примечания сумму погашаемых штрафов
        06/05/2005 madiyar - убрал просроченную индексацию
        10/06/2005 madiyar - итоговая сумма в форме ввода считалась некорректно, исправил
                             в примечаниях к проводке указывается сумма погашения од и %% без индексации
        07/03/2006 Natalya D. - добавила "Касса в пути".
        04.04.2006 Natalya D. - добавила счёта АРП по валюте кредита и по нац.валюте для кассы в пути
        04/05/06 marinav Увеличить размерность поля суммы
        12/03/2007 madiyar - добавил ком.долг
        24/02/09   marinav - добавлено погашение через ARP
        19.02.10   marinav - формат счета 20
        29/04/2010 madiyar - списание штрафов по валютным кредитом
        10/08/10 aigul - погашение 4 и 5 уровней
        23/08/2010 madiyar - комиссия по кредитам бывших сотрудников
        17/09/2010 aigul - вывод суммы по валютам
        07/10/2011 dmitriy - добавил входной параметр v-transac
        17.10.11 lyubov - изменила строки "Всего........." (СЗ от 14.10.11)
        25/07/2012 dmitriy - погашение комиссии по годовой ставке
        09/08/2012 kapar - ТЗ ASTANA-BONUS
        16.10.2012 dmitriy - возможность погашать комиссию по годовой ставке без основного долга (ТЗ 1551)
        22/11/2013 Luiza   - ТЗ 2220 замена текста «Оплата кредита» на «Оплата по договору»
*/

{lonlev.i}
def input parameter v-transac as logi no-undo.

def var v-bal like glbal.bal.

def shared var s-lon like lon.lon.
def new shared var s-gl like gl.gl.     /* payment gl # */
define new shared variable s-gljl like gl.gl.
def new shared var s-acc like jl.acc.   /* payment acct # */
define variable vacc like aaa.aaa.
def new shared var ppay like lon.opnamt.
def new shared var ipay like lon.opnamt.
define new shared variable s-rmz like remtrz.remtrz.
define new shared variable spay as decimal.
define new shared variable spay1 as decimal.
define new shared variable apay  as decimal.
define new shared variable apay1 as decimal.
define new shared variable algpay as decimal.
define new shared variable algpay1 as decimal.
define new shared variable sds-pay as decimal.
define new shared variable sds-pay1 as decimal.
define new shared variable komcl-pay1 as decimal.
define new shared variable komprcr-pay1 as decimal.
define new shared variable komvacc-pay1 as decimal.
define new shared variable komprod-pay1 as decimal.
define variable komcl as decimal.
define variable komprcr as decimal.
define variable komvacc as decimal.
define variable komprod as decimal.
define new shared var v-pay20 as deci init 0.
/*define new shared var v-pay21 as deci init 0.*/
define new shared var v-pay22 as deci init 0.
/*define new shared var v-pay23 as deci init 0.*/
define new shared variable sds-gl like gl.gl.
define new shared variable a-gl like gl.gl init 0.
def new shared var s-ptype as int format "z" init 1.
define new shared variable s-crc like crc.crc.
define new shared variable penlpay as decimal.
define new shared variable penlpay1 as decimal.
def var penipay like lon.opnamt.
def new shared var s-jh like jh.jh init 0.
def new shared var s-jhind like jh.jh init 0. /* номер проводки по погашению индексации */
def new shared var s-jhkom like jh.jh init 0. /* номер проводки по погашению комиссии по годовой ставке */

def var v-f0 like lnsch.f0.
def var v-flp like lnsch.flp.
def var v-del like lnsch.stval.
def new shared var s-vint like lnsci.iv.
def new shared var marked like lnsci.paid-iv.
define new shared variable s-acr as decimal.
def new shared var s-aaa like aaa.aaa.
define variable v-name as character.
define new shared variable ppay1 as decimal.
define new shared variable ipay1 as decimal.
define new shared variable sds-pay5
as decimal.

def var v-dep like ppoint.depart no-undo. /*код департамента сотрудника*/
def new shared var s-arp as char label "Счет кассы в пути:" init "?". /*АРП счет кассы в пути, установленный пользователем*/
def new shared var nc-arp as char . /*АРП счет кассы в пути в нац.валюте*/
def new shared var l-arp as char . /*АРП счет кассы в пути в валюте кредита*/
def var v-cash as logical init yes.
define variable v-code as character.
define variable v-code1 as character.
define variable v-cd as character.
define variable v-cd1 as character.
define variable komclcrc as character.
define variable komprcrcrc as character.
define variable komvacccrc as character.
define variable komprodcrc as character.
define variable vcd as character.
define variable vcd1 as character.
define variable acd  as character.
define variable acd1 as character.
define variable sds-cd as character.
define variable sds-cd1 as character.
define variable algcd as character.
define variable algcd1 as character.
define variable sds  as decimal.
define variable sds-com as decimal.
define variable sds-koms as decimal.
define variable dam-cam1 as decimal.
define variable v-glcash like gl.gl.
define variable kurss as decimal.
define variable dn1 as integer.
define variable dn2 as decimal.
define variable k-p as character.
define variable rcd as logical.
define new shared variable s-falon like falon.falon.
define variable sds-ind as logical.
define variable sds5  as decimal.
define variable sds-cd5 as character.

define buffer b-crc for crc.

define new shared variable s-longl as integer extent 20.
define variable ok as logical.
define new shared variable rc as integer.
define variable ja as logical init no format "да/нет".

/*---- variables for leasing ------*/
{s-lonliz.i "NEW"}
define variable lon-avn as  decimal.      /* avanss */
define variable avn-apm as  decimal.      /* apmaks–ts avanss */
define variable lon-avncrc  as character. /* avansa val­ta */
define variable pvn-sum as  decimal.      /*summa  PVN */
define variable avn-atl as  decimal.      /* apmaks–t PVN % */
define variable avn-atlcrc  as character. /* valuta apmaks. PVN% */
define variable noform-sum  as decimal.   /* summa par noformёЅanu */
define variable noform-crc  as character. /* noformёЅanas val­ta */
define variable noform-crc1 as character. /* noformёЅanas val­ta */
define variable atalg-sum   as decimal.   /* summa par noformёЅanu */
define variable atalg-crc   as character. /* atalgojuma val­ta */
define variable atalg-crc1  as character. /* atalgojuma val­ta */
define variable total-sum   as decimal.   /* kopёja summa */
define variable total-crc   as character. /* val­ta */
define variable total-crc1  as character. /* val­ta */
define variable total-crc2  as character.
define variable total-crc-com  as character.
define variable v-avncrc    as character.
define variable v-avncrc1   as character.
define variable v-pvncrc    as character.
define variable v-pvncrc1   as character.
define variable ppay-save   as decimal.
define variable ppay1-save   as decimal.

def var vbal like jl.dam.
def var vavl like jl.dam.
def var vhbal like jl.dam.
def var vfbal like jl.dam.
def var vcrline like jl.dam.
def var vcrlused like jl.dam.
def var vooo like aaa.aaa.
def buffer bcrc for crc.

def new shared var v-amtod as dec.
def new shared var v-intod as dec.
def new shared var v-amtbl as dec.
def new shared var v-payod as dec.
def new shared var v-payiod as dec.
def new shared var v-payiod1 as dec.
def new shared var v-paybl as dec.
def new shared var v-payod1 as dec.
def new shared var v-paybl1 as dec.
def new shared var v-4ur as dec.
def new shared var v-pay4ur as dec.

define variable damu_v-cd1 as character.
def new shared var damu_ipay1 as dec.
def new shared var damu_v-intod as dec.
def var damu_v-iodcrc1 like crc.code.
def new shared var damu_v-payiod1 as dec.
def new shared var damu_v-4ur as dec.
def var damu_v-odcrc4 like crc.code.

define variable astana_v-cd1 as character.
def new shared var astana_ipay1 as dec.
def new shared var astana_v-intod as dec.
def var astana_v-iodcrc1 like crc.code.
def new shared var astana_v-payiod1 as dec.
def new shared var astana_v-4ur as dec.
def var astana_v-odcrc4 like crc.code.

def new shared var v-total-pay-all as dec.
def new shared var v-total-pay-all2 as dec.

def var v-odcrc like crc.code.
def var v-odcrc20 like crc.code.
def var v-odcrc21 like crc.code.
def var v-odcrc22 like crc.code.
def var v-odcrc23 like crc.code.
def var v-odcrc1 like crc.code.
def var v-iodcrc like crc.code.
def var v-iodcrc1 like crc.code.
def var v-odcrc4 like crc.code.

def var v-blcrc like crc.code.
def var v-blcrc1 like crc.code.
def var v-who as char format "x(50)".
def var v-passp as char .
def var v-perkod as char format "x(50)".
def var i as int.
define new shared variable l-crc like crc.crc.
define frame f_cus
    v-who    label "ПОЛУЧАТЕЛЬ " skip
    v-passp  label "ПАСПОРТ    " format "x(320)" view-as fill-in size 50 by 1 skip
    v-perkod label "ПЕРС.КОД   "
    with row 15 col 16 overlay side-labels.


find lon where lon.lon = s-lon no-error.
find loncon where loncon.lon = lon.lon no-lock.

find falon where falon.falon = lon.lon no-lock no-error.
if loncon.sods2 > 0 or lon.gua = "LK" then sds-ind = yes.
else sds-ind = no.
if sds-ind and available falon then sds = falon.dam[2] - falon.cam[2].
else sds = 0.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 16 no-lock no-error.
if available trxbal then sds = trxbal.dam - trxbal.cam.

/* 4 уровень */
/*run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-4ur).*/
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 4 no-lock no-error.
if available trxbal then v-4ur = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 48 no-lock no-error.
if available trxbal then damu_v-4ur = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 53 no-lock no-error.
if available trxbal then astana_v-4ur = trxbal.dam - trxbal.cam.

/* 5 уровень */
/*run lonbalcrc('lon',lon.lon,g-today,"5",yes,lon.crc,output sds5).*/
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 5 no-lock no-error.
if available trxbal then sds5 = trxbal.dam - trxbal.cam.


/* 13/10/2004 madiyar - ищется 25 уровень только в валюте кредита */
find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 25 and trxbal.crc = lon.crc no-lock no-error.
if available trxbal then komcl = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 27 and trxbal.crc = 1 no-lock no-error.
if available trxbal then komprcr = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 28 and trxbal.crc = lon.crc no-lock no-error.
if available trxbal then komvacc = trxbal.dam - trxbal.cam.

find trxbal where trxbal.sub eq "LON" and trxbal.acc eq lon.lon and trxbal.lev eq 29 and trxbal.crc = lon.crc no-lock no-error.
if available trxbal then komprod = trxbal.dam - trxbal.cam.

sds-com = 0.
for each bxcif where bxcif.cif = lon.cif no-lock:
    sds-com = sds-com + bxcif.amount.
end.

sds-koms = 0.
find first lons where lons.lon = lon.lon no-lock no-error.
if avail lons then sds-koms = lons.amt.

run clear-fg("C").

{global.i}
{x-eomint.f}
{x-eomintl.i}
{get-dep.i}
v-bal = v-bal + v-amt20.
vinttday = vinttday + v-amt22.
dam-cam1 = v-bal.
s-acr = vinttday.
s-crc = lon.crc.
l-crc = lon.crc.
apay = 0.
apay1 = 0.
sds-pay = 0.
sds-pay1 = 0.
sds-pay5 = 0.
algpay =  0.
algpay1 =  0.
find sysc where sysc.sysc = "cashgl" no-lock.
v-glcash = sysc.inval.

lon-avn    = 0.
pvn-sum    = 0.
noform-sum = 0.
atalg-sum  = 0.
total-sum  = 0.

avnpay = 0.
pvnpay = 0.
noform-pay = 0.
atalg-pay = 0.
total-pay = 0.
avnpay1 = 0.
pvnpay1 = 0.
noform-pay1 = 0.
atalg-pay1 = 0.
total-pay1 = 0.
/*total-pay-all = dam-cam1 + vinttday +  v-4ur + sds + sds5 + komcl + komprcr + komvacc + komprod + sds-com + sds-koms.*/
run lonbalcrc('lon',lon.lon,g-today,"33",yes,lon.crc,output v-total-pay-all).
total-pay-all = sds5 + sds +  v-total-pay-all.
run lonbalcrc('lon',lon.lon,g-today,"1,2,7,9,4",yes,lon.crc,output v-total-pay-all2).
/*total-pay-all = dam-cam1 + vinttday +  v-4ur + sds + sds5 + komcl + komprcr + komvacc + komprod + sds-com.*/

total-pay-all2 = v-total-pay-all2 + sds-com + sds-koms.

if lon.gua <> "LK" then lon-pvn = 0.
else do:
    find first lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
    if lonhar.rez-char[3]  <> ""  then lon-pvn = decimal(lonhar.rez-char[3]).
    else lon-pvn = 0.
    pvn-sum = 0.
end.

{s-lontrx.f}

upper:
do on error undo, retry  on endkey undo,return:
    readkey pause 0.
    repeat /* on endkey undo, return */ :
        find crc where crc.crc = lon.crc no-lock.
        kurss = 1. /*оплата всегда только в валюте кредита*/
        v-code = crc.code.
        v-code1 = v-code.
        v-odcrc = crc.code.
        v-odcrc20 = crc.code.
        v-odcrc21 = crc.code.
        v-odcrc22 = crc.code.
        v-odcrc23 = crc.code.
        v-odcrc1 = crc.code.
        v-blcrc = crc.code.
        v-blcrc1 = crc.code.
        v-iodcrc = crc.code.
        v-iodcrc1 = crc.code.
        v-odcrc4 = crc.code.

        v-cd = v-code.
        v-cd1 = v-cd.
        algcd = v-code.
        algcd1 = v-code.
        vcd = v-code.
        vcd1 = v-cd.
        acd = v-code.
        acd1 = v-code.
        sds-cd = 'KZT'.
        sds-cd1 = 'KZT'.
        sds-cd5 = 'KZT'.
        komclcrc = crc.code.
        komprcrcrc = 'KZT'.
        komvacccrc = crc.code.
        komprodcrc = crc.code.
        v-pvncrc = v-code.
        v-pvncrc1 = v-pvncrc.
        total-crc = v-code.
        total-crc1 = total-crc.
        total-crc2 = 'KZT'.
        total-crc-com = crc.code.

        damu_v-cd1 = crc.code.
        damu_v-iodcrc1 = crc.code.
        damu_v-odcrc4 = crc.code.

        astana_v-cd1 = crc.code.
        astana_v-iodcrc1 = crc.code.
        astana_v-odcrc4 = crc.code.

        display v-code1
        v-odcrc1
        v-odcrc20
        v-odcrc21
        v-odcrc22
        v-odcrc23
        v-blcrc1
        v-iodcrc1
        v-odcrc4
        v-cd1
        sds-cd1
        sds-cd5
        komclcrc
        komprcrcrc
        komvacccrc
        komprodcrc
        sds-com
        sds-koms
        total-crc1
        total-crc2
        total-crc-com
        vacc
        s-glrem
        damu_v-cd1
        damu_v-iodcrc1
        damu_v-odcrc4
        astana_v-cd1
        astana_v-iodcrc1
        astana_v-odcrc4
        with frame lon.

        update s-ptype validate(s-ptype = 1 or s-ptype = 2 or s-ptype = 3 or s-ptype = 4 or s-ptype = 5 or s-ptype = 9, "") go-on("PF4") with frame lon.

        if lastkey = keycode("PF4") then return.

        if s-ptype = 1 or s-ptype = 9 then do:
            s-gl = 0.
            v-name = "СПИСАНИЕ".
            if s-ptype eq 1 then do:
                s-gl = v-glcash.
                v-name = "Оплата наличными".
            end.
            display s-gl v-name with frame lon.
        end.

        if s-ptype = 2 then do:
            update s-crc with frame lon.
            v-dep = get-dep(g-ofc, g-today).
            find last ppoint where ppoint.depart = v-dep no-lock no-error.
            find last ofc where ofc.ofc = g-ofc no-lock no-error.

            k-p = " Трнз.сч".
            if s-crc = lon.crc then do:
                run FindArp100200(ofc.titcd, s-crc , output s-arp).
                l-arp = s-arp.
            end.
            else do:
                l-crc = lon.crc.
                run FindArp100200(ofc.titcd, s-crc , output s-arp).
                run FindArp100200(ofc.titcd, l-crc , output l-arp).
            end.

            run FindArp100200(ofc.titcd, 1, output nc-arp).

            if s-arp = "?" then do:
	            message "Счет АРП Касса в пути не найден для департамента " ppoint.name. pause.	undo, return.
            end.
            v-name = " Касса в пути".
            find first arp where arp.arp = s-arp no-lock no-error.
            s-gl = arp.gl.
            vacc = s-arp.
            display k-p vacc with frame lon.
            display s-gl v-name with frame lon.
        end.

        if s-ptype = 3 then do:
            k-p = " Счет".
            display k-p with frame lon.
            update vacc with frame lon.
            s-acc = vacc.
            find aaa where aaa.aaa = s-acc no-error.
            if not available aaa then do:
                bell.
                {mesg.i 2208}.
                undo,retry.
            end.
            if aaa.sta eq "C" then do:
                bell.
                {mesg.i 6207}.
                undo,retry.
            end.
            find cif where cif.cif = aaa.cif no-lock.
            v-name = s-acc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
            if cif.jss ne "" then v-name = v-name + " ИИН/БИН " + cif.bin.
            s-aaa = s-acc.

            find bcrc where bcrc.crc = aaa.crc no-lock no-error.
            run aaa-bal777(input s-aaa, output vbal,output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).

            message "Входящий остаток: " string(vavl, "->>>,>>>,>>9.99") " " bcrc.code.
            pause no-message.

            run aaa-aas.
            find first aas where aas.aaa = s-aaa and aas.sic = 'SP' no-lock no-error.
            if available aas then do:
                pause.
                undo,retry.
            end.
            s-gl = aaa.gl.
            s-crc = aaa.crc.
            display s-crc s-gl v-name with frame lon.
        end.

        if s-ptype = 4 then do:
            find sysc where sysc.sysc eq "RMPY1G" no-lock.
            s-gl = sysc.inval.
            v-name = "Входящий перевод".
            find sysc where sysc.sysc = "BILEXT" no-lock.
            k-p = "#перев.".
            display s-gl k-p v-name with frame lon.
            update vacc with frame lon.
            s-acc = vacc.

            run chklonps(s-acc,"LON",output rcd).
            if not rcd then do:
                message "Нет такого перевода !".
                pause.
                undo,retry.
            end.
            find remtrz where remtrz.remtrz = s-acc no-lock.
            s-crc = remtrz.tcrc.
            s-rmz = remtrz.remtrz.
            s-acc = "".
            if trim(remtrz.INFO[10]) <> "" then do:
                s-gl = integer(trim(remtrz.INFO[10])).
                display s-gl with frame lon.
            end.
            find crc where crc.crc eq remtrz.fcrc no-lock no-error.
            v-name = v-name + " - summa " + string(remtrz.payment) + " " + crc.code.

            if remtrz.sacc <> ? then v-name = v-name + " " + trim(remtrz.sacc).
            if remtrz.ord <> ? then v-name = v-name + " " + trim(remtrz.ord).

            def var o_ordins as char.
            if remtrz.sbank begins "TXB" then do:
                find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
                if available bankl and bankl.name <> "" then do:
                    o_ordins = trim(bankl.name).
                end.
                else do:
                    if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
                    if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[2]).
                    if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[3]).
                    if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[4]).
                end.
            end.
            else do:
                if remtrz.ordins[1] = "NONE" then do:
                    find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
                    if available bankl and bankl.name <> "" then do:
                        o_ordins = trim(bankl.name).
                    end.
                end.
                else do:
                    if remtrz.ordins[1] <> ? then o_ordins = trim (remtrz.ordins[1]).
                    if remtrz.ordins[2] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[2]).
                    if remtrz.ordins[3] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[3]).
                    if remtrz.ordins[4] <> ? then o_ordins = o_ordins + " " + trim(remtrz.ordins[4]).
                end.
            end.
            find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
            if avail bankl then do:
                o_ordins = trim(bankl.bank) + " " + o_ordins.
            end.
            if o_ordins ne "" and o_ordins ne ? then v-name = v-name + " " + o_ordins.
            display v-name with frame lon.
        end.

        if s-ptype = 5 then do:
            k-p = " Тр.счет".
            display k-p with frame lon.
            update vacc with frame lon.
            s-acc = vacc.
            find arp where arp.arp = s-acc no-error.
            if not available arp then do:
                bell.
                {mesg.i 2208}.
                undo,retry.
            end.
            s-gl = arp.gl.
            s-crc = arp.crc.
            v-name = ''.
            display s-crc s-gl v-name with frame lon.
        end.

        if s-ptype <= 2 then update s-crc with frame lon.
        leave.
    end.

    find first b-crc where b-crc.crc = s-crc no-lock no-error.
    total-crc1 = b-crc.code.
    displ total-crc1 with frame lon.

    readkey pause 0.

    inner2:
    repeat on endkey undo,return:
        if lon.gua <> "LK" and lon.gua <> "FK" then do:
            if s-crc = lon.crc then do:
                /*---- all for leasing = 0.-- */
                update ppay1 validate(kurss * ppay1 <= v-bal and ppay1 >= 0," Сумма не должна быть больше задолженности" ) with frame lon.
                ppay = truncate(ppay1, 2).

                if ppay > v-amt20 then v-pay20 = v-amt20.
                else v-pay20 = ppay.

                if ppay - v-pay20 > v-amtod then v-payod = v-amtod.
                else v-payod = ppay - v-pay20.

                v-payod1 = v-payod.

                total-pay = ppay /*+ v-pay20*/.
                total-pay1 = ppay1 /*+ v-pay20*/.

                display v-payod1 v-pay20 total-pay1 with frame lon.

                if (v-amtod > 0 or v-amt20 > 0) and ppay > 0 then
                repeat :
                    update v-pay20 v-payod1 with frame lon.
                    v-payod = v-payod1 / kurss.
                    displ v-pay20 v-payod1 with frame lon.
                    if v-payod + v-pay20 <= ppay then leave.
                    else do:
                        message "Превышена сумма платежа".
                        pause 5.
                    end.
                end.
            end.
        end.
        pause 0.

        if lastkey = 13 and ppay1 = 0 and ipay1 = 0 then run lonstl-p.
        else leave.
    end.
    readkey pause 0.

    if s-ptype = 4 then do:
        if ppay1 + pvnpay1 + apay1 + algpay1 > remtrz.payment then do:
            bell.
            message "Превышена сумма перевода !".
            pause.
            undo,retry.
        end.
    end.

    repeat on endkey undo, return:
        if lon.gua <> "LK" and lon.gua <> "FK" then do:
            if s-crc = lon.crc then do:
                update ipay1 with frame lon.
                ipay = ipay1.

                if ipay > v-amt22 then v-pay22 = v-amt22.
                else v-pay22 = ipay.

                if ipay - v-pay22 > v-intod then v-payiod = v-intod.
                else v-payiod = ipay - v-pay22.
                /*4 уровень
                if ipay - v-payiod > v-4ur then v-pay4ur = v-4ur.
                else v-pay4ur = ipay - v-payiod.
                */

                v-payiod1 = v-payiod.

                total-pay = ppay + ipay .
                total-pay1 = ppay1 + ipay1.

                display ipay1 v-pay22 v-payiod1 /*v-pay4ur*/ total-pay1 with frame lon.
                if (v-payiod1 > 0 or v-pay22 > 0 /*or v-pay4ur > 0*/) and ipay > 0 then
                repeat:
                    update v-pay22 v-payiod1 /*v-pay4ur*/ with frame lon.
                    v-payiod = v-payiod1.
                    displ v-pay22 v-payiod1 /*v-pay4ur*/ with frame lon.
                    if v-pay22 + v-payiod1 /*+ v-pay4ur*/ <= ipay1 then leave.
                    else do:
                        message "Превышена сумма платежа".
                        pause 5.
                    end.
                end.
            end.
        end.
        pause 0.

        if ipay1 = 0 and lastkey = 13 then run lonstl-i.
        else leave.
    end.

    readkey pause 0.
    if s-ptype = 4 then do:
        if ppay1 + pvnpay1 + ipay1 + apay1 > remtrz.payment
        then do:
            bell.
            message "Превышена сумма перевода  !".
            pause.
            undo,retry.
        end.
    end.

    repeat on endkey undo, return:
        if s-ptype = 4 and lon.gua = 'LK' then do on endkey undo,leave:
            display ppay1 /* lon-pvn pvn-sum pvnpay pvnpay1 */
            ipay1 with frame lon.
            update pvnpay1 with frame lon.
            pvnpay  = round(pvnpay1 * kurss, 2).
            pvn-sum = pvnpay.
        end.
        else leave.

        total-pay = ppay + pvnpay + ipay + spay.
        total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
        display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */ ipay1 ipay
        total-pay total-pay1 loncon.konts /* apay1 apay */ with frame lon.
        leave.
    end.
    pause 0.

    repeat on endkey undo, return:
        if dam-cam1 = ppay and lon.gua = 'LK' then do on endkey undo,leave:
            display ppay1 ppay /* lon-pvn pvn-sum pvnpay pvnpay1 */
            ipay1 ipay with frame lon.
            update pvnpay with frame lon.
            pvn-sum = pvnpay.
            pvnpay1 = round(pvnpay / kurss, 2).
        end.
        else leave.

        total-pay = ppay + pvnpay + ipay + spay.
        total-pay1 = ppay1 + pvnpay1 + ipay1 + spay1.
        display ppay1 ppay ipay1 ipay total-pay total-pay1 loncon.konts with frame lon.
        leave.
    end.
    pause 0.

    repeat on endkey undo, return:
        if sds > 0 and ((s-crc = 1) or s-ptype = 9) then do:
            update sds-pay1 with frame lon.
            sds-pay = round(sds-pay1, 2).
            if s-crc = 1 then do:
                total-pay = ppay + ipay + sds-pay.
                total-pay1 = ppay1 + ipay1 + sds-pay1.
            end.
            display sds-pay1 total-pay1 with frame lon.
        end.
        if sds-pay1 le sds then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.
    /* 5 уровень
    repeat on endkey undo, return:
        if sds5 > 0 and ((s-crc = 1) or s-ptype = 5) then do:
            update sds-pay5 with frame lon.
            sds-pay = round(sds-pay5, 2).
            if s-crc = 1 then do:
                total-pay = ppay + ipay + sds-pay.
                total-pay1 = ppay1 + ipay1 + sds-pay5.
            end.
            display sds-pay5 total-pay1 with frame lon.
        end.
        if sds-pay5 le sds5 then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.
    */
    repeat on endkey undo, return:
        if komcl > 0 and s-crc = lon.crc then do:
            update komcl-pay1 with frame lon.
            total-pay = ppay + ipay + sds-pay + komcl-pay1.
            total-pay1 = ppay1 + ipay1 + sds-pay1 + komcl-pay1.
            display komcl-pay1 total-pay1 with frame lon.
        end.
        if komcl-pay1 le komcl then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.

    repeat on endkey undo, return:
        if komprcr > 0 and s-crc = 1 then do:
            update komprcr-pay1 with frame lon.
            total-pay = ppay + ipay + sds-pay + komcl-pay1 + komprcr-pay1.
            total-pay1 = ppay1 + ipay1 + sds-pay1 + komcl-pay1 + komprcr-pay1.
            display komprcr-pay1 total-pay1 with frame lon.
        end.
        if komprcr-pay1 le komprcr then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.

    repeat on endkey undo, return:
        if komvacc > 0 and s-crc = lon.crc then do:
            update komvacc-pay1 with frame lon.
            total-pay = ppay + ipay + sds-pay + komcl-pay1 + komprcr-pay1 + komvacc-pay1.
            total-pay1 = ppay1 + ipay1 + sds-pay1 + komcl-pay1 + komprcr-pay1 + komvacc-pay1.
            display komcl-pay1 total-pay1 with frame lon.
        end.
        if komvacc-pay1 le komvacc then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.

    repeat on endkey undo, return:
        if komprod > 0 and s-crc = lon.crc then do:
            update komprod-pay1 with frame lon.
            total-pay = ppay + ipay + sds-pay + komcl-pay1 + komprcr-pay1 + komvacc-pay1 + komprod-pay1.
            total-pay1 = ppay1 + ipay1 + sds-pay1 + komcl-pay1 + komprcr-pay1 + komvacc-pay1 + komprod-pay1.
            display komprod-pay1 total-pay1 with frame lon.
        end.
        if komprod-pay1 le komprod then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.

/*------------- Комиссия по годовой ставке -----------------*/

    repeat on endkey undo, return:
        if sds-koms > 0 and s-crc = lon.crc then do:
            update ppay-kom with frame lon.
            total-pay = ppay + ipay + sds-pay + komcl-pay1 + komprcr-pay1 + komvacc-pay1 + komprod-pay1 + ppay-kom.
            total-pay1 = ppay1 + ipay1 + sds-pay1 + komcl-pay1 + komprcr-pay1 + komvacc-pay1 + komprod-pay1 + ppay-kom.
            display komprod-pay1 total-pay1 with frame lon.
        end.
        if ppay-kom le sds-koms then leave.
        else do:
            message "Превышена сумма платежа".
            pause 5.
        end.
    end.

/*----------------------------------------------------------*/

    readkey pause 0.
    if s-ptype = 4 then do:
        if ppay1 + pvnpay1 + ipay1 + apay1 > remtrz.payment
        then do:
            bell.
            message "Превышена сумма перевода !".
            pause.
            undo,retry.
        end.
    end.

    if s-ptype = 4 then do:
        if ppay1 + pvnpay1 + ipay1 + spay1 + apay1 + algpay1 <> remtrz.payment
        then do:
            bell.
            message "Сумма платежа и перевода не совпадают !".
            pause.
            undo,retry.
        end.
    end.
    if s-ptype eq 9 then do:
        if (ppay gt dam-cam1) or (ipay gt vinttday) then do:
            message "Превышена сумма долга" view-as alert-box.
            undo,retry.
        end.
    end.

    /* dobavlenije primechanija */
    find crc where crc.crc eq lon.crc no-lock no-error.
    if ppay - v-pay20 ne 0 then s-glrem2 = "Сумма погашаемого ОД " + trim(string(ppay - v-pay20,">>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code.
    else s-glrem2 = "".
    if ipay - v-pay22 ne 0 then s-glrem3 = "Сумма погашаемых %% " + trim(string(ipay - v-pay22,">>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code.
    else s-glrem3 = "".
    if ppay-kom ne 0 then s-glkom = "Cумма погашаемой комиссии " + trim(string(ppay-kom ,">>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code.
    else s-glkom = "".


    if sds-pay ne 0 then do:
        if s-glrem3 <> "" then s-glrem3 = s-glrem3 + ", штрафов " + trim(string(sds-pay,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
        else s-glrem3 = "Сумма погашаемых штрафов " + trim(string(sds-pay,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
    end.

    display s-glrem2 s-glrem3 s-glkom with frame lon.
    pause 0.
    update v-name with frame lon.
    display v-name with frame lon.
    pause 0.
    update s-glrem2 with frame lon.
    display s-glrem2 with frame lon.
    pause 0.
    update s-glrem3 with frame lon.
    display s-glrem3 with frame lon.
    pause 0.
    update s-glkom with frame lon.
    display s-glkom with frame lon.
    pause 0.

    if lastkey = keycode("PF4") then next.
end.

s-lon = lon.lon.
if ppay = 0 and ipay = 0 and spay = 0 and apay = 0 and sds-pay = 0 and komcl-pay1 = 0 and komprcr-pay1 = 0 and komvacc-pay1 = 0 and komprod-pay1 = 0 and ppay-kom = 0 then undo,return.
ja = no.
update ja with frame lon.
if ja then do:

    if v-4ur > 0 or sds5 > 0 then
    message "Необходим перенос остатков с 4 и/или 5 уровней на 9 и/или 16 уровни соответственно!" view-as alert-box title "Внимание!".
    s-ordtype = 2. /* apmaksa */
    if s-ptype eq 1 or s-ptype eq 2 then
    update v-who v-passp v-perkod with frame f_cus.

    find lon where lon.lon eq s-lon no-lock no-error.
    find cif where cif.cif eq lon.cif no-lock no-error.
    find loncon where loncon.lon eq s-lon no-lock no-error.
    find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= g-today no-lock no-error.
    find crc where crc.crc eq lon.crc no-lock no-error.
    s-glrem = "Оплата по договору " + s-lon + " " + ln%his.lcnt + " " + trim(string(ln%his.opnamt,">>>,>>>,>>>,>>>,>>>,>>9.99-")) +
              " " + crc.code + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) /*+ " ИИН " + cif.jss*/ .
    if s-ptype = 4 then s-glrem = s-rmz + " " + s-glrem.

    s-glremx[1] = s-glrem.
    s-glremx[2] = s-glrem2.
    s-glremx[3] = s-glrem3.
    s-glremx[4] = v-name.
    if s-ptype = 1 or s-ptype = 2 then s-glremx[5] = "/ПЛАТЕЛЬЩИК/" + v-who + "/ПАСПОРТ/" + v-passp + "/ПЕРС.КОД/" + v-perkod.

    if v-transac = yes then run s-lontrx1.
    else message "Проводки запрещены!" view-as alert-box title "Внимание!".
end.
run clear-fg("C").

