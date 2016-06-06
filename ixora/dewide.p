/* dewide.p
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Выписка по клиентским счетам
 * RUN

 * CALLER
        stgen.p - по таблице процедур печати выписок, там почти везде вот эта программа указана
 * SCRIPT

 * INHERIT

 * MENU
        Пункт меню - 1.4.4.2.
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        14/09/2001 sasco    - diling
        21/09/2001 sasco    - ekvival. KZT =
        29/10/2001 sasco    - выписка тенг/экв. только в пункте 2.4.2
        01/11/2001 sasco    - для JOU проводок dealsdet заполняется из jl.
        18/02/2002          - output to...  выполняется после запроса на тенговые эквиваленты (чтоб не попал на печать :-)
        18/12/2002          - РНН отправителя денег для внутрибанка
        24/01/2003 nadejda  - теперь пересчет валюты идет по умолчанию по СРЕДНЕВЗВЕШЕННОМУ курсу!
        28/10/2003 nadejda  - в рекламе добавила Променад
        08.04.2004 nadejda  - увеличен формат сумм до 10 после запятой для избежания ошибок округления
        25.06.2004 dpuchkov - добавил исполнителя в выписку согласно постановлению нац банка
        03.08.2004 suchkov  - добавил пару строк в рекламу
        03.11.2004 dpuchkov - сделал чтоб исходящий остаток был равен фактическому(без отображения специнструкций).
        06.12.2004 dpuchkov - добавил отображение РНН бенефициара между клиентами банка.
        29.06.2005 dpuchkov - изменил адрес РКО Самал
        08.09.2005 dpuchkov - добавил рекламу РКО на Ауэзова, убрал Променад
        19.04.2006 dpuchkov - изменинил номер телефона для РКО МЕРКУР
        26.04.2006 u00121   - поменял телефон у Меркура
        24.06.2006 tsoy     - Если платеж на АРП картела то показывать реквизиты Картела в АТФ банке
        25.06.2006 tsoy     - Исправлен глюк с филиальской выпиской
        14.12.09 marinav    - добавлена информация для клиентов
        19/01/2010 madiyar  - добавлена строчка с 20-значным счетом
        11.06.10 marinav    - изменена информация для клиентов
        14.09.10 marinav    - изменена информация для клиентов
        28.09.10 marinav    - изменена информация для клиентов
        06.03.2012 damir    - переход на новые форматы, нередактируемые документы.
        14.03.2012 damir    - изменено сообщение клиентам на матричном.(Служебка 02.02.2012)
        28.03.2012 damir    - убрал вывод выписки на матричный принтер.
        13.04.2012 damir    - изменил формат с "yes/no" на "да/нет".
        20.04.2012 damir    - перекомпиляция в связи с изменением hronos.i, dbsum.i.
        24/04/2012 evseev   - изменения в .i
        27/04/2012 evseev   - повтор
        05.05.2012 damir    - добавил функцию replace_bnamebik, изменения в hronos.i, dbsum.i.
        07/05/2012 evseev   - подключил replacebnk.i
        11.05.2012 damir    - перекомпиляция в связи с изменением hronos.i, dbsum.i.
        23.05.2012 damir    - добавил functext.i.
        11.07.2012 damir    - перекомпиляция...
        17.09.2012 damir    - Оптимизация кода, тестирование ИИН/БИН, внедрено Т.З. № 1379. убрал message "ВАЛЮТНЫЙ СЧЕТ",
                              изменения в hronos.i,dbsum.i,defhwide.i,functext.i.
        25.09.2012 damir    - Внедрено Т.З. № 1522.
        09.10.2012 damir    - Небольшая корректировка в hronos.i,dbsum.i по изменению 17.09.2012.
        26.12.2012 damir    - Внедрено Т.З. 1624.
        19.01.2012 damir    - Перекомпиляция в связи с изменениями в hronos.i,dbsum.i. Добавлена GetRnnRmz.i.
        28.01.2013 damir    - Перекомпиляция в связи с изменением GetRnnRmz.i.
        01.02.2013 damir    - По комиссиям КНП = 840. При тестировании не обнаружили. Подправил в процедуре SearchDt.
        28.05.2013 damir    - Внедрено Т.З. № 1541.
        25.11.2013 damir - Внедрено Т.З. № 2219.
*/

{comm-txb.i}
{replacebnk.i}
{chbin.i}

define input parameter destination as character.
define shared var g-lang as char.
define shared var g-fname like nmenu.fname.
def var vdet as char.

def var vatf as char.
def var vkartel as char.

{nbankBik.i}

define var seltxb as int.
seltxb = comm-cod().

/* -------  Новая переменная --- индикатор счета (валюта или теньге) */
/* -------  Если в валюте, то VAL_ACC = YES иначе NO -----*/
def variable fun2_4_2  as logical init no.
def variable val_acc   as logical format "да/нет" init yes.
def variable val_peres as decimal decimals 10 format "->>,>>>,>>>,>>>,>>9.99".
def variable val_from  like crc.rate[1].
def variable val_to    like crc.rate[1].
def var val_kind as integer format "9" init 1. /* 1 - пересчет по средневзвеш.курсу, 2 - по нацбанку */

def variable numline as integer init 1.
def variable prevjou as char init "".
def variable i as integer.

/* Temporary Tables Structure Defining --------------------------------- */

{header-t.i "shared" }
{deals.i    "shared" }

define variable crccode as character.
define variable crccode20 as character no-undo.

define variable v-kurs as decimal.                  /* --- Currency Kurs     */
define variable v-koef as integer.                  /* --- Currency Quantity */
define variable lines as integer initial 0.         /* --- Lines in deal          */

define variable d_t as decimal initial 0.
define variable c_t as decimal initial 0.

define variable ordins         as character extent 4.
define variable ordcust  as character extent 4.
define variable ordacc         as character.
define variable benfsr   as character extent 4.
define variable benbank  as character extent 4.
define variable benacc   as character .
define variable dealsdet as character extent 4.
define variable bankinfo as character extent 4.

define variable itogo_c as decimal init 0.
define variable itogo_d as decimal init 0.
define variable t-amt as decimal init 0.
def var v-aaa20 as char no-undo.

/* 31.10.2001 by sasco ::: check if global f-name is 2.4.2 "STACC" */
if g-fname = 'stacc' then fun2_4_2 = yes.
                     else fun2_4_2 = no.
/* --------------------------------------------------------------------- */

{stlib.i}
{r-htrx2.f}

/* --------------------------------------------------------------------- */

def shared var s-cif        like cif.cif.
def shared var g-comp       AS character.
def shared var g-today      as date.
def shared var g-batch      as logical.
def shared var g-ofc        like ofc.ofc.
def shared var date_from    as date.
def shared var date_to      as date.
def shared var hronol       as logi.
def shared var dksum        as logi.

