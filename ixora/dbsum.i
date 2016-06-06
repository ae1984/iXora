/* dbsum.i
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Выписка по клиентским счетам.Группирование по суммам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - dewide.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        06.03.2012 damir.
        17.04.2012 damir   - не отображалась проводка, исправлено...
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        27/04/2012 evseev  - повтор
        05.05.2012 damir   - вызов функции replace_bnamebik.
        11.05.2012 damir   - исправил выходила ошибка.
        23.05.2012 damir   - добавил remconv.
        24.05.2012 damir   - выходили ошибки с entry, везде сделал проверки.
        17.09.2012 damir   - Оптимизация кода, тестирование ИИН/БИН, внедрено Т.З. № 1379.
        25.09.2012 damir   - Внедрено Т.З. № 1522.
        09.10.2012 damir   - Небольшая корректировка по изменению 17.09.2012.
        26.12.2012 damir   - Внедрено Т.З. 1624.
        19.01.2012 damir   - Добавлены функции GetNameBenOrd,GetRnnBenOrd.
        28.05.2013 damir   - Внедрено Т.З. № 1541.
        25.11.2013 damir - Внедрено Т.З. № 2219.
*/
for each deals where deals.account = acc_list.aaa and ( deals.servcode = "lt" or deals.servcode = "st" ) and
deals.d_date >= acc_list.d_from and deals.d_date <= acc_list.d_to break by deals.dc:
    if first-of(deals.dc) then do:
        for each b-deals where b-deals.account = acc_list.aaa and ( b-deals.servcode = "lt" or b-deals.servcode = "st" ) and b-deals.d_date >= acc_list.d_from and
        b-deals.d_date <= acc_list.d_to and b-deals.dc = deals.dc break by b-deals.amount:
            /*ПРОВЕРКА*/
            /*if trim(b-deals.dealtrn) begins "RMZ" then*/
            /*if b-deals.dealsdet begins "Счет на оплату" then*/
            /*if s-jh = 299454 then*/
            /*if substr(trim(b-deals.custtrn),index(b-deals.custtrn,"Nr.") + 3,length(b-deals.custtrn)) = "8" then*/
            /*if b-deals.amount = 2057751.36 then*/
            /*if (v-KOd + v-KBe + v-KNP = "") or (bankcontrbik + bankcontrnam = "") then*/
                /*message "1=" b-deals.dealtrn "2=" b-deals.ordins "3=" b-deals.ordcust "4=" b-deals.ordacc "5=" b-deals.benfsr "6=" b-deals.benacc "7=" b-deals.benbank
                "8=" b-deals.dealsdet "9 = " b-deals.bankinfo "10=" b-deals.d_date "11=" b-deals.dc "12=" b-deals.servcode "13=" b-deals.trxcode "14=" b-deals.custtrn
                "15=" b-deals.amount "16=" b-deals.account "17=" b-deals.in_value "18=" b-deals.trxtrn "|" v-KOd v-KBe v-KNP "|" bankcontrbik bankcontrnam view-as
                alert-box.*/
            /*end.*/
            /*if substr(trim(b-deals.custtrn),index(b-deals.custtrn,"Nr.") + 3,length(b-deals.custtrn)) <> "129" then next.*/

            run InitParam.

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
                    sumalldb = sumalldb + b-deals.amount.
                    db = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
                    cr = "0.00".
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
                    sumallcr = sumallcr + b-deals.amount.
                    db = "0.00".
                    cr = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
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

                    db = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
                    cr = "0.00".
                    sumalldb = sumalldb + b-deals.amount.
                end.
                else if b-deals.dc = "C" then do:

                    if v-KOd + v-KBe + v-KNP = "" then run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

                    v-code = "КОд:" + v-KOd.
                    if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".

                    run SearchCt.

                    db = "0.00".
                    cr = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
                    sumallcr = sumallcr + b-deals.amount.
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
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = b-deals.dc and t-jl.acc = b-deals.account no-lock no-error.
                        if avail t-jl then run GetCods(v-storned,s-jh,b-deals.dc,t-jl.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = "C" and t-jl.acc = b-deals.account no-lock no-error.
                        if avail t-jl then run GetCods(v-storned,s-jh,"C",t-jl.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    v-code = "КБе:" + v-KBe.

                    db = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
                    cr = "0.00".
                    sumalldb = sumalldb + b-deals.amount.
                end.
                else if b-deals.dc = "C" then  do:
                    run GetCods(v-storned,s-jh,b-deals.dc,b-deals.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).

                    if b-deals.dealsdet matches "*Погашение отрицательного сальдо*" then v-KNP = "890".
                    if b-deals.dealsdet begins "Перевод остатков" or b-deals.dealsdet begins "Автоматический перевод остатков" then v-KNP = "321".

                    run SearchCt.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = b-deals.dc and t-jl.acc = b-deals.account no-lock no-error.
                        if avail t-jl then run GetCods(v-storned,s-jh,b-deals.dc,t-jl.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    if v-KOd + v-KBe + v-KNP = "" then do:
                        find first t-jl where t-jl.jh = s-jh and t-jl.dc = "D" and t-jl.acc = b-deals.account no-lock no-error.
                        if avail t-jl then run GetCods(v-storned,s-jh,"D",t-jl.amount,b-deals.account,output v-KOd,output v-KBe,output v-KNP).
                    end.

                    v-code = "КОд:" + v-KOd.

                    db = "0.00".
                    cr = string(b-deals.amount,"->>>,>>>,>>>,>>>,>>9.99").
                    sumallcr = sumallcr + b-deals.amount.
                end.
                naznplat = remconv(b-deals.trxtrn,naznplat).
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
                "<TD>" aaa + "<br>" + trim(RazdSpace(namebank,28)) + "<br>".
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
                sumekv = string(b-deals.amount * v-curs,"->>>,>>>,>>>,>>>,>>9.99").
                put stream v-out unformatted
                    "<TD>" replace(sumekv,","," ") "</TD>" skip.

                v-SumEkviv = v-SumEkviv + b-deals.amount * v-curs.
                v-crclog = yes.
            end.
            if naznplat <> "" then put stream v-out unformatted
                "<TD align=left >" RemSpace(ReplMarks(naznplat)) "</TD>" skip.
            else put stream v-out unformatted
                "<TD align=left >" RemSpace(ReplMarks(b-deals.dealsdet)) "</TD>" skip.
            put stream v-out unformatted
                "<TD>" v-KNP "</TD>" skip
                "</TR>" skip.
        end.
    end. /*if first-of*/
end. /*for each deals*/

sumekvItog = string(v-SumEkviv,"->>>,>>>,>>>,>>>,>>9.99").
put stream v-out unformatted
    "<TR align=center style='font-size:11pt;font-family:calibri'>" skip
    "<TD align=left colspan=4><B>Всего оборотов:</B></TD>" skip
    "<TD style='font-size:8pt'>" replace(string(sumalldb,"->>>,>>>,>>>,>>>,>>9.99"),","," ") "</TD>" skip
    "<TD style='font-size:8pt'>" replace(string(sumallcr,"->>>,>>>,>>>,>>>,>>9.99"),","," ") "</TD>" skip.
if v-crclog then put stream v-out unformatted
    "<TD style='font-size:8pt'>" replace(sumekvItog,","," ") "</TD>" skip.
put stream v-out unformatted
    "<TD></TD>" skip
    "<TD></TD>" skip
    "</TR>" skip.



