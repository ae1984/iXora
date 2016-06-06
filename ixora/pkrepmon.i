/* pkrepmon.i
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Сбор списка задолжников по текущему виду кредита во временную таблицу
 * RUN

 * CALLER
        pkrepmon.p, pkletter.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        12.12.2003 nadejda - вырезала из pkrepmon.p
 * CHANGES
        19.12.2003 nadejda - оптимизация поиска pkanketa
        06.01.2004 nadejda - в подсчет дней просрочки поставила условие <= для учета сегодняшнего дня в графике
        26.01.2004 nadejda - изменение сбора сумм по процентам для схемы 3
                             добавлены штрафы, менеджер, КредКом
        29.01.2004 nadejda - передается параметр отбора по виду кредита
        01.02.2004 nadejda - место работы брать из cif.ref[8]
        07.03.2004 sasco   - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        30.03.2004 nadejda - добавлен вывод дня погашения
        07.04.2004 tsoy    - проверку на avail bookcod
        20.04.2004 nadejda - сумма просрочки % на заданную дату сделана через histrxbal, а не расчетом назад по графику
        20/05/2004 madiyar - исправил расчет % и просрочки (считался неправильно для 1 и 2 схем)
                             расчет % и просрочки для третьей и четвертой схем выделил в pkrasprc.i
        28/09/2004 madiyar - изменил расчет просрочки с прогнозной на реальную
        14/10/2004 tsoy    - изменил срок с 45 дней до 30, для заведения в черный список.
        15/03/2005 madiyar - добавил поле pen_prem (текущая ставка по штрафам)
        15/08/2005 madiyar - добавил поле com_acc (долг по комиссии за вед. тек. счета)
        01/11/2005 madiyar - добавил внебаланс
        06/04/2006 madiyar - анкеты казпочты - вид "kp"
        25/04/2006 madiyar - добавил 4,5 уровни
        28/09/2006 madiyar - казпочтовые кредиты раскидал по РУПСам
        12/11/2007 madiyar - телефоны берем не из клиентской записи, а из анкеты
        24/02/2009 galina - добавила поле com_acckzt комиссионный долг в тенге
                            ищем сотаток на ОД (1,7) в валюте кредита
        13/03/2009 madiyar - изменения согласно ТЗ 483 от ОМиВК
        17/03/2009 madiyar - подправил расчет суммы оплаты за время просрочки (уровень = 1)
        26/05/2009 madiyar - возвраты штрафов теперь делают не только кред. администраторы, но и менеджеры филиалов
        02.06.2009 galina - добавила поле кол-во предстоящих платежей
        14.09.2009 galina - выводим фактическое количество дней просрочки
        28/01/2010 galina - добавила движимое и недвижимое имущество, счета в БВУ
        01/02/2010 galina - добавила описание в столбцы по недвижимости
        03/02/2010 galina - выводим записи по имуществу и счетам в БВУ черезе символ ";"
        08/02/2010 madiyar - перекомпиляция
        21/09/2010 galina - поменяла формат ввода для движимого имущества
	22/11/2010 id00024 - исправил проблему с МКО
*/


def var v-aaa as char no-undo.


def temp-table  wrk no-undo
    field lon    like lon.lon
    field stype  as char
    field cif    like lon.cif
    field name   like cif.name
    field rdt    like lon.rdt
    field duedt  like lon.rdt
    field opnamt like lon.opnamt
    field balans like lon.opnamt
    field crc    like lon.crc
    field prem   like lon.prem
    field pen_prem as deci
    field bal1   like lon.opnamt
    field dt1    as   inte
    field bal2   like lon.opnamt
    field dt2    as   inte
    field balpen   like lon.opnamt
    field bal3   like lon.opnamt
    field bal13 as decimal
    field bal14 as decimal
    field bal30 as decimal
    field bal4 as decimal
    field bal5 as decimal
    field com_acc as decimal
    field aaabal as decimal
    field aaabaldt as decimal
    field aaabaltim as decimal
    field sum_in as decimal /* сумма, поступившая на тек. счет после выхода на просрочку */
    field pen_paid as decimal /* штрафы, оплаченные в тек. году */
    field pr_kol as integer /* количество просрочек */
    field tel as char
    field job as char
    field rwho as char
    field kredkom as char
    field lcnt as char
    field day as integer
    field oinscount as integer
    field realp as char
    field movp as char
    field acc as char
    index main is primary crc DESC bal3 DESC
    index bal bal1 bal2.

/* Функция проверяет переданный логин на права кредитного администратора */
/*
function is_loan_adm returns logi (input p-ofc as char).
    def var res as logi no-undo init no.
    find first ofc where ofc.ofc = p-ofc no-lock no-error.
    if avail ofc then res = (lookup("p00047",ofc.expr[1]) > 0).
    return res.
end function.
*/