define variable strbal as character initial "Промежуточный остаток".
define variable sakbal as character initial "Входящий остаток".
define variable dpre   as logical.

def var bankcontrbik as char format "x(100)". /*БИК*/
def var bankcontrnam as char format "x(100)". /*Банк контрагента*/
def var aaa          as char.
def var knp          as char.
def var rnn          as char.
def var v-code       as char.
def var namebank     as char format "x(100)". /*Наименование банка*/
def var v-KOd        as char.
def var v-KBe        as char.
def var v-KNP        as char.
def var v-ccode      as char.
def var s-jh         as inte.
def var s-sum        as deci decimals 2.
def var db           as char.
def var cr           as char.
def var sumekv       as char.
def var sumekvItog   as char.
def var sumalldb     as deci.
def var sumallcr     as deci.
def var naznplat     as char.
def var v-storned    as logi init no.
def var C_Col        as inte.
def var C_Mod        as inte.
def var v-SumEkviv   as deci.
def var v-crclog     as logi.
def var v-Foreign    as logi.
def var v-bnkbin     as char.
def var v-curs as deci.

def buffer b-deals for deals.

def temp-table t-jl
    field jh as inte
    field gl as inte
    field acc as char
    field dc as char
    field ln as inte
    field amount as deci format "->>>>>>>>>>>>>>>>>9.99"
    field rem as char
index idx1 is primary jh ascending
index idx2 jh ascending
           acc ascending
           dc ascending
           amount ascending
index idx3 jh ascending
           dc ascending
           amount ascending
index idx4 jh ascending
           dc ascending
           acc ascending.

def buffer b-t-jl  for t-jl.

output to value (destination).
def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile_1 as char init "/data/export/statpersonalacc.htm". /*Книжная форма выписки*/
def var v-inputfile_2 as char init "/data/export/statpersonalaccVIP.htm". /*Альбомная форма выписки*/
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

find first cmp no-lock no-error.
find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bnkbin = trim(sysc.chval).

procedure InitParam.
    v-storned = false.
    for each jl where jl.jh = inte(b-deals.trxtrn) no-lock break by jl.ln:
        create t-jl.
        t-jl.jh = jl.jh.
        t-jl.gl = jl.gl.
        t-jl.acc = jl.acc.
        t-jl.dc = jl.dc.
        t-jl.ln = jl.ln.
        if jl.dc = "D" then t-jl.amount = jl.dam.
        else t-jl.amount = jl.cam.
        t-jl.rem = trim(trim(jl.rem[1]) + " " + trim(jl.rem[2]) + " " + trim(jl.rem[3]) + " " + trim(jl.rem[4]) + " " + trim(jl.rem[5])).
        if t-jl.rem matches "*storn*" then v-storned = true.
    end.

    assign bankcontrbik = "" bankcontrnam = "" aaa = "" knp = "" rnn = "" v-code = "" namebank = "" db = "" cr = "" naznplat = "" s-jh = 0 s-sum = 0
    v-KOd = "" v-KBe = "" v-KNP = "" v-ccode = "".
end procedure.

procedure Get_EKNP:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-KOd as char.
    def output parameter p-KBe as char.
    def output parameter p-KNP as char.

    find first sub-cod where sub-cod.sub = p-sub and sub-cod.acc = p-acc and sub-cod.d-cod = p-d-cod no-lock no-error.
    if avail sub-cod then do:
        p-KOd = substr(sub-cod.rcode,1,2).
        p-KBe = substr(sub-cod.rcode,4,2).
        p-KNP = substr(sub-cod.rcode,7,3).
    end.
end procedure.

procedure GetCcode:
    def input parameter p-sub as char.
    def input parameter p-acc as char.
    def input parameter p-d-cod as char.
    def output parameter p-ccode as char.

    find first sub-cod where sub-cod.sub = p-sub and sub-cod.acc = p-acc and sub-cod.d-cod = p-d-cod no-lock no-error.
    if avail sub-cod then p-ccode = sub-cod.ccode.
end procedure.

procedure SearchDt:
    find first t-jl where t-jl.jh = s-jh and t-jl.acc = b-deals.account and t-jl.dc = "D" and t-jl.amount = round(b-deals.amount,2) no-lock no-error.
    if avail t-jl then do:
        naznplat = t-jl.rem.
        find first b-t-jl where b-t-jl.jh = s-jh and b-t-jl.dc = "C" and b-t-jl.amount = round(t-jl.amount,2) no-lock no-error.
        if avail b-t-jl then do:
            if string(b-t-jl.gl) begins "4" then do:
                if not (naznplat matches "*Комиссия*") then naznplat = "Комиссия  " + naznplat.
                v-KNP = "840".
            end.

            find first arp where arp.arp = b-t-jl.acc no-lock no-error.
            if avail arp then do:
                if bankcontrbik + bankcontrnam = "" then do:
                    bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                    bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
                end.
                aaa = arp.arp.
                namebank = replace_bnamebik(v-nbankru,b-deals.d_date).
                if v-bin then do:
                    if b-deals.d_date ge v-bin_rnn_dt then rnn = v-bnkbin.
                    else rnn = trim(cmp.addr[2]).
                end.
                else rnn = trim(cmp.addr[2]).
                run GetCcode('arp',arp.arp,'secek',output v-ccode).
                v-code = "КБе:" + substr(trim(arp.geo),3,1) + v-ccode.
                v-KBe = substr(trim(arp.geo),3,1) + v-ccode.
            end.
            else do:
                find first aaa where aaa.aaa = b-t-jl.acc no-lock no-error.
                if avail aaa then do:
                    aaa = aaa.aaa.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        if v-bin then do:
                            if b-deals.d_date ge v-bin_rnn_dt then rnn = cif.bin.
                            else rnn = cif.jss.
                        end.
                        else rnn = cif.jss.
                        namebank = trim(cif.prefix) + " " + trim(cif.name).
                        run GetCcode('cln',cif.cif,'secek',output v-ccode).
                        v-code = "КБе:" + substr(trim(cif.geo),3,1) + v-ccode.
                        v-KBe = substr(trim(cif.geo),3,1) + v-ccode.
                    end.
                end.
                else do:
                    if bankcontrbik + bankcontrnam = "" then do:
                        bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                        bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
                    end.
                    aaa = string(b-t-jl.gl).
                    namebank = replace_bnamebik(v-nbankru,b-deals.d_date).
                    if v-bin then do:
                        if b-deals.d_date ge v-bin_rnn_dt then rnn = v-bnkbin.
                        else rnn = trim(cmp.addr[2]).
                    end.
                    else rnn = trim(cmp.addr[2]).
                end.
            end.
        end.
    end.
end procedure.

