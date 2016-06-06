/* extract.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Выписки по счетам клиентов ЮЛ/ИП
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        17.07.2013 damir - Внедрено Т.З. № 1523.
        04.10.2013 damir - Внедрено Т.З. № 1513,1648.
        25.11.2013 damir - Внедрено Т.З. № 2219.
*/

/*ВНИМАНИЕ!!!*/
/*Платежное поручение в extract.p печатается также в программе prtppp.p*/
/*Операционный ордер в extract.p печатается также в программе printvouord.p*/
/*Изменения нужно вносить в обоих программах*/

{nbankBik.i}
{chbin.i}
{comm-txb.i}
{deals.i "new shared"}
{replacebnk.i}
{classes.i}
{convgl.i "bank"}

def buffer b-crc for crc.
def buffer b-deals for deals.
def buffer b-cif for cif.
def buffer b-cmp for cmp.
def buffer b-sysc for sysc.
def buffer b-jl for jl.
def buffer b2-jl for jl.
def buffer b3-jl for jl.

def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var v-crc as inte.

define new shared temp-table ljl like jl.

def temp-table t-cif no-undo
    field cif as char
    field name as char
    field print as char
index idx1 is primary cif ascending
index idx2 print ascending.

def temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif
   field wcrc like crc.crc.

def temp-table remfile
   field rem as character.

def var v-ourbnk as char.
def var v-bnkbin as char.
def var v-bnkbik as char.
def var lastdt as date.
def var i as inte.
def var v-file1 as char init "extract.htm".
def var v-str as char.
def var bankcontrbik as char.
def var bankcontrnam as char.
def var aaa as char.
def var knp as char.
def var rnn as char.
def var v-code as char.
def var namebank as char.
def var v-KOd as char.
def var v-KBe as char.
def var v-KNP as char.
def var v-ccode as char.
def var s-jh as inte.
def var db as char.
def var cr as char.
def var sumekv as char.
def var sumekvItog as char.
def var sumalldb as deci.
def var sumallcr as deci.
def var naznplat as char.
def var v-storned as logi.
def var C_Col as inte.
def var C_Mod as inte.
def var v-SumEkviv as deci.
def var v-Foreign as logi.
def var v-curs as deci.
def var v-inbal as deci.
def var v-outbal as deci.
def var k as inte.

def stream v-out.

{functext.i}
{GetRnnRmz.i}

v-ourbnk = comm-txb().

function RemSpace returns char(input rem as char).
    rem = trim(rem).
    rem = replace(rem,"\n"," ").
    rem = replace(rem,"\r","").
    return rem.
end function.

form
    v-dtb label "С                " format "99/99/9999" skip
    v-dte label "По               " format "99/99/9999" skip
    v-crc label "Валюта счета     " format "z9" validate(can-find(b-crc where b-crc.crc = v-crc no-lock),"Неверный код валюты!Повторите ввод!") help "Выбор через клавишу F2"
    v-cod as char no-label format "x(3)" skip
    v-print as logi label "Печать документов" format "да/нет"
with side-labels row 5 column 1 width 50 title "ВЫПИСКА ПО СЧЕТАМ КЛИЕНТОВ" frame extract.

on help of v-crc in frame extract do:
    {itemlist.i
    &file    = "b-crc"
    &frame   = "row 6 centered scroll 1 20 down overlay "
    &where   = "true"
    &flddisp = " b-crc.crc label 'Код' format 'z9'
                 b-crc.code label 'Валюта' format 'x(3)' "
    &chkey   = "crc"
    &chtype  = "integer"
    &index   = "crc"}
    if avail b-crc then do: v-crc = b-crc.crc. v-cod = b-crc.code. end.
    displ v-crc v-cod with frame extract.
end.

v-dtb = g-today. v-dte = g-today. v-crc = 1.
find b-crc where b-crc.crc = v-crc no-lock no-error.
if avail b-crc then v-cod = b-crc.code.
displ v-dtb v-dte v-crc v-cod v-print with frame extract.
update v-dtb v-dte v-crc v-print with frame extract.

find first b-cmp no-lock no-error.
find first cmp no-lock no-error.
find first b-sysc where b-sysc.sysc = "bnkbin" no-lock no-error.
if avail b-sysc then v-bnkbin = trim(b-sysc.chval).
find first b-sysc where b-sysc.sysc = "CLECOD" no-lock no-error.
if avail b-sysc then v-bnkbik = trim(b-sysc.chval).

run extract2.

/*for each b-deals no-lock:
    message "1=" b-deals.dealtrn "2=" b-deals.ordins "3=" b-deals.ordcust "4=" b-deals.ordacc "5=" b-deals.benfsr "6=" b-deals.benacc "7=" b-deals.benbank
            "8=" b-deals.dealsdet "9 = " b-deals.bankinfo "10=" b-deals.d_date "11=" b-deals.dc "12=" b-deals.servcode "13=" b-deals.trxcode "14=" b-deals.custtrn
            "15=" b-deals.amount "16=" b-deals.account "17=" b-deals.in_value "18=" b-deals.trxtrn "|" view-as
            alert-box.
end.*/

empty temp-table t-cif.
for each b-deals no-lock break by b-deals.cif:
    if first-of(b-deals.cif) then do:
        find b-cif where b-cif.cif = b-deals.cif no-lock no-error.
        create t-cif.
        t-cif.cif = b-deals.cif.
        t-cif.name = trim(trim(b-cif.prefix) + " " + trim(b-cif.name)).
    end.
end.

run Show.

procedure Show:
    def buffer b-cif for cif.

    def button b_all label "Выделить все".
    def button b_print label "Выписка".

    def query q_list for t-cif scrolling.
    def browse b_list query q_list no-lock
    displ
        t-cif.cif column-label "CIF-код" format "x(7)"
        t-cif.name column-label "Наименование клиента" format "x(40)"
        t-cif.print column-label "Отметить" format "x(1)"
    with title "<Enter>-отметить,<delete>-удалить" 10 down centered width 63 overlay no-row-markers.

    def frame extract2
        b_list
        b_all colon 24
        b_print
    with no-labels row 12 centered overlay width 65 title "СПИСОК КЛИЕНТОВ".

    on "ENDKEY" of frame extract2 do:
        hide all no-pause.
        return.
    end.

    on "RETURN" of browse b_list do:
        get current q_list.
        if avail t-cif then t-cif.print = "V".
        displ t-cif.print with browse b_list.
    end.

    on "DELETE" of browse b_list do:
        get current q_list.
        if avail t-cif then t-cif.print = "".
        displ t-cif.print with browse b_list.
    end.

    on CHOOSE of b_all do:
        FOR EACH t-cif exclusive-lock:
            t-cif.print = "V".
        end.
        OPEN QUERY q_list FOR EACH t-cif no-lock by t-cif.cif.
    end.

    on CHOOSE of b_print do:
        run printdoc.
    end.

    OPEN QUERY q_list FOR EACH t-cif no-lock by t-cif.cif.

    enable all with frame extract2.
    apply "value-changed" to b_list in frame extract2.
    wait-for "endkey" of frame extract2 focus browse b_list.
