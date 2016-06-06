/* a_cas3printapp.i
 * MODULE
        Название модуля - 15 Клиентские операции
 * DESCRIPTION
        Описание - 3. Внутренние переводы (В национальной валюте)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 15.1.1
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        05.05.2012 damir.
        05.06.2012 damir - корректировка в substr.
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.
        02.01.2013 damir - Переход на ИИН/БИН.
*/
v-inputfile = "/data/export/statement5.htm".

find cif where cif.cif = aaa.cif no-lock no-error.
find ofc where ofc.ofc = g-ofc no-lock no-error.

if avail joudoc then do:
    v-naznplat = trim(joudoc.remark[1]) + " " + trim(joudoc.remark[2]) + " " + trim(joudoc.rescha[3]).
end.

if avail cif then do:
    numpassp = substr(trim(cif.pss),1,10).
    whnpassp = substr(trim(cif.pss),11,11).
    whopassp = substr(trim(cif.pss),22,length(cif.pss)).
    perpassp = string(cif.dtsrokul,"99/99/9999").
end.

output stream v-out to value(v-file).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*platnum*" then do:
            if v-ref <> "" then v-str = replace (v-str,"platnum",trim(v-ref)).
            else v-str = replace (v-str,"platnum","").
            next.
        end.
        if v-str matches "*filingdt*" then do:
            v-str = replace (v-str,"filingdt",string(g-today,"99/99/9999")).
            next.
        end.
        if v-str matches "*valuedt*" then do:
            v-str = replace (v-str,"valuedt",string(g-today,"99/99/9999")).
            next.
        end.
        if v-str matches "*sender*" then do:
            if v_name <> "" then do:
                if index(v_name,"/") > 0 then v-str = replace (v-str,"sender",entry(1,trim(v_name),"/")).
                else v-str = replace (v-str,"sender",trim(v_name)).
            end.
            else v-str = replace (v-str,"sender","").
            next.
        end.
        if v-str matches "*telefon*" then do:
            if avail cif then do:
                if trim(cif.tel) + trim(cif.tlx) <> "" then v-str = replace (v-str,"telefon",trim(cif.tel) + ", " + trim(cif.tlx)).
                else v-str = replace (v-str,"telefon","").
            end.
            else v-str = replace (v-str,"telefon","").
            next.
        end.
        if v-str matches "*numudv*" then do:
            if numpassp <> "" then v-str = replace (v-str,"numudv",trim(numpassp)).
            else v-str = replace (v-str,"numudv","").
            next.
        end.
        if v-str matches "*kemvydan*" then do:
            if whopassp <> "" then v-str = replace (v-str,"kemvydan",trim(whopassp)).
            else v-str = replace (v-str,"kemvydan","").
            next.
        end.
        if v-str matches "*rnnsen*" then do:
            if v_rnn <> "" then v-str = replace (v-str,"rnnsen",trim(v_rnn)).
            else v-str = replace (v-str,"rnnsen","").
            next.
        end.
        if v-str matches "*rndt*" then do:
            if whnpassp <> "" and index(whnpassp,"/") > 0 then v-str = replace (v-str,"rndt",trim(entry(1,whnpassp,"/"))).
            else v-str = replace (v-str,"rndt","").
            next.
        end.
        if v-str matches "*rnmt*" then do:
            if whnpassp <> "" and index(whnpassp,"/") > 0 then v-str = replace (v-str,"rnmt",trim(entry(2,whnpassp,"/"))).
            v-str = replace (v-str,"rnmt","").
            next.
        end.
        if v-str matches "*rnyear*" then do:
            if whnpassp <> "" and index(whnpassp,"/") > 0 then v-str = replace (v-str,"rnyear",trim(entry(3,whnpassp,"/"))).
            v-str = replace (v-str,"rnyear","").
            next.
        end.
        if v-str matches "*rval*" then do:
            if perpassp <> "" and index(perpassp,"/") > 0 then v-str = replace (v-str,"rval",trim(entry(1,perpassp,"/"))).
            v-str = replace (v-str,"rval","").
            next.
        end.
        if v-str matches "*rvamt*" then do:
            if perpassp <> "" and index(perpassp,"/") > 0 then v-str = replace (v-str,"rvamt",trim(entry(2,perpassp,"/"))).
            v-str = replace (v-str,"rvamt","").
            next.
        end.
        if v-str matches "*rvayear*" then do:
            if perpassp <> "" and index(perpassp,"/") > 0 then v-str = replace (v-str,"rvayear",trim(entry(3,perpassp,"/"))).
            v-str = replace (v-str,"rvayear","").
            next.
        end.
        if v-str matches "*iiksen*" then do:
            if v-chet <> "" then v-str = replace (v-str,"iiksen",trim(v-chet)).
            else v-str = replace (v-str,"iiksen","").
            next.
        end.
        if v-str matches "*adresssen*" then do:
            if avail cif then do:
                if cif.addr[1] <> "" then v-str = replace (v-str,"adresssen",trim(cif.addr[1])).
                else do:
                    if cif.addr[2] <> "" then v-str = replace (v-str,"adresssen",trim(cif.addr[2])).
                    else v-str = replace (v-str,"adresssen","").
                end.
            end.
            else v-str = replace (v-str,"adresssen","").
            next.
        end.
        if v-str matches "*+A*" then do:
            if v_code <> "" then v-str = replace (v-str,"+A",substr(trim(v_code),1,1)).
            else v-str = replace (v-str,"+A","").
            next.
        end.
        if v-str matches "*+B*" then do:
            if v_code <> "" then v-str = replace (v-str,"+B",substr(trim(v_code),2,1)).
            else v-str = replace (v-str,"+B","").
            next.
        end.
        if v-str matches "*sumcifer*" then do:
            if v_sum <> 0 then v-str = replace (v-str,"sumcifer",string(v_sum,">>>>>>>>>>>>>>>>>>>>>>>>>>>9.99")).
            else v-str = replace (v-str,"sumcifer","").
            next.
        end.
        if v-str matches "*sumpropis*" then do:
            if v_sum <> 0 then do:
                assign decAmount = v_sum.
                temp = string(decAmount).
                if num-entries(temp,".") = 2 then do:
                    temp = substring(temp, length(temp) - 1, 2).
                    if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
                end.
                else temp = "00".
                strTemp = string(truncate(decAmount,0)).
                run Sm-vrd(input decAmount, output strAmount).
                run sm-wrdcrc(input strTemp,input temp,input v-crc,output str1,output str2).
                strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
                if strAmount <> "" then  do:
                    if substr(strAmount,1,54) <> "" then v-str = replace (v-str,"sumpropis1",substr(strAmount,1,54)).
                    else v-str = replace (v-str,"sumpropis1","").
                    if substr(strAmount,55,length(strAmount)) <> "" then v-str = replace (v-str,"sumpropis2",substr(strAmount,55,length(strAmount))).
                    else v-str = replace (v-str,"sumpropis2","").
                end.
                else do:
                    v-str = replace (v-str,"sumpropis1","").
                    v-str = replace (v-str,"sumpropis2","").
                end.
            end.
            else do:
                v-str = replace (v-str,"sumpropis1","").
                v-str = replace (v-str,"sumpropis2","").
            end.
            next.
        end.
        if v-str matches "*crccode*" then do:
            if v-crc <> 0 then do:
                find first crc where crc.crc = v-crc no-lock no-error.
                if avail crc then v-str = replace (v-str,"crccode",trim(crc.code)).
                else v-str = replace (v-str,"crccode","").
            end.
            else v-str = replace (v-str,"crccode","").
            next.
        end.
        if v-str matches "*receibenefic*" then do:
            if v_namep <> "" then v-str = replace (v-str,"receibenefic",trim(v_namep)).
            else v-str = replace (v-str,"receibenefic","").
            next.
        end.
        if v-str matches "*recstrana*" then do:
            v-str = replace (v-str,"recstrana","Казахстан").
            next.
        end.
        if v-str matches "*recadres*" then do:
            v-str = replace (v-str,"recadres","").
            next.
        end.
        if v-str matches "*accpolcseht*" then do:
            if v-chetp <> "" then do:
                if index(v-chetp,"/") > 0 then v-str = replace (v-str,"accpolcseht",replace(v-chetp,"/","")).
                else v-str = replace (v-str,"accpolcseht",trim(v-chetp)).
            end.
            else v-str = replace (v-str,"accpolcseht","").
            next.
        end.
        if v-str matches "*rnnpol*" then do:
            if v_rnnp <> "" then v-str = replace (v-str,"rnnpol",trim(v_rnnp)).
            else v-str = replace (v-str,"rnnpol","").
            next.
        end.
        if v-str matches "*+C*" then do:
            if v_kbe <> "" then v-str = replace (v-str,"+C",substr(trim(v_kbe),1,1)).
            else v-str = replace (v-str,"+C","").
            next.
        end.
        if v-str matches "*+D*" then do:
            if v_kbe <> "" then v-str = replace (v-str,"+D",substr(trim(v_kbe),2,1)).
            else v-str = replace (v-str,"+D","").
            next.
        end.
        if v-str matches "*bankbenficir*" then do:
            find first aaa where aaa.aaa = trim(v-chetp) no-lock no-error.
            if avail aaa then v-str = replace (v-str,"bankbenficir","АО «ForteBank»").
            else v-str = replace (v-str,"bankbenficir","").
            next.
        end.
        if v-str matches "*bikbenficiry*" then do:
            find first aaa where aaa.aaa = trim(v-chetp) no-lock no-error.
            if avail aaa then v-str = replace (v-str,"bikbenficiry","FOBAKZKA").
            else v-str = replace (v-str,"bikbenficiry","").
            next.
        end.
        if v-str matches "*benefstrana*" then do:
            v-str = replace (v-str,"benefstrana","").
            next.
        end.
        if v-str matches "*celperev1*" then do:
            if substr(v-naznplat,1,30) <> "" then v-str = replace (v-str,"celperev1",trim(substr(v-naznplat,1,30))).
            else v-str = replace (v-str,"celperev1","").
            next.
        end.
        if v-str matches "*celperev2*" then do:
            if substr(v-naznplat,31,53) <> "" then v-str = replace (v-str,"celperev2",trim(substr(v-naznplat,31,53))).
            else v-str = replace (v-str,"celperev2","").
            next.
        end.
        if v-str matches "*celperev3*" then do:
            if substr(v-naznplat,84,53) <> "" then v-str = replace (v-str,"celperev3",trim(substr(v-naznplat,84,53))).
            else v-str = replace (v-str,"celperev3","").
            next.
        end.
        if v-str matches "*celperev4*" then do:
            if substr(v-naznplat,137,53) <> "" then v-str = replace (v-str,"celperev4",trim(substr(v-naznplat,137,53))).
            else v-str = replace (v-str,"celperev4","").
            next.
        end.
        if v-str matches "*vknp*" then do:
            if v_knp <> "" then v-str = replace (v-str,"vknp",trim(v_knp)).
            else v-str = replace (v-str,"vknp","").
            next.
        end.
        if v-str matches "*vkbk*" then do:
            v-str = replace (v-str,"vkbk","").
            next.
        end.
        if v-str matches "*officcername*" then do:
            if avail ofc then v-str = replace (v-str,"officcername",trim(ofc.name)).
            else v-str = replace (v-str,"officcername","").
            next.
        end.
        if v-str matches "*RNNBNN*" then do:
            if v-bin then v-str = replace (v-str,"RNNBNN","ИИН").
            else v-str = replace (v-str,"RNNBNN","РНН").
            next.
        end.
        if v-str matches "*LDHFTD*" then do:
            if v-bin then v-str = replace (v-str,"LDHFTD","ИИН/БИН").
            else v-str = replace (v-str,"LDHFTD","РНН").
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.

output stream v-out close.
unix silent cptwin value(v-file) winword.


