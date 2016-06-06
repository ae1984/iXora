/* repayment1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        отчет Сведения о фактическом погашении обязательств перед нерезидентами Республики Казахстан
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
        29/11/2012 Luiza
 * BASES
        BANK COMM TXB
 * CHANGES
*/

def shared var v-fil-cnt as char format "x(30)".
def shared var v-fil-int as int.
def shared var v-ful1 as int no-undo.
def shared var v-sel as int no-undo.

find first txb.cmp no-lock no-error.
if available txb.cmp then v-fil-cnt = txb.cmp.name.
displ  "Ждите, формир-ся данные " + v-fil-cnt format "x(70)" with row 15 frame ww .
pause 0.
v-fil-int = v-fil-int + 1.
def var v-txb as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
v-txb = trim(txb.sysc.chval).

def shared temp-table wrk2 no-undo  /* план факт для текущего года  */
    field Num as integer
    field vid as char
    field vid1 as char
    field vid2 as char
    field year as int
    field month as int
    field p_debt as decim extent 13
    field f_debt as decim extent 13
    field p_reward as decim extent 13
    field f_reward as decim extent 13.

def shared temp-table wrk3 no-undo /* план факт для следующего года  */
    field Num as integer
    field vid as char
    field vid1 as char
    field vid2 as char
    field year as int
    field month as int
    field p_debt as decim extent 13
    field f_debt as decim extent 13
    field p_reward as decim extent 13
    field f_reward as decim extent 13.

def shared temp-table wrk no-undo  /* факт */
    field Num as integer
    field vid as char
    field sub as char
    field vid1 as char
    field vid2 as char
    field jh as int
    field whn as date
    field month as int
    field p_debt as decim extent 12
    field f_debt as decim extent 12
    field p_reward as decim extent 12
    field f_reward as decim extent 12
    field cif as char /* cif клиента */
    field name as char /* наименование  */
    field acc as char /* счет  */
    field geo as char /* гео код */
    field pri as char /* физ юр  */
    field gl4 as char /* балансовый счет 4 знака */
    field gl7 as char /* 7 знаков  + IBAN  */
    field crc as int /* валюта счета  */
    field dopen as date /* дата открытия счета  */
    field dclose as date /* дата закрытия  */
    field stav as decim /* проц ставки  */
    field dt4 as char /* дебет бал счет 4 знака  */
    field dt7 as char /* дебет бал счет 7 знака   */
    field ct4 as char /* кредит бал счет 4 знака  */
    field ct7 as char /* кредит бал счет 7 знака  */
    field sumd as decim /* сумма номинал дебета */
    field sumtngd as decim /* сумма в тенге  */
    field sumc as decim /* сумма номинал кредита */
    field sumtngc as decim /* сумма в тенге  */
    field fil as char /* филиал  */
    field txb as char /* филиал  */
    field df as char /* долг вознагр признак */
    index ind is primary txb num cif acc .

def shared temp-table wrk1 no-undo   /* план */
    field Num as integer
    field vid as char
    field sub as char
    field vid1 as char
    field vid2 as char
    field jh as int
    field month as int
    field p_debt as decim
    field f_debt as decim
    field p_reward as decim
    field f_reward as decim
    field cif as char /* cif клиента */
    field name as char /* наименование  */
    field acc as char /* счет  */
    field geo as char /* гео код */
    field pri as char /* физ юр  */
    field gl4 as char /* балансовый счет 4 знака */
    field gl7 as char /* 7 знаков  + IBAN  */
    field crc as int /* валюта счета  */
    field dopen as date /* дата открытия счета  */
    field dclose as date /* дата закрытия  */
    field stav as decim /* проц ставки  */
    field dt4 as char /* дебет бал счет 4 знака  */
    field dt7 as char /* дебет бал счет 7 знака   */
    field ct4 as char /* кредит бал счет 4 знака  */
    field ct7 as char /* кредит бал счет 7 знака  */
    field sum as decim /* сумма номинал  */
    field sumtngd as decim /* сумма в тенге  */
    field sumtngr as decim /* сумма в тенге  */
    field ostf as decim /* сумма в тенге  */
    field oste as decim /* сумма в тенге  */
    field fil as char /* филиал  */
    field txb as char /* филиал  */
    field df as char /* долг вознагр признак */
    index ind is primary txb acc.

define temp-table wgl no-undo
    field Num as integer
    field vid as char
    field gl     as integer /*like gl.gl*/
    field des as character
    field lev as integer
    field subled as character /*like gl.subled*/
    field type   as character /*like gl.type*/
    field grp as int
    field dc as char
    field code as char
    index wgl-idx1 is unique primary gl
    index wgl-idx2  subled.


def shared var dt1 as date no-undo.
def shared var dt2 as date no-undo.
def shared var dt3 as date no-undo.
def shared var dt4 as date no-undo.
def shared var vmonth as int  no-undo.

