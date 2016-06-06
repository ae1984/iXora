/* r-cash3.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
	Общийй отчет по проведенным кассовым операциям 100110
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        13/12/10 marinav
        15/02/2011 Luiza добавила отражение внебаланса согласно тз 850.
        17.02.2011 Luiza закомментировала старый внебаланс
        22.02.2011 Luiza убрала отступы двух пустых строк перед подписями для размещения таблицы на одной странице
        05.05.2011 Luiza добавила арп счета по залоговым документам
        14.05.2011 Luiza добавила арп счета по бланкам гарантий актюб обл
        20.05.2011 Luiza согласно СЗ добавила новые арп счета по выданным гарантиям
        16.06.2011 Luiza добавила в СП Туркестан новый арп счет ГК 733910 Прочие  ценности  KZ52470147339A020215
        21.06.2011 Luiza внебаланс по носителям ключей
        05.07.2011 Luiza внебаланс KZ56470147339A030716  Залоговые документы ЦО
        08.07.2011 Luiza заменила  Туркестан СП1 внебаланс носители ключей kz52470147339A020215 на KZ84470147339A020415
        15.09.2011 Lyubov исправила процедуру addit, а именно cashf.crc = 99, вместо 9
        03.11.2011 lyubov - в базе Чимкента добавила возможность выбора поздразделения
        04.11.2011 lyubov - исправила обороты
        21.12.2011 aigul - добавила 733920 движение по счету ARP kz34470147339a018405
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        24.07.2012 Lyubov - добавила ARP для 733910 Платежные карты к выдаче
        25.07.2012 Lyubov - в АФ менеджер видит данные только по своему ЦОКу
        27.07.2012 Lyubov - перенесла счета для ЦОК в r-cash9
        29.08.2012 Lyubov - исправила ошибку, в ARP-счете была звездочка
        28.06.2013 Lyubov - ТЗ № 1859, перенесла список внебалансовых счетов в справочник codfr "casvnbal"
 * CHANGES
*/
{nbankBik.i}
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-ln    like aal.ln    no-undo.
def var m-dc    like jl.dc    no-undo.
def var m-sumd  like aal.amt   no-undo.
def var m-sumk  like aal.amt   no-undo.
def var m-damk  as inte   no-undo.
def var m-camk  as inte   no-undo.
def var m-cashgl like jl.gl    no-undo.
def var v-bnk as char.
def var v-acc1 as char.
def var v-acc2 as char.
def var v_des as char.
def var v-dep as int.
def var v_pr as int.
def var vdpt as inte.
def var lg as logi.
def var i as int.

def temp-table cashf
    field crc like crc.crc
    field des as char
    field bal like glbal.dam
    field dam like glbal.dam
    field damk as inte
    field cam like glbal.cam
    field camk as inte.

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
v-bnk = trim(sysc.chval).

def var v-from as date .
    v-from = g-today.
    update   v-from label "  Дата отчета"  help " Задайте дату отчета" skip
    with row 8 centered  side-label frame opt title "Сводная справка по счету 100110".
    hide frame  opt.
   m-cashgl = 100110.

/* для шимкента определяем сп  */
if v-bnk = "TXB15" then do:
    find last ofchis where ofchis.ofc = g-ofc and ofchis.regdt <= v-from use-index ofchis no-lock no-error.
    if avail ofchis then v-dep = ofchis.depart. else v-dep = 1.
    run sel2 ("Подразделение :", " 01 г.Шымкент ул. МОМЫШ.УЛЫ 25/1 | 02 СП-1 Туркестан ", output vdpt).
    hide message.
end.

if v-bnk = "TXB15" then do:
    find first jl where jl.jdt = v-from no-lock no-error.
    if available jl then do:
        for each jl  where jl.jdt = v-from and jl.depart = vdpt no-lock break by jl.crc by jl.jh by jl.ln :
            if first-of(jl.crc) then do:
                find crc where crc.crc = jl.crc no-lock no-error.
                m-sumd = 0. m-damk = 0.
                m-sumk = 0. m-camk = 0.
                m-ln = 0.
            end.
            if jl.gl = m-cashgl then do:
                if jl.dc eq "D" then do:
                    m-sumd = m-sumd + jl.dam.
                    if jl.jh ne m-ln then m-damk = m-damk + 1.
                    if jl.jh = m-ln and m-dc ne jl.dc then m-damk = m-damk + 1.
                end.
                else do:
                    m-sumk = m-sumk + jl.cam.
                    if jl.jh ne m-ln then m-camk = m-camk + 1.
                    if jl.jh = m-ln and m-dc ne jl.dc then m-camk = m-camk + 1.
                end.
                m-ln = jl.jh. m-dc = jl.dc.
            end.
            if last-of(jl.crc) then do:
                find first cashf where cashf.crc = jl.crc.
                cashf.dam  = cashf.dam  + m-sumd .
                cashf.cam  = cashf.cam  + m-sumk .
                cashf.damk = cashf.damk + m-damk .
                cashf.camk = cashf.camk + m-camk .
            end.
        end.
    end.
    m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
end.