def var bilance as decimal no-undo format "->,>>>,>>>,>>9.99".
def var dlong as date no-undo.
def var v-ankln as integer no-undo.
def var v-aabbal as decimal no-undo.
def var v-aabbaltim as decimal no-undo.
def var v-tim as integer no-undo init 50400.  /* 14-00 - время отсечки для определения, сколько было клиентов без денег на счете на день погашения */
def var v-credtype as char no-undo.

def var daymax as integer no-undo.
def var v-respr as integer no-undo.
def var v-maxpr as integer no-undo.
def var v-lnlast as integer no-undo.


find first sysc where sysc.sysc = "pktim" no-lock no-error.
if avail sysc then v-tim = sysc.inval.

for each londebt where {&param} no-lock:

     find first lon where lon.lon = londebt.lon no-lock no-error.

     v-ankln = 0.
     for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = londebt.cif no-lock:
       if pkanketa.lon = londebt.lon {&credtype} then do:
         v-ankln = pkanketa.ln.
         v-credtype = pkanketa.credtype.
         leave.
       end.
     end.
     if v-ankln = 0 then next.

     find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = v-credtype and pkanketa.ln = v-ankln no-lock no-error.
     /* run atl-dat (lon.lon,datums,output bilance).*/
     run lonbalcrc('lon',londebt.lon,datums,"1,7",yes,lon.crc,output bilance). /* остаток  ОД*/
     find cif where cif.cif = lon.cif no-lock.

        dlong = lon.duedt.
        if lon.ddt[5] <> ? then do:
          dlong = lon.ddt[5].
          if lon.ddt[5] > g-today then next.
        end.
        if lon.cdt[5] <> ? then do:
          dlong = lon.cdt[5].
          if lon.cdt[5] > g-today then next.
        end.

