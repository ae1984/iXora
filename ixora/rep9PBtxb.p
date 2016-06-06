/* rep9PBtxb.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет о состоянии финансовых требований к нерезидентам и обязательств перед ними
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU

 * BASES
         TXB BANK
 * AUTHOR
        28/12/2012 Luiza
 * CHANGES

*/



/******************************************************************************/

define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then
do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(txb.sysc.chval).

def shared var vasof  as date  no-undo.
def shared var vasof_f  as date  no-undo.

def var v-bald_b    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bald_e   as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-balf_b    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-balf_e    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal_b    as   dec  format "zz,zzz,zzz,zzz.99-".
def var v-bal_e    as   dec  format "zz,zzz,zzz,zzz.99-".
DEF VAR vbankname AS CHAR.
DEF VAR v-r AS CHAR.
DEF VAR v-countr AS CHAR.
DEF VAR v-vidur AS CHAR.
DEF VAR v-cgr AS CHAR.
DEF VAR v-hs AS CHAR.
DEF VAR v-geoi AS INT.
DEF VAR v-code AS CHAR.
DEF VAR vrdt AS date.
DEF VAR vedt AS date.
DEF VAR v-scu AS CHAR.
DEF VAR v-gl AS INT.

/******************************************************************************/
/*Временные таблицы*********************************************/
define shared temp-table tgl
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .

define shared temp-table tglf
    field txb    as character
    field gl     as integer
    field gl4 as integer
    field gl7 as integer
    field gl-des  as character
    field crc   as integer
    field sum  as decimal     format "->>>>>>>>>>>>>>9.99"
    field sum-val as decimal     format "->>>>>>>>>>>>>>9.99"
    field type as character
    field sub-type as character
    field totlev as integer
    field totgl  as integer
    field level as integer
    field code as character
    field grp as integer
    field acc as character
    field acc-des as character
    field geo as character
    field odt as date
    field cdt as date
    field perc as decimal
    field prod as char
    index tgl-id1 is primary gl7 .


/* таблицы для расшифровки  */
/* обороты */
define shared temp-table t-salde no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field dt as decimal
    field dttng as decimal
    field dtus as decimal
    field ct as decimal
    field cttng as decimal
    field ctus as decimal
    field rdt as date
    field rate as decimal
    field rateus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field jh as int
    field dc as char
    field ln as int
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb jh
    INDEX indwrk wrk num.

/* остатки */
define shared temp-table t-ost no-undo
    field num as char
    field num1 as char
    field num2 as char
    field gl as int
    field gl7 as int
    field acc as char
    field crc as int
    field b as decimal
    field btng as decimal
    field bus as decimal
    field e as decimal
    field etng as decimal
    field eus as decimal
    field rateb as decimal
    field ratebus as decimal
    field ratee as decimal
    field rateeus as decimal
    field country as char
    field cng as char
    field secek as char
    field vidur as char
    field dtop as date
    field dtcl as date
    field cntday as int
    field period as int
    field name as char
    field rez as char
    field txb as char
    field txbname as char
    field df as char
    field sub as char
    field wrk as char
    index ind is primary txb
    INDEX indwrk wrk num.

/* доходы-расходы */
define shared temp-table t-income no-undo
    field num as char
    field num1 as char
    field num2 as char
    field oper as char
    field oper1 as char
    field oper2  as char
    field gl as int
    field dt7 as int
    field ct7 as int
    field jh as int
    field rdt as date
    field name as char
    field dtacc as char
    field ctacc as char
    field sum1 as decimal   /* остаток на начало */
    field sumus1 as decimal
    field rateus1 as decimal
    field sumdt as decimal   /* обороты дебет */
    field sumusdt as decimal
    field rateus as decimal
    field sumct as decimal   /* обороты кредит */
    field sumusct as decimal
    field sum2 as decimal    /* остаток на конец */
    field sumus2 as decimal
    field rateus2 as decimal
    field rem as char
    field country as char
    field cng as char
    field txb as char
    field txbname as char
    field wrk as char
    field crc as int
    index ind is primary oper.

define shared temp-table wgl no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field num as char
    field wrk as char
    field df as char
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.

define shared temp-table wgl1 no-undo
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field code as char
    field grp as int
    field num as char
    field wrk as char
    field df as char
    index wgl-idx1 is unique primary gl.