procedure SearchCt:
    find first t-jl where t-jl.jh = s-jh and t-jl.acc = b-deals.account and t-jl.dc = "C" and t-jl.amount = round(b-deals.amount,2) no-lock no-error.
    if avail t-jl then do:
        naznplat = t-jl.rem.
        find first b-t-jl where b-t-jl.jh = s-jh and b-t-jl.dc = "D" and b-t-jl.amount = round(t-jl.amount,2) no-lock no-error.
        if avail b-t-jl then do:
            find first arp where arp.arp = b-t-jl.acc no-lock no-error.
            if avail arp then do:
                if bankcontrbik + bankcontrnam = "" then do:
                    bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                    bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
                end.
                aaa = arp.arp.
                namebank = replace_bnamebik(v-nbankru,b-deals.d_date).
                if v-bin then do:
                    if b-deals.d_date ge v-bin_rnn_dt then rnn = v-bnkbin.
                    else rnn = trim(cmp.addr[2]).
                end.
                else rnn = trim(cmp.addr[2]).
                run GetCcode('arp',arp.arp,'secek',output v-ccode).
                v-code = "КОд:" + substr(trim(arp.geo),3,1) + v-ccode.
                v-KOd = substr(trim(arp.geo),3,1) + v-ccode.
            end.
            else do:
                find first aaa where aaa.aaa = b-t-jl.acc no-lock no-error.
                if avail aaa then do:
                    aaa = aaa.aaa.
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                        if v-bin then do:
                            if b-deals.d_date ge v-bin_rnn_dt then rnn = cif.bin.
                            else rnn = cif.jss.
                        end.
                        else rnn = cif.jss.
                        namebank = trim(cif.prefix) + " " + trim(cif.name).
                        run GetCcode('cln',cif.cif,'secek',output v-ccode).
                        v-code = "КОд:" + substr(trim(cif.geo),3,1) + v-ccode.
                        v-KOd = substr(trim(cif.geo),3,1) + v-ccode.
                    end.
                end.
                else do:
                    if bankcontrbik + bankcontrnam = "" then do:
                        bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                        bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
                    end.
                    aaa = string(b-t-jl.gl).
                    namebank = replace_bnamebik(v-nbankru,b-deals.d_date).
                    if v-bin then do:
                        if b-deals.d_date ge v-bin_rnn_dt then rnn = v-bnkbin.
                        else rnn = trim(cmp.addr[2]).
                    end.
                    else rnn = trim(cmp.addr[2]).
                end.
            end.
        end.
    end.
end procedure.

function RemSpace returns char(input rem as char).
    rem = trim(rem).
    rem = replace(rem,"\n"," ").
    rem = replace(rem,"\r","").
    return rem.
end function.

{functext.i}
{GetRnnRmz.i}

new_page = yes.
frmt = "x(" + string(cols) + ")".

/* ----- Destination Processing --------------------------------------- */
if destination = ? or destination = "" then destination = "rpt.img".

