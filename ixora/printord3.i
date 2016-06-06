/* printord3.i
 * MODULE
        Название модуля - Используется во всех модулях.
 * DESCRIPTION
        Описание - Вывод в формате WORD кассовых ордеров в 15 модуле, обменные операции.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - printord2.p.
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
        18.04.2012 damir.
        05.05.2012 damir    - информация о филиале тянется c sysc - <fullnamerus>, убрал v-bankname
        10.05.2012 damir    - уменьшил размер вырезки substr назначения платежа.
        07.05.2012 damir    - вывод номера ЭК в чеке БКС.
        18.06.2012 damir    - вывод ОКПО в чеке БКС.
        22.06.2012 damir    - вывод v-passpnum,v-passpdt,v-passpwho.
        28.06.2012 damir    - перекомпиляция.
        05.07.2012 damir    - отображение CASH в шаблонах по обменным операциям.
        12.07.2012 damir    - убрал v-bankname.
        11.09.2012 damir    - Переход на ИИН/БИН. Реализовано Т.З. <Изменение цветовой гаммы в приходных/расходных ордерах>.
        02.11.2012 damir    - Изменения, связанные с изменением шаблонов по конвертации.isConvGL,v-convGL.
        26.12.2012 damir    - Внедрено Т.З. 1624.
        12.02.2013 damir    - Внедрено Т.З. 1676.
*/
find ofc where ofc.ofc = jh.who no-lock no-error.
find jh where jh.jh eq jhnum no-lock no-error.

procedure CODSOBM:
    ln1 = 0. ln2 = 0. v-gl1 = 0. v-gl2 = 0. v-KOd = "". v-KBe = "". v-KNP = "".
    if wjl.dc = "D" then do:
        ln1 = wjl.ln.
        ln2 = wjl.ln + 1.
    end.
    if ln1 <> 0 and ln2 <> 0 then do:
        v-lnstr = string(ln1) + "," + string(ln2).
        v-dcstr = "D,C".
        do j = 1 to 2:
            KOd = "". KBe = "". KNP = "".
            run GetEKNP(jhnum,inte(entry(j,v-lnstr)),entry(j,v-dcstr),input-output KOd,input-output KBe,input-output KNP).
            if KOd <> "" then v-KOd = KOd.
            if KBe <> "" then v-KBe = KBe.
            if KNP <> "" then v-KNP = KNP.
        end.
    end.
end.

for each wjl of jh use-index jhln where (wjl.gl = 100100 or wjl.gl = 100500) no-lock break by wjl.ln:
    v-ifileobmenop  = "/data/export/inoutcashordobmen.htm".  /*Шаблон - обменные операции*/ /*С БКС*/
    v-ifileobmenop2 = "/data/export/inoutcashordobmen2.htm". /*Шаблон - обменные операции*/ /*БЕЗ БКС*/

    xin = 0. xout = 0. v-KOd = "". v-KBe = "". v-KNP = "". v-crc = "". v-crc2 = "". v-obmenoper = no. v-onacc = "". v-accfrom = "".
    v-crcobmen = "". v-crccod = 0. v-crccod2 = 0. decAmountT = 0. decAmountT2 = 0. strAmountkzt = "". strAmountkzt2 = "". decAmount = 0.
    decAmount2 = 0. v-glcash = no. v-elcash = "". v-convGL = false.

    if wjl.dc eq "D" then do:
        xin = wjl.dam.
        v-onacc = string(wjl.gl).
        find first crc where crc.crc = wjl.crc no-lock no-error.
        if avail crc then do:
            v-crc = crc.code.
            v-crccod = crc.crc.
        end.
        find first b-wjl where b-wjl.dc = "C" and b-wjl.ln = wjl.ln + 1 no-lock no-error.
        if avail b-wjl then do:
            v-convGL = isConvGL(b-wjl.gl).
            if v-convGL then do:
                v-obmenoper = yes.
                if b-wjl.crc = 1 then v-strtmp = "ПРОДАЖИ".
                else v-strtmp = "ПОКУПКИ".
                find first b2-wjl where b2-wjl.dc = "C" and b2-wjl.ln = wjl.ln + 3 no-lock no-error.
                if avail b2-wjl then do:
                    xout = b2-wjl.cam.
                    v-accfrom = string(b2-wjl.gl).
                    v-sumobmenoper = b2-wjl.cam.
                    find first crc where crc.crc = b2-wjl.crc no-lock no-error.
                    if avail crc then do:
                        v-crc2 = crc.code.
                        v-crccod2 = crc.crc.
                    end.
                end.
            end.
        end.
        if wjl.crc <> 1 then v-crcobmen = "KZT".
        else v-crcobmen = v-crcobm.

        if wjl.gl = v-cash100500 and wjl.acc <> "" then do:
            find first sub-cod where sub-cod.sub = "arp" and sub-cod.acc = wjl.acc and sub-cod.d-cod = "arptype" and
            sub-cod.ccode <> "msc" no-lock no-error.
            if avail sub-cod then v-elcash = sub-cod.ccode.

            v-glcash = yes.
        end.
    end.

    run CODSOBM.

    run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz). /* День месяц(прописью) год */

    run pkdefdtstr(string(g-today,"99/99/9999"), output v-databks, output v-databkskz). /* День месяц(прописью) год */

