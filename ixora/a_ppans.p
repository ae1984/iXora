/* a_ppans.p
 * MODULE
        Длительные поручения
 * DESCRIPTION
        Загрузка ответных файлов по длительным платежным поручениям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        15-7-5
 * AUTHOR
        16/07/2013 Luiza
 * BASES
        BANK COMM
 * CHANGES
         30/09/2013 Luiza  - ТЗ 2047
*/

def var v-bank      as char no-undo.
def var v-bcode     as char no-undo.
def var v-fname     as char no-undo.
def var v-ln        as int  no-undo.
def var v-spcrc     as char no-undo.
def var v-spcrc3    as char no-undo.
def var v-spf0      as char no-undo.
def var v-spf1      as char no-undo.
def var v-spf2      as char no-undo.
def var v-spf       as char no-undo.
def var i           as int  no-undo.
def var j           as int  no-undo.
def var m           as int  no-undo.
def var n           as int  no-undo.
def var l           as int  no-undo.
def var v-str       as char no-undo.
def var v-arc       as char no-undo.
def var v-home      as char no-undo.
def var v-exist1    as char no-undo.
def var v-ldt       as date no-undo.
def var v-trdt      as date no-undo.
def var v-dtchar    as char no-undo.
def var v-crc3      as char no-undo.
def var v-fcrc      as int  no-undo.
def var v-lcrc      as int  no-undo.
def var v-dacc      as char no-undo.
def var v-cacc      as char no-undo.
def var v-amt       as deci no-undo.
def var v-s         as logi no-undo.
def var v-arp       as char format "x(20)" no-undo.
def var v-gl        as int  no-undo.
def var v-r         as char no-undo.
def var v-cgr       as char no-undo.
def var v-transp    as int  no-undo.
def var v-qq        as char no-undo.
def var er          as char no-undo.
def var v_rmzdoc    as char no-undo.
def var v-inval as int no-undo.
def var v-loval as logic no-undo.

v-gl = 186012.

def temp-table t-prot no-undo
    field namef as char
    field txb   as char
    field acc   as char
    field fio   as char
    field crc   as char
    field amt   as deci
    field stat  as char.

{global.i}
{srvcheck.i}
{xmlParser.i}

function getcrc returns char (parm1 as char).
    def var crc1 as char extent 3 init ["1","2","3"].
    def var crc2 as char extent 3 init ["398","840","978"].
	def var j as integer.
    repeat j = 1 to 3:
	   if parm1 = crc2[j] then return crc1[j].
       j = j + 1.
     end.
     return parm1.
end function.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.
if v-bank <> "TXB00" then do:
    message "Доступ только с ЦО!" view-as alert-box error.
    return.
end.

find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'bankcode'
                     no-lock no-error.
if avail bookcod then v-bcode = bookcod.name.
else do:
    message "Нет кода <bankcode> в справочнике <pc> !" view-as alert-box error.
    return.
end.

find first sysc where sysc.sysc = "ppout10" no-lock no-error.
if not avail sysc then do:
    run savelog( "PPOUT", " There is not parameter ppout10 sysc!").
    return.
end.
v-inval = sysc.inval. /* запоминаем признак прогрузки 10-часового ответного файла*/
v-loval = sysc.loval.

find first sysc where sysc.sysc = "ppout13" no-lock no-error.
if not avail sysc then do:
    run savelog( "PPOUT", " There is not parameter ppout13 sysc!").
    return.
end.


assign v-fname = '*' + v-bcode + '*.*'
       v-ln    = length(v-bcode) + 1.
find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'crc'
                     no-lock no-error.
if avail bookcod then v-spcrc = bookcod.name.
if v-spcrc = '' then do:
    message "Нет кода <crc> в справочнике <pc> !"view-as alert-box error.
    return.
end.
find first bookcod where bookcod.bookcod = 'pc'
                     and bookcod.code    = 'crc3'
                     no-lock no-error.
if avail bookcod then v-spcrc3 = bookcod.name.
if v-spcrc3 = '' then do:
    message "Нет кода <crc3> в справочнике <pc> !"view-as alert-box error.
    return.
end.
if num-entries(v-spcrc) ne num-entries(v-spcrc3) then do:
    message "Нет соответствия кодов валют <crc> и  <crc3> в справочнике <pc> !"view-as alert-box error.
    return.
end.
display '   Ждите идет загрузка ответного файла ' with row 8 frame ww centered.
pause 0.


    if isProductionServer() then do:
        input through value("ssh Administrator@fs01.metrobank.kz -q dir /b 'D:\\euraz\\Cards\\In\\PAYMFROM\\" + v-fname + "'") no-echo.
    end.
    else do:
        input through value("ssh Administrator@fs01.metrobank.kz -q dir /b 'D:\\euraz\\Cards\\In\\test\\PAYMFROM\\" + v-fname + "'") no-echo.
    end.