def var kol1 as int.
def var kol2 as int.
def var vsub as char.
def buffer b-jl for txb.jl.
def buffer b-histrxbal for txb.histrxbal.
def var vstrgl as char  no-undo.
def var vstrgld as char  no-undo.
def var vstrglc as char  no-undo.
def var v-cgr as char  no-undo.
def var v-r as char  no-undo.
def var v-hs as char  no-undo.
def var v-geoi as int  no-undo.
def var v-pp as int  no-undo.
def var v-cls as char no-undo.
def var v-ddd as logic no-undo. /* признак того что запись прошла по долгу */


function getSUMtng returns deci (input p-sum as decimal, input p-dt as date, input crc as integer).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    find first txb.crc where txb.crc.crc = crc no-lock no-error.
    if avail txb.crc then do:
        res1 = p-sum.
        if res1 <> 0 then do:
            if txb.crc.crc = 1 then res = res + res1.
            else do:
                find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                if avail txb.crchis then res = res + (res1 * txb.crchis.rate[1]).
            end.
        end.
    end.
    return res.
end function.

/* определение счета главной книги */
function fgl return integer (input v-gl as integer, input v-lev as integer).
    define variable v-glout as integer no-undo.
    v-glout = 0.
    find txb.gl where txb.gl.gl eq v-gl no-lock no-error.
    if available txb.gl then
    do :
        find txb.trxlevgl where txb.trxlevgl.gl eq v-gl
            and txb.trxlevgl.lev eq v-lev
            and txb.trxlevgl.sub eq gl.subled use-index glsublev no-lock no-error.
        if available txb.trxlevgl then v-glout = txb.trxlevgl.glr.
    end.
    return v-glout.
end function.

/*******************************************************************************************************/
function Igl return integer(input gl as integer, input v-lev as integer,
    input acc as character,input des as character, input sub as character, input v-crc as integer,
    input v-r as character, input v-cgr as character, input v-hs as character,
    input odt as date, input cdt as date,
    input perc as decimal, input prod as char).
    /*if cdt >= dt1 and cdt <= dt2 then do:*/  /* закроется в следующем месяце */
        define variable v-gl   as integer.
        define variable v-code as character.
        define variable v-bal  as decimal.
        define variable v-bale  as decimal.
        define variable v-bal2_f  as decimal.
        v-gl = fgl(gl,v-lev).
        find wgl where wgl.gl = v-gl no-lock no-error.
        if available wgl then do :

            v-code = string(truncate(v-gl / 100, 0)) + v-r + v-cgr + v-hs.
            if v-code eq ? or index(v-code,"msc") > 0 then return 1.
            /*find last txb.histrxbal where  txb.histrxbal.dt < dt1 and txb.histrxbal.acc = acc and
                txb.histrxbal.lev = 1 and
                txb.histrxbal.subled  = sub and
                txb.histrxbal.crc = v-crc
                use-index dtacc no-lock no-error.
            if available txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam. else v-bal = 0.*/
            run lonbalcrc_txb(sub,acc,dt1,"1",yes,v-crc,output v-bal).
            v-bal = - v-bal.
            /*find last b-histrxbal where  b-histrxbal.dt < dt2 and b-histrxbal.acc = acc and
                b-histrxbal.lev = 1 and
                b-histrxbal.subled  = sub and
                b-histrxbal.crc = v-crc
                use-index dtacc no-lock no-error.
            if available b-histrxbal then v-bale = b-histrxbal.cam - b-histrxbal.dam. else v-bale = 0.*/

            run lonbalcrc_txb(sub,acc,dt2,"1",yes,v-crc,output v-bale).
            v-bale = - v-bale.

            v-bal2_f = 0.
            run lonbalcrc_txb(sub,acc,dt2 + 1,"2",no,v-crc,output v-bal2_f).
            v-bal2_f = - v-bal2_f.

            /*if wgl.type eq "A" or wgl.type eq "E" then v-bal = - v-bal.
            find txb.sub-cod where txb.sub-cod.sub = "gld" and txb.sub-cod.d-cod = "gldic"
                           and txb.sub-cod.acc = string(v-gl) no-lock no-error.
            if available txb.sub-cod and txb.sub-cod.ccode eq "01" and v-bal <> 0 then v-bal = - v-bal.*/

            if perc = 0 then do:
                find first txb.deal where txb.deal.deal = acc no-lock no-error.
                if avail txb.deal then perc = txb.deal.intrate.
            end.
            if des = "" then des = wgl.des.
            find first wrk1 where wrk1.txb = v-txb and wrk1.acc = acc no-error.
            if not available wrk1 or (wgl.dc = "d" and wrk1.sumtngd <> 0 ) or (wgl.dc = "f" and wrk1.sumtngr <> 0) then do:
                create wrk1.
                wrk1.txb = v-txb.
                wrk1.fil = v-fil-cnt.
                wrk1.name = des.
                wrk1.dopen = odt.
                wrk1.dclose = cdt.
                wrk1.geo = "02" + v-r.
                wrk1.stav = perc.
                wrk1.crc = v-crc.
                wrk1.acc = acc.
                wrk1.vid = wgl.vid.
                wrk1.num = wgl.num.
                wrk1.ostf = getSUMtng(v-bal,dt1,v-crc).
                wrk1.oste = getSUMtng(v-bale,dt2,v-crc).
            end.
            if wgl.dc = "d" then do:
                wrk1.dt4 = substring(v-code,1,4).
                wrk1.dt7 = v-code.
                wrk1.p_debt = v-bale.
                wrk1.sumtngd = getSUMtng(v-bale,dt2,v-crc).
                if cdt >= dt3 and cdt <= dt4 then wrk1.df = wgl.dc.
                /*find first wrk3 where wrk3.num = wgl.num no-error.
                if available wrk3 then wrk3.f_debt[month(dt1)] = wrk3.f_debt[month(dt1)] + v-bal.*/
            end.
            if wgl.dc = "f" then do:
                wrk1.ct4 = substring(v-code,1,4).
                wrk1.ct7 = v-code.
                wrk1.p_reward = v-bal2_f.
                wrk1.sumtngr = getSUMtng(v-bal2_f,dt2,v-crc).
                if cdt >= dt3 and cdt <= dt4 then wrk1.df = wgl.dc.
                /*find first wrk3 where wrk3.num = wgl.num no-error.
                if available wrk3 then wrk3.f_reward[month(dt1)] = wrk3.f_reward[month(dt1)] + v-bal.*/
            end.
        end.
   /* end.*/