/*-------------------------------Вывод суммы прописью---------------------------------------*/

    if wjl.dc eq "D" then do:
        decAmount = xin.
        temp = string(decAmount).
        if num-entries(temp,".") = 2 then do:
            temp = substring(temp, length(temp) - 1, 2).
            if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".
        strTemp = string(truncate(decAmount,0)).
        run Sm-vrd(input decAmount, output strAmount).
        run sm-wrdcrc(input strTemp,input temp,input v-crccod,output str1,output str2).
        strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
        if length(strAmount) > 80 then do:
            str1 = substring(strAmount,1,80).
            str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        end.

        if v-crccod <> 1 then do:
            find first drate where drate.crc = v-crccod no-lock no-error.
            if avail drate then decAmountT = decAmount * drate.rate[1].
            temp = string (decAmountT).
            if num-entries(temp,".") = 2 then do:
                temp = substring(temp, length(temp) - 1, 2).
                if num-entries(temp,".") = 2 then
                temp = substring(temp,2,1) + "0".
            end.
            else temp = "00".
            strTemp = string(truncate(decAmountT,0)).
            run Sm-vrd(input decAmountT, output strAmountkzt).
            run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
            strAmountkzt = "(" + strAmountkzt + " " + str1 + " " + temp + " " + str2 + ")".
            if length(strAmountkzt) > 80 then do:
                str1 = substring(strAmountkzt,1,80).
                str2 = substring(strAmountkzt,81,length(strAmountkzt,"CHARACTER") - 80).
            end.
        end.
    /*-----------------------------------------------------------------------------------------------*/
    /*-------------------------------Вывод суммы прописью---------------------------------------*/
        decAmount2 = xout.
        temp = string(decAmount2).
        if num-entries(temp,".") = 2 then do:
            temp = substring(temp, length(temp) - 1, 2).
            if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
        end.
        else temp = "00".
        strTemp = string(truncate(decAmount2,0)).
        run Sm-vrd(input decAmount2, output strAmount2).
        run sm-wrdcrc(input strTemp,input temp,input v-crccod2,output str1,output str2).
        strAmount2 = strAmount2 + " " + str1 + " " + temp + " " + str2.
        if length(strAmount2) > 80 then do:
            str1 = substring(strAmount2,1,80).
            str2 = substring(strAmount2,81,length(strAmount2,"CHARACTER") - 80).
        end.

        if v-crccod2 <> 1 then do:
            find first drate where drate.crc = v-crccod2 no-lock no-error.
            if avail drate then decAmountT2 = decAmount2 * drate.rate[1].
            temp = string (decAmountT2).
            if num-entries(temp,".") = 2 then do:
                temp = substring(temp, length(temp) - 1, 2).
                if num-entries(temp,".") = 2 then
                temp = substring(temp,2,1) + "0".
            end.
            else temp = "00".
            strTemp = string(truncate(decAmountT2,0)).
            run Sm-vrd(input decAmountT2, output strAmountkzt2).
            run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
            strAmountkzt2 = "(" + strAmountkzt2 + " " + str1 + " " + temp + " " + str2 + ")".
            if length(strAmountkzt2) > 80 then do:
                str1 = substring(strAmountkzt2,1,80).
                str2 = substring(strAmountkzt2,81,length(strAmountkzt2,"CHARACTER") - 80).
            end.
        end.
    /*-----------------------------------------------------------------------------------------------*/
        v-whorecei  = "-".
        v-incas     = "-".
        v-clien     = "-".
        v-outcas    = "-".
        v-passpnum  = "-".
        v-passpdt   = ?.
        v-passpwho  = "-".
        v-iinbin    = "-".

        if wjl.rem[1] <> "" then v-naznplat = wjl.rem[1].
        else if wjl.rem[2] <> "" then v-naznplat = wjl.rem[2].
        else if wjl.rem[3] <> "" then v-naznplat = wjl.rem[3].
        else if wjl.rem[4] <> "" then v-naznplat = wjl.rem[4].
        else if wjl.rem[5] <> "" then v-naznplat = wjl.rem[5].
    end.
    if wjl.dc eq "D" then do:
        if jh.sts = 6 then do:
            output stream v-out to value(v-iofileord3).
            input from value(v-ifileobmenop).
        end.
        else do:
            output stream v-out to value(v-iofileord3).
            input from value(v-ifileobmenop2).
        end.
        output stream v-out2 to value(v-iofileord4).
        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-str matches "*day*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"day",entry(1,v-datastr," ")).
                    else v-str = replace (v-str,"day","").
                    next.
                end.
                if v-str matches "*month*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"month",entry(2,v-datastr," ")).
                    else v-str = replace (v-str,"month","").
                    next.
                end.
                if v-str matches "*year*" then do:
                    if v-datastr <> "" then v-str = replace (v-str,"year",entry(3,v-datastr," ")).
                    else v-str = replace (v-str,"year","").
                    next.
                end.
                if v-str matches "*ofcname*" then do:
                    v-str = replace (v-str,"ofcname",ofc.name).
                    next.
                end.
                if v-str matches "*fullnmbnkobl*" then do:
                    if v-city <> "" then v-str = replace (v-str,"fullnmbnkobl",v-city).
                    else v-str = replace (v-str,"fullnmbnkobl","").
                    next.
                end.
                if v-str matches "*cok*" then do:
                    if v-cokname <> "" then v-str = replace (v-str,"cok",trim(v-cokname)).
                    else v-str = replace (v-str,"cok","").
                    next.
                end.
                if v-str matches "*account*" then do:
                    if v-onacc <> "" then v-str = replace (v-str,"account",v-onacc).
                    else v-str = replace (v-str,"account","").
                    next.
                end.
                if v-str matches "*jheader*" then do:
                    v-str = replace (v-str,"jheader",string(jh.jh)).
                    next.
                end.
                if v-str matches "*joudocnum*" then do:
                    if v_doc <> "" then v-str = replace (v-str,"joudocnum",v_doc).
                    else v-str = replace (v-str,"joudocnum","").
                    next.
                end.
                if v-str matches "*whoreceive*" then do:
                    if v-whorecei <> "" then v-str = replace (v-str,"whoreceive",trim(v-whorecei)).
                    else v-str = replace (v-str,"whoreceive","").
                    next.
                end.
                if v-str matches "*receivefrom*" then do:
                    if v-incas <> "" then v-str = replace (v-str,"receivefrom",v-incas).
                    else v-str = replace (v-str,"receivefrom","").
                    next.
                end.
                if v-str matches "*nmclpoiuwyet*" then do:
                    if v-clien <> "" then v-str = replace (v-str,"nmclpoiuwyet",trim(v-clien)).
                    else v-str = replace (v-str,"nmclpoiuwyet","").
                    next.
                end.
                if v-str matches "*receivewho*" then do:
                    if v-outcas <> "" then v-str = replace (v-str,"receivewho",v-outcas).
                    else v-str = replace (v-str,"receivewho","").
                    next.
                end.
                if v-str matches "*udostoverenie*" then do:
                    if v-passpnum <> "" then v-str = replace (v-str,"udostoverenie",v-passpnum).
                    else v-str = replace (v-str,"udostoverenie","").
                    next.
                end.
                if v-str matches "*udovwhnvydan*" then do:
                    if v-passpdt <> ? then v-str = replace (v-str,"udovwhnvydan",string(v-passpdt,"99/99/9999")).
                    else v-str = replace (v-str,"udovwhnvydan","").
                    next.
                end.
                if v-str matches "*udovkemvydan*" then do:
                    if v-passpwho <> "" then v-str = replace (v-str,"udovkemvydan",v-passpwho).
                    else v-str = replace (v-str,"udovkemvydan","").
                    next.
                end.
                if v-str matches "*iin*" then do:
                    if v-iinbin <> "" then v-str = replace (v-str,"iin",v-iinbin).
                    else v-str = replace (v-str,"iin", "").
                    next.
                end.

                if v-str matches "*+A*" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+A",substr(trim(v-KOd),1,1)).
                    else v-str = replace (v-str,"+A", "").
                    next.
                end.
                if v-str matches "*+B**" then do:
                    if v-KOd <> "" then v-str = replace (v-str,"+B",substr(trim(v-KOd),2,1)).
                    else v-str = replace (v-str,"+B","").
                    next.
                end.
                if v-str matches "*+C*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+C",substr(trim(v-KBe),1,1)).
                    else v-str = replace (v-str,"+C","").
                    next.
                end.
                if v-str matches "*+D*" then do:
                    if v-KBe <> "" then v-str = replace (v-str,"+D",substr(trim(v-KBe),2,1)).
                    else v-str = replace (v-str,"+D","").
                    next.
                end.
                if v-str matches "*+KNP*" then do:
                    if v-KNP <> "" then v-str = replace (v-str,"+KNP",trim(v-KNP)).
                    else v-str = replace (v-str,"+KNP","").
                    next.
                end.
                if v-str matches "*sumoperation*" then do:
                    if xin <> 0 then v-str = replace (v-str,"sumoperation",string(xin,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sumoperation","").
                    next.
                end.
                if v-str matches "*sumoperpropis*" then do:
                    if strAmount <> "" then v-str = replace (v-str,"sumoperpropis",strAmount).
                    else v-str = replace (v-str,"sumoperpropis","").
                    next.
                end.
                if v-str matches "*ekvivalten*" then do:
                    if strAmountkzt <> "" then v-str = replace (v-str,"ekvivalten",strAmountkzt).
                    else v-str = replace (v-str,"ekvivalten","-").
                    next.
                end.
                if length(trim(v-naznplat)) < 90 then do:
                    if v-str matches "*naznplat*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"naznplat",trim(v-naznplat)).
                        else v-str = replace (v-str,"naznplat","").
                        next.
                    end.
                    if v-str matches "*extension*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"extension"," ").
                        else v-str = replace (v-str,"extension"," ").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*naznplat*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"naznplat",substr(trim(v-naznplat),1,90)).
                        else v-str = replace (v-str,"naznplat","").
                        next.
                    end.
                    if v-str matches "*extension*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"extension",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                        else v-str = replace (v-str,"extension"," ").
                        next.
                    end.
                end.
                if v-str matches "*bksnumber*" then do:
                    if d_bksnmb <> "" then v-str = replace (v-str,"bksnumber",trim(d_bksnmb)).
                    else v-str = replace (v-str,"bksnumber","").
                    next.
                end.
                if v-str matches "*oiwjhrgonlkjdfg*" then do:
                    if v-accfrom <> "" then v-str = replace (v-str,"oiwjhrgonlkjdfg",v-accfrom).
                    else v-str = replace (v-str,"oiwjhrgonlkjdfg","").
                    next.
                end.
                if v-str matches "*crccode*" then do:
                    if v-crc <> "" then v-str = replace (v-str,"crccode",trim(v-crc)).
                    else v-str = replace (v-str,"crccode","").
                    next.
                end.
                if v-str matches "*ksjdhksdg*" then do:
                    if v-crc2 <> "" then v-str = replace (v-str,"ksjdhksdg",trim(v-crc2)).
                    else v-str = replace (v-str,"ksjdhksdg","").
                    next.
                end.
                if v-str matches "*sjldhgslkghlkj*" then do:
                    if xout <> 0 then v-str = replace (v-str,"sjldhgslkghlkj",string(xout,">>>,>>>,>>>,>>>,>>>,>>9.99")).
                    else v-str = replace (v-str,"sjldhgslkghlkj","").
                    next.
                end.
                if v-str matches "*sadjksdghgksdjf*" then do:
                    if strAmount2 <> "" then v-str = replace (v-str,"sadjksdghgksdjf",strAmount2).
                    else v-str = replace (v-str,"sadjksdghgksdjf","").
                    next.
                end.
                if v-str matches "*wseilryowieuhojks*" then do:
                    if strAmountkzt2 <> "" then v-str = replace (v-str,"wseilryowieuhojks",strAmountkzt2).
                    else v-str = replace (v-str,"wseilryowieuhojks","-").
                    next.
                end.
                if length(trim(v-naznplat)) < 90 then do:
                    if v-str matches "*akuwrouhbdlfhnl*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"akuwrouhbdlfhnl",trim(v-naznplat)).
                        else v-str = replace (v-str,"akuwrouhbdlfhnl","").
                        next.
                    end.
                    if v-str matches "*luiyehofbnskldg*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"luiyehofbnskldg"," ").
                        else v-str = replace (v-str,"luiyehofbnskldg"," ").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*akuwrouhbdlfhnl*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"akuwrouhbdlfhnl",substr(trim(v-naznplat),1,90)).
                        else v-str = replace (v-str,"akuwrouhbdlfhnl","").
                        next.
                    end.
                    if v-str matches "*luiyehofbnskldg*" then do:
                        if v-naznplat <> "" then v-str = replace (v-str,"luiyehofbnskldg",trim(substr(trim(v-naznplat),91,length(trim(v-naznplat))))).
                        else v-str = replace (v-str,"luiyehofbnskldg"," ").
                        next.
                    end.
                end.
                if v-str matches "*dtbks*" then do:
                    v-str = replace (v-str,"dtbks",entry(1,v-databks," ")).
                    next.
                end.
                if v-str matches "*mhbks*" then do:
                    v-str = replace (v-str,"mhbks",entry(2,v-databks," ")).
                    next.
                end.
                if v-str matches "*yrbks*" then do:
                    v-str = replace (v-str,"yrbks",entry(3,v-databks," ")).
                    next.
                end.
                if v-str matches "*timebks*" then do:
                    v-str = replace (v-str,"timebks",string(time,"HH:MM:SS")).
                    next.
                end.
                if v-glcash = yes then do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" and v-elcash <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb) + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> Рег.№ ЭК </B> &nbsp;" + v-elcash + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <B style='color:RGB(87,32,17)'> ОКПО </B> &nbsp;" + v-okpo).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*regnumbks*" then do:
                        if s_nknmb <> "" then v-str = replace (v-str,"regnumbks",trim(s_nknmb)).
                        else v-str = replace (v-str,"regnumbks","").
                        next.
                    end.
                end.
                if v-str matches "*binbnk*" then do:
                    if v-bnkbin <> "" then v-str = replace (v-str,"binbnk",trim(v-bnkbin)).
                    else v-str = replace (v-str,"binbnk","").
                    next.
                end.
                if v-str matches "*elcash*" then do:
                    if v-elcash <> "" then v-str = replace (v-str,"elcash",v-elcash).
                    else v-str = replace (v-str,"elcash","").
                    next.
                end.
                if v-str matches "*kassirfioname*" then do:
                    if v-ofcnam <> "" then v-str = replace (v-str,"kassirfioname",v-ofcnam).
                    else v-str = replace (v-str,"kassirfioname","").
                    next.
                end.
                if v-str matches "*prihod*" then do:
                    if xin <> 0 then v-str = replace (v-str,"prihod",string(xin, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crc).
                    else v-str = replace (v-str,"prihod","").
                    next.
                end.
                if v-obmenoper = yes then do:
                    if v-str matches "*rashod*" then do:
                        v-str = replace (v-str,"rashod",string(v-sumobmenoper, ">>>,>>>,>>>,>>>,>>>,>>9.99") + " " + v-crcobmen).
                        next.
                    end.
                end.
                else do:
                    if v-str matches "*rashod*" then do:
                        v-str = replace (v-str,"rashod","").
                        next.
                    end.
                    if v-str matches "*КУРС*" then v-str = replace (v-str,"КУРС","").
                end.
                if v-str matches "*kursbks*" then do:
                    if v-obmenoper = yes then do:
                        if v-curs <> 0 then v-str = replace (v-str,"kursbks",v-strtmp + " " + string(v-curs, ">>>,>>>,>>>,>>>,>>>,>>9.99")).
                        else v-str = replace (v-str,"kursbks","").
                    end.
                    else do:
                        v-str = replace (v-str,"kursbks","").
                    end.
                    next.
                end.
                if v-str matches "*RNBNIN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"RNBNIN","ИИН/БИН").
                        else v-str = replace (v-str,"RNBNIN","РНН").
                    end.
                    else v-str = replace (v-str,"RNBNIN","РНН").
                    next.
                end.
                if v-str matches "*BNNRNN*" then do:
                    if v-bin then do:
                        if dtreg ge v-bin_rnn_dt then v-str = replace (v-str,"BNNRNN","БИН").
                        else v-str = replace (v-str,"BNNRNN","РНН").
                    end.
                    else v-str = replace (v-str,"BNNRNN","РНН").
                    next.
                end.
                leave.
            end.
            put stream v-out unformatted v-str skip.
        end.
        input close.
        output stream v-out close.

        input from value(v-iofileord3).

        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
                if v-doccontrol = yes then do:
                    find first ordsignat where ordsignat.ofc = v-idconfname no-lock no-error.
                    if avail ordsignat and ordsignat.sign = yes then do:
                        if v-str matches "*signcon*" then do:
                            v-str = replace (v-str,"signcon","<img src='c:\\\\tmp\\\\" + v-idconfname + "order.jpg' width = '85'
                            height = '30'").
                            next.
                        end.
                    end.
                    else do:
                        if v-str matches "*signcon*" then do:
                            v-str = replace (v-str,"signcon","").
                            next.
                        end.
                    end.
                end.
                else do:
                    if v-str matches "*signcon*" then do:
                        v-str = replace (v-str,"signcon","").
                        next.
                    end.
                end.
                leave.
            end.
            put stream v-out2 unformatted v-str skip.
        end.
        input close.
        output stream v-out2 close.

        unix silent cptwin value(v-iofileord4) winword.
    end.
end.




