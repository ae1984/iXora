/* pcgllooad.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Загрузка файлов GL
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        22/10/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
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
def stream r-in.
def stream r-out.
def temp-table t-prot no-undo
    field t-namef as char
    field t-n     as char
    field t-dacc  as char
    field t-cacc  as char
    field t-amt   as deci
    field t-prim  as char.

{global.i}

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
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
input through value("ssh Administrator@fs01.metrobank.kz -q dir /b 'D:\\euraz\\Cards\\In\\GL\\" + v-fname + "'") no-echo.
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
    find first pcgl where pcgl.fname = v-fname no-lock no-error.
    if avail pcgl then do:
        v-spf1 = v-spf1 + v-fname + "|".
        next.
    end.
    else do:
        if length(entry(1,v-fname,".")) < (v-ln + 3) then do:
            v-spf2 = v-spf2 + v-fname + "|".
            next.
        end.
        find first crc where crc.code begins substr(v-fname, v-ln + 1,2) no-lock no-error.
        if not avail crc then do:
            v-spf2 = v-spf2 + v-fname + "|".
            next.
        end.
    end.
    v-spf = v-spf + v-fname + "|".
end.

if v-spf1 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf1,'|') + " были загружены ранее."
    view-as alert-box information buttons ok title " Внимание " .
end.
if v-spf2 ne '' then do:
    message "Файл/файлы " + right-trim(v-spf2,'|') + " имеют некорректное название!"
    view-as alert-box information buttons ok title " Внимание " .
end.
if v-spf = '' then do:
    message "Нет новых файлов на подгрузку!"
    view-as alert-box information buttons ok title " Внимание " .
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
    input through value("scp Administrator@fs01.metrobank.kz:D:/euraz/Cards/In/GL/" +  entry(i, v-spf, "|") + " " + v-home + ";echo $?").
    repeat:
        import unformatted v-str.
    end.

    if v-str <> "0" then do:
        message "Ошибка копирования файла " + entry(i, v-spf, "|") + "!~n" + v-str + "~nДальнейшая работа невозможна!~Обратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание " .
        return.
    end.
end.
unix silent value('cp ' + v-home + '*.* ' + v-arc).
v-ldt = g-today.
do i = 1 to num-entries(v-spf, "|"):
    do transaction:
        v-fname = entry(i, v-spf, "|").
        v-s = if substr(v-fname,1,1) = 'S' then yes else no.
        unix silent value('echo "" >> ' + v-home + v-fname).
        assign v-str   = ""
               j       = 0
               m       = 0
               n       = 0.
        input stream r-in from value(v-home + v-fname).
        repeat:
            import stream r-in unformatted v-str.

            if v-str ne "" then do:
                j = j + 1.
                if substr(v-str,1,2) = 'FH' then do:
                    v-dtchar = substr(v-str,46,8).
                    v-trdt = date(substr(v-dtchar,7,2) + substr(v-dtchar,5,2) + substr(v-dtchar,1,4)) no-error.
                    v-crc3  = substr(v-str,54,3).
                    l = lookup(v-crc3,v-spcrc3).
                    if l > 0 then v-fcrc = int(entry(l,v-spcrc)) no-error.
                    if v-s then do:
                        v-crc3  = substr(v-str,57,3).
                        l = lookup(v-crc3,v-spcrc3).
                        if l > 0 then v-lcrc = int(entry(l,v-spcrc)) no-error.
                    end.
                    else v-lcrc = v-fcrc.
                    m = 0.
                end.
                if substr(v-str,1,2) = 'RD' then do:
                   m = m + 1.
                   if v-s then assign v-dacc = substr(v-str,27,20)
                                      v-cacc = substr(v-str,59,20)
                                      v-amt  = deci(substr(v-str,91,15)) / 100.
                   else assign v-dacc = substr(v-str,558,20)
                               v-cacc = substr(v-str,622,20)
                               v-amt  = deci(substr(v-str,267,15)) / 100.
                   if substr(v-dacc,5,3) ne '470' or not can-find(txb where txb.bank = 'txb' + substr(v-dacc,19,2))then do:
                    create t-prot.
                    assign t-prot.t-namef = v-fname
                           t-prot.t-n     = substr(v-str,3,6)
                           t-prot.t-dacc  = v-dacc
                           t-prot.t-cacc  = v-cacc
                           t-prot.t-amt   = v-amt
                           t-prot.t-prim  = 'некорректный счет Дт'.
                    n = n + 1.
                    next.
                   end.
                   if substr(v-cacc,5,3) ne '470' or not can-find(txb where txb.bank = 'txb' + substr(v-cacc,19,2)) then do:
                    create t-prot.
                    assign t-prot.t-namef = v-fname
                           t-prot.t-n     = substr(v-str,3,6)
                           t-prot.t-dacc  = v-dacc
                           t-prot.t-cacc  = v-cacc
                           t-prot.t-amt   = v-amt
                           t-prot.t-prim  = 'некорректный счет Кт'.
                    n = n + 1.
                    next.
                   end.
                   create pcgl.
                   assign pcgl.fname  = v-fname
                          pcgl.ldt    = v-ldt
                          pcgl.trdt   = v-trdt
                          pcgl.fcrc   = v-fcrc
                          pcgl.lcrc   = v-lcrc
                          pcgl.trnum  = substr(v-str,9,10)
                          pcgl.trcode = if v-s then trim(substr(v-str,19,8)) else trim(substr(v-str,19,4))
                          pcgl.dacc   = v-dacc
                          pcgl.cacc   = v-cacc
                          pcgl.tramt  = v-amt
                          pcgl.trlamt = if v-s then deci(substr(v-str,106,15)) / 100 else v-amt
                          pcgl.trdes  = if v-s then trim(substr(v-str,121,100)) else trim(substr(v-str,288,32))
                          pcgl.grid   = if v-s then substr(v-str,222,9) else '0000000000'
                          pcgl.who    = g-ofc
                          pcgl.dbnk   = 'txb' + substr(v-dacc,19,2)
                          pcgl.cbnk   = 'txb' + substr(v-cacc,19,2)
                          pcgl.sts    = 'new'
                          no-error.

                end.
            end. /* v-str ne '' */
        end. /* repeat */
    end. /* do transaction*/

    input stream r-in close.

    /* копирование в архив */
    unix silent value('cp ' + v-home + v-fname + ' ' + v-arc).
    input through value ("ssh Administrator@fs01.metrobank.kz  -q move " + "D:\\\\euraz\\\\Cards\\\\In\\\\GL\\\\" + v-fname + " D:\\\\euraz\\\\Cards\\\\In\\\\arc\\\\" + v-fname + " ;echo $?").
    repeat:
        import unformatted v-str.
    end.
    if v-str <> "0" then do:
        message "Ошибка копирования файла " + v-fname + " в архив!~Код ошибки " + v-str + ".~nОбратитесь в ДИТ!"
        view-as alert-box information buttons ok title " Внимание " .
    end.
    unix silent value ("rm -f " + v-home + v-fname).
    message "Файл " + v-fname + " обработан! Всего записей " + string(m) + ". Ошибок " + string(n) + "."  view-as alert-box title "ВНИМАНИЕ".