/***************************************************************/
/*******************************************************************************************************/
define variable v-glout as integer no-undo.

function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
        if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.

function Convcrcb returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
    define buffer bcrc1 for txb.crchis.
    define buffer bcrc2 for txb.crchis.
    if c1 <> c2 then do:
        find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt < d1 no-lock no-error.
        find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt < d1 no-lock no-error.
        if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
    end.
    else return sum.
end function.

function GetRate returns decimal(crc$ as int, dt$ as date).
    find last txb.crchis where txb.crchis.crc = crc$ and txb.crchis.rdt <= dt$ no-lock no-error.
    if available txb.crchis then return txb.crchis.rate[1].
    else return 0.
end.
function GetRateb returns decimal(crc$ as int, dt$ as date).
    find last txb.crchis where txb.crchis.crc = crc$ and txb.crchis.rdt < dt$ no-lock no-error.
    if available txb.crchis then return txb.crchis.rate[1].
    else return 0.
end.
/*******************************************************************************************************/
function chek returns char (input p1 as char,input cod as char,input fil as char,input ggl as int,input vgl as int).
    def var res as char.
    res = "".
    case p1:
        when "251" then do:
            if string(ggl) begins "2203" then do:
                if INDEX( fil, "филиал" ) <> 0 or INDEX( fil, "Представительство" ) <> 0 then  res = "253".
                else res = "251".
            end.
        end.
        when "273" then do:
            if string(ggl) begins "2721" then do:
                if string(vgl) begins "2206" then  res = "267".
                else res = "273".
            end.
            else do:
                if INDEX( fil, "филиал" ) <> 0 or INDEX( fil, "Представительство" ) <> 0 then  res = "272".
                else res = "273".
            end.
        end.
        OTHERWISE res = p1.
    end case.
    return res.
end function.
/*-------------------------------------------------------------------------------------------------------------*/
find first comm.txb where comm.txb.bank = s-ourbank no-lock no-error.
if available comm.txb then vbankname = comm.txb.info.
displ  "Ждите, формир-ся данные " + vbankname format "x(70)" with row 5 overlay frame ww .
pause 0.
/*Сбор данных***********************************************************************************************************************************************************/
define buffer bjl for txb.jl.
define buffer bbjl for txb.jl.

