/* r-eknp.p
 * MODULE
        Бухгалтерская отчетность
 * DESCRIPTION
        Отчет ЕКНП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 8.8.6.7
 * AUTHOR
        01/05/2011 marinav
 * BASES
        BANK COMM
 * CHANGES
        09/01/2012 madiyar - доработка
        13.01.2012 damir - добавил if avail, выдавало ошибку.
        17.01.2012 damir - вывел новые поля в отчете согласно доп.заданию от Ген.Бухг.
        25.01.2012 damir - доп.задание к т.з. № 1249 выполнено. (Шманова Актолкын)
        16.04.2012 damir - выполнено Т.З. № 1301 (Дополнение к отчету), изменен полносью алгоритм расчета курсовой разницы,
        с техническими заданиями можно ознакомится X:\IT\_doc\Damir. Отчет доработан полностью.
        18.04.2012 damir - проверка на время запуска.
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

{mainhead.i}
{nbankBik.i}
def var ttime as integer no-undo.
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "spfbos" no-lock no-error.
if not(avail pksysc and pksysc.loval) then do:
    ttime = time.
    if ttime > 32400 and ttime < 64800 then do:
        message skip "Данный отчет сильно влияет на производительность системы,~nпоэтому отчет можно формировать только в период времени с 18:00 до 09:00.~n~n" +
                "В случае крайней необходимости срочного формирования отчета обратитесь в техподдержку." skip(1) view-as alert-box information.
        return.
    end.
end.

def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var v-dt as date.

def var v-gllistL    as char init "1051,1052,2013".
def var v-sum        as deci.
def var s_locat      as char format "x(1)".
def var s_secek      like s_locat.
def var r_locat      like s_locat.
def var r_secek      like s_locat.
def var knp$         as char format "x(3)".
def var v-country    as char format 'x(2)'.
def var v-gl1        as inte no-undo.
def var v-gl2        as inte no-undo.
def var v-sr         as char no-undo.
def var v-pr         as char no-undo.
def var v-sumob      as deci.
def var v-sumdb      as deci. /*Обороты по Дт*/
def var v-sumcr      as deci. /*Обороты по Кт*/
def var v-inputbal   as deci init 0 decimals 2.
def var v-outputbal  as deci init 0 decimals 2.
def var v-outputbal1 as deci init 0 decimals 2.
def var v-inputbal2  as deci init 0 decimals 2.
def var v-outputbal2 as deci init 0 decimals 2.
def var gllist       as char init "1051,1052".
def var k            as inte.
def var i            as inte.
def var v-tmpstring  as char.

def new shared temp-table t-eknp
    field sr        as char
    field pr        as char
    field jdt       like jl.jdt
    field acc       as char
    field gl        like jl.gl
    field sbank     as char format "x(12)"
    field l_sbank   as char
    field sbank1    as char format "x(12)"
    field l_sbank1  as char
    field gl1       like jl.gl
    field rbank     as char format "x(12)"
    field l_rbank   as char
    field rbank1    as char format "x(12)"
    field l_rbank1  as char
    field gl2       like jl.gl
    field crc       like crc.crc
    field crccode   as char format "x(3)" label "Вал"
    field jh        like jl.jh
    field rmz       as char
    field sum       as deci format "zzz,zzz,zzz,zz9.99"
    field sumkzt    as deci format "zzz,zzz,zzz,zz9.99"
    field s_locat   as char
    field s_secek   as char
    field r_locat   as char
    field r_secek   as char
    field knp       as char format "999"
    field cnt1      as char format "x(2)"
    field cnt2      as char format "x(2)"
    field rem       like jl.rem[1]
    field ptype     as char
    field drgl7     as char   /*п.м. 8.8.3.12*/
    field crgl7     as char   /*п.м. 8.8.3.12*/
    field dracc20   as char
    field cracc20   as char
    field draccname as char
    field craccname as char
    field prizplat  as char
    field trxcode   as char
    field namebnk   as char.

def temp-table t-corracc
  field gl      like gl.gl
  field acc     like dfb.dfb
  field crc     like crc.crc
  field crccode as char format "x(3)"
  field sum     as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field balb    as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field bale    as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field balbkzt as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field balekzt as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field balcurs as deci format "->>>,>>>,>>>,>>>,>>9.99"
  field s_locat as inte format ">" column-label "" label ""
  field s_secek as inte format ">" column-label "" label ""
  field r_locat as inte format ">" column-label "" label ""
  field r_secek as inte format ">" column-label "" label ""
  field knp     as inte format ">>>" column-label "КНП" label "КНП"
  field ptype   as char format "x(2)"
  index acc gl crc acc.

def temp-table t-wrk2
    field gl        as inte
    field bic       as char
    field bankname  as char
    field s_locat   as char
    field s_secek   as char
    field r_locat   as char
    field r_secek   as char
    field knp       as char
    field sum       as deci
    field crc       as inte.

def buffer b-jl     for jl.
def buffer b-bankt  for bankt.
def buffer b-t-eknp for t-eknp.

v-dte = date(month(g-today),1,year(g-today)) - 1.
v-dtb = date(month(v-dte),1,year(v-dte)).

update skip(1)
    v-dtb label "    Дата начала отчетного периода " format "99/99/9999" validate (v-dtb < g-today, " Неверная дата!") " " skip
    v-dte label "    Дата конца отчетного периода  " format "99/99/9999" validate (v-dtb < g-today, " Неверная дата!") skip(1)
with row 5 centered side-labels title " ПАРАМЕТРЫ ОТЧЕТА ".

