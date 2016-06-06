/* r-knsf.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Книга налоговых счетов-фактур
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-4-9
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - поставила в конце вывод в menu-prt
        06.07.2004 kanat   - добавил вывод месячных счетов - фактур коммерсантов
        08.07.2004 kanat   - карточные счета - фактуры идут без НДС
        31/01/05   marinav - проверка ГК в sub-cod - с НДС или без НДС , и выводить только с НДС
        06/09/06   marinav - перестроены циклы по fakturis
        15.03.10   marinav - после 15 марта в номер добавлять код филиала
        11.07.2012 damir   - добавил группирование по номеру Фактуры.
        15.11.2012 Lyubov  - для счета-фактуры, которая формируются по коду комиссии 057, выводится jdt
        28.11.2012 damir - Внедрено Т.З. № 1588.
        05.02.2012 damir - Исправил ошибку которая была до изменения 11.07.2012. Все поправлено.
        12.10.2013 dmitriy - ТЗ 1526. Включение счетов-фактур по комиссиям за ЭЦП в реестр по реализации
*/

{mainhead.i}
{comm-txb.i}

def var v-dt1 as date.
def var v-dt2 as date.
def var npk as inte.
def var k-sm as deci extent 3.
def var v-name as char.
def var v-name1 as char.
def var v-jss like cif.jss.
def var druka as logi init false.
def var v-nds% as deci.
def var v-pvn as deci.
def var v-neto as deci.
def var v-gl as inte.
def var v-txb as char.
def var v-addlog as logi.

define stream s1.

find sysc where sysc = "nds" no-lock no-error.
if avail sysc then v-nds% = sysc.deval.

v-dt2 = date(month(g-today),1,year(g-today)) - 1.
v-dt1 = date(month(v-dt2),1,year(v-dt2)).
display v-dt1 format "99/99/9999" label "С..."
        v-dt2 format "99/99/9999" label "По...".
update v-dt1 v-dt2.
if v-dt2 > g-today or v-dt1 > v-dt2
then undo,retry.


output stream s1 to rpt.img.
put stream s1 "КНИГА РЕГИСТРАЦИИ НАЛОГОВЫХ СЧЕТОВ-ФАКТУР" at 45 skip.
put stream s1 "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip.
put stream s1 "      :   Дата   :        Н а и м е н о в а н и е         :     РНН    :  Номер и :   Стоимость  :Ставка:     Сумма    :     Общая     : Номер       :  Менеджер :  Счет  :" skip.
put stream s1 " П/п  :  выписки :          п о к у п а т е л я           : покупателя :дата дого-: поставки без : НДС, :      НДС,    :   стоимость   : фактуры     :           : доходов:  " skip.
put stream s1 "      :   НСФ    :                                        :            :вора (кон-:  НДС, тенге  :  %   :     тенге    :   поставки    :             :           :        : " skip.
put stream s1 "      :          :                                        :            :тракта) на:              :      :              :               :             :           :        : " skip.
put stream s1 "      :          :                                        :            : поставку :              :      :              :               :             :           :        : " skip.
put stream s1 "      :          :                                        :            :  товаров :              :      :              :               :             :           :        : " skip.
put stream s1 "      :          :                                        :            :  (работ, :              :      :              :               :             :           :        : " skip.
put stream s1 "      :          :                                        :            :  услуг)  :              :      :              :               :             :           :        : " skip.
put stream s1 "------:----------:----------------------------------------:------------:----------:--------------:------:--------------:---------------:--------------------------------------" skip.


npk = 0.
k-sm[1] = 0.
k-sm[2] = 0.
k-sm[3] = 0.

{Inter-Branch.i "new"} /*shared parameters*/

for each fakturis where fakturis.rdt >= v-dt1 and fakturis.rdt <= v-dt2 and substring(fakturis.sts,3,1) = "O" and
fakturis.info[1] = "FILPAYMENT" no-lock by rdt descending:
    find first comm.filpayment where comm.filpayment.jhcom = fakturis.jh and trim(comm.filpayment.bankfrom) = trim(fakturis.info[2]) no-lock no-error.
    if avail comm.filpayment then do:
        if lookup(trim(comm.filpayment.bankfrom),trim(v_TXB)) = 0 then do:
            if v_TXB <> "" then v_TXB = v_TXB + ',' + trim(comm.filpayment.bankfrom).
            else v_TXB = trim(comm.filpayment.bankfrom).
        end.
        create t-work.
        t-work.txb = comm.filpayment.bankfrom.
        t-work.docnum = comm.filpayment.jou.
        t-work.jh = comm.filpayment.jhcom.
    end.
end.

/*-----Сбор данных в филиалах, в которых были межфилиальные операции------*/

{r-branchSEL.i &proc = "str_strx_txb"}