for each wgl where wgl.subled <> "" no-lock :
    for each tgl where tgl.txb = s-ourbank and tgl.gl = wgl.gl and tgl.geo = "022" no-lock:
        v-r = "".
        v-countr = "".
        v-vidur = "".
        v-cgr = "".
        v-bald_b = 0.
        v-balf_b = 0.
        v-bald_e = 0.
        v-balf_e = 0.
        if wgl.sub = "CIF" or wgl.sub = "ARP" or wgl.sub = "LON" then do:   /* Клиентские счета*/
            find txb.aaa where txb.aaa.aaa = tgl.acc no-lock no-error.
            if available txb.aaa then do:
                find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif then do:
                    if NUM-ENTRIES(txb.cif.addr[1],",") >= 1 then v-countr = entry(1,txb.cif.addr[1],",").
                    else v-countr = txb.cif.addr[1].
                    v-vidur = txb.cif.prefix.
                end.
            end.
        end.
        if wgl.sub = "FUN" then do:   /* Казначейские счета*/
            find first txb.fun where txb.fun.fun = tgl.acc no-lock no-error.
            if available txb.fun then do:
                find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                if available txb.bankl and substring(string(txb.bankl.stn,"999"),3,1) eq "2"  then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.
        if wgl.sub = "DFB" then do:   /* Корреспондентские счета*/
            find first txb.dfb where txb.dfb.dfb = tgl.acc no-lock no-error.
            if available txb.dfb then do:
                find last txb.bankl where txb.bankl.bank eq txb.dfb.bank use-index bank no-lock no-error.
                if available txb.bankl and substring(string(txb.bankl.stn,"999"),3,1) eq "2" then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.
        if wgl.sub = "SCU" then do:   /* Ценные бумаги */
            find first txb.scu where txb.scu.scu = tgl.acc no-lock no-error.
            if available txb.scu then do:
                find last txb.bankl where txb.bankl.bank eq txb.scu.bank use-index bank no-lock no-error.
                if available txb.bankl then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.

        /* second date */
        if wgl.df = "d" then v-bald_e = tgl.sum-val.
        else v-balf_e = tgl.sum-val.

        /* first date */
        find first tglf where tglf.txb = s-ourbank and tglf.gl = wgl.gl and tglf.geo <> "021" and tglf.acc = tgl.acc no-lock no-error.
        if available tglf then do:
            if wgl.df = "d" then v-bald_b = tglf.sum-val.
            else v-balf_b = tglf.sum-val.
            tglf.prod = "yes".
        end.
        if substring(trim(tgl.acc),10,4) <> "" then v-glout = int(substring(trim(tgl.acc),10,4)).
        else v-glout = 0.
        create t-ost.
        t-ost.num = chek(wgl.num,substring(string(tgl.gl7),6,1),v-vidur,wgl.gl,v-glout).
        t-ost.num1 = "".
        t-ost.num2 = "".
        t-ost.gl = wgl.gl.
        t-ost.gl7 = tgl.gl7.
        t-ost.acc = tgl.acc.
        t-ost.crc = tgl.crc.
        if wgl.df = "d" then t-ost.b = v-bald_b.
        else t-ost.b = v-balf_b.
        if wgl.df = "d" then t-ost.btng = Convcrcb(v-bald_b,tgl.crc,1,vasof_f).
        else t-ost.btng = Convcrcb(v-balf_b,tgl.crc,1,vasof_f).
        if wgl.df = "d" then t-ost.bus = Convcrcb(v-bald_b,tgl.crc,2,vasof_f).
        else t-ost.bus = Convcrcb(v-balf_b,tgl.crc,2,vasof_f).

        if wgl.df = "d" then t-ost.e = v-bald_e.
        else t-ost.e = v-balf_e.
        if wgl.df = "d" then t-ost.etng =  Convcrc(v-bald_e,tgl.crc,1,vasof).
        else t-ost.etng = Convcrc(v-balf_e,tgl.crc,1,vasof).
        if wgl.df = "d" then t-ost.eus = Convcrc(v-bald_e,tgl.crc,2,vasof).
        else t-ost.eus = Convcrc(v-balf_e,tgl.crc,2,vasof).
        t-ost.rateb = GetRateb(tgl.crc,vasof_f).
        t-ost.ratebus = GetRateb(2,vasof_f).
        t-ost.ratee = GetRate(tgl.crc,vasof).
        t-ost.rateeus = GetRate(2,vasof).
        t-ost.country = v-countr.
        if INDEX( v-countr, "(RU)" ) <> 0 then t-ost.cng = "RU".
        else if INDEX(v-countr, "(AZ)") <> 0 or INDEX(v-countr, "(BY)") <> 0 or INDEX(v-countr, "(GE)") <> 0 or
                INDEX(v-countr, "(KG)") <> 0 or INDEX(v-countr, "(TJ)") <> 0 or INDEX(v-countr, "(TM)") <> 0 or
                INDEX(v-countr, "(UZ)") <> 0 or INDEX(v-countr, "(MD)") <> 0 or INDEX(v-countr, "(AM)") <> 0 or
                INDEX(v-countr, "(KZ)") <> 0 then t-ost.cng = "SNG".
        t-ost.secek = substring(string(tgl.gl7),6,1).
        t-ost.vidur = v-vidur.
        t-ost.dtop = tgl.odt.
        t-ost.dtcl = tgl.cdt.
        t-ost.cntday = t-ost.dtcl - t-ost.dtop.
        /*  t-ost.period = "". */
        t-ost.name = tgl.acc-des.
        t-ost.rez = substring(tgl.geo,3,1).
        t-ost.txb = s-ourbank.
        t-ost.txbname = vbankname.
        t-ost.df = wgl.df.
        t-ost.wrk = wgl.wrk.
        t-ost.sub = wgl.subled.
        /*Обороты */
        for each txb.jl where txb.jl.acc = tgl.acc and txb.jl.jdt >= vasof_f and txb.jl.jdt <= vasof and txb.jl.gl = wgl.gl use-index acc no-lock:
            create t-salde.
            t-salde.num = chek(wgl.num,substring(string(tgl.gl7),6,1),v-vidur,wgl.gl,v-glout).
            t-salde.num1 = "".
            t-salde.num2 = "".
            t-salde.gl = wgl.gl.
            t-salde.gl7 = tgl.gl7.
            t-salde.acc = txb.jl.acc.
            t-salde.crc = txb.jl.crc.
            t-salde.dt = txb.jl.dam.
            t-salde.dttng = Convcrc(txb.jl.dam,txb.jl.crc,1,txb.jl.jdt).
            t-salde.dtus = Convcrc(txb.jl.dam,txb.jl.crc,2,txb.jl.jdt).
            t-salde.ct = txb.jl.cam.
            t-salde.cttng = Convcrc(txb.jl.cam,txb.jl.crc,1,txb.jl.jdt).
            t-salde.ctus = Convcrc(txb.jl.cam,txb.jl.crc,2,txb.jl.jdt).
            t-salde.rdt = txb.jl.jdt.
            t-salde.rate = GetRate(txb.jl.crc,txb.jl.jdt).
            t-salde.rateus = GetRate(2,txb.jl.jdt).
            t-salde.country = v-countr.
            if INDEX( v-countr, "(RU)" ) <> 0 then t-salde.cng = "RU".
            else if INDEX(v-countr, "(AZ)") <> 0 or INDEX(v-countr, "(BY)") <> 0 or INDEX(v-countr, "(GE)") <> 0 or
                    INDEX(v-countr, "(KG)") <> 0 or INDEX(v-countr, "(TJ)") <> 0 or INDEX(v-countr, "(TM)") <> 0 or
                    INDEX(v-countr, "(UZ)") <> 0 or INDEX(v-countr, "(MD)") <> 0 or INDEX(v-countr, "(AM)") <> 0 or
                    INDEX(v-countr, "(KZ)") <> 0 then t-salde.cng = "SNG".
            t-salde.secek = substring(string(tgl.gl7),6,1).
            t-salde.vidur = v-vidur.
            t-salde.dtop = tgl.odt.
            t-salde.dtcl = tgl.cdt.
            t-salde.cntday = t-salde.dtcl - t-salde.dtop.
            /*  t-salde.period = "". */
            t-salde.name = tgl.acc-des.
            t-salde.rez = substring(tgl.geo,3,1).
            t-salde.txb = s-ourbank.
            t-salde.txbname = vbankname.
            t-salde.jh = txb.jl.jh.
            t-salde.dc = txb.jl.dc.
            t-salde.ln = txb.jl.ln.
            t-salde.df = wgl.df.
            t-salde.wrk = wgl.wrk.
            t-salde.sub = wgl.subled.
            /* сбор данных для Раздела III. Текущие операции банка с нерезидентами за отчетный период */
        end. /*for each txb.jl */
        run currentop(tgl.acc,v-countr,tgl.gl7,tgl.acc-des,wgl.num).
    end. /* for each tgl */