function GLRET returns char(input acc as char).
    def var v-gl7  as char init "".
    def var v-hs   as char.
    def var v-geoi as inte.
    def var v-cgr  as char.
    def var v-r    as char.

    find last arp where arp.arp eq acc use-index arp no-lock no-error.
    if avail arp then do:
        find last crchs where crchs.crc eq arp.crc no-lock no-error.
        if avail crchs then do:
            if crchs.hs eq "L" then v-hs = "1".
            else if crchs.hs eq "H" then v-hs = "2".
            else if crchs.hs eq "S" then v-hs = "3".
        end.
        find last cif where cif.cif eq arp.cif use-index cif no-lock no-error.
        if available cif then do:
            v-geoi = integer(cif.geo).
            find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if avail sub-cod then v-cgr = sub-cod.ccode.
        end.
        else do:
            v-geoi = integer(arp.geo).
            find last sub-cod where sub-cod.sub = 'arp' and sub-cod.acc = arp.arp and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if avail sub-cod then v-cgr = sub-cod.ccode.
        end.
        if substr(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        assign v-gl7 = string(truncate(arp.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last ast where ast.ast eq acc use-index ast no-lock no-error.
    if avail ast then do:
        assign v-gl7 = string(truncate(ast.gl / 100, 0)) + "1" + "4" + "1".
    end.

    find last aaa where aaa.aaa eq acc use-index aaa no-lock no-error.
    if avail aaa then do:
        find last cif where cif.cif eq aaa.cif use-index cif no-lock no-error.
        find last crchs where crchs.crc eq aaa.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
        else if crchs.hs eq "H" then v-hs = "2".
        else if crchs.hs eq "S" then v-hs = "3".
        if avail cif then do:
            if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
            else v-r = "2".
            find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
            if available sub-cod then v-cgr = sub-cod.ccode.
        end.
        assign v-gl7 = string(truncate(aaa.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last dfb where dfb.dfb eq acc use-index dfb no-lock no-error.
    if avail dfb then do:
        find last bankl where bankl.bank eq dfb.bank use-index bank no-lock no-error.
        if available bankl then v-geoi = bankl.stn.
        find last crchs where crchs.crc eq dfb.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
        else if crchs.hs eq "H" then v-hs = "2".
        else if crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        if dfb.gl ge 105100 and dfb.gl lt 105200 then v-cgr = '3'.
        else v-cgr = '4'.
        assign v-gl7 = string(truncate(dfb.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last fun where fun.fun eq acc use-index fun no-lock no-error.
    if avail fun then do:
        find last bankl where bankl.bank eq fun.bank use-index bank no-lock no-error.
        if available bankl then v-geoi = bankl.stn.
        find last crchs where crchs.crc eq fun.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
        else if crchs.hs eq "H" then v-hs = "2".
        else if crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last sub-cod where sub-cod.sub = 'fun' and sub-cod.acc = fun.fun and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available sub-cod then v-cgr = sub-cod.ccode.
        else v-cgr = '4'.
        assign v-gl7 = string(truncate(fun.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last scu where scu.scu eq acc use-index scu no-lock no-error.
    if avail scu then do:
        v-geoi = integer(scu.geo) no-error.
        if error-status:error then v-geoi = 21.
        find last crchs where crchs.crc eq scu.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
        else if crchs.hs eq "H" then v-hs = "2".
        else if crchs.hs eq "S" then v-hs = "3".
        if substring(string(v-geoi,"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        v-cgr = scu.type. /* сектор экономики */
        assign v-gl7 = string(truncate(scu.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    find last lon where lon.lon eq acc use-index lon no-lock no-error.
    if avail lon then do:
        find last cif where cif.cif eq lon.cif use-index cif no-lock no-error.
        find last crchs where crchs.crc eq lon.crc no-lock no-error.
        if crchs.hs eq "L" then v-hs = "1".
        else if crchs.hs eq "H" then v-hs = "2".
        else if crchs.hs eq "S" then v-hs = "3".
        if substring(string(integer(cif.geo),"999"),3,1) eq "1" then v-r = "1".
        else v-r = "2".
        find last sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = 'secek' use-index sub-cod-idx3 no-lock no-error.
        if available sub-cod then v-cgr = sub-cod.ccode.
        assign v-gl7 = string(truncate(lon.gl / 100, 0)) + v-r + v-cgr + v-hs.
    end.

    return v-gl7.
end.

function ACCNAM returns char(input acc as char).
    def var v-name as char.

    find last arp where arp.arp eq acc use-index arp no-lock no-error.
    if avail arp then do:
        v-name = arp.des.
    end.
    find last ast where ast.ast eq acc use-index ast no-lock no-error.
    if avail ast then do:
        v-name = ast.name.
    end.
    find last aaa where aaa.aaa eq acc use-index aaa no-lock no-error.
    if avail aaa then do:
        v-name = aaa.name.
    end.
    find last dfb where dfb.dfb eq acc use-index dfb no-lock no-error.
    if avail dfb then do:
        v-name = dfb.name.
    end.
    find last fun where fun.fun eq acc use-index fun no-lock no-error.
    if avail fun then do:
        v-name = fun.cst.
    end.
    find last lon where lon.lon eq acc use-index lon no-lock no-error.
    if avail lon then do:
        find first cif where cif.cif = lon.cif no-lock no-error.
        if avail cif then v-name = cif.name.
    end.

    return v-name.
end function.

do v-dt = v-dtb - 1 to v-dte:
    do i = 1 to num-entries(v-gllistL) :
        for each jl where jl.jdt = v-dt and string(jl.gl) begins entry(i,v-gllistL) use-index jdt no-lock:
            find jh where jh.jh = jl.jh no-lock no-error.
            create t-eknp.
            t-eknp.gl = jl.gl.
            t-eknp.rmz = substr(jh.party, 1, 10).
            /*if jh.sub <> "rmz" then next.*/
            if jh.sub = "rmz" then do:
                find remtrz where remtrz.remtrz = substr(jh.party, 1, 10) no-lock no-error.
                /*if remtrz.remtrz <> "RMZA610330" then next.*/
                t-eknp.jdt = v-dt.
                if avail remtrz then do:
                    assign
                    t-eknp.sbank     = remtrz.sbank
                    t-eknp.sbank1    = remtrz.sbank
                    t-eknp.gl1       = remtrz.drgl
                    t-eknp.gl2       = remtrz.crgl
                    t-eknp.rmz       = remtrz.remtrz
                    t-eknp.dracc20   = remtrz.dracc
                    t-eknp.cracc20   = remtrz.cracc
                    t-eknp.drgl7     = GLRET(t-eknp.dracc20)
                    t-eknp.crgl7     = GLRET(t-eknp.cracc20)
                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                end.
                if jl.dc = 'd' then do:
                    find first bankt where bankt.acc = jl.acc no-lock no-error.
                    if avail bankt then do:
                        find first bankl where bankl.bank = bankt.cbank no-lock no-error.
                        if avail bankl then do:
                            if bankl.bic <> "" then t-eknp.rbank = bankl.bic.
                        end.
                    end.
                    if t-eknp.rbank = "" then do:
                        assign v-tmpstring = "*" + trim(t-eknp.draccname) + "*".
                        find first bankl where trim(bankl.name) matches v-tmpstring no-lock no-error.
                        if avail bankl then t-eknp.rbank = bankl.bank.
                    end.
                end.
                else do:
                    find first bankt where bankt.acc = jl.acc no-lock no-error.
                    if avail bankt then do:
                        find first bankl where bankl.bank = bankt.cbank no-lock no-error.
                        if avail bankl then do:
                            if bankl.bic <> "" then t-eknp.rbank1 = bankl.bic.
                        end.
                    end.
                    if t-eknp.rbank1 = "" then do:
                        assign v-tmpstring = "*" + trim(t-eknp.craccname) + "*".
                        find first bankl where trim(bankl.name) matches v-tmpstring no-lock no-error.
                        if avail bankl then t-eknp.rbank1 = bankl.bank.
                    end.
                end.
                if avail remtrz then do:
                    if remtrz.rbank matches "*TXB*" or remtrz.rcbank matches "*TXB*" then do:
                        if avail remtrz then do:
                            assign
                            t-eknp.rbank = remtrz.sbank
                            t-eknp.rbank1 = remtrz.scbank.
                        end.
                    end.
                    if remtrz.sbank matches "*TXB*" or remtrz.scbank matches "*TXB*" then do:
                        if avail remtrz then do:
                            assign
                            t-eknp.rbank = remtrz.rbank
                            t-eknp.rbank1 = remtrz.rcbank.
                        end.
                    end.
                end.
                if t-eknp.draccname matches "*Платежный*" then do:
                    find first bankl where bankl.name matches "*Платежный Центр*" no-lock no-error.
                    if avail bankl then if t-eknp.rbank = "" then assign t-eknp.rbank = bankl.bank.
                end.
                if t-eknp.craccname matches "*Платежный*" then do:
                    find first bankl where bankl.name matches "*Платежный Центр*" no-lock no-error.
                    if avail bankl then if t-eknp.rbank1 = "" then assign t-eknp.rbank1 = bankl.bank.
                end.
                if t-eknp.rbank <> "" then t-eknp.rbank1 = t-eknp.rbank.
                else if t-eknp.rbank = "" and t-eknp.rbank1 <> "" then t-eknp.rbank = t-eknp.rbank1.
                t-eknp.crc = jl.crc.
                find first crc where crc.crc = jl.crc no-lock no-error.
                t-eknp.crccode = crc.code.
                t-eknp.jh = jh.jh.
                t-eknp.sum = remtrz.amt.
                find last crchis where crchis.crc = crc.crc and crchis.rdt <= v-dt - 1 no-lock no-error.
                t-eknp.sumkzt = remtrz.amt * crchis.rate[1].
                find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" no-lock no-error.
                if avail sub-cod and sub-cod.ccode = "eknp" and num-entries(sub-cod.rcode) = 3 then do:
                    t-eknp.s_locat = substr(sub-cod.rcode, 1, 1).
                    t-eknp.s_secek = substr(sub-cod.rcode, 2, 1).
                    t-eknp.r_locat = substr(sub-cod.rcode, 4, 1).
                    t-eknp.r_secek = substr(sub-cod.rcode, 5, 1).
                    t-eknp.knp     = substr(sub-cod.rcode, 7, 3).
                end.
                v-country = "".
                find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "iso3166" no-lock no-error.
                if avail sub-cod and sub-cod.ccode <> "msc" then do:
                    if t-eknp.s_locat = "2" then t-eknp.cnt1 = sub-cod.ccode. else t-eknp.cnt2 = sub-cod.ccode.
                    v-country = sub-cod.ccode.
                end.
                if remtrz.ptype = "5" then do:
                    /* входящий платеж на филиал - взять ЕКНП и страну с филиала */
                    find txb where txb.consolid and txb.bank = remtrz.rbank no-lock no-error.
                    if connected ("txb") then disconnect "txb".
                    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
                    run eknp_fil (remtrz.remtrz, remtrz.racc, remtrz.amt, output s_locat, output s_secek, output r_locat, output r_secek, output knp$, output v-country).
                    disconnect "txb".
                    t-eknp.s_locat = s_locat.
                    t-eknp.s_secek = s_secek.
                    t-eknp.r_locat = r_locat.
                    t-eknp.r_secek = r_secek.
                    t-eknp.knp     = knp$.
                    if t-eknp.s_locat = "2" then t-eknp.cnt1 = v-country. else t-eknp.cnt2 = v-country.
                end.
                if t-eknp.s_locat = "1" then t-eknp.cnt1 = 'KZ'.
                if t-eknp.r_locat = "1" then t-eknp.cnt2 = 'KZ'.

                /*  поищем сами страну банка */
                if jl.dc = 'D' then do:
                    find first bankl where bankl.bank = t-eknp.sbank no-lock no-error.
                    if avail bankl then t-eknp.l_sbank = bankl.frb.
                    t-eknp.l_sbank1 = v-country.
                end.
                else do:
                    find first bankl where bankl.bank = t-eknp.rbank no-lock no-error.
                    if avail bankl then t-eknp.l_rbank = bankl.frb.
                    t-eknp.l_rbank1 = v-country.
                end.
                t-eknp.rem = jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5].
                t-eknp.ptype = remtrz.ptype.
                find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "pdoctng"
                and sub-cod.ccode <> "msc" no-lock no-error.
                if avail sub-cod then assign t-eknp.prizplat = sub-cod.ccode.
                /*if remtrz.remtrz <> "RMZA610330" then message t-eknp.rbank t-eknp.rbank1 view-as alert-box.*/
            end.
            else do:
                /*if jh.jh <> 1538696 then next.*/
                if jh.sub = "jou" then do:
                    find joudoc where joudoc.docnum = substr(jh.party, 1, 10) no-lock no-error.
                    if avail joudoc then do:
                        find first sub-cod where sub-cod.sub = "jou" and sub-cod.acc = joudoc.docnum and
                        sub-cod.d-cod = "pdoctng" and sub-cod.ccode <> "msc" no-lock no-error.
                        if avail sub-cod then assign t-eknp.prizplat = sub-cod.ccode.
                    end.
                end.
                t-eknp.jdt = v-dt.
                find first b-jl where b-jl.jh = jl.jh and b-jl.ln <> jl.ln and (b-jl.cam + b-jl.dam) = (jl.dam + jl.cam)
                use-index jhln no-lock no-error.
                if jl.dc = 'd' then do:
                    assign
                    t-eknp.dracc20 = jl.acc
                    t-eknp.gl1     = jl.gl.
                    if avail b-jl then do:
                        t-eknp.gl2 = b-jl.gl.
                        t-eknp.cracc20 = b-jl.acc.
                    end.
                    assign
                    t-eknp.drgl7     = GLRET(t-eknp.dracc20)
                    t-eknp.crgl7     = GLRET(t-eknp.cracc20)
                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    find first bankt where bankt.acc = t-eknp.dracc20 no-lock no-error.
                    if avail bankt then do:
                        find first bankl where bankl.bank = bankt.cbank no-lock no-error.
                        if avail bankl then if bankl.bic <> "" then t-eknp.rbank = bankl.bic.
                    end.
                    if t-eknp.draccname matches "*Платежный*" then do:
                        find first bankl where bankl.name matches "*Платежный*" no-lock no-error.
                        if avail bankl then assign t-eknp.rbank = bankl.bank.
                    end.
                    if t-eknp.rbank = "" then do:
                        assign v-tmpstring = "*" + trim(t-eknp.draccname) + "*".
                        find first bankl where trim(bankl.name) matches v-tmpstring no-lock no-error.
                        if avail bankl then t-eknp.rbank = bankl.bank.
                    end.
                end.
                else do:
                    if avail b-jl then do:
                        t-eknp.dracc20 = b-jl.acc.
                        t-eknp.gl1     = b-jl.gl.
                    end.
                    /*if jl.jh = 1511187 then message t-eknp.dracc20 t-eknp.cracc20 view-as alert-box.*/
                    assign
                    t-eknp.cracc20   = jl.acc
                    t-eknp.gl2       = jl.gl
                    t-eknp.drgl7     = GLRET(t-eknp.dracc20)
                    t-eknp.crgl7     = GLRET(t-eknp.cracc20)
                    t-eknp.draccname = ACCNAM(t-eknp.dracc20)
                    t-eknp.craccname = ACCNAM(t-eknp.cracc20).
                    find first bankt where bankt.acc = t-eknp.cracc20 no-lock no-error.
                    if avail bankt then do:
                        find first bankl where bankl.bank = bankt.cbank no-lock no-error.
                        if avail bankl then if bankl.bic <> "" then t-eknp.rbank1 = bankl.bic.
                    end.
                    if t-eknp.craccname matches "*Платежный*" then do:
                        find first bankl where bankl.name matches "*Платежный Центр*" no-lock no-error.
                        if avail bankl then assign t-eknp.rbank1 = bankl.bank.
                    end.
                    if t-eknp.rbank1 = "" then do:
                        assign v-tmpstring = "*" + trim(t-eknp.craccname) + "*".
                        find first bankl where trim(bankl.name) matches v-tmpstring no-lock no-error.
                        if avail bankl then t-eknp.rbank1 = bankl.bank.
                    end.
                end.
                if t-eknp.rbank <> "" and t-eknp.rbank1 = "" then t-eknp.rbank1 = t-eknp.rbank.
                else if t-eknp.rbank = "" and t-eknp.rbank1 <> "" then t-eknp.rbank = t-eknp.rbank1.
                /*if jl.jh = 1483438 then message "2=" jl.jh jl.dc t-eknp.rbank t-eknp.rbank1 view-as alert-box.*/
                t-eknp.crc = jl.crc.
                find first crc where crc.crc = jl.crc no-lock no-error.
                t-eknp.crccode = crc.code.
                t-eknp.jh = jh.jh.
                t-eknp.sum = (jl.dam + jl.cam).
                find last crchis where crchis.crc = crc.crc and crchis.rdt <= v-dt - 1 no-lock no-error.
                t-eknp.sumkzt = (jl.dam + jl.cam) * crchis.rate[1].

                find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.codfr = "locat" no-lock no-error.
                if avail trxcods then do:
                    if jl.dc = "d" then t-eknp.s_locat = trxcods.code.
                    else t-eknp.r_locat = trxcods.code.
                end.
                find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = jl.ln and trxcods.codfr = "secek" no-lock no-error.
                if avail trxcods then do:
                    if jl.dc = "d" then t-eknp.s_secek = trxcods.code.
                    else t-eknp.r_secek = trxcods.code.
                end.

                for each b-jl where b-jl.jh = jl.jh and b-jl.ln <> jl.ln no-lock use-index jhln:
                    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = "locat" no-lock no-error.
                    if avail trxcods then do:
                        if b-jl.dc = "d" then t-eknp.s_locat = trxcods.code.
                        else t-eknp.r_locat = trxcods.code.
                    end.
                    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = "secek" no-lock no-error.
                    if avail trxcods then do:
                        if b-jl.dc = "d" then t-eknp.s_secek = trxcods.code.
                        else t-eknp.r_secek = trxcods.code.
                    end.
                end.

                find first trxcods where trxcods.trxh = jl.jh and trxcods.codfr = "spnpl" no-lock no-error.
                if avail trxcods then t-eknp.knp = trxcods.code.

                t-eknp.rem = jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5].

                /* если нерезидент и страну не заполнили, то поищем сами*/
                if t-eknp.s_locat = "2" and t-eknp.cnt1 = "" then do:
                    find first bankl where bankl.bank = t-eknp.sbank no-lock no-error.
                    if avail bankl then t-eknp.cnt1 = bankl.frb.
                end.
                if t-eknp.r_locat = "2" and t-eknp.cnt2 = "" then do:
                    find first bankl where bankl.bank = t-eknp.rbank no-lock no-error.
                    if avail bankl then t-eknp.cnt2 = bankl.frb.
                end.

                if t-eknp.s_locat = "1" then t-eknp.cnt1 = 'KZ'.
                if t-eknp.r_locat = "1" then t-eknp.cnt2 = 'KZ'.

                find first bankl where bankl.bank = t-eknp.sbank no-lock no-error.
                if avail bankl then assign t-eknp.l_sbank = bankl.frb t-eknp.l_sbank1 = bankl.frb .
                find first bankl where bankl.bank = t-eknp.rbank no-lock no-error.
                if avail bankl then assign t-eknp.l_rbank = bankl.frb t-eknp.l_rbank1 = bankl.frb .
            end.

            /* определим среду и признак */
            v-gl1 = jl.gl.
            if jl.dc = 'd' then
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 and (b-jl.cam + b-jl.dam) = (jl.dam + jl.cam)
            use-index jhln no-lock no-error.
            else
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln - 1 and (b-jl.cam + b-jl.dam) = (jl.dam + jl.cam)
            use-index jhln no-lock no-error.

            if avail b-jl then v-gl2 = b-jl.gl.

            if (string(v-gl1) begins "1051") or (string(v-gl2) begins "1051") then v-sr = "03".
            else do:
                if lookup(string(v-gl1),"287033,287034,287035,287036,287037") > 0 then v-sr = "05".
                else do:
                    if (string(v-gl1) begins "1052") or (string(v-gl1) begins "2013") or (string(v-gl2) begins "1052") or (string(v-gl2) begins "2013") then do:
                        if substring(t-eknp.rbank,5,2) = "KZ" then v-sr = "06".
                        else v-sr = "07".
                    end.
                end.
            end.

            if jl.dc = 'D' then do:
                if (string(v-gl1) begins "1051") or (string(v-gl1) begins "1052") then do:
                    if (string(v-gl2) begins "4703") then v-pr = "08".
                    else v-pr = "04".
                end.
                if (string(v-gl1) begins "2013") then do:
                    if (string(v-gl2) begins "4703") then v-pr = "09".
                    else v-pr = "05".
                end.
            end.
            else do:
                if (string(v-gl1) begins "1051") or (string(v-gl1) begins "1052") then do:
                    if (string(v-gl2) begins "5703") then v-pr = "07".
                    else v-pr = "03".
                end.
                if (string(v-gl1) begins "2013") then do:
                    if (string(v-gl2) begins "5703") then v-pr = "10".
                    else v-pr = "06".
                end.
            end.

            if v-sr = "08" then v-pr = "11".

            t-eknp.sr = v-sr.
            t-eknp.pr = v-pr.

            /*Наименование филиала*/
            find first sysc where sysc.sysc = 'OURBNK' no-lock no-error.
            if avail sysc then do:
                find first comm.txb where trim(comm.txb.bank) = trim(sysc.chval) no-lock no-error.
                if avail comm.txb then assign t-eknp.namebnk = comm.txb.info.
            end.
            /*Наименование шаблона*/
            assign t-eknp.trxcode = jl.trx.
        end.
    end.
end.

{r-branch.i &proc = "r-eee"} /*Сбор данных по филиалам*/

define stream rep.
output stream rep to eknp.htm.

put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
       put stream rep unformatted "<tr style=""font:bold"" ><td align=""center"" ><BR>".
       put stream rep unformatted "</td></tr>" skip.
       put stream rep unformatted "<tr style=""font:bold"" >"
                                  "<td align=""center"" > за  г.</td></tr>"  skip.
       put stream rep "</table>" skip.
       put stream rep unformatted "<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td align=""center"" rowspan=2>Среда</td>"
                  "<td align=""center"" rowspan=2>Признак</td>"
                  "<td align=""center"" rowspan=2>ГК</td>"
                  "<td align=""center"" rowspan=2>БИК получателя</td>"
                  "<td align=""center"" rowspan=2>Рез-во получателя</td>"
                  "<td align=""center"" rowspan=2>БИК бенефициара</td>"
                  "<td align=""center"" rowspan=2>Рез-во бенефициара</td>"
                  "<td align=""center"" rowspan=2>ГК</td>"
                  "<td colspan=3>Отправитель</td>"
                  "<td colspan=3>Получатель</td>"
                  "<td align=""center"" rowspan=2>КНП</td>"
                  "<td align=""center"" rowspan=2>Сумма</td>"
                  "<td align=""center"" rowspan=2>Валюта</td>"
                  "<td align=""center"" rowspan=2>Сумма в тенге</td>"
                  "<td align=""center"" rowspan=2>Проводка</td>"
                  "<td align=""center"" rowspan=2>Док</td>"
                  "<td align=""center"" rowspan=2>Дата</td>"
                  "<td align=""center"" rowspan=2>Наим ГК Дт</td>"
                  "<td align=""center"" rowspan=2>Наим ГК Кт</td>"
                  "<td align=""center"" rowspan=2>Курс</td>"
                  "<td align=""center"" rowspan=2>ДПС ГК Дт</td>"
                  "<td align=""center"" rowspan=2>ДПС ГК Кт</td>"
                  "<td align=""center"" rowspan=2>Дт лицевой счет</td>"
                  "<td align=""center"" rowspan=2>Кт лицевой счет</td>"
                  "<td align=""center"" rowspan=2>Наименование счета Дт</td>"
                  "<td align=""center"" rowspan=2>Наименование счета Кт</td>"
                  "<td align=""center"" rowspan=2>Признак документа</td>"
                  "<td align=""center"" rowspan=2>Код шаблона</td>"
                  "<td align=""center"" rowspan=2>Наименование филиала</td>"
                  "<td align=""center"" rowspan=2>Количество платежей</td>"
                  "</tr>" skip.

       put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Резидент</td>"
                  "<td >Сек эк</td>"
                  "<td > Страна</td>"
                  "<td >Резидент</td>"
                  "<td >Сек эк</td>"
                  "<td > Страна</td>"
                  "</tr>"
                   skip.

for each t-eknp where t-eknp.jdt ge v-dtb and t-eknp.jdt le v-dte exclusive-lock:
    /*if t-eknp.jh = 1483438 then message "1=" t-eknp.sr t-eknp.pr t-eknp.jh t-eknp.rbank t-eknp.rbank1 view-as alert-box.*/

    if (string(t-eknp.gl1) begins "1051" or string(t-eknp.gl1) begins "1052") and
    (string(t-eknp.gl2) begins "1051" or string(t-eknp.gl2) begins "1052") then do:
        if t-eknp.rbank <> "" and t-eknp.rbank1 = "" then t-eknp.rbank1 = t-eknp.rbank.
        else if t-eknp.rbank1 <> "" and t-eknp.rbank = "" then t-eknp.rbank = t-eknp.rbank1.
    end.
    else do:
        if trim(t-eknp.sr) = "03" and t-eknp.pr = "03" then assign t-eknp.rbank  = "NBRKKZKX".
        if trim(t-eknp.sr) = "03" and t-eknp.pr = "04" then assign t-eknp.rbank1 = "NBRKKZKX".
    end.

    if t-eknp.rbank begins "00" then assign t-eknp.rbank = substr(t-eknp.rbank,3,length(t-eknp.rbank)).
    if t-eknp.rbank1 begins "00" then assign t-eknp.rbank1 = substr(t-eknp.rbank1,3,length(t-eknp.rbank1)).
    /*if t-eknp.jh = 1483438 then message "2=" t-eknp.jh t-eknp.rbank t-eknp.rbank1 view-as alert-box.*/
end.

for each t-eknp where t-eknp.jdt ge v-dtb and t-eknp.jdt le v-dte no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td>" t-eknp.sr "</td>" skip
        "<td>" t-eknp.pr "</td>" skip
        "<td align=""center"">" t-eknp.gl1 "</td>" skip
        "<td align=""center"">" t-eknp.rbank "</td>" skip
        "<td align=""center"">" t-eknp.l_rbank "</td>" skip
        "<td align=""center"">" t-eknp.rbank1 "</td>" skip
        "<td align=""center"">" t-eknp.l_rbank1 "</td>" skip
        "<td align=""center"">" t-eknp.gl2 "</td>" skip
        "<td align=""center"">" t-eknp.s_locat "</td>" skip
        "<td align=""center"">" t-eknp.s_secek "</td>" skip
        "<td align=""center"">" t-eknp.cnt1 "</td>" skip
        "<td align=""center"">" t-eknp.r_locat "</td>" skip
        "<td align=""center"">" t-eknp.r_secek "</td>" skip
        "<td align=""center"">" t-eknp.cnt2 "</td>" skip
        "<td align=""center"">" t-eknp.knp "</td>" skip
        "<td>" replace(string(t-eknp.sum , ">>>>>>>>>>>9.99"), ".", ",") "</td>" skip
        "<td align=""center"">" t-eknp.crccode "</td>" skip
        "<td>" replace(string(t-eknp.sumkzt , ">>>>>>>>>>>9.99"), ".", ",") "</td>" skip
        "<td align=""center"">" t-eknp.jh "</td>" skip
        "<td align=""center"">" t-eknp.rmz "</td>" skip
        "<td align=""center"">" string(t-eknp.jdt,"99/99/9999") "</td>" skip.

    put stream rep unformatted "<td align=""center"">".
    find first gl where gl.gl = t-eknp.gl1 no-lock no-error.
    put stream rep unformatted if avail gl then trim(gl.des) else ''.
    put stream rep unformatted "</td>".

    put stream rep unformatted "<td align=""center"">".
    find first gl where gl.gl = t-eknp.gl2 no-lock no-error.
    put stream rep unformatted if avail gl then trim(gl.des) else ''.
    put stream rep unformatted "</td>".

    put stream rep unformatted "<td align=""center"">".
    find last crchis where crchis.crc = t-eknp.crc and crchis.rdt <= t-eknp.jdt - 1 no-lock no-error.
    put stream rep unformatted if avail crchis then replace(trim(string(crchis.rate[1], ">>>>>>>>>>>9.99")), ".", ",") else ''.
    put stream rep unformatted "</td>".

    put stream rep unformatted
        "<td align=center>" t-eknp.drgl7     "</td>" skip
        "<td align=center>" t-eknp.crgl7     "</td>" skip
        "<td align=center>" t-eknp.dracc20   "</td>" skip
        "<td align=center>" t-eknp.cracc20   "</td>" skip
        "<td align=center>" t-eknp.draccname "</td>" skip
        "<td align=center>" t-eknp.craccname "</td>" skip
        "<td align=center>" t-eknp.prizplat  "</td>" skip
        "<td align=center>" t-eknp.trxcode   "</td>" skip
        "<td align=center>" t-eknp.namebnk   "</td>" skip
        "<td align=center>1</td>" skip.

    put stream rep unformatted
        "</tr>".
end.

/*Расчет и вывод Курсовой разницы*/
/*Расчет ведется по курсу за предыдущий день (Актолкын сказала)*/

def buffer b-dfb    for dfb.
def buffer b-bankl  for bankl.
def buffer b2-bankl for bankl.

def temp-table t-wrk
    field name          as char
    field bank          as char
    field acc           as char
    field crc           as inte
    field gl            as inte
    field bic           as char
    field inputost      as deci
    field outputost     as deci
    field debetob       as deci
    field creditob      as deci
    field inputostkzt   as deci
    field outputostkzt  as deci
    field debetobkzt    as deci
    field creditobkzt   as deci.

def temp-table t-date
    field dayrep as date
    field num    as inte
    index idx is primary num ascending.

def var nummonth as inte.
def var yearnum  as inte.
def var v-modulo as inte.
def var s        as inte.
def var begyear  as date.

begyear  = date(01,01,year(v-dte)).
nummonth = month(v-dte).
yearnum  = year(v-dte).

do k = 1 to nummonth:
    if k = 1 or k = 3 or k = 5 or k = 7 or k = 8 or k = 10 or k = 12 then do:
        create t-date.
        assign
        t-date.dayrep = date(k,31,yearnum)
        t-date.num    = k.
    end.
    if k = 4 or k = 6 or k = 11 or k = 9 then do:
        create t-date.
        assign
        t-date.dayrep = date(k,30,yearnum)
        t-date.num    = k.
    end.
    if k = 2 then do:
        v-modulo = integer(substr(string(yearnum),3,2)) modulo 4.
        if v-modulo = 0 then do:
            create t-date.
            assign
            t-date.dayrep = date(k,29,yearnum)
            t-date.num    = k.
        end.
        else do:
            create t-date.
            assign
            t-date.dayrep = date(k,28,yearnum)
            t-date.num    = k.
        end.
    end.
end.

empty temp-table t-wrk.
for each dfb where length(dfb.dfb) = 20 and dfb.crc <> 1 no-lock break by dfb.bank:
    if first-of(dfb.bank) then do:
        for each b-dfb where b-dfb.bank = dfb.bank and b-dfb.crc <> 1 and length(b-dfb.dfb) = 20 no-lock break by b-dfb.crc:
            create t-wrk.
            assign
            t-wrk.name = b-dfb.name
            t-wrk.bank = b-dfb.bank
            t-wrk.acc  = b-dfb.dfb
            t-wrk.crc  = b-dfb.crc
            t-wrk.gl   = b-dfb.gl.
            find first bankl where trim(bankl.name) = trim(b-dfb.name) and bankl.bic <> "" no-lock no-error.
            if avail bankl then assign t-wrk.bic = bankl.bic.
            else do:
                find first b-bankl where trim(b-bankl.bank) = trim(b-dfb.bank) and b-bankl.bic <> "" no-lock no-error.
                if avail b-bankl then assign t-wrk.bic = b-bankl.bic.
                else do:
                    find first b2-bankl where trim(b2-bankl.bank) = trim(b-dfb.bank) and b2-bankl.bic = "" and b2-bankl.bank <> ""
                    no-lock no-error.
                    if avail b2-bankl then assign t-wrk.bic = b2-bankl.bank.
                end.
            end.
            if t-wrk.bic begins "00" then assign t-wrk.bic = substr(t-wrk.bic,3,length(t-wrk.bic)).
        end.
    end.
end.

for each t-eknp where t-eknp.crc <> 1 no-lock:
    if string(t-eknp.gl1) begins "1051" or string(t-eknp.gl1) begins "1052" or string(t-eknp.gl1) begins "2013" then do:
        if not(string(t-eknp.gl2) begins "1051") and not(string(t-eknp.gl2) begins "1052") and
        not(string(t-eknp.gl2) begins "2013") then do:
            find first t-wrk where t-wrk.gl = t-eknp.gl1 and trim(t-wrk.acc) = trim(t-eknp.dracc20) no-lock no-error.
            if not avail t-wrk then do:
                create t-wrk.
                assign
                t-wrk.name = trim(t-eknp.draccname).
                find first bankl where trim(bankl.name) = trim(t-wrk.name) no-lock no-error.
                if avail bankl then assign t-wrk.bank = bankl.bank.
                assign
                t-wrk.bic  = t-eknp.rbank
                t-wrk.acc  = t-eknp.dracc20
                t-wrk.crc  = t-eknp.crc
                t-wrk.gl   = t-eknp.gl1.
            end.
        end.
    end.
    if string(t-eknp.gl2) begins "1051" or string(t-eknp.gl2) begins "1052" or string(t-eknp.gl2) begins "2013" then do:
        if not(string(t-eknp.gl1) begins "1051") and not(string(t-eknp.gl1) begins "1052") and
        not(string(t-eknp.gl1) begins "2013") then do:
            find first t-wrk where t-wrk.gl = t-eknp.gl2 and trim(t-wrk.acc) = trim(t-eknp.cracc20) no-lock no-error.
            if not avail t-wrk then do:
                create t-wrk.
                assign
                t-wrk.name = trim(t-eknp.craccname).
                find first bankl where trim(bankl.name) = trim(t-wrk.name) no-lock no-error.
                if avail bankl then assign t-wrk.bank = bankl.bank.
                assign
                t-wrk.bic  = t-eknp.rbank1
                t-wrk.acc  = t-eknp.cracc20
                t-wrk.crc  = t-eknp.crc
                t-wrk.gl   = t-eknp.gl2.
            end.
        end.
    end.
end.

for each t-wrk where t-wrk.acc = "" exclusive-lock:
    delete t-wrk.
end.

def var v-sumdeb    as deci.
def var v-sumcre    as deci.
def var v-sumdebkzt as deci.
def var v-sumcrekzt as deci.

for each t-wrk exclusive-lock:
    /*Исходящий остаток*/
    find last histrxbal where histrxbal.acc = trim(t-wrk.acc) and histrxbal.lev = 1 and histrxbal.dt <= v-dte no-lock no-error.
    if avail histrxbal then do:
        find last crchis where crchis.crc = t-wrk.crc and crchis.rdt <= v-dte no-lock no-error.
        if t-wrk.crc <> 1 then assign t-wrk.outputostkzt = t-wrk.outputostkzt + (ABSOLUTE(histrxbal.dam - histrxbal.cam)) * crchis.rate[1].
        t-wrk.outputost = t-wrk.outputost + ABSOLUTE(histrxbal.dam - histrxbal.cam). /*В валюте*/
    end.
    /*Входящий остаток*/
    find last t-date where t-date.num = month(v-dte) - 1 no-lock no-error.
    find last histrxbal where histrxbal.acc = trim(t-wrk.acc) and histrxbal.lev = 1 and histrxbal.dt <= t-date.dayrep no-lock no-error.
    if avail histrxbal then do:
        find last crchis where crchis.crc = t-wrk.crc and crchis.rdt <= t-date.dayrep no-lock no-error.
        if t-wrk.crc <> 1 then assign t-wrk.inputostkzt = t-wrk.inputostkzt + (ABSOLUTE(histrxbal.dam - histrxbal.cam)) * crchis.rate[1].
        t-wrk.inputost = t-wrk.inputost + ABSOLUTE(histrxbal.dam - histrxbal.cam). /*В валюте*/
    end.
    /*Обороты по дебету и кредиту*/
    assign v-sumdeb = 0 v-sumcre = 0 v-sumdebkzt = 0 v-sumcrekzt = 0.
    for each jl where jl.acc = trim(t-wrk.acc) and jl.jdt >= v-dtb and jl.jdt <= v-dte no-lock:
        if jl.dc = "D" then do:
            find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt - 1 no-lock no-error.
            if jl.crc <> 1 then v-sumdebkzt = v-sumdebkzt + (jl.dam * crchis.rate[1]).
            v-sumdeb = v-sumdeb + jl.dam.
        end.
        else do:
            find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt - 1 no-lock no-error.
            if jl.crc <> 1 then v-sumcrekzt = v-sumcrekzt + (jl.cam * crchis.rate[1]).
            v-sumcre = v-sumcre + jl.cam.
        end.
    end.
    assign
    t-wrk.debetob = v-sumdeb
    t-wrk.creditob = v-sumcre
    t-wrk.debetobkzt = v-sumdebkzt
    t-wrk.creditobkzt = v-sumcrekzt.
end.

for each t-wrk no-lock:
    put stream rep unformatted
        "<tr>" skip.
    if string(t-wrk.gl) begins "1051" then put stream rep unformatted "<td>03</td>" skip.
    else if string(t-wrk.gl) begins "1052" or string(t-wrk.gl) begins "2013" then do:
        if t-wrk.bic matches "*KZ*" then put stream rep unformatted "<td>06</td>" skip.
        else put stream rep unformatted "<td>07</td>" skip.
    end.
    if string(t-wrk.gl) begins "1051" or string(t-wrk.gl) begins "1052" then do:
        if (t-wrk.outputostkzt + (t-wrk.creditobkzt - t-wrk.debetobkzt) - t-wrk.inputostkzt) > 0 then put stream rep unformatted
            "<td>08</td>" skip.
        else put stream rep unformatted
            "<td>07</td>" skip.
    end.
    else if string(t-wrk.gl) begins "2013" then do:
        if (t-wrk.outputostkzt + (t-wrk.debetobkzt - t-wrk.creditobkzt) - t-wrk.inputostkzt) > 0 then put stream rep unformatted
            "<td>10</td>" skip.
        else put stream rep unformatted
            "<td>09</td>" skip.
    end.
    put stream rep unformatted
        "<td align=""center"">" t-wrk.gl "</td>" skip
        "<td align=""center"">" t-wrk.bic "</td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center"">" t-wrk.bic "</td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center"">" t-wrk.gl "</td>" skip
        "<td align=""center"">1</td>" skip
        "<td align=""center"">4</td>" skip
        "<td align=""center"">KZ</td>" skip
        "<td align=""center"">1</td>" skip
        "<td align=""center"">4</td>" skip
        "<td align=""center"">KZ</td>" skip
        "<td align=""center"">290</td>" skip.
    if string(t-wrk.gl) begins "1051" or string(t-wrk.gl) begins "1052" then put stream rep unformatted
        "<td align=""center"">" replace(string(ABSOLUTE(t-wrk.outputostkzt + t-wrk.creditobkzt - t-wrk.debetobkzt - t-wrk.inputostkzt), ">>>>>>>>>>>>>>>>>>9.99-"), ".", ",") "</td>" skip.
    else if string(t-wrk.gl) begins "2013" then put stream rep unformatted
        "<td align=""center"">" replace(string(ABSOLUTE(t-wrk.outputostkzt - t-wrk.creditobkzt + t-wrk.debetobkzt - t-wrk.inputostkzt), ">>>>>>>>>>>>>>>>>>9.99-"), ".", ",") "</td>" skip.
    find first crc where crc.crc = t-wrk.crc no-lock no-error.
    if avail crc then put stream rep unformatted
        "<td align=""center"">" crc.code "</td>" skip.
    if string(t-wrk.gl) begins "1051" or string(t-wrk.gl) begins "1052" then put stream rep unformatted
        "<td align=""center"">" replace(string(ABSOLUTE(t-wrk.outputostkzt + t-wrk.creditobkzt - t-wrk.debetobkzt - t-wrk.inputostkzt), ">>>>>>>>>>>>>>>>>>9.99-"), ".", ",") "</td>" skip.
    else if string(t-wrk.gl) begins "2013" then put stream rep unformatted
        "<td align=""center"">" replace(string(ABSOLUTE(t-wrk.outputostkzt - t-wrk.creditobkzt + t-wrk.debetobkzt - t-wrk.inputostkzt), ">>>>>>>>>>>>>>>>>>9.99-"), ".", ",") "</td>" skip.
    put stream rep unformatted
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip
        "<td align=""center""></td>" skip.

    put stream rep unformatted "<td align=""center"">".
    find first gl where gl.gl = t-wrk.gl no-lock no-error.
    put stream rep unformatted if avail gl then trim(gl.des) else ''.
    put stream rep unformatted "</td>".

    put stream rep unformatted "<td align=""center"">".
    find first gl where gl.gl = t-wrk.gl no-lock no-error.
    put stream rep unformatted if avail gl then trim(gl.des) else ''.
    put stream rep unformatted "</td>".

    put stream rep unformatted "<td align=""center""></td>".

    put stream rep unformatted
        "<td align=center></td>" skip
        "<td align=center></td>" skip
        "<td align=center>" t-wrk.acc         "</td>" skip
        "<td align=center>" t-wrk.acc         "</td>" skip
        "<td align=center>" ACCNAM(t-wrk.acc) "</td>" skip
        "<td align=center>" ACCNAM(t-wrk.acc) "</td>" skip
        "<td align=center></td>" skip
        "<td align=center></td>" skip
        "<td align=center></td>" skip
        "<td align=center>1</td>" skip.

    put stream rep unformatted
        "</tr>".
end.


put stream rep "</table>" skip.

put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin eknp.htm excel.



