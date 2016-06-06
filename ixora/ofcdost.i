/* ofcdost.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2011 damir
 * BASES
        BANK COMM TXB
 * CHANGES
*/

for each txb.ofc where lookup("p00006",trim(txb.ofc.expr[1])) > 0 or lookup("p00126",trim(txb.ofc.expr[1])) > 0 no-lock:
    if v-ofcmain <> "" then do:
        if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofcmain), ";") > 0 then next.
        else v-ofcmain = v-ofcmain + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
    end.
    else do:
        v-ofcmain = trim(txb.ofc.ofc) + "@metrocombank.kz".
    end.
end.


if v-txb = "TXB01" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb01 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb01), ";") > 0 then next.
            else v-ofctxb01 = v-ofctxb01 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb01 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB02" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb02 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb02), ";") > 0 then next.
            else v-ofctxb02 = v-ofctxb02 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb02 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB03" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb03 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb03), ";") > 0 then next.
            else v-ofctxb03 = v-ofctxb03 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb03 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB04" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb04 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb04), ";") > 0 then next.
            else v-ofctxb04 = v-ofctxb04 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb04 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB05" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb05 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb05), ";") > 0 then next.
            else v-ofctxb05 = v-ofctxb05 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb05 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB06" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb06 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb06), ";") > 0 then next.
            else v-ofctxb06 = v-ofctxb06 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb06 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB07" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb07 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb07), ";") > 0 then next.
            else v-ofctxb07 = v-ofctxb07 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb07 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB08" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb08 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb08), ";") > 0 then next.
            else v-ofctxb08 = v-ofctxb08 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb08 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB09" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb09 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb09), ";") > 0 then next.
            else v-ofctxb09 = v-ofctxb09 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb09 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB10" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb10 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb10), ";") > 0 then next.
            else v-ofctxb10 = v-ofctxb10 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb10 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB11" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb11 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb11), ";") > 0 then next.
            else v-ofctxb11 = v-ofctxb11 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb11 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB12" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb12 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb12), ";") > 0 then next.
            else v-ofctxb12 = v-ofctxb12 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb12 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB13" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb13 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb13), ";") > 0 then next.
            else v-ofctxb13 = v-ofctxb13 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb13 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB14" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb14 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb14), ";") > 0 then next.
            else v-ofctxb14 = v-ofctxb14 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb14 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB15" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb15 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb15), ";") > 0 then next.
            else v-ofctxb15 = v-ofctxb15 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb15 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.
if v-txb = "TXB16" then do:
    for each txb.ofc where lookup("p00136",trim(txb.ofc.expr[1])) > 0 or lookup("p00121",trim(txb.ofc.expr[1])) > 0 no-lock:
        if v-ofctxb16 <> "" then do:
            if lookup(trim(txb.ofc.ofc) + "@metrocombank.kz", trim(v-ofctxb16), ";") > 0 then next.
            else v-ofctxb16 = v-ofctxb16 + ";" + trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
        else do:
            v-ofctxb16 = trim(txb.ofc.ofc) + "@metrocombank.kz".
        end.
    end.
end.