end.  /*   for each wgl     */
/***************************************************************************************************************************************************************/
/* для счетов которых не было в tgl */
for each wgl where wgl.subled <> "" no-lock :
    for each tglf where tglf.txb = s-ourbank and tglf.gl = wgl.gl and tglf.geo = "022" and tglf.prod = "no" no-lock:
        v-r = "".
        v-countr = "".
        v-vidur = "".
        v-cgr = "".
        v-bald_b = 0.
        v-balf_b = 0.
        v-bald_e = 0.
        v-balf_e = 0.
        if wgl.sub = "CIF" or wgl.sub = "ARP" or wgl.sub = "LON" then do:   /* Клиентские счета*/
            find txb.aaa where txb.aaa.aaa = tglf.acc no-lock no-error.
            if available txb.aaa then do:
                find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                if avail txb.cif then do:
                    if NUM-ENTRIES(txb.cif.addr[1],",") >= 1 then v-countr = entry(1,txb.cif.addr[1],",").
                    else v-countr = txb.cif.addr[1].
                    v-vidur = txb.cif.prefix.
                end.
            end.
        end.
        if wgl.sub = "FUN" then do:   /* Казначейские счета*/
            find first txb.fun where txb.fun.fun = tglf.acc no-lock no-error.
            if available txb.fun then do:
                find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                if available txb.bankl and substring(string(txb.bankl.stn,"999"),3,1) eq "2"  then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.
        if wgl.sub = "DFB" then do:   /* Корреспондентские счета*/
            find first txb.dfb where txb.dfb.dfb = tglf.acc no-lock no-error.
            if available txb.dfb then do:
                find last txb.bankl where txb.bankl.bank eq txb.dfb.bank use-index bank no-lock no-error.
                if available txb.bankl and substring(string(txb.bankl.stn,"999"),3,1) eq "2" then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.
        if wgl.sub = "SCU" then do:   /* Ценные бумаги */
            find first txb.scu where txb.scu.scu = tglf.acc no-lock no-error.
            if available txb.scu then do:
                find last txb.bankl where txb.bankl.bank eq txb.scu.bank use-index bank no-lock no-error.
                if available txb.bankl then v-countr = "("  + txb.bankl.frbno + ")".
            end.
        end.

        /* first date */
        if wgl.df = "d" then v-bald_b = tglf.sum-val.
        else v-balf_b = tglf.sum-val.

        if substring(trim(tglf.acc),10,4) <> "" then v-glout = int(substring(trim(tglf.acc),10,4)).
        else v-glout = 0.
        create t-ost.
        t-ost.num = chek(wgl.num,substring(string(tglf.gl7),6,1),v-vidur,wgl.gl,v-glout).
        t-ost.num1 = "".
        t-ost.num2 = "".
        t-ost.gl = wgl.gl.
        t-ost.gl7 = tglf.gl7.
        t-ost.acc = tglf.acc.
        t-ost.crc = tglf.crc.
        if wgl.df = "d" then t-ost.b = v-bald_b.
        else t-ost.b = v-balf_b.
        if wgl.df = "d" then t-ost.btng = Convcrcb(v-bald_b,tglf.crc,1,vasof_f).
        else t-ost.btng = Convcrcb(v-balf_b,tglf.crc,1,vasof_f).
        if wgl.df = "d" then t-ost.bus = Convcrcb(v-bald_b,tglf.crc,2,vasof_f).
        else t-ost.bus = Convcrcb(v-balf_b,tglf.crc,2,vasof_f).

        if wgl.df = "d" then t-ost.e = v-bald_e.
        else t-ost.e = v-balf_e.
        if wgl.df = "d" then t-ost.etng =  Convcrc(v-bald_e,tglf.crc,1,vasof).
        else t-ost.etng = Convcrc(v-balf_e,tglf.crc,1,vasof).
        if wgl.df = "d" then t-ost.eus = Convcrc(v-bald_e,tglf.crc,2,vasof).
        else t-ost.eus = Convcrc(v-balf_e,tglf.crc,2,vasof).
        t-ost.rateb = GetRateb(tglf.crc,vasof_f).
        t-ost.ratebus = GetRateb(2,vasof_f).
        t-ost.ratee = GetRate(tglf.crc,vasof).
        t-ost.rateeus = GetRate(2,vasof).
        t-ost.country = v-countr.
        if INDEX( v-countr, "(RU)" ) <> 0 then t-ost.cng = "RU".
        else if INDEX(v-countr, "(AZ)") <> 0 or INDEX(v-countr, "(BY)") <> 0 or INDEX(v-countr, "(GE)") <> 0 or
                INDEX(v-countr, "(KG)") <> 0 or INDEX(v-countr, "(TJ)") <> 0 or INDEX(v-countr, "(TM)") <> 0 or
                INDEX(v-countr, "(UZ)") <> 0 or INDEX(v-countr, "(MD)") <> 0 or INDEX(v-countr, "(AM)") <> 0 or
                INDEX(v-countr, "(KZ)") <> 0 then t-ost.cng = "SNG".
        t-ost.secek = substring(string(tglf.gl7),6,1).
        t-ost.vidur = v-vidur.
        t-ost.dtop = tglf.odt.
        t-ost.dtcl = tglf.cdt.
        t-ost.cntday = t-ost.dtcl - t-ost.dtop.
        /*  t-ost.period = "". */
        t-ost.name = tglf.acc-des.
        t-ost.rez = substring(tglf.geo,3,1).
        t-ost.txb = s-ourbank.
        t-ost.txbname = vbankname.
        t-ost.df = wgl.df.
        t-ost.wrk = wgl.wrk.
        t-ost.sub = wgl.subled.
        /*Обороты */
        for each txb.jl where txb.jl.acc = tglf.acc and txb.jl.jdt >= vasof_f and txb.jl.jdt <= vasof  and txb.jl.gl = wgl.gl use-index acc no-lock:
            create t-salde.
            t-salde.num = chek(wgl.num,substring(string(tglf.gl7),6,1),v-vidur,wgl.gl,v-glout).
            t-salde.num1 = "".
            t-salde.num2 = "".
            t-salde.gl = wgl.gl.
            t-salde.gl7 = tglf.gl7.
            t-salde.acc = txb.jl.acc.
            t-salde.crc = txb.jl.crc.
            t-salde.dt = txb.jl.dam.
            t-salde.dttng = Convcrc(txb.jl.dam,txb.jl.crc,1,txb.jl.jdt).
            t-salde.dtus = Convcrc(txb.jl.dam,txb.jl.crc,2,txb.jl.jdt).
            t-salde.ct = txb.jl.cam.
            t-salde.cttng = Convcrc(txb.jl.cam,txb.jl.crc,1,txb.jl.jdt).
            t-salde.ctus = Convcrc(txb.jl.cam,txb.jl.crc,2,txb.jl.jdt).
            t-salde.rdt = txb.jl.jdt.
            t-salde.rate = GetRate(txb.jl.crc,txb.jl.jdt).
            t-salde.rateus = GetRate(2,txb.jl.jdt).
            t-salde.country = v-countr.
            if INDEX( v-countr, "(RU)" ) <> 0 then t-salde.cng = "RU".
            else if INDEX(v-countr, "(AZ)") <> 0 or INDEX(v-countr, "(BY)") <> 0 or INDEX(v-countr, "(GE)") <> 0 or
                    INDEX(v-countr, "(KG)") <> 0 or INDEX(v-countr, "(TJ)") <> 0 or INDEX(v-countr, "(TM)") <> 0 or
                    INDEX(v-countr, "(UZ)") <> 0 or INDEX(v-countr, "(MD)") <> 0 or INDEX(v-countr, "(AM)") <> 0 or
                    INDEX(v-countr, "(KZ)") <> 0 then t-salde.cng = "SNG".
            t-salde.secek = substring(string(tglf.gl7),6,1).
            t-salde.vidur = v-vidur.
            t-salde.dtop = tglf.odt.
            t-salde.dtcl = tglf.cdt.
            t-salde.cntday = t-salde.dtcl - t-salde.dtop.
            /*  t-salde.period = "". */
            t-salde.name = tglf.acc-des.
            t-salde.rez = substring(tglf.geo,3,1).
            t-salde.txb = s-ourbank.
            t-salde.txbname = vbankname.
            t-salde.jh = txb.jl.jh.
            t-salde.dc = txb.jl.dc.
            t-salde.ln = txb.jl.ln.
            t-salde.df = wgl.df.
            t-salde.wrk = wgl.wrk.
            t-salde.sub = wgl.subled.
            /* сбор данных для Раздела III. Текущие операции банка с нерезидентами за отчетный период */
        end. /*for each txb.jl */
        run currentop(tglf.acc,v-countr,tglf.gl7,tglf.acc-des,wgl.num).
    end. /* for each tglf */
