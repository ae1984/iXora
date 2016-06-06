/* a_tng1printapp.i
 * MODULE
        Название модуля - 15 Клиентские операции
 * DESCRIPTION
        Описание - 1. ПЕРЕВОДЫ В ТЕНГЕ БЕЗ ОТКРЫТИЯ СЧЕТА | 1. ОТПРАВЛЕНИЕ ПЕРЕВОДА | 1. ВНУТРИБАНКОВСКИЙ ПЕРЕВОД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню - 15.1.2
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        05.05.2012 damir.
        07.05.2012 damir - изменил на РНН получателяв назначении платежа, вывод переменной v-cityname.
        08.05.2012 damir - переотправил.
        05.06.2012 damir - корректировка в substr.
        14.08.2012 damir - дополнения согласно С.З. от 13.08.2012.
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.
        02.01.2013 damir - Переход на ИИН/БИН.
*/
v-inputfile = "/data/export/statement5.htm".

find first ofc where ofc.ofc = g-ofc no-lock no-error.
find first cmp no-lock no-error.

if avail joudoc then do:
    v-naznplat = trim(joudoc.remark[1]) + " " + trim(v_lname1) + " " + trim(v_name1) + " " + trim(v_mname1) + " " +
    trim(v_doc_num1) + " " + trim(v_docwho1) + " " + string(v_docdt1,"99/99/9999") + " " + replace(trim(v_label),":","") + " " +
    trim(v_rnnp).
end.

numpassp = trim(v_doc_num).
whnpassp = string(v_docdt,"99/99/9999").
whopassp = trim(v_docwho).
perpassp = string(v_docdtf,"99/99/9999").

output stream v-out to value(v-file).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*platnum*" then do:
            find first sernumdoc where sernumdoc.transfer = v-joudoc no-lock no-error.
            if avail sernumdoc then v-str = replace (v-str,"platnum",string(sernumdoc.numtrans)).
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
            if trim(v_lname) + trim(v_name) + trim(v_mname) <> "" then
            v-str = replace (v-str,"sender",trim(v_lname) + " " + trim(v_name) + " " + trim(v_mname)).
            else v-str = replace (v-str,"sender","").
            next.
        end.
        if v-str matches "*telefon*" then do:
            if v_tel <> "" then v-str = replace (v-str,"telefon",trim(v_tel)).
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
            v-str = replace (v-str,"iiksen","-").
            next.
        end.
        if v-str matches "*adresssen*" then do:
            if v_addr <> "" then v-str = replace (v-str,"adresssen",trim(v_addr)).
            else v-str = replace (v-str,"adresssen","").
            next.
        end.
        if v-str matches "*+A*" then do:
            if v_rez <> "" then v-str = replace (v-str,"+A",substr(trim(v_rez),1,1)).
            else v-str = replace (v-str,"+A","").
            next.
        end.
        if v-str matches "*+B*" then do:
            if v_rez <> "" then v-str = replace (v-str,"+B",substr(trim(v_rez),2,1)).
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
                run sm-wrdcrc(input strTemp,input temp,input v_crc,output str1,output str2).
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
            if v_crc <> 0 then do:
                find first crc where crc.crc = v_crc no-lock no-error.
                if avail crc then v-str = replace (v-str,"crccode",trim(crc.code)).
                else v-str = replace (v-str,"crccode","").
            end.
            else v-str = replace (v-str,"crccode","").
            next.
        end.
        if v-str matches "*receibenefic*" then do:
            if v-citbenef <> "" then v-str = replace (v-str,"receibenefic",trim(v-citbenef)).
            else v-str = replace (v-str,"receibenefic","").
            next.
        end.
        if v-str matches "*recstrana*" then do:
            v-str = replace (v-str,"recstrana","Казахстан").
            next.
        end.
        if v-str matches "*recadres*" then do:
            if v_bank <> "" then v-str = replace (v-str,"recadres",trim(v_bank)).
            else v-str = replace (v-str,"recadres","").
            next.
        end.
        if v-str matches "*accpolcseht*" then do:
            if v_numch <> "" then v-str = replace (v-str,"accpolcseht",trim(v_numch)).
            else v-str = replace (v-str,"accpolcseht","").
            next.
        end.
        if v-str matches "*rnnpol*" then do:
            if v-rnnbenef <> "" then v-str = replace (v-str,"rnnpol",trim(v-rnnbenef)).
            else v-str = replace (v-str,"rnnpol","").
            next.
        end.
        if v-str matches "*+C*" then do:
            if v_rez1 <> "" then v-str = replace (v-str,"+C",substr(trim(v_rez1),1,1)).
            else v-str = replace (v-str,"+C","").
            next.
        end.
        if v-str matches "*+D*" then do:
            if v_rez1 <> "" then v-str = replace (v-str,"+D",substr(trim(v_rez1),2,1)).
            else v-str = replace (v-str,"+D","").
            next.
        end.
        if v-str matches "*bankbenficir*" then do:
            v-str = replace (v-str,"bankbenficir","АО «ForteBank»").
            next.
        end.
        if v-str matches "*bikbenficiry*" then do:
            v-str = replace (v-str,"bikbenficiry","FOBAKZKA").
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