if v-bnk <> "TXB15" then do:
    find first jl where jl.jdt = v-from no-lock no-error.
    if available jl then do:
        for each jl  where jl.jdt = v-from no-lock  break by jl.crc by jl.jh by jl.ln :
            if first-of(jl.crc) then do:
                find crc where crc.crc = jl.crc no-lock no-error.
                m-sumd = 0. m-damk = 0.
                m-sumk = 0. m-camk = 0.
                m-ln = 0.
            end.
            if jl.gl = m-cashgl then do:
                if jl.dc eq "D" then do:
                    m-sumd = m-sumd + jl.dam.
                    if jl.jh ne m-ln then m-damk = m-damk + 1.
                    if jl.jh = m-ln and m-dc ne jl.dc then m-damk = m-damk + 1.
                end.
                else do:
                    m-sumk = m-sumk + jl.cam.
                    if jl.jh ne m-ln then m-camk = m-camk + 1.
                    if jl.jh = m-ln and m-dc ne jl.dc then m-camk = m-camk + 1.
                end.
                m-ln = jl.jh. m-dc = jl.dc.
            end.
            if last-of(jl.crc) then do:
                find first cashf where cashf.crc = jl.crc.
                cashf.dam  = cashf.dam  + m-sumd .
                cashf.cam  = cashf.cam  + m-sumk .
                cashf.damk = cashf.damk + m-damk .
                cashf.camk = cashf.camk + m-camk .
            end.
        end.
    end.
    m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
end.

/*Lyubov - внебалансовые счета тянутся из справочника*/

if v-bnk = "TXB15" then find first codfr where codfr.codfr = 'casvnbal' and codfr.code = v-bnk + '-' + string(vdpt) no-lock no-error.
else find first codfr where codfr.codfr = 'casvnbal' and codfr.code = v-bnk no-lock no-error.

do i = 1 to num-entries(codfr.name[1]):
    v-acc1 = entry(i,(codfr.name[1])).
    find first arp where arp.arp = v-acc1 no-lock no-error.
    if avail arp then do:

    find first gl where gl.gl = arp.gl no-lock no-error.
    v_des = 'ГК ' + string(arp.gl) + ' &nbsp ' + gl.des + ' <br> ' + arp.des + ' <br> '.
    run addit (v-acc1, v_des).
    end.
end.

/* -----------------------------------------------------*/
if v-bnk = "TXB15" then do:
    find first ppoint where ppoint.depart = vdpt /*and ppoint.info[1] = 'cash'*/ no-lock no-error.
    find first cmp.
end.
else do:
    find first ppoint where ppoint.info[1] = 'cash' no-lock no-error.
    find first cmp.
end.

define stream rep.
output stream rep to cas.htm.

put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

for each crc where crc.sts ne 9 no-lock:
    v_pr = 0.
    run table1.
    if crc.crc = 1 then do:
        v_pr = 1.
        run table1.
        v_pr = 0.
    end.
end.

put stream rep "</body></html>" skip.
output stream rep close.
unix silent cptwin cas.htm winword.