repeat:
    import  unformatted v-str.
    if v-str begins 'the system' or v-str = 'file not found' then do:
        message "Нет файлов " + v-fname + " на подгрузку."
        view-as alert-box information buttons ok title " Внимание" .
        undo, return.
    end.
    v-spf0 = v-spf0 + v-str + '|'.
end.

v-spf0 = right-trim(v-spf0,'|').

do i = 1 to num-entries(v-spf0,"|"):
    v-fname = entry(i,v-spf0,"|").
    find first pplist where pplist.namefin = v-fname no-lock no-error.
    if avail pplist then do:
        v-spf1 = v-spf1 + v-fname + "|~n".
        next.
    end.
    find first pplist where pplist.namefout = substring(trim(v-fname),3,length(trim(v-fname)) - 2) and pplist.stat <> "Обработан" no-lock no-error.
    if not avail pplist then do:
        v-spf2 = v-spf2 + v-fname + "|".
        next.
    end.
    v-spf = v-spf + v-fname + "|".
end.

if v-spf1 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf1,'|') + " были загружены ранее."
    view-as alert-box information buttons ok title " Внимание1 " .
end.
if v-spf2 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf2,'|') + " имеют некорректное название!"
    view-as alert-box information buttons ok title " Внимание2 " .
end.
if v-spf = '' then do:
    message "Нет новых файлов на подгрузку!"
    view-as alert-box information buttons ok title " Внимание3 " .
    return.
end.

v-arc = "/data/import/pc/".
input through value( "find " + v-arc + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-arc).
    unix silent value ("chmod 777 " + v-arc).
end.

v-arc = "/data/import/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
input through value( "find " + v-arc + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-arc).
    unix silent value ("chmod 777 " + v-arc).
end.

