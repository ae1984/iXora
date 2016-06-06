/* r-cash91.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Общий отчет по проведенным кассовым операциям 100100 в разрезе СПФ и доп ARP счетами согласно приложения в ТЗ № 850.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK COMM
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31.08.2012 Lyubov - скопировала из программы r-cash9
        04.09.2012 Lyubov - исправила: при поиске в таблице cslist указала cbo_dep
        11.09.2012 Lyubov - исправила подсчет количества документов
        30.09.2013 damir - Внедрено Т.З. № 1496.
 * CHANGES
*/
{get-dep.i}.
{nbankBik.i}
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-ln    like aal.ln    no-undo.
def var m-dc    like jl.dc    no-undo.
def var m-bal  as int init 0. /* признак кассы, наличия остатка на начало дня */
def var m-sumd  like aal.amt   no-undo.
def var m-sumk  like aal.amt   no-undo.
def var m-damk  as inte   no-undo.
def var m-camk  as inte   no-undo.
def var v-crclist  as char   no-undo.
def var m-cashgl like jl.gl    no-undo.
def var v-bnk as char.
def var v-acc1 as char.
def var v_des as char.
def var cbo as char.
def var cbo_dep as int.
def var ll as char no-undo.
def var ll_dep as char no-undo.
def var ll_who as char no-undo.
def var v_dep as int no-undo.
def var v-from as date init today.

define temp-table wrk1 no-undo
    field gl  like jl.gl
    field jh  like jl.jh
    field dam like jl.dam
    field cam like jl.cam
    field crc like jl.crc
    field who like jl.who
    field tim as char
    field tel like jl.teller
    field rem as char
    field dc  like jl.dc
    field cd  as   inte
    field acc like jl.acc
    index ind is PRIMARY cd cam dam.

def var dam like jl.dam.
def var cam like jl.dam.

define stream rep.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
v-bnk = trim(sysc.chval).

DEFINE VARIABLE cboname AS char FORMAT "x(20)"
       VIEW-AS COMBO-BOX list-items "".
ll = "".
ll_dep = "".
find first ppoint no-lock no-error.
cbo_dep = ppoint.dep.
cbo = entry(1,trim(ppoint.name)).

for each ppoint  no-lock.
    ll = ll + entry(1,trim(ppoint.name)) + ",".
    ll_dep = ll_dep + string(ppoint.dep) + ",".
end.
ll = substring(ll,1,length(ll) - 1).
ll_dep = substring(ll_dep,1,length(ll_dep) - 1).

def temp-table t-jl
    field dc  like jl.dc
    field crc like jl.crc
    field acc like jl.acc
    field dam like jl.dam
    field cam like jl.cam
    field damk like jl.dam
    field camk like jl.cam
index acc is primary acc crc.

for each codfr where codfr.codfr = 'ekcrc' no-lock:
    v-crclist = v-crclist + string(codfr.code) + ','.
end.
v-crclist = right-trim(v-crclist,',').