end. /* do */

output stream r-out to pcglload.htm.
put stream r-out unformatted "<html><head><title></title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
find first cmp no-lock no-error.
put stream r-out unformatted "<br><br>" cmp.name "<br>" skip.
put stream r-out unformatted "<br>" "Протокол загрузки файлов GL(ошибочные строки) за " string(g-today) "<br>" skip.
for each t-prot no-lock break by t-prot.t-namef :
    if first-of(t-prot.t-namef) then do:
        put stream r-out unformatted "<br>Файл: " + t-prot.t-namef + "<br>" skip.
        put stream r-out unformatted "</tr></table>" skip.
        put stream r-out unformatted "<br>" skip.
        put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">№ строки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Счет Дт</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Счет Кр</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" valign=""top"">Примечание</td>"
                  "</tr>" skip.
    end.
    put stream r-out unformatted
              "<tr>"
              "<td>" t-prot.t-n "</td>"
              "<td>" t-prot.t-dacc "</td>"
              "<td>" t-prot.t-cacc "</td>"
              "<td>" replace(trim(string(t-prot.t-amt,  ">>>>>>>>9.99")),'.',',') "</td>"
              "<td>" t-prot.t-prim format 'x(70)' "</td>"
              "</tr>" skip.
    if last-of(t-prot.t-namef) then do:
        put stream r-out unformatted "</tr></table>" skip.
        put stream r-out unformatted "<br>" skip.
    end.
end.
output stream r-out close.

unix silent cptwin pcglload.htm excel.
unix silent value("rm -f pcstload.htm").