end.  /*   for each wgl     */
/***************************************************************************************************************************************************************/

/* GL, не имеющие sub */
    for each wgl where wgl.subled = '' no-lock.
        for each txb.crchs no-lock.
            v-bal_b = 0.
            v-bal_e = 0.
            v-code = "".
            v-cgr = "".
            v-r = "".
            v-hs = "".
            if txb.crchs.hs eq "L" then v-hs = "1".
            else
                if txb.crchs.hs eq "H" then v-hs = "2".
                else if txb.crchs.hs eq "S" then v-hs = "3".

            if v-hs = "1" then v-r = "1".
            else v-r = "2".
            if v-r = "2" then do:
                find last txb.glday where txb.glday.gl = wgl.gl and txb.glday.crc = txb.crchs.crc and txb.glday.gdt < vasof_f use-index glday no-lock no-error.
                if available txb.glday  then do:
                    if txb.glday.gl lt 105000 then v-cgr = "3".
                    else
                        if string(glday.gl) begins "2551" then v-cgr = "4".
                        else v-cgr = "6".

                    v-code = string(truncate(glday.gl / 100, 0)) + v-r + v-cgr + v-hs.
                    v-bal_b = txb.glday.cam - txb.glday.dam.
                    v-bal_b = absolute(v-bal_b).


                    find last txb.glday where txb.glday.gl = wgl.gl and txb.glday.crc = txb.crchs.crc and txb.glday.gdt <= vasof use-index glday no-lock no-error.
                    if available txb.glday  then do:
                        v-bal_e = txb.glday.cam - txb.glday.dam.
                        v-bal_e = absolute(v-bal_e).
                    end.

                    if v-bal_b <> 0 or v-bal_e <> 0 then do:
                        create t-ost.
                        t-ost.num = chek(wgl.num,v-cgr,v-vidur,wgl.gl,wgl.gl).
                        t-ost.num1 = "".
                        t-ost.num2 = "".
                        t-ost.gl = wgl.gl.
                        t-ost.gl7 = int(v-code).
                        t-ost.crc = txb.glday.crc.
                        t-ost.b = v-bal_b.
                        t-ost.btng = Convcrcb(v-bal_b,txb.glday.crc,1,vasof_f).
                        t-ost.bus = Convcrcb(v-bal_b,txb.glday.crc,2,vasof_f).

                        t-ost.e = v-bal_e.
                        t-ost.etng = Convcrc(v-bal_e,txb.glday.crc,1,vasof).
                        t-ost.eus = Convcrc(v-bal_e,txb.glday.crc,2,vasof).
                        t-ost.rateb = GetRateb(txb.glday.crc,vasof_f).
                        t-ost.ratebus = GetRateb(2,vasof_f).
                        t-ost.ratee = GetRate(txb.glday.crc,vasof).
                        t-ost.rateeus = GetRate(2,vasof).
                        t-ost.secek = v-cgr.
                        t-ost.name = wgl.des.
                        t-ost.rez = v-r.
                        if txb.glday.crc = 4 then t-ost.cng = "RU".
                        t-ost.txb = s-ourbank.
                        t-ost.txbname = vbankname.
                        t-ost.df = wgl.df.
                        t-ost.wrk = wgl.wrk.
                        t-ost.sub = wgl.subled.
                    end.
                    /*Обороты */
                    for each txb.jl where txb.jl.jdt >= vasof_f and txb.jl.jdt <= vasof and txb.jl.gl = wgl.gl and txb.jl.crc = txb.crchs.crc and substring(string(txb.jl.gl),1,4) <> "2551" use-index jdt no-lock:
                        create t-salde.
                        t-salde.num = chek(wgl.num,v-cgr,v-vidur,wgl.gl,wgl.gl).
                        t-salde.num1 = "".
                        t-salde.num2 = "".
                        t-salde.gl = wgl.gl.
                        t-salde.gl7 = int(v-code).
                        t-salde.acc = txb.jl.acc.
                        t-salde.crc = txb.jl.crc.
                        t-salde.dt = txb.jl.dam.
                        t-salde.dttng = Convcrc(txb.jl.dam,txb.jl.crc,1,txb.jl.jdt).
                        t-salde.dtus = Convcrc(txb.jl.dam,txb.jl.crc,2,txb.jl.jdt).
                        t-salde.ct = txb.jl.cam.
                        t-salde.cttng = Convcrc(txb.jl.cam,txb.jl.crc,1,txb.jl.jdt).
                        t-salde.ctus = Convcrc(txb.jl.cam,txb.jl.crc,2,txb.jl.jdt).
                        t-salde.rdt = txb.jl.jdt.
                        t-salde.rate = GetRate(txb.jl.crc,txb.jl.jdt).
                        t-salde.rateus = GetRate(2,txb.jl.jdt).
                        t-salde.secek = v-cgr.
                        t-salde.name = wgl.des.
                        t-salde.rez = v-r.
                        if txb.jl.crc = 4 then t-salde.cng = "RU".
                        t-salde.txb = s-ourbank.
                        t-salde.txbname = vbankname.
                        t-salde.jh = txb.jl.jh.
                        t-salde.dc = txb.jl.dc.
                        t-salde.ln = txb.jl.ln.
                        t-salde.df = wgl.df.
                        t-salde.wrk = wgl.wrk.
                        t-salde.sub = wgl.subled.
                    end.
                end. /* if available txb.glday  */
            end.  /* if v-r = "2"  */
        end. /* for each txb.crchs */
    end. /* for wgl  */
