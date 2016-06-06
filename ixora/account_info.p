/* account_info
 * MODULE
        Возвращает данные по счету
 * DESCRIPTION
        Описание программы
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
        13.12.2012 e.berdibekov
 * BASES
        BANK TXB
 * CHANGES
        24/01/2013 madiyar - убрал global.i
        19.04.2013 evseev - tz-1720 убрал передачу cif.irs
        14.05.2013 yerganat tz-1740, добавил поиск счета из arp, если находит возвращает xml
*/

def shared var g-today as date.

define input parameter pAccount       as char.

define input parameter xmlH           as handle.
define output parameter replyH        as handle.

define variable r-des                 as char.
define variable r-code                as integer.

define variable number                as char.
define variable currency              as char.
define variable available_balance     as char.
define variable total_balance         as char.
define variable freeze                as char.
define variable recent                as char.

define variable rnn                   as char.
define variable bin                   as char.

define variable v_ost                 as decimal.


define new shared variable d_gtday as date .

d_gtday = g-today.

replyH = xmlH.

find first txb.aaa where txb.aaa.aaa = pAccount no-lock no-error.
if not avail txb.aaa then do:
    find first txb.arp where txb.arp.arp = pAccount no-lock no-error.
    if not avail txb.arp then do:
      r-des = "Отсутствует счет клиента.".
      r-code = 1.
      run setIntProperty in replyH("ERRCODE",r-code).
      run setStringProperty in replyH("ERRDESC",r-des).
      return.
    end.
    else do:
      find last txb.crc where txb.crc.crc = txb.arp.crc no-lock no-error.
      if not avail txb.crc then do:
        r-des = 'Счет не найден'.
        r-code = 1.
        run setIntProperty in replyH("ERRCODE",r-code).
        run setStringProperty in replyH("ERRDESC",r-des).
        return.
      end.

      currency = txb.crc.code.
      run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>\n").
      run appendText in replyH ("<ACCOUNT>").
      run appendText in replyH ("<NUMBER>" +  pAccount + "</NUMBER>").
      run appendText in replyH ("<CURRENCY>" +  currency + "</CURRENCY>").
      run appendText in replyH ("<ARP>" +  "1" + "</ARP>").
      run appendText in replyH ("</ACCOUNT>").
      return.
    end.
end.

find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
if not avail txb.lgr then do:
    r-des = 'Счет не найден'.
    r-code = 1.
    run setIntProperty in replyH("ERRCODE",r-code).
    run setStringProperty in replyH("ERRDESC",r-des).

    return.
end.

find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
if not avail txb.crc then do:
    r-des = 'Неизвестная валюта'.
    r-code = 2.
    run setIntProperty in replyH("ERRCODE",r-code).
    run setStringProperty in replyH("ERRDESC",r-des).

    return.
end.


number = txb.aaa.aaa.
currency = txb.crc.code.
total_balance = string(txb.aaa.cbal).
freeze = string(txb.aaa.hbal).
available_balance = string(txb.aaa.cbal - txb.aaa.hbal).

for each txb.jl where txb.jl.acc = txb.aaa.aaa and txb.jl.jdt = d_gtday  no-lock :
    v_ost = v_ost + abs(txb.jl.cam - txb.jl.dam).
end.

recent = string(v_ost).

run setText in replyH ("<?xml version=""1.0"" encoding=""UTF-8""?>\n").
run appendText in replyH ("<ACCOUNT>").
run appendText in replyH ("<NUMBER>" +  number + "</NUMBER>").
run appendText in replyH ("<CURRENCY>" +  currency + "</CURRENCY>").
run appendText in replyH ("<AVAILABLE_BALANCE>" +  string(available_balance) + "</AVAILABLE_BALANCE>").
run appendText in replyH ("<TOTAL_BALANCE>" + string(total_balance)  + "</TOTAL_BALANCE>").
run appendText in replyH ("<FREEZE>" +  freeze + "</FREEZE>").
run appendText in replyH ("<RECENT>" +  recent + "</RECENT>").

/* logs */
message "Response xml:".
message "<?xml version=""1.0"" encoding=""UTF-8""?>".
message "<ACCOUNT>".
message "<NUMBER>" +  number + "</NUMBER>".
message "<CURRENCY>" +  currency + "</CURRENCY>".
message "<AVAILABLE_BALANCE>" +  string(available_balance) + "</AVAILABLE_BALANCE>".
message "<TOTAL_BALANCE>" + string(total_balance)  + "</TOTAL_BALANCE>".
message "<FREEZE>" +  freeze + "</FREEZE>".
message "<RECENT>" +  recent + "</RECENT>".


find last txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
if not avail txb.cif then do:
    r-des = 'Клиент не найден'.
    r-code = 3.
end.

rnn = txb.cif.jss. /* depricated */
bin = txb.cif.bin.


run appendText in replyH("<NAMEPREFIX><![CDATA[" + trim(txb.cif.prefix) + "]]></NAMEPREFIX>").
run appendText in replyH("<NAME><![CDATA[" + trim(txb.cif.name) + "]]></NAME>").
run appendText in replyH("<SNAME><![CDATA[" + trim(txb.cif.sname) + "]]></SNAME>").
run appendText in replyH("<IDN>" + bin + "</IDN>").
run appendText in replyH("<GEO>" + txb.cif.geo + "</GEO>").
if txb.cif.geo = "022" then run appendText in replyH("<IRS>" + "2" + "</IRS>").
else if txb.cif.geo = "021" then run appendText in replyH("<IRS>" + "1" + "</IRS>").
run appendText in replyH("<SUB-CODES>").

message "<NAME>" + txb.cif.Name + "</NAME>".
message "<IDN>" + bin + "</IDN>".
message "<GEO>" + txb.cif.geo + "</GEO>".
if txb.cif.geo = "022" then message "<IRS>" + "2" + "</IRS>".
else if txb.cif.geo = "021" then message "<IRS>" + "1" + "</IRS>".
message "<SUB-CODES>".

run outSubcodes(txb.aaa.cif, replyH).

run appendText in replyH("</SUB-CODES>").
run appendText in replyH ("</ACCOUNT>").

message "</SUB-CODES>".
message "</ACCOUNT>".


/***********************************************************************************/
procedure outSubcodes:
    def input parameter cif as char.
    def input parameter replyH as handle.

    for each txb.sub-cod where txb.sub-cod.acc = cif no-lock:
        run appendText in replyH("<SUB-COD>").
        run appendText in replyH("<SUB>" + txb.sub-cod.sub + "</SUB>").
        run appendText in replyH("<D-COD>" + txb.sub-cod.d-cod + "</D-COD>").
        run appendText in replyH("<C-COD>" + txb.sub-cod.ccode + "</C-COD>").
        run appendText in replyH("<REG-DATE>" + string(txb.sub-cod.rdt) + "</REG-DATE>").
        run appendText in replyH("<R-COD>" + txb.sub-cod.rcode + "</R-COD>").
        run appendText in replyH("</SUB-COD>").

        /* logs */
        /* Sub-codes we dont show
        message "<SUB-COD>".
        message "<SUB>" + txb.sub-cod.sub + "</SUB>".
        message "<D-COD>" + txb.sub-cod.d-cod + "</D-COD>".
        message "<REG-DATE>" + string(txb.sub-cod.rdt) + "</REG-DATE>".
        message "<R-COD>" + txb.sub-cod.d-cod + "</R-COD>".
        message "</SUB-COD>".
        */
    end.

end procedure.
/***********************************************************************************/


