/* a_us2printapp.i
 * MODULE
        Название модуля - 15 Клиентские операции
 * DESCRIPTION
        Описание - 2. Переводы со счета клиента в ин.валюте
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
        08.05.2012 damir - изменения переменная v_tar (код тарифов).
        05.06.2012 damir - корректировка в substr.
        24.12.2012 damir - Внедрено Т.З. № 1619.Тестирование ИИН/БИН.
*/
v-inputfile = "/data/export/statement6.htm".

if avail remtrz then do:
    v-naznplat = trim(remtrz.detpay[1]).
end.

find cif where cif.cif = aaa.cif no-lock no-error.
find codfr where codfr.codfr = "iso3166" and codfr.child = false and codfr.code <> "msc" and codfr.code = v_countr1 no-lock no-error.
find ofc where ofc.ofc = g-ofc no-lock no-error.

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
            v-str = replace (v-str,"valuedt",string(v-dat2,"99/99/9999")).
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
            if v-bin5 <> "" then v-str = replace (v-str,"rnnsen",trim(v-bin5)).
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
            if v-pnp <> "" then v-str = replace (v-str,"iiksen",trim(v-pnp)).
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
                run sm-wrdcrc(input strTemp,input temp,input v_crc,output str1,output str2).
                strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
                if strAmount <> "" then  do:
                    if substr(strAmount,1,51) <> "" then v-str = replace (v-str,"sumpropis1",substr(strAmount,1,51)).
                    else v-str = replace (v-str,"sumpropis1","").
                    if substr(strAmount,52,length(strAmount)) <> "" then v-str = replace (v-str,"sumpropis2",substr(strAmount,52,length(strAmount))).
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
        if v-str matches "*vidvalyutyfromacc*" then do:
            if v_crc <> 0 then do:
                find first crc where crc.crc = v_crc no-lock no-error.
                if avail crc then v-str = replace (v-str,"vidvalyutyfromacc",trim(crc.code)).
                else v-str = replace (v-str,"vidvalyutyfromacc","").
            end.
            else v-str = replace (v-str,"vidvalyutyfromacc","").
            next.
        end.
        if v-str matches "*receibenefic*" then do:
            if v_namepol <> "" then v-str = replace (v-str,"receibenefic",trim(v_namepol)).
            else v-str = replace (v-str,"receibenefic","").
            next.
        end.
        if v-str matches "*recstrana*" then do:
            if avail codfr then v-str = replace (v-str,"recstrana",trim(codfr.name[1])).
            else v-str = replace (v-str,"recstrana","").
            next.
        end.
        if v-str matches "*recadres*" then do:
            v-str = replace (v-str,"recadres","").
            next.
        end.
        if v-str matches "*accpolcseht*" then do:
            if v_chpol <> "" then do:
                if index(v_chpol,"/") > 0 then do:
                    v-str = replace (v-str,"accpolcseht",replace(v_chpol,"/","")).
                end.
                else v-str = replace (v-str,"accpolcseht",trim(v_chpol)).
            end.
            else v-str = replace (v-str,"accpolcseht","").
            next.
        end.
        if v-str matches "*rnnpol*" then do:
            if v_innpol <> "" then v-str = replace (v-str,"rnnpol",trim(v_innpol)).
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
            if trim(v_bank1) + trim(v_bank2) <> "" then v-str = replace (v-str,"bankbenficir",trim(v_bank1) + " " + trim(v_bank2)).
            else v-str = replace (v-str,"bankbenficir","").
            next.
        end.
        if v-str matches "*bikbenficiry*" then do:
            if v_swbic1 <> "" then v-str = replace (v-str,"bikbenficiry",trim(v_swbic1)).
            else v-str = replace (v-str,"bikbenficiry","").
            next.
        end.
        if v-str matches "*benefstrana*" then do:
            if avail codfr then v-str = replace (v-str,"benefstrana",trim(codfr.name[1])).
            else v-str = replace (v-str,"benefstrana","").
            next.
        end.
        if v-str matches "*accnumbe*" then do:
            if v_bank <> "" then v-str = replace (v-str,"accnumbe",trim(v_numch1)).
            else v-str = replace (v-str,"accnumbe","").
            next.
        end.
        if v-str matches "*bankkorr*" then do:
            if v_bank <> "" then v-str = replace (v-str,"bankkorr",trim(v_bank)).
            else v-str = replace (v-str,"bankkorr","").
            next.
        end.
        if v-str matches "*iiknizhekomis*" then do:
            if v-chetk <> "" then v-str = replace (v-str,"iiknizhekomis",trim(v-chetk)).
            else v-str = replace (v-str,"iiknizhekomis","").
            next.
        end.
        if v-str matches "*bankorrbik*" then do:
            if v_swbic <> "" then v-str = replace (v-str,"bankorrbik",trim(v_swbic)).
            else v-str = replace (v-str,"bankorrbik","").
            next.
        end.
        if v-str matches "*celperev1*" then do:
            if substr(v-naznplat,1,42) <> "" then v-str = replace (v-str,"celperev1",trim(substr(v-naznplat,1,42))).
            else v-str = replace (v-str,"celperev1","").
            next.
        end.
        if v-str matches "*celperev2*" then do:
            if substr(v-naznplat,43,60) <> "" then v-str = replace (v-str,"celperev2",trim(substr(v-naznplat,43,60))).
            else v-str = replace (v-str,"celperev2","").
            next.
        end.
        if v-str matches "*celperev3*" then do:
            if substr(v-naznplat,103,60) <> "" then v-str = replace (v-str,"celperev3",trim(substr(v-naznplat,103,60))).
            else v-str = replace (v-str,"celperev3","").
            next.
        end.
        if v-str matches "*celperev4*" then do:
            if substr(v-naznplat,163,33) <> "" then v-str = replace (v-str,"celperev4",trim(substr(v-naznplat,163,33))).
            else v-str = replace (v-str,"celperev4","").
            next.
        end.
        if v-str matches "*vknp*" then do:
            if v_knp <> "" then v-str = replace (v-str,"vknp",trim(v_knp)).
            else v-str = replace (v-str,"vknp","").
            next.
        end.
        if v-str matches "*osobyeusloviya1*" then do:
            v-str = replace (v-str,"osobyeusloviya1","").
            next.
        end.
        if v-str matches "*osobyeusloviya2*" then do:
            v-str = replace (v-str,"osobyeusloviya2","").
            next.
        end.
        if v-str matches "*officcername*" then do:
            if avail ofc then v-str = replace (v-str,"officcername",trim(ofc.name)).
            else v-str = replace (v-str,"officcername","").
            next.
        end.
        if v-str matches "*fiorukovoditel*" then do:
            v-str = replace (v-str,"fiorukovoditel","").
            next.
        end.
        if v-str matches "*fioglbuhgalter*" then do:
            v-str = replace (v-str,"fioglbuhgalter","").
            next.
        end.
        if v-str matches "*sdgsdfkgjkjbsdkjbhs*" then do:
            if (v_tar = 204 or v_tar = 208 or v_tar = 305) then v-str = replace (v-str,"sdgsdfkgjkjbsdkjbhs","получателя").
            else if (v_tar = 205 or v_tar = 209 or v_tar = 306 or v_tar = 217 or v_tar = 218) then v-str = replace (v-str,"sdgsdfkgjkjbsdkjbhs","отправителя").
            else if (v_tar = 304) then v-str = replace (v-str,"sdgsdfkgjkjbsdkjbhs","получателя/отправителя").
            else v-str = replace (v-str,"sdgsdfkgjkjbsdkjbhs","").
            next.
        end.
        if v-str matches "*RNNBNN*" then do:
            if v-bin then v-str = replace (v-str,"RNNBNN","БИН/ИИН").
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






