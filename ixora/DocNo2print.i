/* DocNo2print.i
 * MODULE
        Название модуля - 2 Операции
 * DESCRIPTION
        Описание - 2 Покупка ин.валюты на следующий день
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        05.05.2012 damir.
*/
find ofc where ofc.ofc = g-ofc no-lock no-error.
find cif where trim(cif.cif) = trim(clientno) no-lock no-error.
if avail cif then do:
    assign V-KOD = "".
    V-KOD = substr(cif.geo,3,1).
    find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "secek" and sub-cod.ccode <> "msc"
    no-lock no-error.
    if avail sub-cod then V-KOD = V-KOD + sub-cod.ccode.
end.

output stream v-out to value(v-file).

assign v-inputfile = "/data/export/statement1.htm".

find cif where cif.cif = clientno no-lock no-error.
if avail cif then assign v_rezid = substr(trim(cif.geo),3,1).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*filingdt*" then do:
            v-str = replace (v-str,"filingdt",string(g-today,"99/99/9999")).
            next.
        end.
        if v-str matches "*client*" then do:
            if clientname <> "" then v-str = replace (v-str,"client",trim(clientname)).
            else v-str = replace (v-str,"client","").
            next.
        end.
        if v-str matches "*accfromtransfer*" then do:
            if from_accno <> "" then v-str = replace (v-str,"accfromtransfer",trim(from_accno)).
            else v-str = replace (v-str,"accfromtransfer","").
            next.
        end.
        if v-str matches "*vidvalyutyfromacc*" then do:
            if from_lab0 <> "" then v-str = replace (v-str,"vidvalyutyfromacc",trim(from_lab0)).
            else v-str = replace (v-str,"vidvalyutyfromacc","").
            next.
        end.
        if v-str matches "*vidvalyutytoacc*" then do:
            if to_lab0 <> "" then v-str = replace (v-str,"vidvalyutytoacc",trim(to_lab0)).
            else v-str = replace (v-str,"vidvalyutytoacc","").
            next.
        end.
        if v-str matches "*crccomisaccfrom*" then do:
            find first crc where trim(crc.code) = trim(com_lab0) no-lock no-error.
            if avail crc then do:
                if crc.crc = 1 then v-str = replace (v-str,"crccomisaccfrom","в тенге").
                else v-str = replace (v-str,"crccomisaccfrom","в иностранной валюте").
            end.
            else v-str = replace (v-str,"crccomisaccfrom","").
            next.
        end.
        if v-str matches "*sumaccfromcifer*" then do:
            if conv_summ <> 0 then v-str = replace (v-str,"sumaccfromcifer",string(conv_summ,">>>>>>>>>>>>>>>>>>>>>>>>>>>9.99")).
            else v-str = replace (v-str,"sumaccfromcifer","").
            next.
        end.
        if v-str matches "*xxxsumciferpropaccfrom*" then do:
            if conv_summ <> 0 then do:
                assign decAmount = conv_summ.
                temp = string(decAmount).
                if num-entries(temp,".") = 2 then do:
                    temp = substring(temp, length(temp) - 1, 2).
                    if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
                end.
                else temp = "00".
                assign v_crc = 0.
                find first crc where trim(crc.code) = trim(from_lab) no-lock no-error.
                if avail crc then assign v_crc = crc.crc.
                strTemp = string(truncate(decAmount,0)).
                run Sm-vrd(input decAmount, output strAmount).
                run sm-wrdcrc(input strTemp,input temp,input v_crc,output str1,output str2).
                strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
                if strAmount <> "" then  do:
                    if substr(strAmount,1,60) <> "" then v-str = replace (v-str,"xxxsumciferpropaccfrom1",substr(strAmount,1,60)).
                    else v-str = replace (v-str,"xxxsumciferpropaccfrom1","").
                    if substr(strAmount,61,length(strAmount)) <> "" then v-str = replace (v-str,"xxxsumciferpropaccfrom2",substr(strAmount,61,length(strAmount))).
                    else v-str = replace (v-str,"xxxsumciferpropaccfrom2","").
                end.
                else do:
                    v-str = replace (v-str,"xxxsumciferpropaccfrom1","").
                    v-str = replace (v-str,"xxxsumciferpropaccfrom2","").
                end.
            end.
            else do:
                v-str = replace (v-str,"xxxsumciferpropaccfrom1","").
                v-str = replace (v-str,"xxxsumciferpropaccfrom2","").
            end.
            next.
        end.
        if v-str matches "*sumacctocifer*" then do:
            if result_summ <> 0 then v-str = replace (v-str,"sumacctocifer",string(result_summ,">>>>>>>>>>>>>>>>>>>>>>>>>>>9.99")).
            else v-str = replace (v-str,"sumacctocifer","").
            next.
        end.
        if v-str matches "*xxxsumciferpropaccto*" then do:
            if conv_summ <> 0 then do:
                assign decAmount = result_summ.
                temp = string(decAmount).
                if num-entries(temp,".") = 2 then do:
                    temp = substring(temp, length(temp) - 1, 2).
                    if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
                end.
                else temp = "00".
                assign v_crc = 0.
                find first crc where trim(crc.code) = trim(to_lab) no-lock no-error.
                if avail crc then assign v_crc = crc.crc.
                strTemp = string(truncate(decAmount,0)).
                run Sm-vrd(input decAmount, output strAmount).
                run sm-wrdcrc(input strTemp,input temp,input v_crc,output str1,output str2).
                strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
                if strAmount <> "" then  do:
                    if substr(strAmount,1,60) <> "" then v-str = replace (v-str,"xxxsumciferpropaccto1",substr(strAmount,1,60)).
                    else v-str = replace (v-str,"xxxsumciferpropaccto1","").
                    if substr(strAmount,61,length(strAmount)) <> "" then v-str = replace (v-str,"xxxsumciferpropaccto2",substr(strAmount,61,length(strAmount))).
                    else v-str = replace (v-str,"xxxsumciferpropaccto2","").
                end.
                else do:
                    v-str = replace (v-str,"xxxsumciferpropaccto1","").
                    v-str = replace (v-str,"xxxsumciferpropaccto2","").
                end.
            end.
            else do:
                v-str = replace (v-str,"xxxsumciferpropaccto1","").
                v-str = replace (v-str,"xxxsumciferpropaccto2","").
            end.
            next.
        end.
        if v-str matches "*kurscel*" then do:
            if currate <> 0 then
            v-str = replace (v-str,"kurscel",entry(1,string(currate,">>>>>>>9.99"),".")).
            else v-str = replace (v-str,"kurscel","").
            next.
        end.
        if v-str matches "*kursnecel*" then do:
            if currate <> 0 then
            v-str = replace (v-str,"kursnecel",entry(2,string(currate,">>>>>>>9.99"),".")).
            else v-str = replace (v-str,"kursnecel","").
            next.
        end.
        if v-str matches "*acctotransfer*" then do:
            if to_accno <> "" then v-str = replace (v-str,"acctotransfer",trim(to_accno)).
            else v-str = replace (v-str,"acctotransfer","").
            next.
        end.
        if v-str matches "*acccomission*" then do:
            if com_accno <> "" then v-str = replace (v-str,"acccomission",trim(com_accno)).
            else v-str = replace (v-str,"acccomission","").
            next.
        end.
        if v-str matches "*+A*" then do:
            if v_rezid <> "" then v-str = replace (v-str,"+A",trim(v_rezid)).
            else v-str = replace (v-str,"+A","").
            next.
        end.
        if v-str matches "*+B*" then do:
            v-str = replace (v-str,"+B","9").
            next.
        end.
        if v-str matches "*+C*" then do:
            if v_rezid <> "" then v-str = replace (v-str,"+C",trim(v_rezid)).
            else v-str = replace (v-str,"+C","").
            next.
        end.
        if v-str matches "*+D*" then do:
            v-str = replace (v-str,"+D","9").
            next.
        end.
        if v-str matches "*vknp*" then do:
            v-str = replace (v-str,"vknp","213").
            next.
        end.
        if v-str matches "*officcername*" then do:
            if avail ofc then v-str = replace (v-str,"officcername",trim(ofc.name)).
            else v-str = replace (v-str,"officcername","").
            next.
        end.
        if v-str matches "*konvertwhenday*" then do:
            if dType = 1 or dType = 3 or dType = 6 then v-str = replace (v-str,"konvertwhenday","день в день").
            else v-str = replace (v-str,"konvertwhenday","на следующий день").
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.

output stream v-out close.
unix silent cptwin value(v-file) winword.




