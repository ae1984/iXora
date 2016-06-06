/* lnppay.p
 * MODULE
        Частичное погашение
 * DESCRIPTION
        Частичное погашение
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.1.1
 * BASES
        BANK
 * AUTHOR
        23/08/10 aigul
 * CHANGES

*/
{global.i}

def shared var v-cif like cif.cif.
def shared var s-lon like lon.lon.
define var choice as logic.
define var log_date as logic.
def var v-name as char.
def var v-acc as char.
def var v-bal as deci.
def var v-newbal as deci.
def var v-i as integer.
def var v-od as deci.
def var v-lev as deci.
def var v-first as deci.
def var i as integer.
def var j as decimal.
def var sum2 as decimal.
def var v-sum as decimal.
def var v-com as decimal.
def var v-com1 as decimal.
def var v-comm as decimal.
def var v-sum2 as decimal.
def var v-sum3 as decimal.
def var v-ostsum as deci no-undo.
def var v-sum-gr as decimal.
def var v-sum-gr1 as decimal.
def var v-truncsum as decimal.
def var v-in-sum as decimal.
def var v-lnsch as decimal.
def var v-lnsci as decimal.


def var v-bal1 as deci no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def new shared var s-jh like jh.jh.
def var v-nxt as integer no-undo.

define frame f_pog
    v-cif     label  "Код клиента" skip
    v-acc     label  "Номер счета" format "x(20)" skip
    v-bal     label "Баланс на счету" format "->>>,>>>,>>>,>>>,>>9.99" skip
    v-sum3    label  "Доступная сумма для частичного погашени" format ">>>,>>>,>>>,>>>,>>9.99" skip
    space(7)
    with width 85 row 5 centered overlay side-labels.

define temp-table t-wrk no-undo
    field dat like lnsch.stdat
    field od1 as decimal
    field newdat as date
    field newod1 like lnsch.stval
    field vozn like lnsci.iv-sc
    field kom as deci
    field sled as deci
    field od2 as deci
    index idx is primary dat.

v-name = "".
v-acc = "".
v-bal = 0.
v-lev = 0.
v-com = 0.
v-com1 = 0.
sum2 = 0.
v-sum = 0.
v-od = 0.
v-sum2 = 0.
v-sum3 = 0.
v-sum-gr = 0.
v-sum-gr1 = 0.
v-in-sum = 0.

/* find cif */
find cif where cif.cif = v-cif no-lock no-error.
    if avail cif then v-name = cif.name.
/* find lon */
find first lon where lon.lon = s-lon and lon.cif = cif.cif  no-lock no-error.
    /* find group */
    v-acc = lon.aaa.