for each acc_list break by acc_list.crc by acc_list.aaa .
    {stmeuro.i}
    new_acc = yes.
    t1 = fa3.
    if first-of (acc_list.crc) then do:
        find first crc where crc.crc = acc_list.crc no-lock no-error.
        if crc.code = "Ls" then crccode = "LVL".
        else crccode = crc.code.
        tcrc = crccode.
    end.
    /*-------  ВСТАВКА ПРОВЕРКИ ТИПА СЧЕТА (ВАЛЮТА / ТЕНГЕ)-------- */
    val_acc = no.
    if fun2_4_2 = yes then do:
        if crc.crc ne 1 then val_acc = yes.
        else val_acc = no.
        /*if val_acc = yes then update val_acc label  " ВЫПИСАТЬ ТЕНГОВЫЕ ЭКВИВАЛЕНТЫ? (да/нет)" skip
        val_kind label " КУРС ПЕРЕСЧЕТА:  1-средневзвеш. 2-НБ РК" skip
        with row 12 centered side-label title " ВАЛЮТНЫЙ СЧЕТ ! " frame yesfrr.*/
        hide frame yesfrr.
    end.
    /*output to value (destination) page-size 0.*/
    /* -- Account Header Position Checking -- */
    lines = 30.  /* Minimum row for account output */
    if row_in_page + lines >= rows then do:
        new_page = no.
        do while new_page = no : run pwskip(0). end.
    end.
    page_num = 1.
    /* --- Statement Header Generation --- */
    {defhwide.i}
    /* --- Account Header --- */
    put "Счет " + acc_list.aaa + " " + crccode at 1 + margin format "x(40)".
    new_acc = no.
    run pwskip(0).

    /* IBAN header */
    find first aaa where aaa.aaa = acc_list.aaa no-lock no-error.
    if avail aaa then do:
        v-aaa20 = aaa.aaa20.
        find first aaa where aaa.aaa = v-aaa20 no-lock no-error.
        if avail aaa then do:
            crccode20 = ''.
            find first crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then crccode20 = crc.code.
            put "Новая структура счета  " + aaa.aaa + " " + crccode20 at 1 + margin format "x(60)".
            run pwskip(0).
        end.
    end.
    /* IBAN header - end*/
    /* .. Opening Balance .. */
    find first deals where deals.account = acc_list.aaa and deals.servcode = "ob" and deals.d_date = acc_list.d_from no-error.
    if available deals then intermbal = deals.amount.
    else intermbal = 0.

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip.

    put stream v-out unformatted
        "<TR bgcolor='#c2c2c2' border-color='#808080' align=center style='font-size:9pt;font:bold;padding-left:0.0cm;color:#571b24;font-family:calibri'>" skip
        "<TD>дата</TD>" skip
        "<TD>№<br>доку<br>мента</TD>" skip
        "<TD>банк<br>Контрагента</TD>" skip
        "<TD>реквизиты<br>Контрагента</TD>" skip
        "<TD>сумма<br>по дебету</TD>" skip
        "<TD>сумма<br>по кредиту</TD>" skip.

    v-Foreign = no.
    find first b-deals where b-deals.account = acc_list.aaa and
    b-deals.d_date >= acc_list.d_from and b-deals.d_date <= acc_list.d_to no-lock no-error.
    if avail b-deals and b-deals.crc <> 1 then do:
        v-Foreign = yes.
        put stream v-out unformatted
            "<TD>эквивалент<br>в тенге *</TD>" skip.
    end.

    put stream v-out unformatted
        "<TD style='width:30%'>назначение <br> платежа</TD>" skip
        "<TD>КНП</TD>" skip
        "</TR>" skip.

    /* ---- Transaction Processing --- */
    for each deals where deals.account = acc_list.aaa and ( deals.servcode = "lt" or deals.servcode = "st" ) and
    deals.d_date >= acc_list.d_from and deals.d_date <= acc_list.d_to and deals.who <> "exception"  break by deals.account
    by deals.d_date by deals.trxtrn.
        dpre = yes.
        if new_page = yes or first-of(deals.account)  then do:
            /* ---- Deals List Header */
            {acchwide.i}
            def var t-am111 as decimal.
            def var t-am1 as decimal.
            def var t-am2 as decimal.
            def var t-am222 as decimal.
            t-am111 = 0.
            t-am222 = 0.
            for each jl where jl.acc = acc_list.aaa and jl.jdt >= acc_list.d_from - 25 and jl.jdt <= acc_list.d_from and
            jl.who = "exception" no-lock:
                if jl.dc = "d" then t-am111 = t-am111 +  jl.dam.
                else t-am111 = t-am111 -  jl.cam.
            end.
            if first-of(deals.account) then do:
                find first b-deals where b-deals.account = acc_list.aaa and
                b-deals.d_date >= acc_list.d_from and b-deals.d_date <= acc_list.d_to no-lock no-error.

                put stream v-out unformatted
                    "<TR bgcolor='#f2f2f2' align=left style='font-size:11pt;font:bold;font-family:calibri'>" skip.
                if avail b-deals and b-deals.crc <> 1 then put stream v-out unformatted
                    "<TD colspan=9>Входящий остаток:   " string(absolute(intermbal - t-am111),"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip.
                else put stream v-out unformatted
                    "<TD colspan=8>Входящий остаток:   " string(absolute(intermbal - t-am111),"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip.
                put stream v-out unformatted
                    "</TR>" skip.
            end.

            if first-of(deals.account) then put sakbal format "x(25)" at 11 + margin.
            else put strbal format "x(25)" at 11 + margin.
            if intermbal < 0 then put absolute(intermbal - t-am111) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            else put intermbal - t-am111 format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            run pwskip(0).
            /* ------------------------------------------- TEST --- VAL_ACC --- */
            if val_acc = yes then do:
                if first-of(deals.account) then run crc-to-kzt1 (val_kind, crc.crc, acc_list.d_from, intermbal, output val_peres).
                else run crc-to-kzt1 (val_kind, crc.crc, acc_list.d_to, intermbal, output val_peres).
                put "Входящий курс" format "x(27)" at 11 + margin.
                run find-rate1 (val_kind, crc.crc, acc_list.d_from, output val_from).
                put val_from at 100 + margin.
                run pwskip(0).
                if first-of(deals.account) then put "Входящий остаток в тенге" format "x(27)" at 11 + margin.
                else put "Промежуточный остаток в тенге" format "x(32)" at 11 + margin.
                if val_peres < 0 then put absolute(val_peres) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                else put val_peres format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                run pwskip(0).
                /*
                /* -------------------- курсовая разница ------------------- */
                /* Найти курс на начало и конец периода */
                run find-rate1 (val_kind, crc.crc, acc_list.d_from, output val_from).
                run find-rate1 (val_kind, crc.crc, acc_list.d_to, output val_to).
                if val_from <> val_to then do:
                    put "Курсовая разница" format "x(25)" at 11 + margin.
                    /* Пересчет разницы - сумм по курсам на начало и конец периода */
                    put absolute((intermbal * val_to) - (intermbal * val_from)) format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                    run pwskip(0).
                    val_peres = intermbal * val_to.
                    if first-of(deals.account) then put "Входящий остаток в тенге" format "x(27)" at 11 + margin.
                    else put "Промежуточный остаток в тенге" format "x(32)" at 11 + margin.
                    put absolute(intermbal * val_to) format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                    run pwskip(0).
                end.*/
            end.
            if first-of(deals.account) then put fill ("-",cols) at 1 + margin format frmt. run pwskip(0).
            new_page = no.
        end. /* ... new page ... new account ... */
        /* String Quantity Calculation */
        lines = 2. /* --- TRN & Amount --- */
        /* --- Deals Details */
        {declear.i}
        if deals.dc = "c" then do:
            ordins[1] = substring(deals.ordins,1,70).
            if ordins[1] <> "" then lines = lines + 1.
            ordins[2] = substring(deals.ordins,71,70).
            if ordins[2] <> "" then lines = lines + 1.
            ordcust[1] = substring(deals.ordcust,1,70).
            if ordcust[1] <> "" then lines = lines + 1.
            ordcust[2] = substring(deals.ordcust,71,70).
            if ordcust[2] <> "" then lines = lines + 1.
            ordacc = substring(deals.ordacc, 1, 35).
            if ordacc <> ? then lines = lines + 1.
        end.
        else do: /* --- deals.dc = "d" --- */
            benbank[1] = substring(deals.benbank,1,70).
            if benbank[1] <> "" then lines = lines + 1.
            benbank[2] = substring(deals.benbank,71,70).
            if benbank[2] <> "" then lines = lines + 1.
            benacc  = substring(deals.benacc,1,35).
            if benacc <> "" then lines = lines + 1.
            benfsr[1] = substring(deals.benfsr,1,70).
            if benfsr[1] <> "" then lines = lines + 1.
            benfsr[2] = substring(deals.benfsr,71,70).
            if benfsr[2] <> "" then lines = lines + 1.
        end.
        if deals.trxcode begins "COM" then do:
            find first codfr where codfr.codfr = v-codfr and codfr.code = deals.trxcode no-lock no-error.
            if not available codfr then do:
                dealsdet[1] = "Комиссия.".
                dealsdet[2] = "".
                dealsdet[3] = "".
                dealsdet[4] = "".
            end.
            else do:
                dealsdet[1] = codfr.name[1].
                dealsdet[2] = "".
                dealsdet[3] = "".
                dealsdet[4] = "".
            end.
            if dealsdet[1] <> "" then lines = lines + 1.
        end.
        else do:
            dealsdet[1] = substring(deals.dealsdet,1,70).
            if dealsdet[1] <> "" then lines = lines + 1.
            dealsdet[2] =  substring(deals.dealsdet,71,70).
            if dealsdet[2] <> "" then lines = lines + 1.
            /* 01.11.2001. by sasco ---------------------------------*/
            if substring(deals.dealtrn,1,3) = 'jou' then if dealsdet[1] matches "*тариф*" or dealsdet[2] matches "*тариф*" then do:
                find first joudoc where joudoc.docnum eq deals.dealtrn no-lock no-error.
                if avail joudoc then do:
                    find first jl where jl.jh = joudoc.jh and (jl.rem[1] matches "*ариф*" or jl.rem[5] matches "*ариф*") no-lock no-error.
                    if avail jl then do:
                        if jl.rem[1] <> "" then dealsdet[1] = jl.rem[1].
                        if jl.rem[5] <> "" then dealsdet[2] = jl.rem[5].
                    end.
                end.
            end.
            dealsdet[3] =  substring(deals.dealsdet,141,70).
            if dealsdet[3] <> "" then lines = lines + 1.
            dealsdet[4] =  substring(deals.dealsdet,211,70).
            if dealsdet[4] <> "" then lines = lines + 1.
            bankinfo[1] = substring(deals.bankinfo,1,70).
            if bankinfo[1] <> "" then lines = lines + 1.
            bankinfo[2] =  substring(deals.bankinfo,71,70).
            if bankinfo[2] <> "" then lines = lines + 1.
        end.
        if row_in_page + lines >= rows then do:    /* =========== New Page Processing ============= */
            do while new_page = no :
                run pwskip(0).
            end.
            /* ---- Deals List Header ---- */
            {acchwide.i}
            put strbal format "x(25)" at 11 + margin.
            if intermbal < 0 then put absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            else put intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            run pwskip(1).
            /* ----------------- CHECK  VAL_ACC  ----------------------- */
            if val_acc = yes then do:
                put strbal format "x(25)" at 11 + margin.
                if intermbal < 0 then put absolute(intermbal) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                else put intermbal format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                if first-of(deals.account) then put "Входящий остаток в тенге" format "x(27)" at 11 + margin.
                else put "Промежуточный остаток в тенге" format "x(32)" at 11 + margin.
                if first-of(deals.account) then run crc-to-kzt1 (val_kind, crc.crc, acc_list.d_from, intermbal,
                output val_peres).
                else run crc-to-kzt1 (val_kind, crc.crc, acc_list.d_to, intermbal,output val_peres).
                if val_peres < 0 then put absolute(val_peres) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                else put val_peres format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                run pwskip(1).
            end.
            /* ----------------- CHECK  VAL_ACC  ----------------------- */
            new_page = no.
        end. /* ... row_in_page + lines >= rows ... */
        put deals.d_date at 1 + margin.
        put deals.trxtrn format "x(10)" at 11 + margin.
        put deals.custtrn format "x(18)" at 22 + margin.
        if deals.dc = "d"  then do:
            put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            intermbal = intermbal - deals.amount.
        end.
        else do:
            put deals.amount format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            intermbal = intermbal + deals.amount.
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        if val_acc = yes then do:
            run find-rate1 (val_kind, crc.crc, deals.d_date, output val_from).
            put "Курс" at 11 + margin.
            put val_from at 100 + margin.
            run pwskip(0).
            run crc-to-kzt1 (val_kind, crc.crc, deals.d_date, deals.amount, output val_peres).
            put "Сумма в тенге" format "x(15)" at 11 + margin.
            if deals.dc = "d"  then do:
                put val_peres format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                intermbal = intermbal - deals.amount.
                itogo_d = itogo_d + val_peres.
            end.
            else do:
                put val_peres format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                intermbal = intermbal + deals.amount.
                itogo_c = itogo_c + val_peres.
            end.
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        run pwskip(0).
        put upper(deals.trxcode) to 10  + margin format "x(5)".
        if deals.dealtrn <> "" then put deals.dealtrn format "x(16)" at 11 + margin.
        run pwskip(0).
        /* sasco - вывод РНН для кредитового внутрибанка */
        if deals.dealtrn <> "" and deals.dc = "c" then do:
            find joudoc where joudoc.docnum = deals.dealtrn no-lock no-error.
            if avail joudoc then do:
                find aaa where aaa.aaa = joudoc.dracc no-lock no-error.
                if avail (aaa) then find cif where cif.cif = aaa.cif no-lock no-error.
                if avail (aaa) and avail (cif) then do:
                    if v-bin then do:
                        if deals.d_date ge v-bin_rnn_dt then do:
                            put ">" at 9 + margin "БИН отправителя денег: " at 11 + margin.
                            if cif.bin <> "" then put cif.bin.
                            else put " <не известен>".
                        end.
                        else do:
                            put ">" at 9 + margin "РНН отправителя денег: " at 11 + margin.
                            if cif.jss <> "" and cif.jss <> "000000000000" then put cif.jss.
                            else put " <не известен>".
                        end.
                    end.
                    else do:
                        put ">" at 9 + margin "РНН отправителя денег: " at 11 + margin.
                        if cif.jss <> "" and cif.jss <> "000000000000" then put cif.jss.
                        else put " <не известен>".
                    end.
                    run pwskip(0).
                end.
            end.
        end.
        find remtrz where  remtrz.remtrz = deals.dealtrn no-lock no-error.
        if avail remtrz and seltxb <> 0 then do:
            if remtrz.ba = "011999832" and remtrz.rbank = "TXB00" then  do:
                vdet = "Оплата за телефон " + dealsdet[1]   +  " oт " + string(remtrz.valdt1) + ". Сумма " +
                REPLACE(string( (deals.amount ), '>>>,>>>,>>9.99' ),","," ")  + " в т.ч. НДС " + string((deals.amount) * 0.15).
                dealsdet[1]  = substring(vdet, 1,70).
                dealsdet[2]  = substring(vdet,71,70).
                vatf       = "г.АЛМАТЫ ФИЛИАЛ АО 'АТФБАНК'".
                vkartel    = "ТОО 'КаР-Тел'480091,Г.АЛМАТЫ, УЛ.ФУРМАНОВА, 130"         .
                put ">" at 9 + margin vatf format "x(70)" at 11 + margin. run pwskip(0).
                put ">" at 9 + margin vkartel format "x(70)" at 11 + margin. run pwskip(0).
                put ">" at 9 + margin dealsdet[1]  format "x(70)" at 11 + margin. run pwskip(0).
                if  dealsdet[2] <> "" then do: put ">" at 9 + margin dealsdet[2]  format "x(70)" at 11 + margin. run pwskip(0). end.
            end.
            else do:
                /* --- Ordering Customer --- */
                if deals.dc = "c" then do:
                    if ordins[1] <> "" then do: put ">" at 9 + margin ordins[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if ordins[2] <> "" then do: put ordins[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if ordcust[1] <> "" then do: put ">" at 9 + margin ordcust[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if ordcust[2] <> "" then do: put ordcust[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if ordacc <> "" then do: put ">" at 9 + margin ordacc format "x(70)" at 11 + margin. run pwskip(0). end.
                end.
                else do: /* --- if deals.dc = "d" --- */
                    if benbank[1] <> "" then do: put ">" at 9 + margin benbank[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if benbank[2] <> "" then do: put benbank[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if deals.dealtrn begins "jou" then do:
                        find joudoc where joudoc.docnum = deals.dealtrn no-lock no-error.
                        if avail joudoc then do:
                            find aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                            if avail (aaa) then find cif where cif.cif = aaa.cif no-lock no-error.
                            if avail (aaa) and avail (cif) and benfsr[1] <> "" then benacc = benacc + " /RNN/" + cif.jss.
                        end.
                    end.
                    if benfsr[1] <> "" then do: put ">" at 9 + margin benfsr[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if benfsr[2] <> "" then do: put benfsr[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                    if benacc <> "" then do: put ">" at 9 + margin benacc format "x(70)" at 11 + margin. run pwskip(0). end.
                end.
                /* --- Deals Details --- */
                if dealsdet[1] <> "" then do: put ">" at 9 + margin dealsdet[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if dealsdet[2] <> "" then do: put dealsdet[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                if dealsdet[3] <> "" then do: put dealsdet[3] format "x(70)" at 11 + margin. run pwskip(0). end.
                if dealsdet[4] <> "" then do: put dealsdet[4] format "x(70)" at 11 + margin. run pwskip(0). end.
                /* --- Bank Information --- */
                if bankinfo[1] <> "" then do: put ">" at 9 + margin bankinfo[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if bankinfo[2] <> "" then do: put bankinfo[2] format "x(70)" at 11 + margin. run pwskip(0). end.
            end.
        end.
        else do:
            /* --- Ordering Customer --- */
            if deals.dc = "c" then do:
                if ordins[1] <> "" then do: put ">" at 9 + margin ordins[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if ordins[2] <> "" then do: put ordins[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                if ordcust[1] <> "" then do: put ">" at 9 + margin ordcust[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if ordcust[2] <> "" then do: put ordcust[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                if ordacc <> "" then do: put ">" at 9 + margin ordacc format "x(70)" at 11 + margin. run pwskip(0). end.
            end.
            else do: /* --- if deals.dc = "d" --- */
                if benbank[1] <> "" then do: put ">" at 9 + margin benbank[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if benbank[2] <> "" then do: put benbank[2] format "x(70)" at 11 + margin. run pwskip(0). end.

                if deals.dealtrn begins "jou" then do:
                    find joudoc where joudoc.docnum = deals.dealtrn no-lock no-error.
                    if avail joudoc then do:
                        find aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                        if avail (aaa) then find cif where cif.cif = aaa.cif no-lock no-error.
                        if avail (aaa) and avail (cif) and benfsr[1] <> "" then  benacc = benacc + " /RNN/" + cif.jss.
                    end.
                end.
                if benfsr[1] <> "" then do: put ">" at 9 + margin benfsr[1] format "x(70)" at 11 + margin. run pwskip(0). end.
                if benfsr[2] <> "" then do: put benfsr[2] format "x(70)" at 11 + margin. run pwskip(0). end.
                if benacc <> "" then do: put ">" at 9 + margin benacc format "x(70)" at 11 + margin. run pwskip(0). end.
            end.
            /* --- Deals Details --- */
            if dealsdet[1] <> "" then do: put ">" at 9 + margin dealsdet[1] format "x(70)" at 11 + margin. run pwskip(0). end.
            if dealsdet[2] <> "" then do: put dealsdet[2] format "x(70)" at 11 + margin. run pwskip(0). end.
            if dealsdet[3] <> "" then do: put dealsdet[3] format "x(70)" at 11 + margin. run pwskip(0). end.
            if dealsdet[4] <> "" then do: put dealsdet[4] format "x(70)" at 11 + margin. run pwskip(0). end.
            /* --- Bank Information --- */
            if bankinfo[1] <> "" then do: put ">" at 9 + margin bankinfo[1] format "x(70)" at 11 + margin. run pwskip(0). end.
            if bankinfo[2] <> "" then do: put bankinfo[2] format "x(70)" at 11 + margin. run pwskip(0). end.
        end.
        /* ---- TRX_CODE Table Update ---- */
        find first trx_codes where trx_codes.code = deals.trxcode no-error.
        if not available trx_codes then do:
            find first codfr where codfr.codfr = v-codfr and codfr.code = deals.trxcode no-lock no-error.
            if available codfr then do:
                create trx_codes.
                trx_codes.code = deals.trxcode.
                trx_codes.name = codfr.name[1].
            end.
        end.
        /* --------------------------------- */
    end.  /* for each deals ... */



    sumalldb = 0. sumallcr = 0. C_Col = 0. v-SumEkviv = 0. v-crclog = no.
    /*----------------------------------------------*/
    /*Два вида группирования выписки*/
    if hronol = yes and dksum = no then do:
        {hronos.i}
    end.
    else if dksum = yes and hronol = no then do:
        {dbsum.i}
    end.
    if hronol = no and dksum = no then do:
        {hronos.i}
    end.
    /*----------------------------------------------*/





    /* ---- Turnover Processing ---------------------------------------------------- */
    d_t = 0. c_t = 0.
    find first deals where deals.account = acc_list.aaa and deals.servcode = "ldt" and deals.d_date = acc_list.d_to no-error.
    if available deals then d_t = deals.amount.
    find first deals where deals.account = acc_list.aaa and deals.servcode = "lct" and deals.d_date = acc_list.d_to no-error.
    if available deals then c_t = deals.amount.
    if c_t <> 0 and d_t <> 0 then lines =  9.
    else lines = 13.
    if row_in_page + lines >= rows then do:
        do while new_page = no :
            run pwskip(0).
        end.
    end.
    if c_t <> 0 or d_t <> 0  then do:
        run pwskip(0).
        put fill ("-",cols) at 1 + margin format frmt . run pwskip(0).
        put "Итого" at 1 + margin.
        def var t-amt1 as decimal.
        def var t-amt2 as decimal.
        t-amt1 = 0.
        t-amt2 = 0.
        for each deals where deals.account = acc_list.aaa and (deals.servcode = "lt" or deals.servcode = "st" ) and
        deals.d_date >= acc_list.d_from and deals.d_date <= acc_list.d_to and deals.who = "exception"  break by deals.account
        by deals.d_date by deals.trxtrn.
            if deals.dc = "d"  then t-amt1 = t-amt1 - deals.amount.
            else t-amt2 = t-amt2 - deals.amount.
        end.
        d_t = d_t + t-amt1.
        c_t = c_t + t-amt2.
        /* .. Debit Turnover .. */
        if d_t <> 0 then put d_t format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
        else put 0   format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
        /* .. Credit Turnover .. */
        if c_t <> 0 then put c_t format "z,zzz,zzz,zzz,zz9.99" at 100 + margin. /*run pwskip(1). */
        else put 0 format "z,zzz,zzz,zzz,zz9.99" at 100 + margin. /* run pwskip(1).*/
        /* ----------------- CHECK  VAL_ACC  ----------------------- */

        if val_acc then do:
            put "Итого в тенге" at 1 + margin.
            /* Курс на конец периoда */
            run find-rate1 (val_kind, crc.crc, acc_list.d_to, output val_to).
            put if d_t = 0 then 0 else itogo_d format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            put if c_t = 0 then 0 else itogo_c format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.

            run pwskip(1).
            put "Исходящий курс" at 1 + margin.
            put val_to at 100 + margin.
            run pwskip(0).
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        if c_t <> 0 then run pwskip(1).
    end. /* Turnover ... */
    /* ======================== Balances Output ======================================= */
    balance_mode = yes.
    if dpre = no then do:
        put fill("-",120) at 1 + margin format "x(120)". run pwskip(0).
        put "ДЕБЕТ" to 99 + margin.
        put "КРЕДИТ" to 119 + margin.
        run pwskip(0).
        put fill("-",120) at 1 + margin format "x(120)". run pwskip(0).
        def var t-amt22 as decimal.
        def var t-amt222 as decimal.
        def var t-amt111 as decimal.
        t-amt22 = 0.
        t-am1 = 0.
        t-am2 = 0.
        for each jl where jl.acc = acc_list.aaa and jl.jdt >= acc_list.d_from - 25 and jl.jdt <= acc_list.d_from and
        jl.who = "exception" no-lock:
            if jl.dc = "d" then t-am111 = t-am111 +  jl.dam.
            else t-am111 = t-am111 -  jl.cam.
        end.
        find first deals where deals.account = acc_list.aaa and deals.servcode = "ob" and deals.d_date = acc_list.d_from no-error.
        if available deals then do:
            if deals.amount < 0 then
            put "Входящий остаток" at 1 + margin absolute(deals.amount - t-amt111) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            else
            put "Входящий остаток" at 1 + margin deals.amount - t-amt111  format "z,zzz,zzz,zzz,zz9.99" at 100 + margin .
            /* ----------------- CHECK  VAL_ACC  ----------------------- */
            if val_acc then do:
                run crc-to-kzt1 (val_kind, crc.crc, deals.d_date, deals.amount,output val_peres).
                if val_peres < 0 then
                 put "Входящий остаток в тенге" at 1 + margin absolute(val_peres) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                else
                 put "Входящий остаток в тенге" at 1 + margin val_peres format "z,zzz,zzz,zzz,zz9.99" at 100 + margin .
            end.
            /* ----------------- CHECK  VAL_ACC  ----------------------- */
            run pwskip(0).
        end.
    end.
    t-amt = 0. t-amt22 = 0.
    for each jl where jl.acc = acc_list.aaa and jl.jdt >= acc_list.d_from and jl.jdt <= acc_list.d_to and jl.who = "exception" no-lock:
        if jl.dc = "d" then t-am1 = t-am1 -  (jl.dam - jl.cam).
        else t-am1 = t-am1 -  (jl.cam - jl.dam).
    end.
    /* .. Closing Balance .. */
    find first deals where deals.account = acc_list.aaa and deals.servcode = "cb" and deals.d_date = acc_list.d_to no-error.
    if available deals then do:

        find first b-deals where b-deals.account = acc_list.aaa and
        b-deals.d_date >= acc_list.d_from and b-deals.d_date <= acc_list.d_to no-lock no-error.
        put stream v-out unformatted
            "<TR bgcolor='#f2f2f2' align=left style='font-size:11pt;font:bold;font-family:calibri'>" skip.
        if avail b-deals and b-deals.crc <> 1 then put stream v-out unformatted
            "<TD colspan=9>Исходящий остаток:   " string(deals.amount - t-amt1,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip.
        else put stream v-out unformatted
            "<TD colspan=8>Исходящий остаток:   " string(deals.amount - t-amt1,"zzz,zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip.
        put stream v-out unformatted
            "</TR>" skip.

        if deals.amount < 0 then do:
            put "Исходящий остаток" at 1 + margin absolute(deals.amount - t-amt1) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            {stmeuro1.i "absolute(deals.amount)" "76"}
        end.
        else do:
            put "Исходящий остаток" at 1 + margin deals.amount - t-amt1
            format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            {stmeuro1.i "deals.amount" "96"}
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        if val_acc then do:
            run crc-to-kzt1 (val_kind, crc.crc, deals.d_date, deals.amount - t-amt1,
            output val_peres).
            if val_peres < 0 then do:
                put "Исходящий остаток в тенге" at 1 + margin absolute(val_peres) format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            end.
            else do:
                put "Исходящий остаток в тенге" at 1 + margin val_peres
                format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            end.
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        run pwskip(1).
    end.
    /* .. Available Balance */
    find first deals where deals.account = acc_list.aaa and deals.servcode = "cb" and deals.d_date = acc_list.d_to  no-error.
    if available deals then do:
        if deals.amount < 0 then do:
            put "Доступный остаток" at 1 + margin absolute(deals.amount - t-amt1)
            format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
            {stmeuro1.i "absolute(deals.amount)" "76"}
        end.
        else do:
            put "Доступный остаток" at 1 + margin deals.amount - t-amt1
            format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
            {stmeuro1.i "deals.amount" "96"}
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        if val_acc then do:
            run crc-to-kzt1 (val_kind, crc.crc, deals.d_date, deals.amount,output val_peres).
            if val_peres < 0 then do:
                put "Доступный остаток в тенге" at 1 + margin absolute(val_peres - t-amt)
                format "z,zzz,zzz,zzz,zz9.99" at 80 + margin.
                /*             {stmeuro1.i "absolute(deals.amount)" "76"}*/
            end.
            else do:
                put "Доступный остаток в тенге" at 1 + margin val_peres - t-amt
                format "z,zzz,zzz,zzz,zz9.99" at 100 + margin.
                /*             {stmeuro1.i "deals.amount" "96"}*/
            end.
        end.
        /* ----------------- CHECK  VAL_ACC  ----------------------- */
        new_acc = yes.
        run pwskip(0).
    end.
    /*
    /* .. Hold Balances .. */
    if acc_list.hbal <> 0 then
    for each deals where deals.account = acc_list.aaa and deals.servcode = "hbi" break by deals.account.
        put deals.dealsdet format "x(11)"  deals.amount . run pwskip(0).
        put "           " deals.in_value " " deals.d_date " ".
        put deals.ordcust  format "x(30)" "  /  Izpld:".
        put deals.who      format "x(30)".
        if last-of ( deals.account ) then new_acc = yes.
        run pwskip(0).
    end.
    */
    find sysc where sysc.sysc = 'REKVP' no-lock no-error.
    if avail sysc  and sysc.chval = "1" then do:
        run pwskip(1).
        find first ofc where ofc.ofc = g-ofc no-lock no-error.
        if available ofc then do:
            put "Исполнитель "  at 1 + margin .
            put ofc.name at 13 + margin.
        end.
    end.
    run pwskip(3).
    /* --- Statement footer Output --- */
    put "=========================================== КОНЕЦ ДОКУМЕНТА ==========================================================" at 1 + margin.
    run pwskip(1).
    balance_mode = no.
    /* --- History Registration --- */
    define variable r-cif like cif.cif.
    run getcv("h-cif",output r-cif).
    run hwr(r-cif, acc_list.aaa, acc_list.seq, acc_list.stmsts, acc_list.d_from, acc_list.d_to, "dewide" ).
    if return-value = "1" then do:
        run elog("HISTWR","ERR", "History Writer execution not completed.Terminated.").
        return "1".
    end.
    dpre = no.
end. /* Account List ... */
put skip(1).
/* -------- Codes List Generation ----------------------- */
{codeslist.i}
/* ------------------------------------------------------ */

/********* Информация*/

put "    Уважаемые клиенты! " skip.
put "        Примите, пожалуйста, к сведению, что в соответствии с Законом Республики Казахстан 'О внесении " skip.
put "    изменений в некоторые законодательные акты Республики Казахстан по вопросам идентификационных   " skip.
put "    номеров' изменена дата введения в действие идентификационных номеров (ИН) с 01 января 2012 года на" skip.
put "    1 января 2013 года. Начиная с этой даты Банк будет не вправе осуществлять операции по открытию и ведению" skip.
put "    банковских счетов юридических лиц, не имеющих Бизнес-идентификационного номера (далее - БИН), и " skip.
put "    физических лиц, не имеющих Индивидуального идентификационного номера (далее - ИИН), а также проводить " skip.
put "    платежи и переводы денег указанных лиц.  " skip.
/*put "        Обратите внимание на то, что у большинства граждан Республики Казахстан в удостоверениях личности " skip.
put "    уже имеется ИИН, так как данный номер впечатывается в удостоверение личности с августа 1997 года. " skip.*/
put "        Юридическим лицам рекомендуем заранее провести работу со своими партнерами по внесению " skip.
put "    соответствующих изменений в действующие договоры, во избежание каких-либо недоразумений при " skip.
put "    проведении платежей и перевода средств через Банк. " skip.
put "        Просим Вас переоформить (при необходимости) ранее выданные документы на документы с БИН/ИИН и " skip.
put "    предоставить их в Банк в срок до 1 января 2013 года." skip.
put "    " skip.

/*********/

/* by sasco */
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).
output close.
put stream v-out unformatted
    "</TABLE>" skip.

find ofc where ofc.ofc = g-ofc no-lock no-error.

if v-Foreign then do:
    put stream v-out unformatted
        "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip.
    put stream v-out unformatted
        "<TR><TD colspan=8 style='font-size:9pt;font:bold;color:#571b24;font-family:calibri'>* по курсу НБРК на дату совершения операции</TD></TR>" skip
        "<TR><TD colspan=8 style='height:1cm'></TD></TR>" skip.
    put stream v-out unformatted
        "</TABLE>" skip.
end.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip
    "<TR style='font-family:calibri'><TD style='height:2cm'></TD></TR>" skip
    "</TABLE>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip.
put stream v-out unformatted
    "<tr style='mso-yfti-irow:55;height:1.6pt;mso-row-margin-right:22.75pt;font-family:calibri'>
    <td width=319 colspan=13 valign=top style='width:239.45pt;padding:0cm 0cm 0cm 0cm;
    height:1.6pt'>
    <p class=MsoNormal style='margin-right:-1.15pt;mso-line-height-alt:0pt'><!--[if gte vml 1]><v:shapetype
    id=""_x0000_t32"" coordsize=""21600,21600"" o:spt=""32"" o:oned=""t"" path=""m,l21600,21600e""
    filled=""f"">
    <v:path arrowok=""t"" fillok=""f"" o:connecttype=""none""/>
    <o:lock v:ext=""edit"" shapetype=""t""/>
    </v:shapetype><v:shape id=""_x0000_s1026"" type=""#_x0000_t32"" style='position:absolute;
    margin-left:-56.7pt;margin-top:8.25pt;width:50.25pt;height:0;z-index:1;
    mso-position-horizontal-relative:text;mso-position-vertical-relative:text'
    o:connectortype=""straight"" strokecolor=""#571b24"" strokeweight=""1.5pt"">
    <v:shadow type=""perspective"" color=""#571b24"" opacity="".5"" offset=""1pt""
    offset2=""-1pt""/>
    </v:shape><![endif]--><![if !vml]><span style='mso-ignore:vglayout;
    position:absolute;z-index:1;margin-left:-77px;margin-top:10px;width:70px;
    height:2px'><img width=70 height=2 src=""ACC.files/image003.gif"" v:shapes=""_x0000_s1026""></span><![endif]><b
    style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:14.0pt;
    color:#571b24'>ОТМЕТКИ БАНКА<o:p></o:p></span></b></p>
    </td>
    <td width=18 colspan=2 valign=top style='width:13.5pt;padding:0cm 0cm 0cm 0cm;
    height:1.6pt'>
    <p class=MsoNormal style='mso-line-height-alt:0pt'><span lang=EN-US
    style='font-size:9.0pt;color:#571b24'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=164 colspan=14 valign=top style='width:122.75pt;padding:0cm 0cm 0cm 0cm;
    height:1.6pt'>
    <p class=MsoNormal style='margin-right:-5.4pt;mso-line-height-alt:0pt'><span
    lang=EN-US style='font-size:9.0pt;color:#571b24'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=198 colspan=12 valign=top style='width:148.85pt;padding:0cm 0cm 0cm 0cm;
    height:1.6pt'>
    <p class=MsoNormal style='mso-line-height-alt:0pt'><span lang=EN-US
    style='font-size:9.0pt;color:#571b24'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=30><p class='MsoNormal'>&nbsp;</td>
    </tr>".
put stream v-out unformatted
    "</TABLE>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" bordercolor=""white"" border=""0"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip.

put stream v-out unformatted
    "<TR style='font-size:11pt;font:bold;color:#571b24;font-family:calibri'>"
    "<TD style='width:2cm'>Выдал</TD>" skip
    "<TD style='width:5cm'></TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='width:3cm'></TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='width:2cm'></TD>" skip
    "<TD style='width:5cm'></TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='width:2cm'></TD>" skip
    "</TR>" skip
    "<TR style='font-size:11pt;font:bold;color:#571b24;font-family:calibri'>"
    "<TD style='width:2cm'></TD>" skip
    "<TD style='width:5cm;border-top:1px solid #999999;'></TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='font-size:7pt;width:3cm;border-top:1px solid #999999;color:#999999'>подпись</TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='width:2cm'></TD>" skip
    "<TD style='width:5cm'></TD>" skip
    "<TD style='width:0.5cm'></TD>" skip
    "<TD style='font-size:7pt;width:2cm;color:#999999'></TD>" skip
    "</TR>" skip.
put stream v-out unformatted
    "</TABLE>" skip.
output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

unix silent cptwin value(v-file2) winword.

/*pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.*/


/* ------------------------------------------------------ */