end procedure.

procedure printdoc:
    output stream v-out to value(v-file1).
    {html-title.i &stream = "stream v-out"}

    k = 0.
    for each t-cif where t-cif.print = "V" no-lock:
        find b-cif where b-cif.cif = t-cif.cif no-lock no-error.
        for each deals where deals.cif = t-cif.cif no-lock break by deals.account:
            if last-of(deals.account) then do:
                k = k + 1.

                find last b-deals where b-deals.cif = t-cif.cif and b-deals.account = deals.account and b-deals.d_date <= v-dte no-lock no-error.
                if avail b-deals then lastdt = b-deals.d_date.
                find b-crc where b-crc.crc = deals.crc no-lock no-error.

                v-inbal = 0.
                run lonbalcrc("CIF",deals.account,v-dtb,"1",false,deals.crc,output v-inbal).
                v-outbal = ABSOLUTE(v-inbal).

                run head.
                for each b-deals where b-deals.cif = deals.cif and b-deals.account = deals.account no-lock break by b-deals.d_date:
                    run main.
                end.
                run extend.

                for each b-deals where b-deals.cif = deals.cif and b-deals.account = deals.account no-lock break by b-deals.ref:
                    if v-print then do:
                        if b-deals.ref begins "rmz" then do:
                            if b-deals.crc = 1 then run printnewform. /*Формирование платежного поручения в WORD*/
                        end.
                        else run printvouext. /*Формирование операционного ордера WORD*/
                    end.
                end.
            end.
        end.
    end.

    {html-end.i "stream v-out"}
    output stream v-out close.

    unix silent cptwin value(v-file1) winword.
end procedure.