/* id00024 исправил проблему с МКО */

        if pkanketa.crc = 1 then if pkanketa.aaa <> "" then v-aaa = pkanketa.aaa.
                            else if pkanketa.aaaval <> "" then v-aaa = pkanketa.aaaval.

        find aaa where aaa.aaa = v-aaa no-lock no-error.
		if avail aaa then do:
        	v-aabbal = aaa.cr[1] - aaa.dr[1].
        	v-aabbaltim = v-aabbal.
		end.

        	for each jl where jl.jdt = datums and jl.acc = v-aaa and jl.lev = 1 no-lock:
        	  find jh where jh.jh = jl.jh no-lock no-error.
        	  if (jh.whn = datums and jh.tim >= v-tim) or (jh.whn > datums) then v-aabbaltim = v-aabbaltim + jl.dam - jl.cam.
        	end.

        find first loncon where loncon.lon = lon.lon no-lock no-error.
        create wrk.

        for each bxcif where bxcif.cif = cif.cif and bxcif.crc = lon.crc no-lock:
            wrk.com_acc = wrk.com_acc + bxcif.amount.
        end.

        run lonbalcrc('lon',lon.lon,datums,"13",yes,lon.crc,output wrk.bal13).
        run lonbalcrc('lon',lon.lon,datums,"14",yes,lon.crc,output wrk.bal14).
        run lonbalcrc('lon',lon.lon,datums,"30",yes,1,output wrk.bal30).

        run lonbalcrc('lon',lon.lon,datums,"4",yes,lon.crc,output wrk.bal4).
        run lonbalcrc('lon',lon.lon,datums,"5",yes,1,output wrk.bal5).


        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= datums  no-lock:
          wrk.oinscount  = wrk.oinscount + 1.
        end.
        run lndaysprf(lon.lon,datums, yes, output wrk.dt1, output wrk.dt2).
        assign wrk.cif = cif.cif
               wrk.lon = londebt.lon
               wrk.name = trim(trim(cif.prefix) + " " + trim(cif.name))
               wrk.rdt =  lon.rdt
               wrk.duedt = dlong
               wrk.opnamt = lon.opnamt
               wrk.balans = bilance
               wrk.crc = lon.crc
               wrk.prem = lon.prem
               wrk.pen_prem = loncon.sods1
               wrk.bal1 = londebt.od
               /*wrk.dt1 = londebt.days_od*/
               wrk.bal2 = londebt.prc
               /*wrk.dt2 = londebt.days_prc*/
               wrk.balpen = londebt.penalty
               wrk.bal3 = londebt.od + londebt.prc + londebt.penalty + wrk.com_acc + wrk.bal13 + wrk.bal14 + wrk.bal30.
        if avail aaa then wrk.aaabal = aaa.cr[1] - aaa.dr[1].
        assign wrk.aaabaldt = v-aabbal
               wrk.aaabaltim = v-aabbaltim
               wrk.job = cif.ref[8]
               wrk.rwho = pkanketa.rwho
               wrk.lcnt = loncon.lcnt
               wrk.day = lon.day.

     /* Оплата за время просрочки */
     if wrk.dt1 > wrk.dt2 then daymax = wrk.dt1. else daymax = wrk.dt2.
     for each jl where jl.sub = "cif" and jl.acc = lon.aaa and jl.jdt >= g-today - daymax and jl.dc = 'c' and jl.lev = 1 no-lock:
         if jl.who = 'bankadm' or lookup(jl.trx,"lon0003,lon0004,lon0052,lon0053,lon0070,lon0102,lon0109,lon0110,lon0112,lon0125") > 0 then next.
         wrk.sum_in = wrk.sum_in + jl.cam.
     end.


     /* штрафы, оплаченные в тек. году */
     wrk.pen_paid = 0.
     for each lonres where lonres.lon = lon.lon and lonres.jdt >= date(1,1,year(g-today)) and lonres.lev = 16 no-lock:
         if lonres.dc = 'c' then do:
             if lonres.who = "bankadm" then wrk.pen_paid = wrk.pen_paid + lonres.amt.
         end.
         else do:
             if lonres.who <> "bankadm" then wrk.pen_paid = wrk.pen_paid - lonres.amt.
         end.
     end.

     /* количество просрочек */

     run pkdiscount(pkanketa.rnn, -1, no, output v-respr, output wrk.pr_kol, output v-maxpr, output v-lnlast).

     find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
     wrk.tel = trim(pkanketh.value1).
     find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel2" no-lock no-error.
     if trim(pkanketh.value1) <> '' then do:
       if wrk.tel <> '' then wrk.tel = wrk.tel + ','.
       wrk.tel = wrk.tel + trim(pkanketh.value1).
     end.
     find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel3" no-lock no-error.
     if trim(pkanketh.value1) <> '' then do:
       if wrk.tel <> '' then wrk.tel = wrk.tel + ','.
       wrk.tel = wrk.tel + trim(pkanketh.value1).
     end.
     find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel4" no-lock no-error.
     if trim(pkanketh.value1) <> '' then do:
       if wrk.tel <> '' then wrk.tel = wrk.tel + ','.
       wrk.tel = wrk.tel + trim(pkanketh.value1).
     end.

     if pkanketa.id_org = "kazpost" then DO:
       wrk.stype = "kp".
       find first extuser where extuser.login = pkanketa.rwho no-lock no-error.
       if avail extuser then wrk.stype = wrk.stype + ' - ' + extuser.id_dept.
     END.
     else do:
       find bookcod where bookcod.bookcod = "credtype" and bookcod.code = pkanketa.credtype no-lock no-error.
       if avail bookcod then wrk.stype = bookcod.info[1].
     end.

     find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "gcvpsum" no-lock no-error.
     if avail pkanketh and entry(1, trim(pkanketh.rescha[3])) = "1" then wrk.kredkom = "да".

     for each property where property.cif = cif.cif no-lock:
       if property.type = 'real' then do:
         if wrk.realp <> '' then wrk.realp = wrk.realp + '; '.
         wrk.realp = wrk.realp + 'Исх.номер ' + property.outnum + ' дата '.
         if property.outdt <> ? then wrk.realp = wrk.realp + string(property.outdt,'99/99/9999').
         else wrk.realp = wrk.realp + ' (не указана)'.
         wrk.realp = wrk.realp + ' Вход.номер ответа ' + property.innum + ' дата '.
         if property.indt <> ? then wrk.realp = wrk.realp + string(property.indt,'99/99/9999').
         else wrk.realp = wrk.realp + ' (не указана)'.
         if property.des <> '' then wrk.realp = wrk.realp + ' Сведения о наличии имущества: ' + property.des.
       end.
       if property.type = 'mov' then do:
         if wrk.movp <> '' then wrk.movp = wrk.movp + '; '.
         /*wrk.movp = wrk.movp + 'Исх.номер ' + property.outnum + ' дата '.
         if property.outdt <> ? then wrk.movp = wrk.movp + string(property.outdt,'99/99/9999').
         else wrk.movp = wrk.movp + ' (не указана)'.
         wrk.movp = wrk.movp + ' Вход.номер ответа ' + property.innum + ' дата '.
         if property.indt <> ? then wrk.movp = wrk.movp + string(property.indt,'99/99/9999').
         else wrk.movp = wrk.movp + ' (не указана)'.
         if property.des <> '' then wrk.movp = wrk.movp + ' Сведения о наличии имущества: ' + property.des.*/
         wrk.movp = wrk.movp + 'Гос.номер: ' + property.info[1] + ' Цвет: ' + property.info[2] + ' Марка: ' + property.info[3] + ' Год выпуска: ' + property.info[4] + ' Примечание: ' + property.des.
       end.
       if property.type = 'acc' then do:
         if wrk.acc <> '' then wrk.acc = wrk.acc + '; '.
         wrk.acc = wrk.acc + 'Наименование банка ' + property.info[1] + ' Номер счета ' + property.info[2].
       end.

     end.


end.


for each wrk where wrk.bal1 + wrk.bal2 + wrk.balpen + wrk.com_acc + wrk.bal13 + wrk.bal14 + wrk.bal30 + wrk.bal4 + wrk.bal5 = 0:
  delete wrk.
end.