end function.
/*******************************************************************************************************/
def var isklu as char.
def var iskbeg as char.
iskbeg = "2,4,5".
isklu = "2700,2810, 2830,2024, 2041, 2042, 2047, 2048, 2055, 2058, 2059, 2065, 2068, 2069, 2070, 2128, 2129, 2135, 2136, 2137,
            2138, 2224, 2225, 2226, 2231, 2232, 2233, 2234, 2235, 2236, 2238, 2239, 2304, 2305, 2403, 2404".

/* собираем факт  */
if v-sel = 1 or v-sel = 2 then do:
    for each txb.jl  where txb.jl.jdt >= dt1  and txb.jl.jdt <= dt2 and lookup(substring(string(txb.jl.gl),1,1),iskbeg) > 0  no-lock.
        v-pp = 0.
        for each wrk2.
            kol1 = num-entries(wrk2.vid1).  /* долг */
            kol2 = num-entries(wrk2.vid2).  /* вознагражд */

            do while kol1 >= 1:
                if string(txb.jl.gl) begins entry(kol1,wrk2.vid1) then do:
                    find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
                    /* счет указанного ГК клиентский*/
                    if txb.gl.subled = 'cif' then do:
                        find first txb.aaa where txb.aaa.aaa = txb.jl.acc  use-index aaa no-lock no-error.
                        if available txb.aaa then do:
                            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                            if available txb.cif and substring(string(integer(txb.cif.geo),"999"),3,1) = "2" then do:
                                v-ddd = no.
                                if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                    if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                        substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:

                                        wrk2.f_debt[month(txb.jl.whn)] = wrk2.f_debt[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                        wrk2.f_debt[13] = wrk2.f_debt[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                        v-ddd = yes.
                                    end.
                                end.
                                v-pp = 1. /* проводка попала в один из видов заимств-й */
                                create wrk.
                                wrk.Num = wrk2.Num.
                                wrk.vid = wrk2.vid.
                                wrk.sub = txb.gl.subled.
                                wrk.jh = txb.jl.jh.
                                wrk.whn = txb.jl.jdt.
                                wrk.month = month(txb.jl.whn).
                                wrk.f_debt[month(txb.jl.whn)] =  txb.jl.dam.
                                wrk.cif = txb.aaa.cif.
                                wrk.acc = txb.aaa.aaa.
                                wrk.name = txb.cif.sname.
                                wrk.geo = txb.cif.geo.
                                /*wrk.pri = txb.cif.type.*/
                                /*  ищем код резид сектор эконом и тип валюты  */
                                v-hs = "".
                                v-cgr = "".
                                find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
                                if txb.crchs.hs eq "L" then v-hs = "1".
                                else if txb.crchs.hs eq "H" then v-hs = "2".
                                    else if txb.crchs.hs eq "S" then v-hs = "3".
                                 v-r = "2".
                                find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                                if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

                                wrk.pri = v-cgr.
                                wrk.gl4 = entry(kol1,wrk2.vid1).
                                wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                wrk.crc = txb.aaa.crc.
                                wrk.dopen = txb.aaa.regdt.
                                find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                                if available txb.acvolt and date(txb.acvolt.x1) < dt2 then wrk.dclose = date(txb.acvolt.x3).
                                else wrk.dclose = txb.aaa.expdt.
                                wrk.stav = txb.aaa.rate.
                                if txb.jl.dc = "D" then do:
                                    wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                    wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                    wrk.sumd = txb.jl.dam.
                                    wrk.sumtngd = getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.ct4 = substring(string(b-jl.gl),1,4).
                                        wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                        wrk.sumc = b-jl.cam.
                                        wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                else do:
                                    wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                    wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                    wrk.sumc = txb.jl.cam .
                                    wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.dt4 = substring(string(b-jl.gl),1,4).
                                        wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                        wrk.sumd = b-jl.dam.
                                        wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                wrk.fil = v-fil-cnt.
                                wrk.txb = v-txb.
                                if v-ddd then wrk.df = "d".
                            end. /*  if available txb.cif   */
                        end.
                    end. /*  if txb.gl.subled = 'cif'  */

                    if txb.gl.subled = 'fun' then do:
                        find last txb.fun where txb.fun.fun = txb.jl.acc use-index fun no-lock no-error.
                        if available txb.fun then do:
                             /*  ищем код резид сектор эконом и тип валюты  */
                            v-hs = "".
                            v-cgr = "".
                            find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                            if available txb.bankl then do:
                                v-geoi = txb.bankl.stn.
                                if substring(string(v-geoi,"999"),3,1) = "2" then do:
                                    v-ddd = no.
                                    if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                        if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                            substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:
                                            wrk2.f_debt[month(txb.jl.whn)] = wrk2.f_debt[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                            wrk2.f_debt[13] = wrk2.f_debt[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                            v-ddd = yes.
                                        end.
                                    end.
                                    v-pp = 1. /* проводка попала в один из видов заимств-й */
                                    create wrk.
                                    wrk.Num = wrk2.Num.
                                    wrk.vid = wrk2.vid.
                                    wrk.sub = txb.gl.subled.
                                    wrk.jh = txb.jl.jh.
                                    wrk.whn = txb.jl.jdt.
                                    wrk.month = month(txb.jl.whn).
                                    find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
                                    if txb.crchs.hs eq "L" then v-hs = "1".
                                    else if txb.crchs.hs eq "H" then v-hs = "2". else if txb.crchs.hs eq "S" then v-hs = "3".
                                    v-r = "2".
                                    find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                                    if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                                    else  v-cgr = '4'.

                                    wrk.f_debt[month(txb.jl.whn)] =  txb.jl.dam.
                                    wrk.cif = txb.fun.tbank.
                                    wrk.acc = txb.fun.fun.
                                    wrk.name = txb.fun.cst.
                                    wrk.geo = string(v-geoi,"999").
                                    wrk.pri = v-cgr.
                                    wrk.gl4 = entry(kol1,wrk2.vid1).
                                    wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                    wrk.crc = txb.jl.crc.
                                    wrk.dopen = txb.fun.rdt.
                                    wrk.dclose = txb.fun.duedt.
                                    wrk.stav = 0.
                                    if txb.jl.dc = "D" then do:
                                        wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                        wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                        wrk.sumd = txb.jl.dam.
                                        wrk.sumtngd = getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).

                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                        if available b-jl then do:
                                            wrk.ct4 = substring(string(b-jl.gl),1,4).
                                            wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                            wrk.sumc = b-jl.cam.
                                            wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                        end.
                                    end.
                                    else do:
                                        wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                        wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                        wrk.sumc = txb.jl.cam .
                                        wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                        if available b-jl then do:
                                            wrk.dt4 = substring(string(b-jl.gl),1,4).
                                            wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                            wrk.sumd = b-jl.dam.
                                            wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                        end.
                                    end.
                                    wrk.fil = v-fil-cnt.
                                    wrk.txb = v-txb.
                                    if v-ddd then wrk.df = "d".
                                end. /* if v-geoi = "022"  */
                            end.
                        end.  /* if available txb.fun  */
                    end. /* if txb.gl.subled = 'fun'  */

                end.
                kol1 = kol1 - 1.
            end.

            do while kol2 >= 1:
                if string(txb.jl.gl) begins entry(kol2,wrk2.vid2) then do:
                    find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
                    /* счет указанного ГК клиентский*/
                    if txb.gl.subled = 'cif' then do:
                        find first txb.aaa where txb.aaa.aaa = txb.jl.acc  use-index aaa no-lock no-error.
                        if available txb.aaa then do:
                            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                            if available txb.cif and substring(string(integer(txb.cif.geo),"999"),3,1) = "2" then do:
                                /*find first wrk where wrk.txb = v-txb and wrk.num = wrk2.num and wrk.cif = txb.aaa.cif and wrk.acc = txb.aaa.aaa and wrk.df  = "d" no-error.*/
                                /*if available wrk then do:*/ /* вознаграждение считаем если только был долг */
                                    if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                        v-ddd = no.
                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                        if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                            substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:
                                            wrk2.f_reward[month(txb.jl.whn)] = wrk2.f_reward[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                            wrk2.f_reward[13] = wrk2.f_reward[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                            v-ddd = yes.
                                        end.
                                    end.
                                /*end.*/

                                v-pp = 1. /* проводка попала в один из видов заимств-й */
                                create wrk.
                                wrk.num = wrk2.num.
                                wrk.vid = wrk2.vid.
                                wrk.sub = txb.gl.subled.
                                wrk.jh = txb.jl.jh.
                                wrk.whn = txb.jl.jdt.
                                wrk.month = month(txb.jl.whn).
                                wrk.f_reward[month(txb.jl.whn)] =  txb.jl.dam.
                                wrk.cif = txb.aaa.cif.
                                wrk.acc = txb.aaa.aaa.
                                wrk.name = txb.cif.sname.
                                wrk.geo = txb.cif.geo.
                                /*wrk.pri = txb.cif.type.*/
                                /*  ищем код резид сектор эконом и тип валюты  */
                                v-hs = "".
                                v-cgr = "".
                                find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
                                if txb.crchs.hs eq "L" then v-hs = "1".
                                else if txb.crchs.hs eq "H" then v-hs = "2".
                                    else if txb.crchs.hs eq "S" then v-hs = "3".
                                 v-r = "2".
                                find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                                if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

                                wrk.pri = v-cgr.
                                wrk.gl4 = entry(kol2,wrk2.vid2).
                                wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                wrk.crc = txb.aaa.crc.
                                wrk.dopen = txb.aaa.regdt.
                                find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                                if available txb.acvolt and date(txb.acvolt.x1) < dt2 then wrk.dclose = date(txb.acvolt.x3).
                                else wrk.dclose = txb.aaa.expdt.
                                wrk.stav = txb.aaa.rate.
                                if txb.jl.dc = "D" then do:
                                    wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                    wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                    wrk.sumd = txb.jl.dam.
                                    wrk.sumtngd = getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.ct4 = substring(string(b-jl.gl),1,4).
                                        wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                        wrk.sumc = b-jl.cam.
                                        wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                else do:
                                    wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                    wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                    wrk.sumc = txb.jl.cam .
                                    wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.dt4 = substring(string(b-jl.gl),1,4).
                                        wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                        wrk.sumd = b-jl.dam.
                                        wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                wrk.fil = v-fil-cnt.
                                wrk.txb = v-txb.
                                if v-ddd then wrk.df = "f".
                            end. /*  if available txb.cif   */
                        end.
                    end. /*  if txb.gl.subled = 'cif'  */

                    if txb.gl.subled = 'fun' then do:
                        find last txb.fun where txb.fun.fun = txb.jl.acc use-index fun no-lock no-error.
                        if available txb.fun then do:
                             /*  ищем код резид сектор эконом и тип валюты  */
                            v-hs = "".
                            v-cgr = "".
                            find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                            if available txb.bankl then do:
                                v-geoi = txb.bankl.stn.
                                if substring(string(v-geoi,"999"),3,1) = "2" then do:
                                    /*find first wrk where wrk.txb = v-txb and wrk.num = wrk2.num and wrk.cif = txb.fun.tbank and wrk.acc = txb.fun.fun and wrk.df = "d" no-error.*/
                                    /*if available wrk then do:*/ /* вознаграждение считаем если только был долг */
                                        v-ddd = no.
                                        if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                            if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                                substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:
                                                wrk2.f_reward[month(txb.jl.whn)] = wrk2.f_reward[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                                wrk2.f_reward[13] = wrk2.f_reward[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                                v-ddd = yes.
                                            end.
                                        end.
                                    /*end.*/

                                    v-pp = 1. /* проводка попала в один из видов заимств-й */
                                    create wrk.
                                    wrk.Num = wrk2.Num.
                                    wrk.vid = wrk2.vid.
                                    wrk.sub = txb.gl.subled.
                                    wrk.jh = txb.jl.jh.
                                    wrk.whn = txb.jl.jdt.
                                    wrk.month = month(txb.jl.whn).
                                    find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
                                    if txb.crchs.hs eq "L" then v-hs = "1".
                                    else if txb.crchs.hs eq "H" then v-hs = "2". else if txb.crchs.hs eq "S" then v-hs = "3".
                                    v-r = "2".
                                    find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                                    if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                                    else  v-cgr = '4'.

                                    wrk.f_reward[month(txb.jl.whn)] =  txb.jl.dam.
                                    wrk.cif = txb.fun.tbank.
                                    wrk.acc = txb.fun.fun.
                                    wrk.name = txb.fun.cst.
                                    wrk.geo = string(v-geoi,"999").
                                    wrk.pri = v-cgr.
                                    wrk.gl4 = entry(kol2,wrk2.vid2).
                                    wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                    wrk.crc = txb.jl.crc.
                                    wrk.dopen = txb.fun.rdt.
                                    wrk.dclose = txb.fun.duedt.
                                    wrk.stav = 0.
                                    if txb.jl.dc = "D" then do:
                                        wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                        wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                        wrk.sumd = txb.jl.dam.
                                        wrk.sumtngd = getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                        if available b-jl then do:
                                            wrk.ct4 = substring(string(b-jl.gl),1,4).
                                            wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                            wrk.sumc = b-jl.cam.
                                            wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                        end.
                                    end.
                                    else do:
                                        wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                        wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                        wrk.sumc = txb.jl.cam .
                                        wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                        find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                        if available b-jl then do:
                                            wrk.dt4 = substring(string(b-jl.gl),1,4).
                                            wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                            wrk.sumd = b-jl.dam.
                                            wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                        end.
                                    end.
                                    wrk.fil = v-fil-cnt.
                                    wrk.txb = v-txb.
                                    if v-ddd then wrk.df = "f".
                                end. /* if substring(string(v-geoi,  */
                            end.
                        end.  /* if available txb.fun  */
                    end. /* if txb.gl.subled = 'fun'  */

                end.
                kol2 = kol2 - 1.
            end.
        end.
        if v-pp = 0 then do:  /* если проводка не попала ни один из видов заимств-й записываем в прочие */
            find first txb.gl where txb.gl.gl = txb.jl.gl no-lock no-error.
            if txb.gl.subled = 'cif' and substring(string(txb.gl.gl),1,1) <> "4" and
                    substring(string(txb.gl.gl),1,1) <> "5" and lookup(substring(string(txb.gl.gl),1,4),isklu) = 0
                    and substring(string(txb.gl.gl),1,4) <> "2203" and substring(string(txb.gl.gl),1,4) <> "2204"
                    and substring(string(txb.gl.gl),1,4) <> "2205"  then do:
                find first txb.aaa where txb.aaa.aaa = txb.jl.acc  use-index aaa no-lock no-error.
                if available txb.aaa then do:
                    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
                    if available txb.cif and substring(string(integer(txb.cif.geo),"999"),3,1) = "2" then do:

                        /*find first wrk where  wrk.txb = v-txb and wrk.num = wrk2.num and wrk.cif = txb.aaa.cif and wrk.acc = txb.aaa.aaa no-error.
                        if available wrk  then do:*/
                            v-ddd = no.
                            if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                    substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:
                                    find first wrk2 where wrk2.num = 12.
                                    wrk2.f_debt[month(txb.jl.whn)] = wrk2.f_debt[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                    wrk2.f_debt[13] = wrk2.f_debt[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                    v-ddd = yes.
                                end.
                            end.

                            create wrk.
                            wrk.Num = 12.
                            wrk.vid = "Прочие".
                            wrk.sub = txb.gl.subled.
                            wrk.jh = txb.jl.jh.
                            wrk.whn = txb.jl.jdt.
                            wrk.month = month(txb.jl.whn).
                            wrk.f_debt[month(txb.jl.whn)] =  txb.jl.dam.
                            wrk.cif = txb.aaa.cif.
                            wrk.acc = txb.aaa.aaa.
                            wrk.name = txb.cif.sname.
                            wrk.geo = txb.cif.geo.
                            /*wrk.pri = txb.cif.type.*/
                            /*  ищем код резид сектор эконом и тип валюты  */
                            v-hs = "".
                            v-cgr = "".
                            find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
                            if txb.crchs.hs eq "L" then v-hs = "1".
                            else if txb.crchs.hs eq "H" then v-hs = "2".
                                else if txb.crchs.hs eq "S" then v-hs = "3".
                            v-r = "2".
                            find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                            if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

                            wrk.pri = v-cgr.
                            wrk.gl4 = substring(string(txb.jl.gl),1,4).
                            wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                            wrk.crc = txb.aaa.crc.
                            wrk.dopen = txb.aaa.regdt.
                            find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                            if available txb.acvolt and date(txb.acvolt.x1) < dt2 then wrk.dclose = date(txb.acvolt.x3).
                            else wrk.dclose = txb.aaa.expdt.
                            wrk.stav = txb.aaa.rate.
                            if txb.jl.dc = "D" then do:
                                wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                wrk.sumd = txb.jl.dam  .
                                wrk.sumtngd = getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                if available b-jl then do:
                                    wrk.ct4 = substring(string(b-jl.gl),1,4).
                                    wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                    wrk.sumc = b-jl.cam.
                                    wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                end.
                            end.
                            else do:
                                wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                wrk.sumc = txb.jl.cam .
                                wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                if available b-jl then do:
                                    wrk.dt4 = substring(string(b-jl.gl),1,4).
                                    wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                    wrk.sumd = b-jl.dam.
                                    wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                end.
                            end.
                            wrk.fil = v-fil-cnt.
                            wrk.txb = v-txb.
                            if v-ddd then wrk.df = "d".
                        /*end.*/ /* if not available wrk   */
                    end. /*  if available txb.cif   */
                end.
            end. /*  if txb.gl.subled = 'cif'  */

            if txb.gl.subled = 'fun'  and substring(string(txb.gl.gl),1,1) <> "4" and
                    substring(string(txb.gl.gl),1,1) <> "5" and lookup(substring(string(txb.gl.gl),1,4),isklu) = 0
                    and substring(string(txb.gl.gl),1,4) <> "2203" and substring(string(txb.gl.gl),1,4) <> "2204"
                    and substring(string(txb.gl.gl),1,4) <> "2205" then do:
                find last txb.fun where txb.fun.fun = txb.jl.acc use-index fun no-lock no-error.
                if available txb.fun then do:
                     /*  ищем код резид сектор эконом и тип валюты  */
                    v-hs = "".
                    v-cgr = "".
                    find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                    if available txb.bankl then do:
                        v-geoi = txb.bankl.stn.
                        if substring(string(v-geoi,"999"),3,1) = "2" then do:
                            /*find first wrk where  wrk.txb = v-txb and wrk.num = wrk2.num and wrk.cif = txb.fun.tbank and wrk.acc = txb.fun.fun no-error.
                            if not available wrk then do:*/
                                v-ddd = no.
                                if txb.jl.dc = "D" then do: /* проверка на счета исключения по кредиту */
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                    if available b-jl and substring(string(b-jl.gl),1,1) <> "4" and
                                        substring(string(b-jl.gl),1,1) <> "5" and lookup(substring(string(b-jl.gl),1,4),isklu) = 0 then do:
                                        find first wrk2 where wrk2.num = 12.
                                        wrk2.f_debt[month(txb.jl.whn)] = wrk2.f_debt[month(txb.jl.whn)] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                        wrk2.f_debt[13] = wrk2.f_debt[13] + getSUMtng(txb.jl.dam,txb.jl.jdt,txb.jl.crc).
                                        v-ddd = yes.
                                    end.
                                end.

                                create wrk.
                                wrk.Num = 12.
                                wrk.vid = "Прочие".
                                wrk.sub = txb.gl.subled.
                                wrk.jh = txb.jl.jh.
                                wrk.whn = txb.jl.jdt.
                                wrk.month = month(txb.jl.whn).
                                find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
                                if txb.crchs.hs eq "L" then v-hs = "1".
                                else if txb.crchs.hs eq "H" then v-hs = "2". else if txb.crchs.hs eq "S" then v-hs = "3".
                                v-r = "2".
                                find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                                if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                                else  v-cgr = '4'.

                                wrk.f_debt[month(txb.jl.whn)] =  txb.jl.dam.
                                wrk.cif = txb.fun.tbank.
                                wrk.acc = txb.fun.fun.
                                wrk.name = txb.fun.cst.
                                wrk.geo = string(v-geoi,"999").
                                wrk.pri = v-cgr.
                                wrk.gl4 = substring(string(txb.jl.gl),1,4).
                                wrk.gl7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                wrk.crc = txb.jl.crc.
                                wrk.dopen = txb.fun.rdt.
                                wrk.dclose = txb.fun.duedt.
                                wrk.stav = 0.
                                if txb.jl.dc = "D" then do:
                                    wrk.dt4 = substring(string(txb.jl.gl),1,4).
                                    wrk.dt7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc.
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.ct4 = substring(string(b-jl.gl),1,4).
                                        wrk.ct7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc.
                                        wrk.sumc = b-jl.cam.
                                        wrk.sumtngc = getSUMtng(b-jl.cam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                else do:
                                    wrk.ct4 = substring(string(txb.jl.gl),1,4).
                                    wrk.ct7 = substring(string(txb.jl.gl),1,4) + v-r + v-cgr + v-hs + " " + txb.jl.acc .
                                    wrk.sumc = txb.jl.cam .
                                    wrk.sumtngc = getSUMtng(txb.jl.cam,txb.jl.jdt,txb.jl.crc).
                                    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
                                    if available b-jl then do:
                                        wrk.dt4 = substring(string(b-jl.gl),1,4).
                                        wrk.dt7 = substring(string(b-jl.gl),1,4) + v-r + v-cgr + v-hs + " " + b-jl.acc .
                                        wrk.sumd = b-jl.dam.
                                        wrk.sumtngd = getSUMtng(b-jl.dam,b-jl.jdt,b-jl.crc).
                                    end.
                                end.
                                wrk.fil = v-fil-cnt.
                                wrk.txb = v-txb.
                                if v-ddd then wrk.df = "d".
                            /*end.*/  /* if not available wrk  */
                        end. /* if v-geoi = "022"  */
                    end.
                end.  /* if available txb.fun  */
            end. /* if txb.gl.subled = 'fun'  */
        end.

    end. /* for each txb.jl */
end.  /*  if v-sel = 1 or v-sel = 2  */
/* прогнозируем план */
if v-ful1 = 2 or v-ful1 = 3 or v-sel = 3 or v-sel = 1 then do:
    vstrgld = "2052,2054,2056,2057,2064,2066,2067,2112,2113,2044,2046,2052,2054,2056,2057,2064,2066,2067,2112,2113,2044,2046,
                2401,2402,2406,2222,2022,2023,2123,2124,2125,2126,2127,2131,2133,2206,2207,2208,2211,2213,2215,2216,2217,2219,2223,2240,
                2255,2301,2303".
    vstrglc = "2705,2711,2704,2705,2711,2704,2722,2708,2712,2713,2714,2707,2719,2721,2723,2725,2730".
    for each txb.gl where txb.gl.totlev = 1 and txb.gl.totgl <> 0 and (lookup(substring(string(txb.gl.gl),1,4),vstrgld) > 0 or lookup(substring(string(txb.gl.gl),1,4),vstrglc) > 0) no-lock:
      create wgl. /* формируется рабочая таблица */
        wgl.gl = txb.gl.gl.
        wgl.subled = txb.gl.subled.
        wgl.des = txb.gl.des.
        wgl.lev = txb.gl.level.
        wgl.type   = txb.gl.type.
        wgl.code  = txb.gl.code.
        if lookup(substring(string(txb.gl.gl),1,4),vstrgld) > 0 then do:
            wgl.dc = "d".
            for each wrk3.
                if lookup(substring(string(txb.gl.gl),1,4),wrk3.vid1) > 0 then do:
                    wgl.vid = wrk3.vid.
                    wgl.num = wrk3.num.
                end.
            end.
        end.
        else do:
            wgl.dc = "f".
            for each wrk3.
                if lookup(substring(string(txb.gl.gl),1,4),wrk3.vid2) > 0 then do:
                    wgl.vid = wrk3.vid.
                    wgl.num = wrk3.num.
                end.
            end.
        end.
        wgl.grp = txb.gl.grp.
    end.
    for each txb.trxbal where (txb.trxbal.subled = "CIF" or txb.trxbal.subled = "FUN") and (txb.trxbal.level = 2 or txb.trxbal.level = 1) no-lock :


        if txb.trxbal.sub = "CIF" then do:       /* клиентские счета */
            find last txb.aaa where txb.aaa.aaa = txb.trxbal.acc and length(txb.aaa.aaa) >= 20 use-index aaa no-lock no-error.
            if available txb.aaa then do:

                find last txb.cif where txb.cif.cif eq txb.aaa.cif use-index cif no-lock no-error.
                if available txb.cif then do:
                    if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
                    else v-r = "2".
                    if v-r = "2" then do:
                        find last txb.crchs where txb.crchs.crc eq txb.aaa.crc no-lock no-error.
                        if txb.crchs.hs eq "L" then v-hs = "1".
                        else if txb.crchs.hs eq "H" then v-hs = "2".
                            else if txb.crchs.hs eq "S" then v-hs = "3".

                        find last txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                        if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.

                        v-cls = "".
                        find last txb.sub-cod where txb.sub-cod.sub = "cif" and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "clsa" no-lock no-error .
                        if available txb.sub-cod and (txb.sub-cod.ccode <> "msc" or trim(txb.sub-cod.ccode) = "") then v-cls = "(сч.закрыт)".
                        find last txb.acvolt where txb.acvolt.aaa = txb.aaa.aaa no-lock no-error.
                        if available txb.acvolt and date(txb.acvolt.x1) < dt2 then Igl(txb.aaa.gl, txb.trxbal.lev ,txb.aaa.aaa,txb.cif.name, txb.trxbal.sub, txb.trxbal.crc, v-r , v-cgr ,  v-hs, txb.aaa.regdt, date(txb.acvolt.x3), txb.aaa.rate, "").
                        else Igl(txb.aaa.gl, txb.trxbal.lev ,txb.aaa.aaa,txb.cif.name + v-cls, txb.trxbal.sub, txb.trxbal.crc, v-r , v-cgr ,  v-hs, txb.aaa.regdt, txb.aaa.expdt, txb.aaa.rate, "").
                    end. /* if v-r = "2"   */
                end.  /* if available txb.cif */
            end.
        end. /* if txb.trxbal.sub = "CIF"  */

        if txb.trxbal.sub eq "FUN" then do:      /* межбанковские депозиты и кредиты */

            find last txb.fun where txb.fun.fun eq txb.trxbal.acc use-index fun no-lock no-error.
            if available txb.fun then do:
                find last txb.bankl where txb.bankl.bank eq txb.fun.bank use-index bank no-lock no-error.
                if available txb.bankl then v-geoi = txb.bankl.stn.
                if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
                else v-r = "2".
                if v-r = "2" then do:
                    find last txb.crchs where txb.crchs.crc eq txb.fun.crc no-lock no-error.
                    if txb.crchs.hs eq "L" then v-hs = "1".
                    else if txb.crchs.hs eq "H" then v-hs = "2".
                        else if txb.crchs.hs eq "S" then v-hs = "3".

                    find last txb.sub-cod where txb.sub-cod.sub = 'fun' and txb.sub-cod.acc = txb.fun.fun and txb.sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
                    if available txb.sub-cod then v-cgr = txb.sub-cod.ccode.
                    else  v-cgr = '4'.

                    Igl(txb.fun.gl, txb.trxbal.lev ,txb.trxbal.acc,txb.fun.cst, txb.trxbal.sub, txb.trxbal.crc, v-r , v-cgr ,  v-hs, txb.fun.rdt, txb.fun.duedt, 0, "").
                end.  /* if v-r = "2"   */
            end. /*  if available txb.fun */
        end. /* if txb.trxbal.sub eq "FUN" */
    end. /* for each txb.trxbal*/
end.  /*if v-ful1 = 2 or v-ful1 = 3   */