procedure head:
    if k <> 1 then put stream v-out unformatted '<P><br clear=all style="page-break-before:always"></P>' skip.

    def var v-template as char init "/data/export/statpersonalacc.htm".
    input from value(v-template).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*Dateformirovan*" then do:
                v-str = replace(v-str,"Dateformirovan",string(today,"99/99/9999")).
                next.
            end.
            if v-str matches "*Namebank*" then do:
                if v-nbankru <> "" then v-str = replace(v-str,"Namebank",trim(v-nbankru)).
                else v-str = replace(v-str,"Namebank",'АО "ForteBank"').
                next.
            end.
            if v-str matches "*bank_rnn*" then do:
                if v-bin then do:
                    if v-dte ge v-bin_rnn_dt then v-str = replace(v-str,"bank_rnn","").
                    else v-str = replace(v-str,"bank_rnn",trim(b-cmp.addr[2])).
                end.
                next.
            end.
            if v-str matches "*bank_bin*" then do:
                if v-bnkbin <> "" then v-str = replace(v-str,"bank_bin",v-bnkbin).
                else v-str = replace(v-str,"bank_bin",'').
                next.
            end.
            if v-str matches "*bank_bik*" then do:
                if v-bnkbik <> "" then v-str = replace(v-str,"bank_bik",trim(v-bnkbik)).
                else v-str = replace(v-str,"bank_bik",'').
                next.
            end.
            if v-str matches "*Datefrom*" then do:
                if v-dtb <> ? then v-str = replace(v-str,"Datefrom",string(v-dtb,"99/99/9999")).
                else v-str = replace(v-str,"Datefrom",'').
                next.
            end.
            if v-str matches "*Datedue*" then do:
                if v-dte <> ? then v-str = replace(v-str,"Datedue",string(v-dte,"99/99/9999")).
                else v-str = replace(v-str,"Datedue",'').
                next.
            end.
            if v-str matches "*Bankclienpartner*" then do:
                if b-cif.name <> "" then v-str = replace(v-str,"Bankclienpartner",trim(b-cif.prefix) + " " + trim(b-cif.name)).
                else v-str = replace(v-str,"Bankclienpartner",'').
                next.
            end.
            if v-str matches "*Rnn_client*" then do:
                if v-bin then do:
                    if v-dte ge v-bin_rnn_dt then v-str = replace(v-str,"Rnn_client","").
                    else v-str = replace(v-str,"Rnn_client",trim(b-cif.jss)).
                end.
                next.
            end.
            if v-str matches "*Acc_client*" then do:
                if b-deals.account <> "" then v-str = replace(v-str,"Acc_client",b-deals.account + "&nbsp;&nbsp;" + b-crc.code).
                else v-str = replace(v-str,"Acc_client",'').
                next.
            end.
            if v-str matches "*InnBnn_client*" then do:
                if b-cif.bin <> "" then v-str = replace(v-str,"InnBnn_client",trim(b-cif.bin)).
                else v-str = replace(v-str,"InnBnn_client",'').
                next.
            end.
            if v-str matches "*dataposlplatezh*" then do:
                if lastdt <> ? then v-str = replace(v-str,"dataposlplatezh",string(lastdt,"99/99/9999") + "&nbsp;г.").
                else v-str = replace(v-str,"dataposlplatezh",'').
                next.
            end.
            if v-str matches "*BNNRNN*" then do:
                if v-bin then do:
                    if v-dte ge v-bin_rnn_dt then v-str = replace(v-str,"BNNRNN","").
                    else v-str = replace(v-str,"BNNRNN","РНН").
                end.
                next.
            end.
            if v-str matches "*INNBNN*" then do:
                v-str = replace(v-str,"INNBNN","ИИН/БИН").
                next.
            end.
            if v-str matches "*LSD:*" then do:
                if v-bin then do:
                    if v-dte ge v-bin_rnn_dt then v-str = replace(v-str,"LSD:","").
                    else v-str = replace(v-str,"LSD:","РНН:").
                end.
                next.
            end.
            if v-str matches "*WEH*" then do:
                v-str = replace(v-str,"WEH","БИН").
                next.
            end.
            if v-str matches "*</body>*" then do:
                v-str = replace(v-str,"</body>","").
                next.
            end.
            if v-str matches "*</html>*" then do:
                v-str = replace(v-str,"</html>","").
                next.
            end.
            leave.
        end.

        put stream v-out unformatted v-str skip.
    end.
    input close.

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
    if deals.crc <> 1 then do:
        put stream v-out unformatted
            "<TD>эквивалент<br>в тенге *</TD>" skip.
    end.
    put stream v-out unformatted
        "<TD style='width:30%'>назначение <br> платежа</TD>" skip
        "<TD>КНП</TD>" skip
        "</TR>" skip.
    put stream v-out unformatted
        "<TR bgcolor='#f2f2f2' align=left style='font-size:11pt;font:bold;font-family:calibri'>" skip.
    if deals.crc <> 1 then put stream v-out unformatted
        "<TD colspan=9>Входящий остаток:   " string(absolute(v-inbal),"->>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip.
    else put stream v-out unformatted
        "<TD colspan=8>Входящий остаток:   " string(absolute(v-inbal),"->>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip.
    put stream v-out unformatted
        "</TR>" skip.

    sumalldb = 0. sumallcr = 0. v-SumEkviv = 0.
end procedure.

procedure main:
    bankcontrbik = "". bankcontrnam = "". aaa = "". knp = "". rnn = "". v-code = "". namebank = "". db = "". cr = "". naznplat = "". s-jh = 0. v-KOd = "". v-KBe = "". v-KNP = "". v-ccode = "".

    /*RMZ - документы*/
    if trim(b-deals.dealtrn) begins "RMZ" then do:
        s-jh = inte(b-deals.trxtrn) no-error.

        run Get_EKNP('rmz',b-deals.dealtrn,'eknp',output v-KOd,output v-KBe,output v-KNP).
        if b-deals.dc = "D"  then do:
            v-code = "КБе:" + v-KBe.

            if index(b-deals.benbank,"/") > 0 then do:
                bankcontrbik = substr(trim(b-deals.benbank),1,index(b-deals.benbank,"/") - 1).
                bankcontrnam = substr(trim(b-deals.benbank),index(b-deals.benbank,"/") + 1,length(b-deals.benbank)).
            end.
            else do:
                if trim(b-deals.benbank) begins "TXB" then do:
                    bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                    bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
                end.
                else do:
                    bankcontrbik = substr(trim(b-deals.benbank),1,8).
                    bankcontrnam = substr(trim(b-deals.benbank),9,length(b-deals.benbank)).
                end.
            end.
            if b-deals.benfsr = "" then do:
                run SearchDt.
            end.
            else do:
                namebank = GetNameBenOrd(b-deals.benfsr).
                rnn = GetRnnBenOrd(b-deals.benfsr).
                aaa = b-deals.benacc.
            end.
        end.
        else if b-deals.dc = "C" then do:
            v-code = "КОд:" + v-KOd.

            if trim(b-deals.ordins) begins "TXB" then do:
                bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
                bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).
            end.
            else do:
                bankcontrbik = substr(trim(b-deals.ordins),1,8).
                bankcontrnam = substr(trim(b-deals.ordins),9,length(b-deals.ordins)).
            end.

            if b-deals.ordcust = "" then do:
                run SearchCt.
            end.
            else do:
                namebank = GetNameBenOrd(b-deals.ordcust).
                rnn = GetRnnBenOrd(b-deals.ordcust).
                aaa = b-deals.ordacc.
            end.
        end.
    end.
    /*JOU - документы*/
    else if trim(b-deals.dealtrn) begins "JOU" then do: /*JOU document*/
        s-jh = inte(b-deals.trxtrn).

        run Get_EKNP('jou',b-deals.dealtrn,'eknp',output v-KOd,output v-KBe,output v-KNP).

        bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
        bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).

        if b-deals.dc = "D" then do:

            if v-KOd + v-KBe + v-KNP = "" then run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

            v-code = "КБе:" + v-KBe.
            if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".

            run SearchDt.
        end.
        else if b-deals.dc = "C" then do:

            if v-KOd + v-KBe + v-KNP = "" then run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

            v-code = "КОд:" + v-KOd.
            if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".

            run SearchCt.
        end.
    end.
    /*Другие Операции*/
    else do:
        s-jh = inte(b-deals.trxtrn).

        bankcontrbik = replace_bnamebik(v-clecod,b-deals.d_date).
        bankcontrnam = replace_bnamebik(v-nbankru,b-deals.d_date).

        if b-deals.dc = "D" then do:
            run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

            if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".
            if b-deals.dealsdet begins "Перевод остатков" or b-deals.dealsdet begins "Автоматический перевод остатков" then v-KNP = "321".

            run SearchDt.

            if v-KOd + v-KBe + v-KNP = "" then do:
                find first b-jl where b-jl.jh = s-jh and b-jl.dc = b-deals.dc and b-jl.acc = b-deals.account no-lock no-error.
                if avail b-jl then run GetCods(v-storned,s-jh,b-deals.dc,b-jl.dam,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
            end.

            if v-KOd + v-KBe + v-KNP = "" then do:
                find first b-jl where b-jl.jh = s-jh and b-jl.dc = "C" and b-jl.acc = b-deals.account no-lock no-error.
                if avail b-jl then run GetCods(v-storned,s-jh,"C",b-jl.dam,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
            end.

            v-code = "КБе:" + v-KBe.
        end.
        else if b-deals.dc = "C" then  do:
            run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

            if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".
            if b-deals.dealsdet begins "Перевод остатков" or b-deals.dealsdet begins "Автоматический перевод остатков" then v-KNP = "321".

            run SearchCt.

            if v-KOd + v-KBe + v-KNP = "" then do:
                find first b-jl where b-jl.jh = s-jh and b-jl.dc = b-deals.dc and b-jl.acc = b-deals.account no-lock no-error.
                if avail b-jl then run GetCods(v-storned,s-jh,b-deals.dc,b-jl.cam,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
            end.

            if v-KOd + v-KBe + v-KNP = "" then do:
                find first b-jl where b-jl.jh = s-jh and b-jl.dc = "D" and b-jl.acc = b-deals.account no-lock no-error.
                if avail b-jl then run GetCods(v-storned,s-jh,"D",b-jl.cam,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
            end.

            v-code = "КОд:" + v-KOd.
        end.
        naznplat = remconv(b-deals.trxtrn,naznplat).
    end.

    if b-deals.dc = "D"  then do:
        db = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99").
        cr = "0.00".
        sumalldb = sumalldb + b-deals.amount.
    end.
    else do:
        db = "0.00".
        cr = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99").
        sumallcr = sumallcr + b-deals.amount.
    end.

    C_Col = C_Col + 1.
    C_Mod = C_Col mod 2.

    if C_Mod = 0 then put stream v-out unformatted
        "<TR bgcolor='#f2f2f2' align=center style='font-size:8pt;font-family:calibri'>" skip.
    else put stream v-out unformatted
        "<TR align=center style='font-size:8pt;font-family:calibri'>" skip.
    put stream v-out unformatted
        "<TD>" string(b-deals.d_date,"99/99/99") "</TD>" skip.
    if index(b-deals.custtrn,"Nr.") > 0 then put stream v-out unformatted
        "<TD>" substr(trim(b-deals.custtrn),index(b-deals.custtrn,"Nr.") + 3,length(b-deals.custtrn)) "</TD>" skip.
    else put stream v-out unformatted
        "<TD>" substr(b-deals.trxtrn,1,3) "<br>" substr(b-deals.trxtrn,4,length(b-deals.trxtrn)) "</TD>" skip.
    put stream v-out unformatted
        "<TD>" bankcontrbik + "<br>" + RazdSpace(bankcontrnam,15) "</TD>" skip
        "<TD>" replace(aaa,"/","") + "<br>" + trim(RazdSpace(namebank,28)) + "<br>".
    if v-bin then do:
        if b-deals.d_date ge v-bin_rnn_dt then put stream v-out unformatted
            "ИИН/БИН:" + rnn + ",".
        else put stream v-out unformatted
            "РНН:" + rnn + ",".
    end.
    else put stream v-out unformatted
        "РНН:" + rnn + ",".
    put stream v-out unformatted
        v-code "</TD>" skip
        "<TD>" replace(db,","," ") "</TD>" skip
        "<TD>" replace(cr,","," ") "</TD>" skip.
    if b-deals.crc <> 1 then do:
        v-curs = 0.
        if b-deals.d_date >= 01/05/12 then do:
            find last crcpro where crcpro.crc = b-deals.crc and crcpro.regdt <= b-deals.d_date no-lock no-error.
            if avail crcpro then v-curs = crcpro.rate[1].
        end.
        if b-deals.d_date <= 01/05/12 then do:
            find last ncrchis where ncrchis.crc = b-deals.crc and ncrchis.rdt <= b-deals.d_date no-lock no-error.
            if avail ncrchis then v-curs = ncrchis.rate[1].
        end.
        sumekv = string(b-deals.amount * v-curs,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99").
        put stream v-out unformatted
            "<TD>" replace(sumekv,","," ") "</TD>" skip.

        v-SumEkviv = v-SumEkviv + b-deals.amount * v-curs.
    end.

    if naznplat <> "" then put stream v-out unformatted
        "<TD align=left>" RemSpace(ReplMarks(naznplat)) "</TD>" skip.
    else put stream v-out unformatted
        "<TD align=left>" RemSpace(ReplMarks(b-deals.dealsdet)) "</TD>" skip.
    put stream v-out unformatted
        "<TD>" v-KNP "</TD>" skip
        "</TR>" skip.

end procedure.

procedure extend:
    sumekvItog = string(v-SumEkviv,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99").
    put stream v-out unformatted
        "<TR align=center style='font-size:11pt;font-family:calibri'>" skip
        "<TD align=left colspan=4><B>Всего оборотов:</B></TD>" skip
        "<TD style='font-size:8pt'>" replace(string(sumalldb,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99"),","," ") "</TD>" skip
        "<TD style='font-size:8pt'>" replace(string(sumallcr,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99"),","," ") "</TD>" skip.
    if deals.crc <> 1 then put stream v-out unformatted
        "<TD style='font-size:8pt'>" replace(sumekvItog,","," ") "</TD>" skip.
    put stream v-out unformatted
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.

    v-outbal = v-outbal - sumalldb + sumallcr.
    put stream v-out unformatted
        "<TR bgcolor='#f2f2f2' align=left style='font-size:11pt;font:bold;font-family:calibri'>" skip.
    if deals.crc <> 1 then put stream v-out unformatted
        "<TD colspan=9>Исходящий остаток:   " string(v-outbal,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip.
    else put stream v-out unformatted
        "<TD colspan=8>Исходящий остаток:   " string(v-outbal,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip.
    put stream v-out unformatted
        "</TR>" skip.
    put stream v-out unformatted
        "</TABLE>" skip.
    if deals.crc <> 1 then do:
        put stream v-out unformatted
            "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" style='border-collapse:collapse'>" skip.
        put stream v-out unformatted
            "<TR><TD colspan=9 style='font-size:9pt;font:bold;color:#571b24;font-family:calibri'>* по курсу НБРК на дату совершения операции</TD></TR>" skip
            "<TR><TD colspan=9 style='height:1cm'></TD></TR>" skip.
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
    find first b2-jl where b2-jl.jh = inte(b-deals.trxtrn) and b2-jl.crc = b-deals.crc and b2-jl.dc = "D" and b2-jl.dam = b-deals.amount and b2-jl.ln = b-deals.ln no-lock no-error.
    if avail b2-jl and b2-jl.acc = b-deals.account then do:
        naznplat = trim(trim(b2-jl.rem[1]) + " " + trim(b2-jl.rem[2]) + " " + trim(b2-jl.rem[3]) + " " + trim(b2-jl.rem[4]) + " " + trim(b2-jl.rem[5])).
        find first b3-jl where b3-jl.jh = inte(b-deals.trxtrn) and b3-jl.crc = b2-jl.crc and b3-jl.dc = "C" and b3-jl.cam = b-deals.amount and b3-jl.ln <> b2-jl.ln no-lock no-error.
        if avail b3-jl then do:
            if string(b3-jl.gl) begins "4" then do:
                if not (naznplat matches "*Комиссия*") then naznplat = "Комиссия  " + naznplat.
                v-KNP = "840".
            end.

            find first arp where arp.arp = b3-jl.acc no-lock no-error.
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
                find first aaa where aaa.aaa = b3-jl.acc no-lock no-error.
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
                    aaa = string(b3-jl.gl).
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
    find first b2-jl where b2-jl.jh = inte(b-deals.trxtrn) and b2-jl.crc = b-deals.crc and b2-jl.dc = "C" and b2-jl.cam = b-deals.amount and b2-jl.ln = b-deals.ln no-lock no-error.
    if avail b2-jl and b2-jl.acc = b-deals.account then do:
        naznplat = trim(trim(b2-jl.rem[1]) + " " + trim(b2-jl.rem[2]) + " " + trim(b2-jl.rem[3]) + " " + trim(b2-jl.rem[4]) + " " + trim(b2-jl.rem[5])).
        find first b3-jl where b3-jl.jh = inte(b-deals.trxtrn) and b3-jl.crc = b2-jl.crc and b3-jl.dc = "D" and b3-jl.dam = b-deals.amount and b3-jl.ln <> b2-jl.ln no-lock no-error.
        if avail b3-jl then do:
            find first arp where arp.arp = b3-jl.acc no-lock no-error.
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
                find first aaa where aaa.aaa = b3-jl.acc no-lock no-error.
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
                    aaa = string(b3-jl.gl).
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

procedure printnewform:

    /*ВНИМАНИЕ!!!*/
    /*Это же платежное поручение печатается в программе prtppp.p*/

    def var v-mudate    as char format 'x(070)'. /* v-valdt  */
    def var v-mudate2   as char format 'x(016)'. /* v-valdt2 */
    def var v-m1        as char format 'x(060)'. /* v-ord    */
    def var v-m2        as char format 'x(012)'. /* v-rnn    */
    def var v-bm1       as char format 'x(028)'. /* v-ordins */
    def var v-bm2       as char format 'x(043)'. /* v-ordins */
    def var v-bm3       as char format 'x(043)'. /* v-ordins */
    def var v-bbbb      as char format 'x(043)'.
    def var v-km        as char format 'x(015)'. /* номер счета плательщика */
    def var v-km1       as char format 'x(015)'. /* номер счета плательщика */
    def var v-kbm       as char format 'x(009)'. /* код банка плательщика */
    def var v-sm        as char format 'x(016)'. /* v-payment */
    def var v-s1        as char format 'x(033)'. /* v-bn */
    def var v-s2        as char format 'x(043)'. /* v-bn */
    def var v-bs1       as char format 'x(028)'. /* v-bb */
    def var v-bs2       as char format 'x(043)'. /* v-bb */
    def var v-kbs       as char format 'x(009)'. /* код банка получателя */
    def var v-ks        as char format 'x(020)'. /* v-ba */
    def var v-ks1       as char format 'x(020)'. /* v-ba */
    def var v-numurs    as char format 'x(070)'.
    def var v-chief     as char format 'x(030)'.
    def var v-code      as char format 'x(035)'.
    def var v-plars     as char format 'x(002)'.
    def var v-polrs     as char format 'x(002)'.
    def var v-knp       as char format 'x(003)'.
    def var v-knps      as char format 'x(087)'.
    def var v-sumt      as char extent 6 format 'x(56)'.
    def var v-detch     as char.
    def var glbuhgalter as char.
    def var ourbank     as char.
    def var v-strtmp    as char.
    def var v-sd        as char.
    def var v-ls        as char.
    def var v-cif       as char.
    def var v-tmp       as char.
    def var v-val       as logical init false.
    def var v-new       as logical init false.
    def var s-cust-arp  as char.
    def var s-toter-arp as char.
    def var v-su        like remtrz.payment.

    find first remtrz where remtrz.remtrz = substr(b-deals.ref,1,10) no-lock no-error.
    if avail remtrz then do:
        find sysc where sysc.sysc = 'ourbnk' no-lock no-error.
        if avail sysc then ourbank = sysc.chval.
        find first sysc where sysc = 'cstarp' no-lock no-error.
        if avail sysc then s-cust-arp = sysc.chval.
        find first sysc where sysc = 'ttsarp' no-lock no-error.
        if avail sysc then s-toter-arp = sysc.chval.
        if remtrz.rbank = ourbank then v-ls = trim( if remtrz.racc <> '' then remtrz.racc else remtrz.cracc ).
        else v-ls = trim( if remtrz.sacc <> '' then remtrz.sacc else remtrz.dracc ).
        if length(v-ls) < 9 then v-ls = fill( '0', 9 - length( v-ls )) + v-ls.

        m1:
        do:
            find first aaa where aaa.aaa = v-ls no-lock no-error.
            if avail aaa then do:
                v-cif = aaa.cif.
                leave m1.
            end.

            find first arp where arp.arp = v-ls no-lock no-error.
            if avail arp then do:
                v-cif = arp.cif.
                leave m1.
            end.

            find first lon where lon.lon = v-ls no-lock no-error.
            if avail lon then do:
                v-cif = lon.cif.
                leave m1.
            end.
        end.
        if v-cif <> '' then do.
           find first cif where cif.cif = v-cif no-lock no-error.
           if avail cif then do:
              find first sub-cod where sub-cod.sub = 'cln' and sub-cod.ccode = 'chief' and sub-cod.acc = string(cif.cif) no-lock no-error.
               if avail sub-cod then v-chief = if remtrz.rbank begins 'TXB' then '' else trim(sub-cod.rcode).
           end.
        end.
        else v-chief = "".
        find first crc where crc.crc = remtrz.tcrc no-lock no-error.
        find first sub-cod where sub-cod.d-cod = 'eknp' and sub-cod.ccode = 'eknp' and sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz no-lock no-error.
        if avail sub-cod then do:
            v-plars = substring( sub-cod.rcode, 01, 02 ).
            v-polrs = substring( sub-cod.rcode, 04, 02 ).
            v-knp   = substring( sub-cod.rcode, 07, 03 ).
            find first codfr where codfr.codfr = 'spnpl' and codfr.code  = v-knp no-lock no-error.
            v-knps = if available codfr then codfr.name[1] + codfr.name[2] + codfr.name[3] else ''.
        end.

        if remtrz.tcrc <> 1 then v-val = true. else v-val = false.
        if v-val then do:
            v-m1 = GetNameBenOrd(remtrz.ord).
            v-m2 = GetRnnBenOrd(remtrz.ord).

            v-tmp   = (remtrz.bn[1]) + (remtrz.bn[2]) + (remtrz.bn[3]).
            v-s1 = trim(substring( v-tmp, 001, 80 )).
            v-s2 = trim(substring( v-tmp, 081, 80 )).
        end.
        else do:
            v-m1 = GetNameBenOrd(remtrz.ord).
            v-m2 = GetRnnBenOrd(remtrz.ord).

            def var v-jh3 as int.
            v-jh3 = remtrz.jh3.
            if (remtrz.jh3 <= 0 or remtrz.jh3 = ?) and remtrz.sqn begins "TXB" then  run findjh3(trim(remtrz.sbank), substring(remtrz.ref,11,10), output v-jh3).
            if v-jh3 <= 0 or v-jh3 = ?  then do:
                if v-cif eq '' and (substr(remtrz.racc,4,3) <> "080") and not (remtrz.rcvinfo[1] begins '/PSJ/')  then do.
                    find first depaccnt where lookup(string(depaccnt.acc), v-ls) > 0 no-lock no-error.
                    if not avail depaccnt and lookup(v-ls, s-cust-arp) = 0 and v-ls <> s-toter-arp then do:
                        if v-bin then do:
                            if remtrz.valdt1 ge v-bin_rnn_dt then v-m2 = v-bnkbin.
                            else v-m2 = trim(cmp.addr[2]).
                        end.
                        else v-m2 = trim(cmp.addr[2]).
                    end.
                end.
            end.

            v-s1 = "".
            do i = 1 to 3:
                v-bbbb = ( remtrz.bn[i] ).
                v-s1   = v-s1 + if length(v-bbbb) = 60 then v-bbbb else v-bbbb + " ".
            end.

            v-bbbb = v-s1.

            v-s1 = GetNameBenOrd(v-bbbb).
            v-s2 = GetRnnBenOrd(v-bbbb).
        end.

        v-bm2 = ''.
        if remtrz.ptype eq '6' then v-bm2 = trim(cmp.name) + ' ' + trim(cmp.addr[1]).
        else do.
           do i = 1 to 4:
              v-bbbb = trim( remtrz.ordins[i] ).
              v-bm2 = v-bm2 + if length( v-bbbb ) = 35 then v-bbbb else v-bbbb + ' '.
           end.
        end.
        run stl( v-bm2, 1, 55, ' ', output v-bm1, output i ).
        run stl( v-bm2, i, 55, ' ', output v-bm2, output i ).
        v-bbbb = v-bm1.

        find first txb where txb.visible and txb.bank = remtrz.sbank and txb.city = txb.txb no-lock no-error.
        if available txb then v-kbm = txb.mfo.
        else v-kbm = remtrz.sbank.

        v-km   = trim( if remtrz.sacc <> '' then remtrz.sacc else remtrz.dracc ).
        v-km1  = v-km.
        if index( v-km1, '/' ) <> 0 then do:
           v-km  = entry( 1,v-km, '/' ).
           v-km1 = entry( 2,v-km1,'/' ).
        end.
        else do:
           if index( v-km1,' ' ) <> 0 then do:
              v-km  = entry( 1,v-km, ' ' ).
              v-km1 = entry( 2,v-km1,' ' ).
           end.
           else do:
              if length( v-km1 ) > 20 then do:
                 v-km1 = substr( v-km1,21,20 ).
                 v-km  = substr( v-km,  1,20 ).
              end.
              else v-km1 = ' '.
           end.
        end.

        v-su     = remtrz.payment.
        v-sm     = string( v-su,'>>,>>>,>>>,>>9.99' ).
        v-numurs = trim( substring( remtrz.sqn,19,8 )).
        v-mudate = string( remtrz.valdt1, '99/99/9999' ).
        v-mudate2 = string( remtrz.valdt2, '99/99/9999' ).
        v-numurs = if v-numurs = '' then remtrz.remtrz else v-numurs + ' (' + remtrz.remtrz + ')'.

        find first txb where txb.visible and txb.bank = remtrz.rbank no-lock no-error.
        if available txb then v-kbs = txb.mfo.
                         else v-kbs = remtrz.rbank.

        v-bs2 = ''.
        do i = 1 to 3:
           v-bbbb = trim( remtrz.bb[i] ).
           v-bbbb = if substring( v-bbbb, 1, 1 ) = '/' then substring(
           v-bbbb, 2 ) else v-bbbb.
           v-bs2  = v-bs2 + if length( v-bbbb ) = 60 then v-bbbb else v-bbbb + ' '.
        end.

        run stl( v-bs2, 1, 55, ' ', output v-bs1, output i ).
        run stl( v-bs2, i, 55, ' ', output v-bs2, output i ).

        if substr(remtrz.ba,1,1) = '/' then v-ks = trim(substr(remtrz.ba,2)).
        else v-ks = trim(remtrz.ba).

        v-ks1 = v-ks.
        if index(v-ks1,'/') <> 0 then do:
            v-ks  = substring(v-ks,1,index(v-ks,'/') - 1).
            v-ks1 = substring(v-ks1,index(v-ks1,'/') + 1).
        end.
        else do:
           if index(v-ks1,' ') <> 0 then do:
              v-ks  = substring(v-ks,1,index(v-ks,' ') - 1).
              v-ks1 = substring(v-ks1,index(v-ks1,' ') + 1).
           end.
           else do:
              if length(v-ks1) > 20 then do:
                 v-ks1 = substr(v-ks,21,20).
                 v-ks  = substr(v-ks, 1,20).
              end.
              else v-ks1 = ' '.
           end.
        end.

        run Sm-vrd( input truncate( v-su,0 ), output v-strtmp ).
        if remtrz.tcrc <> 1 then v-strtmp = v-strtmp + ' ' + crc.code + ' ' + string(( v-su - truncate( v-su,0 )) * 100, '99' ) + '.'.
        else v-strtmp = v-strtmp + ' тенге '  + string(( v-su - truncate( v-su,0 )) * 100, '99' ) + ' тиын'.
        v-sumt[1] = ''.
        run stl( v-strtmp, 1, 86, ' ', output v-sumt[1], output i ).
        run stl( v-strtmp, i, 86, ' ', output v-sumt[2], output i ).

        find first budcodes where budcodes.code = int(v-ks1) no-lock no-error.
        if avail budcodes then v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]) + ' ' + budcodes.name.
        else v-detch = trim(remtrz.det[1]) + ' ' + trim(remtrz.det[2]) + ' ' + trim(remtrz.det[3]) + ' ' + trim(remtrz.det[4]).
        find last netbank where netbank.rmz = remtrz.remtrz no-lock no-error.
        if avail netbank then do:
            v-detch = replace(v-detch, "\n", " ").
            v-detch = replace(v-detch, "\r", "").
        end.
        if remtrz.dracc <> "" then do:
            find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
            if avail aaa then do:
                find first cif where cif.cif = aaa.cif no-lock no-error.
                if avail cif then do:
                    find first sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnchfd1" and sub-cod.acc = cif.cif and sub-cod.ccode <> "msc" no-lock no-error.
                    if avail sub-cod then glbuhgalter = sub-cod.rcode.
                end.
            end.
        end.

        put stream v-out unformatted
            "<P>" skip
            "<br clear=all style='page-break-before:always'>" skip
            "</P>" skip.

        {printplat2.i}
    end.
end.

procedure printvouext:
    DEF VAR Doc         as CLASS ConvDocClass.
    def var KOd         as char format "x(2)".
    def var KBe         as char format "x(2)".
    def var KNP         as char format "x(3)".
    def var eknp_bal    as deci.
    def var KOd_        as char format "x(2)".
    def var KBe_        as char format "x(2)".
    def var KNP_        as char format "x(3)".
    def var KOd_1       as char format "x(2)".
    def var KBe_1       as char format "x(2)".
    def var KNP_1       as char format "x(3)".
    def var KOd_2       as char format "x(2)".
    def var KBe_2       as char format "x(2)".
    def var KNP_2       as char format "x(3)".
    def var ln1         as inte init 0.
    def var ln2         as inte init 0.
    def var v-remark1   as char.
    def var v-remark2   as char.
    def var bas_crc     like crc.crc initial 1.
    def var v_doc       as char format "x(10)".
    def var dtreg       as date format "99/99/9999".
    def var refn        as char.
    def var vcode       as char format "x(3)".
    def var vcash       as log.
    def var vdb         as cha format "x(9)" label " ".
    def var vcr         as cha format "x(9)" label " ".
    def var vdes        as cha format "x(32)" label " ". /* chart of account desc */
    def var vname       as cha format "x(30)" label " ". /* name of customer */
    def var vrem        as cha format "x(55)" extent 7 label " ".
    def var vamt        like jl.dam extent 7 label " ".
    def var vext        as cha format "x(40)" label " ".
    def var vtot        like jl.dam label " ".
    def var vcontra     as cha format "x(53)" extent 5 label " ".
    def var vpoint      as int.
    def var inc         as int.
    def var tdes        like gl.des.
    def var tty         as cha format "x(20)".
    def var vconsol     as log.
    def var vcif        as cha format "x(6)" label " ".
    def var vofc        like ofc.ofc label  " ".
    def var vcrc        like crc.code label " ".
    def var xamt        like jl.dam.
    def var xdam        like jl.dam.
    def var xcam        like jl.cam.
    def var xco         as char format "x(2)" label "".
    def var vcha2       as cha format "x(50)".
    def var vcha3       as cha format "x(50)".
    def var vcha1       as cha format "x(65)".
    def var l-prn       as logical init "no" format "да/нет".
    def var ss          as int.
    def var vi          as int.
    def var vv-cif      like cif.cif.
    def var s_payment   as character.
    def var obmenGL2    as integer.
    def var v-cashgl    as integer.
    def var v-remtrz    as char.
    def var v-kod       as char.
    def var v-prtorder  as logi init "no" format "да/нет".
    def var v-lotmp     as logi format "да/нет" init no.
    def var v-docno     as char.
    def var v-crcrate1  as decimal format ">>>>>9.9999".
    def var v-tmpstr    as char init "".
    def var v-tmp       as char init "".
    def var v-point     like point.point.
    def var v-bankbin   as char.

    def buffer d_crc for crc.
    def buffer c_crc for crc.
    def buffer bjl   for jl.

    s-jh = inte(b-deals.trxtrn) no-error.

    find jh where jh.jh eq s-jh no-lock.
    find crc where crc.crc eq 1 no-lock.
    vcode = crc.code.
    find sysc where sysc.sysc = "904kas" no-lock.
    if avail sysc then obmenGL2 = sysc.inval.
    else obmenGL2 = 100200.
    find sysc where sysc.sysc = "CASHGL" no-lock.
    v-cashgl = sysc.inval.
    find ofc where ofc.ofc = jh.who no-lock no-error.
    v-point = ofc.regno / 1000 - 0.5.
    find point where point.point = v-point no-lock no-error.

    empty temp-table ljl.
    for each jl of jh no-lock:
        if jl.ln = 1 then v-remtrz = substr(jl.rem[1],1,10).
        create ljl.
        buffer-copy jl to ljl.
        dtreg = jl.jdt.
    end.

    if jh.sub eq "jou" then do:
        v_doc = jh.ref.
        find first joudoc where joudoc.docnum = v_doc no-lock.
        if avail joudoc then do:
            dtreg = joudoc.whn.
            refn  = joudoc.num.
            v-remark1 = joudoc.remark[1].
            find first tarif2 where tarif2.num + tarif2.kod = joudoc.comcode no-lock no-error.
            if avail tarif2 then v-remark2 = tarif2.pakalp.
            else v-remark2 = "".
        end.
        find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
        if available aaa then do:
            find cif of aaa no-lock.
            vv-cif = cif.cif.
        end.
        else vv-cif = "".
    end.
    if jh.sub eq "rmz" then do:
        v_doc = jh.ref.
        find remtrz where remtrz.remtrz eq v_doc no-lock.
        dtreg = remtrz.rdt.
        refn = substring (remtrz.sqn, 19).
        find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
        if available aaa then do:
            find cif of aaa no-lock.
            vv-cif = cif.cif.
        end.
        else vv-cif = "".
    end.

    Doc = NEW ConvDocClass(0,Base).

    find sysc where sysc.sysc = "bnkbin" no-lock no-error.
    if v-bin then do:
        if dtreg ge v-bin_rnn_dt then v-bankbin = trim(sysc.chval).
        else v-bankbin = trim(cmp.addr[2]).
    end.
    else v-bankbin = trim(cmp.addr[2]).

    put stream v-out unformatted
        "<P>" skip
        "<br clear=all style='page-break-before:always'>" skip
        "</P>" skip.

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream v-out unformatted
        "<TR><TD align=center><FONT size=3>ОПЕРАЦИОННЫЙ ОРДЕР</FONT></TD></TR>" skip
        "<TR><TD height=""30""></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" cmp.name + "  " + string(dtreg,"99/99/9999") + "  " + string(jh.tim,"HH:MM") "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>Рег.Nr.  " v-bankbin + "," + cmp.addr[3] "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" point.name "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" point.addr[1] "</FONT></TD></TR>" skip
        "<TR><TD align=left><FONT size=2>" string(jh.jh) "/" + v_doc + "/" + vv-cif + "/" + "Dok.Nr." + trim(refn) + "   /" +
        ofc.name "</FONT></TD></TR>" skip
        "<TR><TD>=============================================================================</TD></TR>" skip.
    put stream v-out unformatted
        "</TABLE>" skip.

    vcash = false.
    xdam = 0. xcam = 0.

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

    empty temp-table wf.
    for each ljl of jh use-index jhln no-lock break by ljl.crc by ljl.ln:
        find crc where crc.crc eq ljl.crc no-lock.
        find gl of ljl no-lock.

        eknp_bal = eknp_bal + ljl.dam - ljl.cam.
        run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).

        if (ljl.gl = v-cashgl) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or ((ljl.gl = obmenGL2) and can-find (sub-cod where sub-cod.sub = "arp" and
        sub-cod.acc = ljl.acc and sub-cod.d-cod = "arptype" and sub-cod.ccode = "obmen1002" no-lock)) then vcash = true.

        if ljl.dam ne 0 then do:
            xamt = ljl.dam.
            xdam = xdam + ljl.dam.
            xco  = "DR".
        end.
        else do:
            xamt = ljl.cam.
            xcam = xcam + ljl.cam.
            xco = "CR".
        end.
        put stream v-out unformatted
            "<TR align=left><FONT size=2>" skip
            "<TD>" string(ljl.ln) "</TD>" skip
            "<TD>" string(ljl.gl) "</TD>" skip
            "<TD>" string(gl.sname) "</TD>" skip
            "<TD>" ljl.acc "</TD>" skip
            "<TD>" crc.code "</TD>" skip
            "<TD>" string(xamt,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
            "<TD>" xco "</TD>" skip
            "</FONT></TR>" skip.

        if eknp_bal = 0 then do:
            if KOd + KBe + KNP <> "" then do:
                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=7>КОд " KOd + "    КБе " + KBe + "    КНП " + KNP "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            KOd = "". KBe = "". KNP = "".
        end.

        if g-fname = "OUTRMZ" then do:
            if ljl.ln = 1 then do:
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then do:
                    v-kod = "".
                    v-kod = "КОД: " + substr(sub-cod.rcode,1,2) + " КБе: " + substr(sub-cod.rcode,4,2) + " КНП: " + substr(sub-cod.rcode,7,3).
                end.
            end.
            if ljl.ln = 2 then do:
                put stream v-out unformatted
                    "<TR align=center><FONT size=2>" skip
                    "<TD colspan=6>" v-kod "</TD>" skip
                    "<TD></TD>" skip
                    "</FONT></TR>" skip.
            end.
            if ljl.ln = 3 then do:
                if ljl.acc <> "" then do:
                    find first aaa where aaa.aaa = ljl.acc no-lock no-error.
                    if avail aaa then do:
                        v-kod = "".
                        find first cif where cif.cif = aaa.cif no-lock no-error.
                        if avail cif and cif.geo = "021" then v-kod = "1".
                        if avail cif and cif.geo <> "021" then v-kod = "2".
                        find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                        if avail sub-cod then v-kod = v-kod + sub-cod.ccode.
                    end.
                end.
                else do:
                    v-kod = "".
                    find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                    if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
                end.
            end.
            if ljl.ln = 4 then do:
                put stream v-out unformatted
                    "<TR align=center><FONT size=2>" skip
                    "<TD colspan=6>КОД: " + v-kod + " КБе: 14" + " КНП: 840</TD>" skip
                    "<TD></TD>" skip
                    "</FONT></TR>" skip.
            end.
        end.
        if last-of(ljl.crc) then do:
           put stream v-out unformatted
                "<TR align=rigth><FONT size=2>" skip
                "<TD colspan=5>" vcha2 "</TD>" skip
                "<TD>" string(xdam,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" crc.code "</TD>" skip
                "</FONT></TR>" skip
                "<TR align=rigth><FONT size=2>" skip
                "<TD colspan=5>" vcha3 "</TD>" skip
                "<TD>" string(xcam,"->>>,>>>,>>>,>>>,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" crc.code "</TD>" skip
                "</FONT></TR>" skip.

           xcam = 0. xdam = 0.
           KOd = "". KBe = "". KNP = "".
        end.

        if ljl.subled eq "arp" then do:
            find first wf where wf.wsub eq "arp" and wf.wacc eq ljl.acc no-error.
            if not available wf then do:
                create wf.
                wf.wsub = "arp".
                wf.wacc = ljl.acc.
                wf.wcrc = ljl.crc.
            end.
        end.
        else if ljl.subled eq "cif" then do:
            find first wf where wf.wsub eq "cif" and wf.wacc eq ljl.acc no-error.
            if not available wf then do:
                find aaa where aaa.aaa eq ljl.acc no-lock.
                create wf.
                wf.wsub = "cif".
                wf.wacc = ljl.acc.
                wf.wcif = aaa.cif.
                wf.wcrc = ljl.crc.
            end.
        end.
    end.

    put stream v-out unformatted
        "</TABLE>" skip.

    define variable conve as logical.

    conve = false.
    for each ljl of jh no-lock:
        if isConvGL(ljl.gl) then do:
           conve = true.
           leave.
        end.
    end.

    if conve and jh.sub eq "jou" then do:
        find joudoc where joudoc.docnum eq v_doc no-lock.
        find d_crc where d_crc.crc eq joudoc.drcur no-lock.
        find c_crc where c_crc.crc eq joudoc.crcur no-lock.

        if bas_crc ne d_crc.crc then do:
            put stream v-out unformatted
                "<P align=left><FONT size=2>" d_crc.des + " - курс покупки " + string (joudoc.brate,">>>,999.9999") + " " + vcode + "/ " + trim(string(joudoc.bn,"zzzzzzz")) + " " +
                d_crc.code "</FONT></P>" skip.
        end.
        if bas_crc ne c_crc.crc then do:
            put stream v-out unformatted
                "<P align=left><FONT size=2>" d_crc.des + " - курс продажи " + string (joudoc.srate,">>>,999.9999") + " " + vcode + "/ " + trim(string(joudoc.sn,"zzzzzzz")) + " " +
                c_crc.code "</FONT></P>" skip.
        end.
    end.

    empty temp-table remfile.
    for each ljl of jh where ljl.ln = 1 use-index jhln no-lock break by ljl.crc by ljl.ln:
        if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne "" then do vi = 1 to 5 :
            if vi = 1 then do:
                ss = 1.
                repeat:
                    if (trim(substring(ljl.rem[vi],ss,70)) ne "" ) then do:
                        find joudoc where joudoc.docnum eq v_doc no-lock no-error.
                        if avail joudoc then do:
                            if (joudoc.dracctype = "1" and joudoc.cracctype = "5") or (joudoc.dracctype = "2" and joudoc.cracctype = "5") then do:
                                create remfile.
                                remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                            end.
                            else do:
                                create remfile.
                                remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                            end.
                        end.
                        if not avail joudoc then do:
                            create remfile.
                            remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,70)).
                        end.
                    end.
                    else leave.
                    ss = ss + 70.
                end.

                for each wf:
                    find crc where crc.crc = wf.wcrc no-lock no-error.
                    assign v-tmpstr = "".
                    if Doc:FindDocJH(string(jh.jh)) then do:
                        assign v-tmpstr = crc.code.
                    end.
                    if wf.wsub eq "cif" then do:
                        find cif where cif.cif eq wf.wcif no-lock.
                        create remfile.
                        if v-bin then do:
                            if dtreg ge v-bin_rnn_dt then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin + " " + v-tmpstr.
                            else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + v-tmpstr.
                        end.
                        else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss + " " + v-tmpstr.
                    end.
                    else if wf.wsub eq "arp" then do:
                        find arp where arp.arp eq wf.wacc no-lock.
                        find sub-cod where sub-cod.d-cod eq "arprnn" and
                        sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                        if available sub-cod then do:
                            create remfile.
                            remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode + " " + v-tmpstr.
                        end.
                        else do:
                            create remfile.
                            remfile.rem = "     " + wf.wacc + " " + arp.des + " " + v-tmpstr.
                        end.
                    end.
                end.
            end.
            else if (trim(ljl.rem[vi]) ne "" ) then do:
                def var v-spaces as char init "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".
                create remfile.
                remfile.rem = v-spaces + trim(ljl.rem[vi]).
            end.
        end.
        else do:
            gonext:
            for each wf:
                if wf.wsub eq "cif" then do:
                    find cif where cif.cif eq wf.wcif no-lock.
                    create remfile.
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
                        else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
                    end.
                    else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
                end.
                else if wf.wsub eq "arp" then do:
                    if trim(wf.wacc) = "KZ56470142870A010816" then next gonext.
                    find arp where arp.arp eq wf.wacc no-lock.
                    find sub-cod where sub-cod.d-cod eq "arprnn" and sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
                    if available sub-cod then do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
                    end.
                    else do:
                        create remfile.
                        remfile.rem = "     " + wf.wacc + " " + arp.des.
                    end.
                end.
            end.
        end.
    end.

    find first ofc where ofc.ofc = g-ofc no-lock no-error.

    put stream v-out unformatted
        "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
        "<TR><TD>----------------------------------------------------------------------------------------------------------------------------------</TD></TR>" skip.
    for each remfile:
        put stream v-out unformatted
            "<TR><TD align=left><FONT size=2>" remfile.rem "</FONT></TD></TR>" skip.
    end.

    put stream v-out unformatted
        "</TABLE>" skip.

    /*Если документ создан 2.3.1, 2.3.2, 2.3.3, 2.3.4, 2.3.5 и т.д.*/
    if Doc:FindDocJH(string(jh.jh)) then do:
        find crc where crc.crc = Doc:crc no-lock no-error.
        if Doc:DocType >= 1 and Doc:DocType <= 4 then assign v-tmp = crc.code.
        if Doc:DocType = 5 or Doc:DocType = 6 then assign v-tmp = Doc:CRCC:get-code(Doc:tclientaccno) + "-" + Doc:CRCC:get-code(Doc:vclientaccno).

        put stream v-out unformatted
        "<P align=left><FONT size=2>Курс " + v-tmp + ":" string(Doc:rate,">>>,>>9.9999") "</FONT></P>" skip
        "<P align=left><FONT size=2>Менеджер ................ Контролер ................</FONT></P>" skip.
    end.

    if VALID-OBJECT(Doc)  then DELETE OBJECT Doc NO-ERROR.
end procedure.