v-home = "./pc/" .
input through value( "find " + v-home + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
    unix silent value ("mkdir " + v-home).
end.

v-spf = right-trim(v-spf,'|').
do i = 1 to num-entries(v-spf, "|"):
    v-str = ''.
    if isProductionServer() then do:
    /*unix silent value('cp ' + v-home + v-fname + ' ' + v-arc).*/
        input through value("scp -q Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/PAYMFROM/" +  entry(i, v-spf, "|") + " " + v-home + ";echo $?").
    end.
    else do:
        input through value("scp Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/test/PAYMFROM/" +  entry(i, v-spf, "|") + " " + v-home + ";echo $?").
    end.
    repeat:
        import unformatted v-str.
    end.
    if v-str <> "0" then do:
        message "Ошибка копирования файла " + entry(i, v-spf, "|") + "!~n" + v-str + "~nДальнейшая работа невозможна!~Обратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание4 " .
        return.
    end.
end.

unix silent value('cp ' + v-home + '*.* ' + v-arc).
v-ldt = g-today.

do i = 1 to num-entries(v-spf, "|"):
    run parseFileXML (v-home + entry(i, v-spf, "|"), output er).
    if er <> '' then do:
        message "Ошибка parseFileXML файла " + entry(i, v-spf, "|") + "!~n" + er + "~nДальнейшая работа невозможна!~Обратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание5 " .
        return.
    end.
    def buffer doc  for t-node.
    def var v-nodeID  as int no-undo.
    def var v-nodeID1 as int no-undo.
    def var nodeacc   as char no-undo. /* счет */
    def var nodetxb   as char no-undo. /* код филиала */
    def var nodefio   as char no-undo. /* ФИО */
    def var nodecrc   as char no-undo. /* валюта */
    def var nodeamt   as decim no-undo. /* сумма */
    def var nodests   as char no-undo. /* статус */

    for each doc where doc.nodeName = "Doc" no-lock .
        find first t-node where t-node.nodeName = "Destination" and t-node.nodeParentId = doc.nodeId no-lock no-error.
        if available t-node then do:
            v-nodeID =  t-node.nodeId.
            find first t-node where t-node.nodeName = "ContractNumber" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then nodeacc = t-node.nodeValue.
            find first t-node where t-node.nodeName = "MemberId" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then nodetxb = "TXB" + substring(t-node.nodeValue,3,2).
            find first t-node where t-node.nodeName = "Client" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then v-nodeID1 = t-node.nodeId.
            find first t-node where t-node.nodeName = "ClientInfo" and t-node.nodeParentId = v-nodeID1 no-lock no-error.
            if available t-node then v-nodeID1 = t-node.nodeId.
            find first t-node where t-node.nodeName = "ShortName" and t-node.nodeParentId = v-nodeID1 no-lock no-error.
            if available t-node then nodefio = CODEPAGE-CONVERT(t-node.nodeValue,"kz-1048","utf-8").

        end.
        find first t-node where t-node.nodeName = "Transaction" and t-node.nodeParentId = doc.nodeId no-lock no-error.
        if available t-node then do:
            v-nodeID =  t-node.nodeId.
            find first t-node where t-node.nodeName = "Currency" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then nodecrc = t-node.nodeValue.
            find first t-node where t-node.nodeName = "Amount" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then nodeamt = decimal(t-node.nodeValue).
        end.
        find first t-node where t-node.nodeName = "Status" and t-node.nodeParentId = doc.nodeId no-lock no-error.
        if available t-node then do:
            v-nodeID =  t-node.nodeId.
            find first t-node where t-node.nodeName = "RespText" and t-node.nodeParentId = v-nodeID no-lock no-error.
            if available t-node then nodests = t-node.nodeValue.
        end.
        create t-prot.
        t-prot.fio   = nodefio.
        t-prot.txb   = nodetxb.
        t-prot.acc   = nodeacc.
        t-prot.crc   = getcrc(nodecrc).
        t-prot.amt   = nodeamt.
        t-prot.stat  = nodests.
        t-prot.namef  = entry(i, v-spf, "|").

    end.
    for each t-prot no-lock.
        find first pplist where pplist.txb = t-prot.txb and pplist.aaa = t-prot.acc and pplist.sum = t-prot.amt and pplist.stat <> "Обработан" exclusive-lock no-error.
        if available pplist then do:
            if t-prot.stat =  "Successfully completed" then pplist.stat = "Обработан".
            else pplist.stat = "Не обработан".
            pplist.namefin = entry(i, v-spf, "|").
            find current pplist no-lock no-error.
        end.
    end. /* for each t-prot no-lock */
end. /* do i = 1 to num-entries(v-spf, "|") */

/* меняем признаки загрузки ответного файла */
if v-inval = 0 and v-loval then do: /* значит файл отправили, но ответный файл еще не загружали */
    find first sysc where sysc.sysc = "ppout10" exclusive-lock no-error.
    if available sysc then sysc.inval = 1.
    find first sysc where sysc.sysc = "ppout10" no-lock no-error.
end.

if v-inval = 1 and v-loval then do: /* значит 10-часовой файл отправили и ответ уже загрузили */
    find first sysc where sysc.sysc = "ppout13" no-lock no-error.
    if sysc.loval and time >= 46800 and sysc.inval = 0 then do:
        find first sysc where sysc.sysc = "ppout13" exclusive-lock no-error.
        if available sysc then sysc.inval = 1.
        find first sysc where sysc.sysc = "ppout13" no-lock no-error.
    end.
end.

def stream r-out.
output stream r-out to a_ppans.htm.
put stream r-out unformatted "<html><head><title></title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
find first cmp no-lock no-error.
put stream r-out unformatted "<br><br>" cmp.name "<br>" skip.
put stream r-out unformatted "<br>" "Протокол загрузки по длительным платежным поручениям за " string(g-today) "<br>" skip.
put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
          "<tr style=""font:bold"">"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">ФИО</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Счет</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Вал</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Статус</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">file</td>"
          "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Фил</td>"
          "</tr>" skip.
for each t-prot no-lock .
    put stream r-out unformatted
              "<tr>"
              "<td>" t-prot.fio "</td>"
              "<td>" t-prot.acc "</td>"
              "<td>" t-prot.crc "</td>"
              "<td>" replace(trim(string(t-prot.amt,  ">>>>>>>>9.99")),'.',',') "</td>"
              "<td>" t-prot.stat "</td>"
              "<td>" t-prot.namef "</td>"
              "<td>" t-prot.txb "</td>"
              "</tr>" skip.
end.
put stream r-out unformatted "</table>" skip.
put stream r-out unformatted "<br>" skip.
output stream r-out close.

unix silent cptwin a_ppans.htm excel.

/* копирование в архив */
do i = 1 to num-entries(v-spf, "|"):
    v-str = "".
    if isProductionServer() then do:
        unix silent value('cp ' + v-home + entry(i, v-spf, "|") + ' ' + v-arc).
        input through value ("ssh Administrator@fs01.metrobank.kz  -q move " + "D:\\\\euraz\\\\Cards\\\\In\\\\PAYMFROM\\\\" + entry(i, v-spf, "|") + " D:\\\\euraz\\\\Cards\\\\In\\\\arch\\\\PAYMFROM\\\\" + entry(i, v-spf, "|") + " ;echo $?").
    end.
    else do:
        unix silent value('cp ' + v-home + entry(i, v-spf, "|") + ' ' + v-arc).
        input through value ("ssh Administrator@fs01.metrobank.kz  -q move " + "D:\\\\euraz\\\\Cards\\\\In\\\\test\\\\PAYMFROM\\\\" + entry(i, v-spf, "|") + " D:\\\\euraz\\\\Cards\\\\In\\\\test\\\\arc\\\\PAYMFROM\\\\" + entry(i, v-spf, "|") + " ;echo $?").
    end.
    repeat:
        import unformatted v-str.
    end.
    if v-str <> "0" then do:
        message "Ошибка копирования файла " + entry(i, v-spf, "|") + " в архив!~Код ошибки " + v-str + ".~nОбратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание " .
    end.
    unix silent value ("rm -f " + v-home + entry(i, v-spf, "|")).
end.