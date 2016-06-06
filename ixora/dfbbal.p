/* dfbbal.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Денежные потоки по счетам dfb 1051 и 1052
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
        04/09/2013 galina ТЗ1960
 * BASES
        BANK
 * CHANGES
        05/09/2013 galina - ТЗ1960 перекомпеляция
*/

{global.i}
def var v-dtbeg as date.
def var v-dtend as date.

def temp-table t-dfb
    field acc as char
    field bankname as char
    field crccode as char
    field inbal as deci
    field inbalkzt as deci
    field debet as deci
    field debet_kzt as deci
    field cred as deci
    field cred_kzt as deci
    field outbal as deci
    field outbalkzt as deci
    index idx1 is primary crccode acc.

def temp-table t-dfbrmz
    field dfb as char
    field rmz as char
    field debet as deci
    field cred as deci
    field que as char
    field nameben as char
    field bankben as char
    field naznpl as char
    field num as deci
    field jdt as date
    field tim as int
    index idx1 is primary dfb num descending.

def var v-sel as char.
def var v-sel2 as char.
def var v-crccode as char.
def var v-dfb as char.

def frame fdfb
    v-dfb format "x(20)" label 'Счет' validate(v-dfb = '' or can-find(dfb where dfb.dfb = v-dfb and (dfb.gl = 105100 or dfb.gl = 105210 or dfb.gl = 105220) no-lock),'Счет не найден!') help "F2 - список корр. счетов"
    with side-label row 5 centered title ''.

def frame fcrc
    v-crccode format "x(3)" label 'Валюта' validate(trim(v-crccode) <> '' and can-find(crc where crc.code = v-crccode and crc.sts <> 9 no-lock),'Неверный код валюты!') help "F2 - Коды валют"
    with side-label row 5 centered title ''.