find sysc where sysc.sysc = 'CASHGL500' no-lock no-error.
if not avail sysc then message "Нет записи CASHGL в sysc".
else do:
    m-cashgl = sysc.inval.
    def frame opt
        v-from label "  Дата отчета"  help " Задайте дату отчета" skip(1)
        cboname label "  СПФ " help " Выберите СПФ, для вывода списка стрелка вниз, для выбора ENTER" skip
    with side-labels centered row 7 title "Параметры отчета".

    cboname:LIST-ITEMS IN FRAME opt = ll.
    ON VALUE-CHANGED OF cboname
    DO:
        cbo = ENTRY(SELF:LOOKUP(SELF:SCREEN-VALUE),ll).
    END.

    on end-error of cboname in frame opt do:
        hide frame opt.
        undo, return.
    end.
    on end-error of v-from in frame opt do:
    end.

    on return of cboname  in frame opt do:
        m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
        cbo_dep = integer(entry(lookup(cbo,ll),ll_dep)).
        m-cashgl = sysc.inval.
        find first ppoint where ppoint.dep = cbo_dep no-lock no-error.
        if ppoint.info[1] = 'cash' then m-bal = 1.
        else m-bal = 0.

        for each sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.ccode begins 'CASH' no-lock:
            cam = 0. dam = 0.
            for each jl where jl.jdt = v-from and lookup(string(jl.crc),v-crclist) > 0 and jl.acc = sub-cod.acc and jl.depart = cbo_dep no-lock break by jl.acc by jl.crc by jl.jh by jl.ln:
                find arp where arp.arp = jl.acc no-lock no-error.
                if avail arp then do:
                    find first t-jl where t-jl.acc = caps(sub-cod.ccode) and t-jl.crc = jl.crc no-error.
                    if not avail t-jl then do:
                        find crc where crc.crc = jl.crc no-lock no-error.
                        create t-jl.
                        t-jl.acc = caps(sub-cod.ccode).
                        t-jl.crc = crc.crc.
                    end.
                end.
                if jl.gl = m-cashgl then do:
                    ll_who = jl.who.
                    v_dep = get-dep (ll_who, v-from).
                    if cbo_dep = v_dep then do:
                        if not (jl.rem[1] + jl.rem[2] matches "*обмен валюты*") then
                        find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and not (wrk1.rem matches "*обмен валюты*")  no-error.
                        else
                        find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and wrk1.rem matches "*обмен валюты*"  no-error.
                        if not available wrk1 then do:
                            create wrk1.
                            wrk1.jh  = jl.jh.
                            wrk1.gl  = jl.gl.
                            wrk1.crc = jl.crc.
                            wrk1.dam = jl.dam.
                            wrk1.cam = jl.cam.
                            wrk1.dc  = jl.dc.
                            wrk1.acc = caps(sub-cod.ccode).
                            wrk1.rem = jl.rem[1] + jl.rem[2].
                        end.
                        else do:
                            wrk1.dam = wrk1.dam + jl.dam.
                            wrk1.cam = wrk1.cam + jl.cam.
                        end.
                        if jl.dc eq "D" then t-jl.dam = t-jl.dam + jl.dam.
                        else t-jl.cam = t-jl.cam + jl.cam.
                    end.
                end.
            end.
        end.
        /*for each t-jl no-lock:
            message t-jl.acc t-jl.crc t-jl.dam t-jl.cam view-as alert-box.
        end.*/
        find first ppoint where ppoint.dep = cbo_dep no-lock no-error.
        find first cmp no-lock.

        output stream rep to cas.htm.

        for each wrk1 no-lock break by wrk1.crc by wrk1.acc:
            find first t-jl where t-jl.acc = wrk1.acc and t-jl.crc = wrk1.crc exclusive-lock no-error.
            if avail t-jl then do:
                if wrk1.dc = 'D' then t-jl.damk = t-jl.damk + 1.
                else t-jl.camk = t-jl.camk + 1.
            end.
        end.

        put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        for each crc where lookup(string(crc.crc),v-crclist) > 0 no-lock:
            for each cslist where cslist.bank = v-bnk and inte(cslist.info[1]) = cbo_dep no-lock:
                find t-jl where t-jl.crc = crc.crc and t-jl.acc = cslist.nomer no-lock no-error.
                if not avail t-jl then next.
                else do:
                    put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                              "<tr style=""font:bold"" >"
                              "<td align=""center"" >" cmp.name    format 'x(79)' "</td></tr>"
                              "<tr></tr>"
                               skip.
                    put stream rep "</table>" skip.
                    put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                              "<tr>"
                              "<td align=""center"" >" ppoint.name    format 'x(79)' "</td></tr>"
                              "<tr></tr>"
                              "<tr> <td>  </td> </tr>"
                               skip.
                    put stream rep "</table>" skip.
                    put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.
                    put stream rep unformatted "<tr style=""font:bold"" ><td align=""center"" >Сводная справка о кассовых оборотах за день <BR>".
                    put stream rep unformatted "</td></tr>" skip.
                    put stream rep unformatted "<tr style=""font:bold"" >"
                                              "<td align=""center"" > за " string(v-from) " г. </td></tr>" skip.
                    put stream rep unformatted "<tr style=""font:bold"" >"
                                              "<td align=""center"" > ГК " m-cashgl " №" t-jl.acc "</td></tr>"  skip.
                    put stream rep "</table>" skip.
                    put stream rep unformatted "<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
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
                    put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                           "<td align=""center"">" crc.code "</td></b>"
                           "<td align=""center"">" crc.crc "</td>"
                           "<td>" 0.00 format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" t-jl.damk "</td>"
                           "<td>" t-jl.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td align=""center"">" t-jl.camk "</td>"
                           "<td>" t-jl.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                           "<td>" (t-jl.dam - t-jl.cam) format "->>>,>>>,>>>,>>9.99" "</td>" skip
                           "</tr>".
                    put stream rep "</table>" skip.
                    put stream rep unformatted "<br><br><table width=100% cellpadding=""7"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
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
                end.
            end.
        end.

        put stream rep "</body></html>" skip.
        output stream rep close.

        unix silent cptwin cas.htm winword.
    end. /* end on return of cboname */
    update v-from with frame opt.
    cboname = cbo.
    update  cboname FORMAT "x(30)" with frame opt.
end. /* end  if available sysc then do */