/*Окончание сбора данных************************************************************************************************************************************************/

procedure currentop: /* сбор данных для Раздела III. Текущие операции банка с нерезидентами за отчетный период */
    define input parameter acc as char.  /* 20 значн счет */
    define input parameter countr as char.  /* назначение */
    define input parameter vcode as int.  /* балансовый счет 7 знаков */
    define input parameter nname as char.  /* name */
    define input parameter num as char.  /* шифр основной части */
    v-cgr = "".
    v-r = "".
    v-hs = "".
    for each bjl where bjl.jdt >= vasof_f and bjl.jdt <= vasof and bjl.acc = acc no-lock.
        for each bbjl where bbjl.jh = bjl.jh no-lock.
            find first wgl1 where wgl1.gl = bbjl.gl no-lock no-error.
            if available wgl1 or string(bbjl.gl) begins "4" or string(bbjl.gl) = "5" then do:
                find last txb.crchs where txb.crchs.crc eq bbjl.crc no-lock no-error.
                if available txb.crchs then do:
                    if txb.crchs.hs eq "L" then v-hs = "1".
                    else
                        if txb.crchs.hs eq "H" then v-hs = "2".
                        else if txb.crchs.hs eq "S" then v-hs = "3".
                end.
                if v-hs = "1" then v-r = "1".
                else v-r = "2".
                if bbjl.gl lt 105000 then v-cgr = "3".
                else
                    if string(bbjl.gl) begins "2551" then v-cgr = "4".
                    else v-cgr = "6".
                create t-income.
                t-income.num = num.
                t-income.num1 = "".
                t-income.num2 = "".
                if available wgl1 then t-income.oper = wgl1.num.
                else if string(bbjl.gl) begins "4" then t-income.oper = "476". /* прочие поступления */
                     else if string(bbjl.gl) = "5" then t-income.oper = "487".  /* прочие выплаты */
                t-income.oper1 = "".
                t-income.oper2 = "".
                t-income.gl = bbjl.gl.
                if bbjl.dc = "d" then do:
                    t-income.dt7 = int(substring(string(bbjl.gl),1,4) + v-r + v-cgr + v-hs).
                    t-income.ct7 = vcode.
                    t-income.dtacc = bbjl.acc.
                    t-income.ctacc = acc.
                    t-income.sumdt = Convcrc(bbjl.dam,bbjl.crc,1,bbjl.jdt).
                    t-income.sumusdt = Convcrc(bbjl.dam,bbjl.crc,2,bbjl.jdt).
               end.
               else do:
                    t-income.dt7 = vcode.
                    t-income.ct7 = int(substring(string(bbjl.gl),1,4) + v-r + v-cgr + v-hs).
                    t-income.dtacc = acc.
                    t-income.ctacc = bbjl.acc.
                    t-income.sumct = Convcrc(bbjl.cam,bbjl.crc,1,bbjl.jdt).
                    t-income.sumusct = Convcrc(bbjl.cam,bbjl.crc,2,bbjl.jdt).
               end.
                t-income.crc = bbjl.crc.
                t-income.rateus = GetRate(2,bbjl.jdt).
                t-income.rdt = bbjl.jdt.
                t-income.txb = s-ourbank.
                t-income.txbname = vbankname.
                t-income.jh = bbjl.jh.
                t-income.rem = bbjl.rem[1].
                t-income.name = nname.
                t-income.country = countr.
                if INDEX( countr, "(RU)" ) <> 0 then t-income.cng = "RU".
                else if INDEX(countr, "(AZ)") <> 0 or INDEX(countr, "(BY)") <> 0 or INDEX(countr, "(GE)") <> 0 or
                        INDEX(countr, "(KG)") <> 0 or INDEX(countr, "(TJ)") <> 0 or INDEX(countr, "(TM)") <> 0 or
                        INDEX(countr, "(UZ)") <> 0 or INDEX(countr, "(MD)") <> 0 or INDEX(countr, "(AM)") <> 0 then t-income.cng = "SNG".
            end.
        end.
    end.
end procedure.

hide all.