procedure table1:
        put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
        put stream rep unformatted "<tr style=""font:bold"" ><td align=""center"" >Сводная справка о кассовых оборотах за день за " string(v-from) " г. <BR>".
        put stream rep unformatted "</td></tr>" skip.
        put stream rep "</table>" skip.
        put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"
                  "<td align=""left"" >" cmp.name    format 'x(79)' "</td></tr>"
                  "<tr></tr>"
        skip.
        if v-bnk = "TXB16" or v-bnk = "TXB15" then do:
            put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr>"
                  "<td align=""left"" >" ppoint.name    format 'x(79)' "</td></tr>"
                  "<tr></tr>"
                  "<tr> <td>  </td> </tr>"
            skip.
            put stream rep "</table>" skip.
        end.
        put stream rep "</table>" skip.


        put stream rep unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td align=""center"" rowspan=2>Наименование <br> ценностей</td>"
                  "<td align=""center"" rowspan=2>Код <br> вал</td>"
                  "<td rowspan=2>Остаток на <br> начало дня</td>"
                  "<td colspan=2>Приход</td>"
                  "<td colspan=2>Расход</td>"
                  "<td rowspan=2>Остаток на <br> конец дня</td>"
                  "</tr>"
        skip.

        put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "</tr>"
        skip.
        if v_pr = 0 then do:
            find first cashf where cashf.crc = crc.crc no-lock no-error.

            if v-bnk = "TXB15" then do:  /* для Чимкента остаток на начало дня берем из bank.caspoint */
                find last bank.caspoint where  bank.caspoint.depart = vdpt and bank.caspoint.rdt < v-from and bank.caspoint.crc = crc.crc and bank.caspoint.info[1] = string(m-cashgl) no-lock no-error.
                if available bank.caspoint then
                    put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                           "<td align=""center"">" crc.code "</td></b>"
                           "<td align=""center"">" crc.crc "</td>"
                           "<td>" bank.caspoint.amount format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.damk "</td>"
                           "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.camk "</td>"
                           "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" (bank.caspoint.amount + (cashf.dam - cashf.cam)) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                           "</tr>".

                else
                    put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                           "<td align=""center"">" crc.code "</td></b>"
                           "<td align=""center"">" crc.crc "</td>"
                           "<td>" 0.00 format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.damk "</td>"
                           "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.camk "</td>"
                           "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" (cashf.dam - cashf.cam) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                           "</tr>".
            end. /* end if v-bnk = "TXB15"  */
            else do:
                find last glday where glday.gl = m-cashgl and glday.crc = crc.crc and glday.gdt < v-from no-lock no-error.
                if available glday then
                put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                           "<td align=""center"">" crc.code "</td></b>"
                           "<td align=""center"">" crc.crc "</td>"
                           "<td>" glday.bal format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.damk "</td>"
                           "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" cashf.camk "</td>"
                           "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" (glday.bal + (cashf.dam - cashf.cam)) format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "</tr>".
                else
                put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">"
                           "<td>" crc.code "</td>"
                           "<td></td>" skip
                           "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td></td>" skip
                           "</tr>".
            end.
        end.

        if v_pr = 1 then do:
            if v-bnk = "TXB15" then do:  /* для Чимкента остаток на начало дня берем из bank.caspoint */
                find last bank.caspoint where  bank.caspoint.depart = vdpt and bank.caspoint.rdt < v-from and bank.caspoint.crc = crc.crc and bank.caspoint.info[1] = string(m-cashgl) no-lock no-error.
                if available bank.caspoint then do:
                    for each cashf where cashf.crc = 99 no-lock.
                        if cashf.des matches "*Бланки строгой отчетности*"
                              then put stream rep unformatted "<tr align=""right"" style=""font-size:8.0pt"">".
                              else put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">".
                              put stream rep unformatted
                                  "<td align=""center"">" cashf.des "</td>"
                                  "<td align=""center"">" crc.crc "</td>"
                                  "<td>" cashf.bal format ">>>,>>>,>>>,>>9.99" "</td>" skip
                                  "<td align=""center"">" cashf.damk "</td>"
                                  "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                                  "<td align=""center"">" cashf.camk "</td>"
                                  "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                                  "<td>" (cashf.bal + (cashf.dam - cashf.cam)) format ">>>,>>>,>>>,>>9.99" "</td>" skip
                                  "</tr>".
                    end.
                end.
            end.
            if v-bnk <> "TXB15" then do:
                for each cashf where cashf.crc = 99 no-lock.
                    if cashf.des matches "*Бланки строгой отчетности*"
                          then put stream rep unformatted "<tr align=""right"" style=""font-size:8.0pt"">".
                          else put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">".
                          put stream rep unformatted
                              "<td align=""center"">" cashf.des "</td>"
                              "<td align=""center"">" crc.crc "</td>"
                              "<td>" cashf.bal format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td align=""center"">" cashf.damk "</td>"
                              "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td align=""center"">" cashf.camk "</td>"
                              "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "<td>" (cashf.bal + (cashf.dam - cashf.cam)) format ">>>,>>>,>>>,>>9.99" "</td>" skip
                              "</tr>".
                end.
            end.
        end.

    put stream rep "</table>" skip.
    put stream rep unformatted "<table width=100% cellpadding=""7"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr >"
                  "<td colspan=3>Заведующий кассой ______________</td><td ></td><td colspan=3>Обороты сверены с балансовыми <br> данными (лицевым счетом)</td>"
                  "</tr>"
                  "<tr >"
                  "<td align=""center"" colspan=3>(подпись)</td><td ></td><td colspan=3>______________________</td>"
                  "</tr>"
                  "<tr >"
                  "<td colspan=3></td><td ></td><td colspan=3>(подпись бухгалтера)</td>"
                  "</tr></table>"
                  skip.
    put stream rep "<br clear=all style='page-break-before:always'>" skip.
end procedure.

procedure addit:
    def input parameter v_acc1 as char.
    def input parameter v_des as char.

    m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
    for each jl  where jl.jdt = v-from  and jl.acc = v-acc1 no-lock  break by jl.jh by jl.ln :
            if jl.dc eq "D" then do:
                m-sumd = m-sumd + jl.dam.
                if jl.jh ne m-ln then m-damk = m-damk + 1.
            end.
             else do:
                m-sumk = m-sumk + jl.cam.
                if jl.jh ne m-ln then m-camk = m-camk + 1.
             end.
             m-ln = jl.jh.
    end.
    find last histrxbal where histrxbal.subled = 'arp' and histrxbal.acc = v-acc1 and histrxbal.level = 1 and histrxbal.crc = 1 and histrxbal.dt < v-from no-lock no-error.
    create cashf.
    cashf.crc = 99.
    cashf.des = v_des + v-acc1.
    if avail histrxbal then cashf.bal = histrxbal.dam - histrxbal.cam.
    cashf.dam  = cashf.dam  + m-sumd .
    cashf.cam  = cashf.cam  + m-sumk .
    cashf.damk = cashf.damk + m-damk .
    cashf.camk = cashf.camk + m-camk .
end procedure.