/*------------------------------------------------------------------------*/
nextFAKTURIS:
for each fakturis where fakturis.rdt >= v-dt1 and fakturis.rdt <= v-dt2 no-lock break by fakturis.rdt:
    if substr(fakturis.sts,3,1) ne "O" then next nextFAKTURIS.

    v-name = "". v-jss = "". v-pvn = 0. v-neto = 0. v-nds% = 0. v-gl = 0. v-addlog = false.

    find cif where cif.cif = fakturis.cif no-lock no-error.
    if avail cif then do:
        v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
        v-jss = cif.jss.
    end.
    else do:
        find first arp where arp.arp = fakturis.acc no-lock no-error.
        if avail arp then v-name = arp.des.
    end.
    if fakturis.info[1] = "FILPAYMENT" then do:
        for each t-InterBrh where t-InterBrh.jh = fakturis.jh and t-InterBrh.txb = fakturis.info[2] no-lock:
            if string(t-InterBrh.gl) begins '4' or t-InterBrh.gl = 287082 then v-gl = t-InterBrh.gl.
            v-addlog = t-InterBrh.rem[1] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            t-InterBrh.rem[2] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            t-InterBrh.rem[3] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            t-InterBrh.rem[4] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            t-InterBrh.rem[5] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*".
            if v-addlog and t-InterBrh.ln = fakturis.ln then v-gl = t-InterBrh.gl.
        end.
    end.
    else do:
        for each jl where jl.jh = fakturis.jh no-lock:
            if string(jl.gl) begins '4' or jl.gl = 287082 then v-gl = jl.gl.
            v-addlog = jl.rem[1] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            jl.rem[2] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            jl.rem[3] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            jl.rem[4] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*" or
            jl.rem[5] matches "*Комиссия за выпуск электронной цифровой подписи (ЭЦП)*".
            if v-addlog and jl.ln = fakturis.ln then v-gl = jl.gl.
        end.
    end.
    find first sub-cod where sub-cod.sub = "gld" and sub-cod.acc = string(v-gl) and sub-cod.d-cod = "ndcgl" and sub-cod.ccode = "01" no-lock no-error .
    if avail sub-cod or v-addlog then do:
        v-pvn = fakturis.pvn.
        v-neto = fakturis.neto.
        npk = npk + 1.
        k-sm[1] = k-sm[1] + v-neto.
        k-sm[2] = k-sm[2] + v-pvn.
        k-sm[3] = k-sm[3] + fakturis.amt.

        run rin-dal(input-output v-name,output v-name1,40).

        put unformatted skip.

        if fakturis.rdt < 01/01/2009 then v-nds% = 0.13.
        else do:
            find sysc where sysc = "nds" no-lock no-error.
            if avail sysc then v-nds% = sysc.deval. else v-nds% = 0.12.
        end.
        if fakturis.rdt > 03/15/2010 then v-txb = substr(comm-txb(),4,2).
        else v-txb = "  ".
        find first jh where jh.jh = fakturis.jh no-lock no-error.
        if avail jh and jh.party <> '057' then
        put stream s1
            npk format "zzzzz9" ":"
            fakturis.rdt format "99/99/9999" ":"
            v-name1 format "x(40)" ":"
            v-jss format "x(12)" ":"
            "          :"
            v-neto format ">>>,>>>,>>9.99" ":"
            (v-nds% * 100) format "zz9.99" ":"
            v-pvn  format ">>>,>>>,>>9.99" ":"
            fakturis.amt  format ">>>,>>>,>>9.99" " :"
            string(fakturis.faktura,"zzzzzzzz9") format "x(9)" v-txb format "x(2)"  "  :  "
            fakturis.who  " : "
            v-gl format ">>>>>9" skip.
        else
        put stream s1
            npk format "zzzzz9" ":"
            fakturis.jdt format "99/99/9999" ":"
            v-name1 format "x(40)" ":"
            v-jss format "x(12)" ":"
            "          :"
            v-neto format ">>>,>>>,>>9.99" ":"
            (v-nds% * 100) format "zz9.99" ":"
            v-pvn  format ">>>,>>>,>>9.99" ":"
            fakturis.amt  format ">>>,>>>,>>9.99" " :"
            string(fakturis.faktura,"zzzzzzzz9") format "x(9)" v-txb format "x(2)"  "  :  "
            fakturis.who  " : "
            v-gl format ">>>>>9" skip.

        do while trim(v-name) <> "":
            run rin-dal(input-output v-name,output v-name1,40).
            put stream s1 "      :          :"
            v-name1 format "x(40)" ":"
            "            :          :              :      :"
            "              :               :" skip.
        end.
    end.
end.
put stream s1
    "      : И Т О Г О:                                        :"
    "            :          :"
    k-sm[1] format ">>>,>>>,>>9.99" ":"
    "      :"
    k-sm[2] format ">>>,>>>,>>9.99" ":"
    k-sm[3] format ">>>,>>>,>>9.99" skip.
put stream s1
    "---------------------------------------------------------"
    "----------------------------------------------"
    "--------------------------------------------------------------------" skip.
put stream s1 chr(12).
output stream s1 close.

pause 0.
run menu-prt('rpt.img').
