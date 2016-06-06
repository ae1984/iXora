/* a_foreign2printapp.i
 * MODULE
        Название модуля - 15 Клиентские операции
 * DESCRIPTION
        Описание - 2. ПЕРЕВОДЫ В ИН ВАЛЮТЕ БЕЗ ОТКРЫТИЯ СЧЕТА | 2. ПОЛУЧЕНИЕ ПЕРЕВОДА
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
        05.06.2012 damir - корректировка в substr.
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.
*/
v-inputfile = "/data/export/statement3.htm".

find ofc where ofc.ofc = g-ofc no-lock no-error.

if avail joudoc then do:
    v-naznplat = trim(joudoc.remark[1]).
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
        if v-str matches "*filingdt*" then do:
            v-str = replace (v-str,"filingdt",string(g-today,"99/99/9999")).
            next.
        end.
        if v-str matches "*poluchateldeneg*" then do:
            if trim(v_lname) + trim(v_name) + trim(v_mname) <> "" then
            v-str = replace (v-str,"poluchateldeneg",trim(v_lname) + " " + trim(v_name) + " " + trim(v_mname)).
            else v-str = replace (v-str,"poluchateldeneg","").
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
        if v-str matches "*rnnpolcuh*" then do:
            if v_rnn <> "" then v-str = replace (v-str,"rnnpolcuh",trim(v_rnn)).
            else v-str = replace (v-str,"rnnpolcuh","").
            next.
        end.
        if v-str matches "*kjhsd*" then do:
            find first crc where crc.crc = v_crc no-lock no-error.
            if avail crc then v-str = replace (v-str,"kjhsd",trim(crc.code)).
            else v-str = replace (v-str,"kjhsd","").
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
        if v-str matches "*adresssenpoluchet*" then do:
            if v_addr <> "" then v-str = replace (v-str,"adresssenpoluchet",trim(v_addr)).
            else v-str = replace (v-str,"adresssenpoluchet","").
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
                if strAmount <> "" then v-str = replace (v-str,"sumpropis",trim(strAmount)).
                else v-str = replace (v-str,"sumpropis","").
            end.
            else v-str = replace (v-str,"sumpropis","").
            next.
        end.
        if v-str matches "*sender*" then do:
            if trim(v_lname1) + trim(v_name1) + trim(v_mname1) <> "" then
            v-str = replace (v-str,"sender",trim(v_lname1) + " " + trim(v_name1) + " " + trim(v_mname1)).
            else v-str = replace (v-str,"sender","").
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
        if v-str matches "*celperev1*" then do:
            if trim(substr(v-naznplat,1,38)) <> "" then v-str = replace (v-str,"celperev1",trim(substr(v-naznplat,1,38))).
            else v-str = replace (v-str,"celperev1","").
            next.
        end.
        if v-str matches "*celperev2*" then do:
            if trim(substr(v-naznplat,39,56)) <> "" then v-str = replace (v-str,"celperev2",trim(substr(v-naznplat,39,56))).
            else v-str = replace (v-str,"celperev2","").
            next.
        end.
        if v-str matches "*celperev3*" then do:
            if trim(substr(v-naznplat,95,56)) <> "" then v-str = replace (v-str,"celperev3",trim(substr(v-naznplat,95,56))).
            else v-str = replace (v-str,"celperev3","").
            next.
        end.
        if v-str matches "*vknp*" then do:
            if v_knp <> "" then v-str = replace (v-str,"vknp",trim(v_knp)).
            else v-str = replace (v-str,"vknp","").
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
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.

output stream v-out close.
unix silent cptwin value(v-file) winword.