find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then v-com1 = tarifex2.ost.

    if lon.grp = 90 or lon.grp = 92 then do:
        v-i = 0.
        find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= g-today and lnsch.stval = 0 no-lock no-error.
            IF avail lnsch then do:
                message "Кредит реструктурирован! Обратитесь в Кредитный Департамент." view-as alert-box error.
                return.
            end.

        run lonbalcrc('lon',lon.lon,g-today,"7,9,16,5,4",yes,lon.crc,output v-lev).

            if v-lev <> 0 then do:
                message "Этот клиент имеет задолжность! Частичное погашение не может быть выполнено!" view-as alert-box error.
                return.
            end.
            else do:
                run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-first).
                find first aaa where aaa.aaa = lon.aaa no-lock no-error.
                    if avail aaa then do:
                        v-bal = aaa.cbal - aaa.hbal.
                        if v-bal <= 0 then do :
                            message "Баланс счета равен 0. Частичное погашение не может быть выполнено!" view-as alert-box error.
                            return.
                        end.
                    end.
                    /*
                    find last pksysc where pksysc.credtype = "6" and pksysc.sysc = "bdacc" no-lock no-error.
                    find last pkanketa where pkanketa.lon = lon.lon no-lock no-error.
                    */
                        /*v-com = 3 * pkanketa.summa * pksysc.deval / 100.*/
                        /* if avail pkanketa then v-com1 = pkanketa.summa * pksysc.deval / 100. */

                /* find graph of payment */
                v-i = 0.
                for each lnsch where lnsch.f0 > 0 and lnsch.lnn = lon.lon and lnsch.stdat >= g-today no-lock:
                        if avail lnsch then v-i= v-i + 1.
                end.
                if v-i < 4 then do:
                    message "Срок погашения кредита истек или близок концу!" view-as alert-box error.
                    return.
                end.
                /*check for 3 months payment */
                i = 0.
                for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= g-today no-lock:
                    i = i + 1.
                    if i < 4 then do:
                        /*v-od = v-od + lnsch.stval.
                        sum2 = sum2 + lnsci.iv-sc.*/
                        find first lnsci where lnsci.lni = lnsch.lnn and lnsci.idat = lnsch.stdat no-lock no-error.
                            if avail lnsci then v-sum = v-sum + lnsch.stval + lnsci.iv-sc + v-com1.

                    end.

                    find first lnsci where lnsci.lni = lnsch.lnn and lnsci.idat >= g-today and lnsci.iv-sc > 0 no-lock no-error.
                        if avail lnsci then v-comm = lnsci.iv-sc + v-com1.
                        /*3 months payment + 1 month % and commission*/
                        if v-sum > v-bal then do:
                            message "Баланс недостаточен. Частичное погашение не может быть выполнено!" view-as alert-box error.
                            return.
                        end.

                    if v-bal > v-first then do:
                        message "Баланс достаточен для полного погашения!" view-as alert-box error.
                        return.
                    end.
                    if v-sum < v-bal then do:
                        /*avail balance for payment*/
                        v-sum3 = v-bal - v-comm.

                    end.
                end.


            end.


    end.
    else do:
        message "Этот вид операции доступен только для клиентов 90 и 92 вида групп!" view-as alert-box error.
        return.
    end.
    for each lnsch where lnsch.f0 > 0 and lnsch.lnn = lon.lon and lnsch.stdat >= g-today no-lock:
        find last lnsci where lnsci.lni = lnsch.lnn and lnsci.idat >= g-today and lnsci.iv-sc > 0 no-lock no-error.
        v-in-sum = 3 * lnsch.stval + 2 * lnsci.iv-sc + 2 * v-com1.
        v-lnsch = lnsch.stval.
        v-lnsci = lnsci.iv-sc.
    end.

    displ v-cif v-acc format "x(20)"
    v-bal format "->>>,>>>,>>>,>>>,>>9.99" label "Баланс на счету"
    v-sum3 format "->>>,>>>,>>>,>>>,>>9.99" label "Доступная сумма для частичного погашения"
    with frame f_pog.
    update v-sum3 format "->>>,>>>,>>>,>>>,>>9.99" label "Доступная сумма для частичного погашения"
    with frame f_pog.
    if v-sum3 < v-in-sum then do:
        /*displ v-sum3 format "->>>,>>>,>>>,>>>,>>9.99" v-in-sum format "->>>,>>>,>>>,>>>,>>9.99" v-lnsch v-lnsci v-com1.*/
        message "Введите сумму, превышающую 3-х ОД + 2-х вознагр. и коммиссий!" view-as alert-box error.
        return.
    END.


    /* выведем график для проверки правильности реструктуризации */
    def stream rep.
    output stream rep to rep.htm.
    put stream rep unformatted
        "<html><head>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
        "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
        "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
        "</head><body>" skip.
   find first crc where crc.crc = lon.crc no-lock no-error.
   put stream rep unformatted
        "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
        "Ссудный счет: " lon.lon "<BR>" skip
        "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.

    put stream rep unformatted
        "<h2>График погашения основного долга</h2>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td width=30>N</td>" skip
        "<td width=100>Дата</td>" skip
        "<td width=100>Основной долг</td>" skip
        "<td width=100>Вознаграждение</td>" skip
        "<td width=100>Комиссии</td>" skip
        "<td width=100>Итого сумма
                       очередного платежа</td>" skip
        "<td width=100>Остаток суммы основного долга
                       после уплаты очередного платежа</td>" skip
        "</tr>" skip.


    v-ostsum = lon.opnamt.
    j = 0.
    for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
        find first lnsci where lnsci.lni = lnsch.lnn and lnsci.f0 > 0 and lnsci.idat = lnsch.stdat no-lock no-error.
            if lnsch.stdat < g-today then do:
                /*v-sum-gr = v-sum-gr + lnsch.stval.*/
                create t-wrk.
                assign t-wrk.dat = lnsch.stdat
                t-wrk.od1 = lnsch.stval
                t-wrk.vozn = lnsci.iv-sc
                t-wrk.kom = v-com1
                t-wrk.sled = lnsch.stval + lnsci.iv-sc + v-com1
                i = 1.
            end.

            if lnsch.stdat > g-today then do:
                j = j + 1.
            end.
            if lnsch.stdat > g-today then do:
                create t-wrk.
                assign
                t-wrk.dat = lnsch.stdat
                t-wrk.vozn = lnsci.iv-sc
                t-wrk.kom = v-com1.

            end.
    end.

    run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-sum-gr).
    v-sum-gr1 = (v-sum-gr - v-sum3) / (j - 1) .
    v-truncsum = v-sum-gr1 - trunc(v-sum-gr1,0).
    i = 0.
    for each t-wrk where t-wrk.dat > g-today no-lock:
        i = i + 1.
        if i = 1 then do:
            t-wrk.od1 = 0.
            t-wrk.sled = t-wrk.od1 + t-wrk.vozn + v-com1.
        end.
        if i > 1 then do:

        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = t-wrk.dat no-lock no-error.
            if avail lnsci then
                t-wrk.vozn = lnsci.iv-sc.
                if i < j then t-wrk.od1 = trunc(v-sum-gr1,0).
                /*find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = t-wrk.dat no-lock no-error.
                t-wrk.sled = t-wrk.od1 + t-wrk.vozn + v-com1.*/
                if i = j  then
                    t-wrk.od1 = trunc(v-sum-gr1,0) + v-truncsum * (j - 1) .
                    t-wrk.sled = t-wrk.od1 + t-wrk.vozn + v-com1.
        end.
    end.

    create t-wrk.
    assign t-wrk.dat = g-today
    t-wrk.od1 = v-sum3
    t-wrk.vozn = 0
    t-wrk.kom = 0
    t-wrk.sled = v-sum3.
    for each t-wrk no-lock:
        v-ostsum = v-ostsum - t-wrk.od1.

        put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" i "</td>" skip
        "<td align=""center"">" t-wrk.dat "</td>" skip
        "<td align=""right"">" + string(t-wrk.od1,'>>>,>>>,>>>,>>9.99') +  "</td>" skip
        "<td align=""right"">" + string(t-wrk.vozn,'>>>,>>>,>>>,>>9.99') +  "</td>" skip
        "<td align=""right"">" + string(t-wrk.kom,'>>>,>>>,>>>,>>9.99') +  "</td>" skip
        "<td align=""right"">" + string(t-wrk.sled,'>>>,>>>,>>>,>>9.99') +  "</td>" skip
        "<td align=""right"">" + string(v-ostsum,'>>>,>>>,>>>,>>9.99') +  "</td>" skip
        "</tr>" skip.
        i = i + 1.
    end.
    put stream rep unformatted "</table><BR><BR>" skip.
    put stream rep unformatted "</table></body></html>" skip.
    output stream rep close.
    unix silent cptwin rep.htm excel.
    choice = no.
    message "Произвести частичное погашение?" view-as alert-box question buttons yes-no title "" update choice.

    /* погашение */
    if choice then do:

       run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).


       if substr(string(lon.gl),4,1) = '7' then do:
            v-param = '0' + vdel + v-acc + vdel + lon.lon + vdel +
            '423' + vdel +
            '0' + vdel +
            '0' + vdel +
            '0' + vdel +
            string(v-sum3) + vdel +
            '0' + vdel +

            'Погашение ОД' + vdel +
            '' + vdel +
            '' + vdel +
            '' + vdel +
            '' + vdel +
            '0' + vdel +
            '0'.
        end.
        if substr(string(lon.gl),4,1) = '1' then do:
            v-param = '0' + vdel + v-acc + vdel + lon.lon + vdel +
            '421' + vdel +
            '0' + vdel +
            '0' + vdel +
            '0' + vdel +
            string(v-sum3) + vdel +
            '0' + vdel +

            'Погашение ОД' +
            vdel + '' +
            vdel + '' +
            vdel + '' +
            vdel + '' +
            vdel +
            '0' + vdel +
            '0'.
        end.

         run trxgen ("lon0062", vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:

               message rdes.
               pause.
               undo, return.
            end.


        if v-bal1 gt 0 then do:
            v-nxt = 0.
            for each lnsch where lnsch.lnn eq lon.lon no-lock :
               if lnsch.f0 eq 0 and lnsch.flp gt 0 then do:
                  if v-nxt lt lnsch.flp then v-nxt = lnsch.flp.
               end.
            end.
            find first jh where jh.jh = s-jh no-lock no-error.
            create lnsch.
            lnsch.lnn = lon.lon.
            lnsch.f0 = 0.
            lnsch.flp = v-nxt + 1.
            lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
            lnsch.paid = /*v-bal1*/ v-sum3.
            lnsch.stdat = jh.jdt.
            lnsch.jh = jh.jh.
            lnsch.whn = g-today.
            lnsch.who = g-ofc.


        end.

        for each lnsch where lnsch.lnn = lon.lon and lnsch.stdat > g-today and lnsch.f0 > 0 exclusive-lock:
               delete lnsch.
        end.
        for each t-wrk where t-wrk.dat >= g-today no-lock:

               i = i + 1.
               create lnsch.
               assign lnsch.lnn = lon.lon.

                lnsch.f0 = i.
                lnsch.flp = 0.
                lnsch.stdat = t-wrk.dat.
                lnsch.whn = g-today.
                lnsch.who = g-ofc.
                lnsch.stval = t-wrk.od1.
                if t-wrk.dat = g-today then lnsch.commis = no.
        end.
        run lnsch-ren(lnsch.lnn).

    message "Частичное погашение выполнено!" view-as alert-box information  buttons ok title "".

    end.