on help of v-crccode in frame fcrc do:

        {itemlist.i
            &set = "2"
            &file = "crc"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " crc.sts <> 9 "

            &flddisp = " crc.code label 'Код' crc.des label 'Название' "
            &chkey = "code"
            &index  = "crc"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-crccode = crc.code.
        displ v-crccode with frame fcrc.
end.

def var v-crcname as char.
on help of v-dfb in frame fdfb do:
        find first crc where crc.code = v-crccode no-lock no-error.
        {itemlist.i
            &set = "2"
            &file = "dfb"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " (dfb.gl = 105100 or dfb.gl = 105210 or dfb.gl = 105220) and ((dfb.crc = crc.crc and v-crccode <> '') or v-crccode = '')"
            &findadd = " v-crcname = '' . find first crc where crc.crc = dfb.crc no-lock no-error. if avail crc then v-crcname = crc.code. "
            &flddisp = " dfb.dfb label 'Счет' dfb.name label 'Название' v-crcname label 'Валюта'"
            &chkey = "dfb"
            &index  = "dfb"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-dfb = dfb.dfb.
        displ v-dfb with frame fdfb.
end.

def stream outstrem.
def var v-totinbal as deci.
def var v-totinbal_kzt as deci.
def var v-totdebet as deci.
def var v-totdebet_kzt as deci.
def var v-totcred as deci.
def var v-totcred_kzt as deci.
def var v-totoutbal as deci.
def var v-totoutbal_kzt as deci.
def var v-inbal as deci.
def var v-debet as deci.
def var v-cred as deci.


function get_amt returns deci (p-acc as char, p-gl as integer, p-dt as date, p-crc as integer).
  def var v-amt as deci.
  v-amt = 0.
  if p-dt < g-today then do:
    find last histrxbal where histrxbal.subled = 'dfb' and histrxbal.acc = p-acc and histrxbal.level = 1 and histrxbal.crc = p-crc and histrxbal.dt <= p-dt  no-lock no-error.
    if avail histrxbal then do:
      find gl where gl.gl  = p-gl no-lock no-error.
      if avail gl then do:
          if gl.type eq "A" or gl.type eq "E" then
               v-amt = histrxbal.dam - histrxbal.cam.
          else v-amt = histrxbal.cam - histrxbal.dam.
      end.
    end.

  end.
  if p-dt = g-today then do:
    find first trxbal where trxbal.subled = 'dfb' and trxbal.acc = p-acc and trxbal.level = 1 and trxbal.crc = p-crc no-lock no-error.
    if avail trxbal then do:
      find gl where gl.gl  = p-gl no-lock no-error.
      if avail gl then do:
          if gl.type eq "A" or gl.type eq "E" then
               v-amt = trxbal.dam - trxbal.cam.
          else v-amt = trxbal.cam - trxbal.dam.
      end.
    end.
  end.
  return v-amt.
end.

function get_dam returns deci (p-acc as char, p-dt as date, p-crc as integer).
  def var v-dam as deci.
  v-dam = 0.
  if p-dt < g-today then do:
    find last histrxbal where histrxbal.subled = 'dfb' and histrxbal.acc = p-acc and histrxbal.level = 1 and histrxbal.crc = p-crc and histrxbal.dt <= p-dt  no-lock no-error.
    if avail histrxbal then v-dam = histrxbal.dam.
  end.
  if p-dt = g-today then do:
    find first trxbal where trxbal.subled = 'dfb' and trxbal.acc = p-acc and trxbal.level = 1 and trxbal.crc = p-crc no-lock no-error.
    if avail trxbal then v-dam = trxbal.dam.
  end.
  return v-dam.
end.

function get_cam returns deci (p-acc as char, p-dt as date, p-crc as integer).
  def var v-cam as deci.
  v-cam = 0.
  if p-dt < g-today then do:
    find last histrxbal where histrxbal.subled = 'dfb' and histrxbal.acc = p-acc and histrxbal.level = 1 and histrxbal.crc = p-crc and histrxbal.dt <= p-dt  no-lock no-error.
    if avail histrxbal then v-cam = histrxbal.cam.
  end.
  if p-dt = g-today then do:
    find first trxbal where trxbal.subled = 'dfb' and trxbal.acc = p-acc and trxbal.level = 1 and trxbal.crc = p-crc no-lock no-error.
    if avail trxbal then v-cam = trxbal.cam.
  end.
  return v-cam.
end.
find first sysc where sysc.sysc = 'ourbnk' no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    message "Не найдена запись ourbnk в справочнике sysc!" view-as alert-box.
    return.
end.
if trim(sysc.chval) <> 'TXB00' then do:
    message "Данный отчет формируется только в ЦО!" view-as alert-box.
    return.

end.
v-sel = ''.
run sel2 (" Выбор: ", " 1. Консолидированный отчет | 2. Расшифровка по счету/по валюте | 3. Выход ", output v-sel).

if v-sel = '3' then return.
v-dtbeg = g-today.
v-dtend = g-today.
update v-dtbeg validate(v-dtbeg <= g-today,'Дата должна быть меьше или равна ' + string(g-today,'99/99/9999')) label 'C' format "99/99/9999"
       v-dtend validate(v-dtend <= g-today,'Дата должна быть меьше или равна ' + string(g-today,'99/99/9999')) label 'По' format "99/99/9999" with frame fdt row 5 centered side-label title 'ПЕРИОД'.
hide frame fdt.


if v-sel = '1' then do:
    message "Отчет формируется...".
    empty temp-table t-dfb.
    for each dfb where dfb.gl = 105100 or dfb.gl = 105210 or dfb.gl = 105220 no-lock:
        find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = dfb.dfb and sub-cod.d-cod = "clsa" no-lock no-error.
        if avail sub-cod and sub-cod.ccode <> "msc" then next.

        v-inbal = get_amt(dfb.dfb, dfb.gl, v-dtbeg - 1, dfb.crc).
        v-debet = get_dam(dfb.dfb, v-dtend, dfb.crc) - get_dam(dfb.dfb, v-dtbeg - 1, dfb.crc).
        v-cred = get_cam(dfb.dfb, v-dtend, dfb.crc) - get_cam(dfb.dfb, v-dtbeg - 1, dfb.crc).

        if v-dtend = g-today then do:
            for each remtrz where /*remtrz.rdt = g-today and*/ remtrz.cracc = dfb.dfb no-lock:
                find first que where que.remtrz = remtrz.remtrz and (que.pid = 'STW' or que.pid = 'SWS') no-lock no-error.
                if not avail que then next.
                v-cred = v-cred + remtrz.amt.
            end.
        end.
        if v-inbal > 0 or v-debet > 0 or v-cred > 0 then do:
            find first crc where crc.crc = dfb.crc no-lock no-error.
            find first bankl where bankl.bank = dfb.bank no-lock no-error.
            create t-dfb.
            assign t-dfb.acc = dfb.dfb
                   t-dfb.bankname = if avail bankl and trim(bankl.bic) <> '' then dfb.name + '(' + bankl.bic + ')' else dfb.name
                   t-dfb.crccode = if avail crc then crc.code else ''
                   t-dfb.inbal = v-inbal
                   t-dfb.inbalkzt = if avail crc and crc.crc <> 1 then t-dfb.inbal * crc.rate[1] else t-dfb.inbal
                   t-dfb.debet = v-debet
                   t-dfb.debet_kzt = if avail crc and crc.crc <> 1 then t-dfb.debet * crc.rate[1] else t-dfb.debet
                   t-dfb.cred = v-cred.

                   t-dfb.cred_kzt = if avail crc and crc.crc <> 1 then t-dfb.cred * crc.rate[1] else t-dfb.cred.
                   t-dfb.outbal = t-dfb.inbal + t-dfb.debet - t-dfb.cred.
                   t-dfb.outbalkzt = if avail crc and crc.crc <> 1 then t-dfb.outbal * crc.rate[1] else t-dfb.outbal.
        end.
    end.
    find first t-dfb no-lock no-error.
    if avail t-dfb then do:
        output stream   outstrem to rep.htm.
        {html-title.i
         &stream = " stream outstrem "
         &size-add = "xx-"
         &title = " "
        }
         put stream outstrem unformatted
         "<p><B>Мониторинг движений денежных потоков через корреспондентские счета<BR>Консолидированный отчет" skip
         "за период с" + string(v-dtbeg,'99/99/9999') + " по " + string(v-dtend,'99/99/9999') + "</B></p><BR><BR>" skip.
         put stream outstrem unformatted
         "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
         "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
         "<TD>Наименование <br>Банка (Swift)</TD>" skip
         "<TD>Номер корр.счета</TD>" skip
         "<TD>Валюта</TD>" skip
         "<TD>Входящий остаток</TD>" skip
         "<TD>Обороты по дебету </TD>" skip
         "<TD>Обороты по кредиту </TD>" skip
         "<TD>Исходящий остаток</TD>" skip
         "<TD>Входящий остаток <br>в эквиваленте тенге</TD>" skip
         "<TD>Обороты по дебету <br>в эквиваленте тенге</TD>" skip
         "<TD>Обороты по кредиту <br>в эквиваленте тенге</TD>" skip
         "<TD>Исходящий остаток <br>в эквиваленте тенге</TD></TR>" skip.
        for each t-dfb no-lock break by t-dfb.crccode:
            if first-of(t-dfb.crccode) then
            assign v-totinbal = 0
                   v-totinbal_kzt = 0
                   v-totdebet = 0
                   v-totdebet_kzt = 0
                   v-totcred = 0
                   v-totcred_kzt = 0
                   v-totoutbal = 0
                   v-totoutbal_kzt = 0.

            put stream outstrem unformatted "<tr>" skip
            "<td>" t-dfb.bankname "</td>" skip
            "<td>`" t-dfb.acc "</td>" skip
            "<td>" t-dfb.crccode "</td>" skip
            "<td>" replace(string(t-dfb.inbal,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfb.debet,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfb.cred,'>>>>>>>>>>>>>9.99'),'.',',')  "</td>" skip
            "<td>" replace(string(t-dfb.outbal,'->>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfb.inbalkzt,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfb.debet_kzt,'>>>>>>>>>>>>>9.99'),'.',',')"</td>" skip
            "<td>" replace(string(t-dfb.cred_kzt,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfb.outbalkzt,'->>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.

            assign v-totinbal = v-totinbal + t-dfb.inbal
                   v-totinbal_kzt = v-totinbal_kzt + t-dfb.inbalkzt
                   v-totdebet = v-totdebet + t-dfb.debet
                   v-totdebet_kzt = v-totdebet_kzt + t-dfb.debet_kzt
                   v-totcred = v-totcred + t-dfb.cred
                   v-totcred_kzt = v-totcred_kzt + t-dfb.cred_kzt
                   v-totoutbal = v-totoutbal + t-dfb.outbal
                   v-totoutbal_kzt = v-totoutbal_kzt + t-dfb.outbalkzt.
            if last-of(t-dfb.crccode) then do:
                put stream outstrem unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                "<td colspan = 3> Итого по " + t-dfb.crccode + "</td>" skip
                "<td>" replace(string(v-totinbal,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string(v-totdebet,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string(v-totcred,'>>>>>>>>>>>>>9.99'),'.',',')  "</td>" skip
                "<td>" replace(string(v-totoutbal,'->>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string(v-totinbal_kzt,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string( v-totdebet_kzt,'>>>>>>>>>>>>>9.99'),'.',',')"</td>" skip
                "<td>" replace(string(v-totcred_kzt,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string(v-totoutbal_kzt,'->>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.
            end.
        end.
        put stream outstrem unformatted "</table>" skip.
        {html-end.i}
        output stream outstrem close.
        unix silent value("cptwin rep.htm excel").
        unix silent rm -f  rep.htm.
        hide message no-pause.
    end.
end.

if v-sel = '2' then do:
    /*v-sel2 = ''.
    run sel2 (" Выбор: ", " 1. По счету | 2. По валюте | 3. Выход ", output v-sel2).
    if v-sel2  = '3' then return.*/

    /*if v-sel2 = '2' then do:*/
        update v-crccode with frame fcrc.
        hide frame fcrc.
        find first crc where crc.code = v-crccode no-lock no-error.
    /*end.*/


    repeat:
         update v-dfb with frame fdfb.
         find sub-cod where sub-cod.sub = "dfb" and sub-cod.acc = v-dfb and sub-cod.d-cod = "clsa" no-lock no-error.
         if avail sub-cod and sub-cod.ccode <> "msc" then message "Счет закрыт. Выберите другой счет" view-as alert-box.
         else leave.
    end.
    hide frame fdfb.

    message "Отчет формируется...".
    empty temp-table t-dfbrmz.
    if keyfunction (lastkey) = "end-error" then do:
        hide message no-pause.
        return.
    end.

    for each dfb where (dfb.dfb = v-dfb and v-dfb <> '') or (dfb.crc = crc.crc and v-dfb = '') no-lock:

        for each jl where jl.acc = dfb.dfb and jl.dc = 'C' and jl.jdt >= v-dtbeg and jl.jdt <= v-dtend no-lock:
            find first jh where jh.jh = jl.jh no-lock no-error.
            if jh.ref begins 'RMZ' then do:
                find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
                if not avail remtrz then next.
                find first que where que.remtrz = remtrz.remtrz no-lock no-error.
                if not avail que then next.
                find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                if not avail bankl then next.
            end.
            create t-dfbrmz.
            assign t-dfbrmz.dfb = dfb.dfb
                   t-dfbrmz.rmz = if jh.ref begins 'RMZ' then jh.ref else string(jh.jh)
                   t-dfbrmz.cred = jl.cam
                   t-dfbrmz.que = if jh.ref begins 'RMZ' then que.pid else ""
                   t-dfbrmz.naznpl = trim(jl.rem[1]) + ' ' + trim(jl.rem[2]) + ' ' + trim(jl.rem[3]) + ' ' + trim(jl.rem[4]) + ' ' + trim(jl.rem[5])
                   t-dfbrmz.nameben = if jh.ref begins 'RMZ' then remtrz.ord else ""
                   t-dfbrmz.bankben = if jh.ref begins 'RMZ' then bankl.name + (if bankl.bic <> '' then ' (' + bankl.bic + ')' else '') else ""
                   t-dfbrmz.num = jl.cam
                   t-dfbrmz.jdt = jh.jdt
                   t-dfbrmz.tim = jh.tim.
        end.
        for each jl where jl.acc = dfb.dfb and jl.dc = 'D' and jl.jdt >= v-dtbeg and jl.jdt <= v-dtend no-lock:
            find first jh where jh.jh = jl.jh no-lock no-error.
            if jh.ref begins 'RMZ' then do:
                find first remtrz where remtrz.remtrz = jh.ref no-lock no-error.
                if not avail remtrz then next.
                find first que where que.remtrz = remtrz.remtrz no-lock no-error.
                if not avail que then next.
                find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
                if not avail bankl then next.

            end.
            create t-dfbrmz.
            assign t-dfbrmz.dfb = dfb.dfb
                   t-dfbrmz.rmz = if jh.ref begins 'RMZ' then jh.ref else string(jh.jh)
                   t-dfbrmz.debet = jl.dam
                   t-dfbrmz.que = if jh.ref begins 'RMZ' then que.pid else ""
                   t-dfbrmz.naznpl = trim(jl.rem[1]) + ' ' + trim(jl.rem[2]) + ' ' + trim(jl.rem[3]) + ' ' + trim(jl.rem[4]) + ' ' + trim(jl.rem[5])
                   t-dfbrmz.nameben = if jh.ref begins 'RMZ' then remtrz.ord else ""
                   t-dfbrmz.bankben = if jh.ref begins 'RMZ' then bankl.name + (if bankl.bic <> '' then ' (' + bankl.bic + ')' else '') else ""
                   t-dfbrmz.num = jl.dam
                   t-dfbrmz.jdt = jh.jdt
                   t-dfbrmz.tim = jh.tim.

        end.
        if v-dtend = g-today then do:
            for each remtrz where remtrz.cracc = v-dfb /*and remtrz.rdt = v-dtbeg*/ no-lock:
                find first que where que.remtrz = remtrz.remtrz and (que.pid = 'STW' or que.pid = 'SWS') no-lock no-error.
                if not avail que then next.
                find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
                if not avail bankl then next.

                create t-dfbrmz.
                assign t-dfbrmz.dfb = dfb.dfb
                       t-dfbrmz.rmz = remtrz.remtrz
                       t-dfbrmz.cred = remtrz.amt
                       t-dfbrmz.que = que.pid
                       t-dfbrmz.naznpl = remtrz.detpay[1] + ' ' + remtrz.detpay[2] + ' ' + remtrz.detpay[3] + ' ' + remtrz.detpay[4]
                       t-dfbrmz.nameben = remtrz.bn[1]
                       t-dfbrmz.bankben = bankl.name + (if bankl.bic <> '' then ' (' + bankl.bic + ')' else '')
                       t-dfbrmz.num = remtrz.amt.

            end.
        end.
    end.
    find first t-dfbrmz no-lock no-error.
    if avail t-dfbrmz then do:

        output stream   outstrem to rep.htm.
        {html-title.i
         &stream = " stream outstrem "
         &size-add = "xx-"
         &title = " "
         }
        put stream outstrem unformatted
        "<p><B>Мониторинг движений денежных потоков через корреспондентские счета<BR>Расшифровка по счету" skip
        "за период с " + string(v-dtbeg,'99/99/9999') + " по " + string(v-dtend,'99/99/9999') + "<BR>" skip.

        for each t-dfbrmz no-lock break by t-dfbrmz.dfb:
            find first dfb where dfb.dfb = t-dfbrmz.dfb no-lock no-error.
            if first-of(t-dfbrmz.dfb) then do:
                v-totinbal = get_amt(dfb.dfb, dfb.gl, v-dtbeg - 1, dfb.crc).
                 put stream outstrem unformatted
                "<br><br>Номер счета " dfb.dfb  + "<br>Счет банка "  + dfb.name "</B></p>" skip
                "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
                "<TR align=""left"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
                "<td colspan = 2>Входящий<br>остаток</td>" skip
                "<td colspan = 6 >" replace(string(v-totinbal,'>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip
                "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
                "<TD>1</TD><TD>2</TD><TD>3</TD><TD>4</TD><TD>5</TD><TD>6</TD><TD>7</TD><TD>8</TD>" skip
                "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
                "<TD>Номер<br>транзакции</TD>" skip
                "<TD>Дата и время<br>транзакции</TD>" skip
                "<TD>Обороты<br>по дебету </TD>" skip
                "<TD>Обороты<br>по кредиту</TD>" skip
                "<TD>Cтатус</TD>" skip
                "<TD>Банк получатель/отправитель</td>"
                "<TD>Наименование<br>отправителя/получателя</TD>" skip
                "<TD>Назначение платежа</TD></tr>" skip.
                assign v-totdebet = 0
                       v-totcred = 0.
            end.

            assign v-totdebet = v-totdebet + t-dfbrmz.debet
                   v-totcred = v-totcred + t-dfbrmz.cred.
            put stream outstrem unformatted "<tr>" skip
            "<td>" t-dfbrmz.rmz "</td>" skip
            "<td>" if t-dfbrmz.jdt <> ? then string(t-dfbrmz.jdt,'99/99/9999') + ' ' + string(t-dfbrmz.tim,'HH:MM:SS')  else '' "</td>" skip
            "<td>" replace(string(t-dfbrmz.debet,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" replace(string(t-dfbrmz.cred,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
            "<td>" t-dfbrmz.que "</td>" skip
            "<td>" t-dfbrmz.bankben "</td>" skip
            "<td>" t-dfbrmz.nameben "</td>" skip
            "<td>" t-dfbrmz.naznpl "</td>" skip.
            if last-of(t-dfbrmz.dfb) then do:
            put stream outstrem unformatted
                "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
                "<td colspan = 2>ИТОГО</td>" skip
                "<td>" replace(string(v-totdebet,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td>" replace(string(v-totcred,'>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
                "<td></td><td></td><td></td><td></td>" skip
                "<TR align=""left"" valign=""center"" style=""font:bold"";font-size:12 bgcolor=""#C0C0C0"">" skip
                "<td colspan = 2>Исходящий<br>остаток</td>" skip
                "<td colspan = 6 >" replace(string(v-totinbal + v-totdebet - v-totcred,'->>>>>>>>>>>>>9.99'),'.',',') "</td></tr></table>" skip.
            end.
        end.
        {html-end.i}
        output stream outstrem close.
        unix silent value("cptwin rep.htm excel").
        unix silent rm -f  rep.htm.


    end.
    else do:
        if v-dfb <> '' then message "По счету " + v-dfb + " не было оборотов за выбранный период" view-as alert-box.
        if v-dfb = '' then message "По валюте " + v-crccode + " не было оборотов за выбранный период" view-as alert-box.
        return.
    end.
    hide message no-pause.
end.
