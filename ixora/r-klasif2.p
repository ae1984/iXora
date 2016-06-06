/* r-klasif2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.02.2004 marinav В расчет добавлены индексированные уровни
        25.03.2004 marinav добавлены полученные проценты
        31/05/2004 madiyar - в отчет выводились только кредиты, у которых ненулевой остаток ОД. Теперь выводятся и те, у которых
                             остаток ОД = 0, а проценты <> 0
        03/08/2004 madiyar - добавил в wrk поле regdt для колонки "Дата выдачи кредита", поля balansi и balprci для колонок
                             "В т.ч. индексация в тыс.тенге" по ОД и %%
        05/08/2004 madiyar - добавил no-lock
        10/08/2004 madiyar - добавил отображение прогресса формирования отчета
        11/08/2004 madiyar - изменил расчет начисл. % (из истории уровней)
                             провизии брались на текущий момент (из trxbal), теперь - тоже из истории уровней, за заданную дату
        16/08/2004 madiyar - забыл убрать кусок отладочного кода - пропускались все БД и БК
                             исправил ошибку в обращении к истории уровней при вычислении сформированных провизий
        02/11/2004 madiyar - пропускались кредиты с нулевыми ОД и %%, но ненулевыми провизиями, и поэтому провизии не шли с балансом; исправил
        03/11/2004 madiyar - из расчета %% убрал учет предоплаты (10 уровень)
        01/02/2005 madiyar - Индексированные % - отдельно от основных
        07/04/2005 madiyar - добавил поле ecdiv (отрасль)
        27/05/2005 madiyar - добавил поле v-addr (адрес обеспечения)
        29/09/2005 marinav - добавлено поле залогодатель
        22/12/2005 madiyar - обеспечение - с 19 уровня
        23/12/2005 madiyar - мелкое исправление
        08/02/2006 madiyar - полученные проценты с уровней
        30/05/2006 madiyar - наименование клиента в каждой строчке, no-undo
        31/05/2006 madiyar - убрал no-undo из описания шаренных переменных
        03/07/2006 u00121  - заполнение таблицы wrk сделал через assign
        14/07/2006 MARINAV - требования КИК
        29/09/2006 madiyar - разделил на три отчета - юр, физ и бд
        02/10/2006 madiyar - поменял переменную - счетчик цикла
        31/10/2006 madiyar - небольшие изменения
        06/09/2007 madiyar - кредиты с нулями на всех уровнях кроме 12 (получ. проценты) - пропускаем
        05/03/2008 madiyar - евро с 11 на 3
        04/09/2008 madiyar - явно указал индекс в поиске последней записи в lonhar
        04/05/2009 madiyar - провизии в валюте кредита
        01/06/2009 madiyar - по кредитам в валюте провизии переводятся в тенге по курсу за дату отчета
        09/06/2010 galina - убрала столбец КИК
        09/07/2010 aigul - добавила сортировку по МСБ, добавила вывод классификации и рейтинга, суммы обеспечения
        20.07.2010 marinav - добавление счета ГК
        4/08/2010 aigul - добавление информации о клиентах связанных с банком особыми отношениями
        05/08/2010 madiyar - статус по классификации брался не совсем правильно, исправил
        31/08/2010 madiyar - ответственный менеджер
        01/09/2010 aigul - вывод информации о клиентах связанных с банком особыми отношениями по реестру
        13/09/2010 aigul - поправила поиск по справочнику о клиентах связанных с банком особыми отношениями
        21/10/2010 aigul - добавила 70,80,11,21 группы для 4 пункта
        03/01/2011 madiyar - поправил по классификации
        11/01/2011 madiyar - подправил провизии
        24.01.2011 ruslan - справочник ecdivis берем из карты клиента
        01/02/2011 madiyar - еще раз подправил провизии
        14.04.2011 aigul - добавила код займа для бух-ов
        02/06/2011 madiyar - дата выдачи, дата договора
        01/08/2011 madiyar - провизии МСФО
        07/11/2011 kapar - добавил столбцы - «Амортизация дисконта» и «Дисконт по займам»
        23/11/2011 kapar -  добавил столбец - «сумма в тыс. тенге (34 ур)»
        08/11/2011 kapar - «34 уровня» исключения для ссудного счета "005147811"
        17/01/2011 kapar - ТЗ №1255
        03/02/2012 dmitriy - добавил столбец "Отраслевая направленность займа"
        23/01/2013 sayat(id01143) - ТЗ 1661 от 17/01/2013 поиск лиц, связанных особыми отношениями, по ИИН/БИН вместо РНН
        07/03/2013 sayat(id01143) - ТЗ 1655 в блоке "Обеспечение" добавлены 2 столбца "Номер договора залога" и "Дата договора залога"
*/

def var s-ourbank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
def var nm as char.
hide message no-pause.
message s-ourbank.
def var v-dt as date no-undo.
def buffer b-kdlonkl for kdlonkl.

def input parameter datums as date no-undo.
def shared var v-reptype as integer no-undo. /* 1 - юр, 2 - физ (без БД), 3 - только БД, 4 - все */
def shared var g-today as date.
def shared var g-ofc as char.
def var dayc1 as int no-undo init 0.
def var dayc2 as int no-undo init 0.
def new shared var bilance as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var bilancei as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var prov as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-prov_afn as deci no-undo.
def var v-prov_od as deci no-undo.
def var v-prov_prc as deci no-undo.
def var v-prov_pen as deci no-undo.
define variable bilancepl as decimal no-undo format '->,>>>,>>9.99'.
define variable bil1 as decimal no-undo format '->,>>>,>>9.99'.
define variable bil2 as decimal no-undo format '->,>>>,>>9.99'.
define variable sumbil as decimal no-undo format '->,>>>,>>9.99'.
/*def var vcu like txb.lon.opnamt extent 6 decimals 2.*/
def var prc as deci no-undo.
def var prci as deci no-undo.
define variable f-dat1 as date no-undo.
def var tempdt  as date no-undo.
def var tempost as deci no-undo.
def var dlong as date no-undo.
def var v-num as inte no-undo init 1.
def var i as integer no-undo.
def var j as integer no-undo.
def var v-zz as decimal no-undo.
def var v-zzall as decimal no-undo.
def var v-zzall2 as decimal no-undo.
def var ppol as decimal no-undo.
def var v-ofcname as char no-undo.
def var v_amr_dk as deci no-undo.
def var v_zam_dk as deci no-undo.
def var v_bal34 as deci no-undo.
def var t_bal34 as deci no-undo.


def shared temp-table wrk no-undo
    field num    as inte
    field lon    like txb.lon.lon
    field cif    like txb.lon.cif
    field name   like txb.cif.name
    field rdt    as inte
    field regdt  like txb.lon.rdt
    field isdt  as date
    field ddt like txb.lon.rdt
    field grp like txb.lon.grp
    field opnamt like txb.lon.opnamt
    field balans like txb.lon.opnamt
    field balansi like txb.lon.opnamt
    field crc    like txb.lon.crc
    field prem   like txb.lon.prem
    field sts    like txb.lonstat.prc
    field bal1   like txb.lon.opnamt  /*Нач доходы*/
    field balprci like txb.lon.opnamt  /*в т.ч. индексация*/
    field bal11  like txb.lon.opnamt  /*Пол доходы*/
    field bal2   like txb.lon.opnamt   /* Провизии необ  */
    field lcnt_dk as char /*№ договора*/
    field amr_dk  as deci /*Амортизация дисконта*/
    field zam_dk  as deci /*Дисконт по займам*/
    field bal_afn like bank.lon.opnamt  /* Провизии АФН */
    field bal_msfo like bank.lon.opnamt
    field prov_od as deci
    field prov_prc as deci
    field prov_pen as deci
    field kod    as   inte  /* Обесп*/
    field crcz   as   inte  /* Обесп*/
    field v-name as char
    field v-addr as char
    field v-zal as char
    field bal4   like txb.lon.opnamt
    field bal5  like txb.lon.opnamt
    field ecdiv  as char
    field kodd  as char
    field rate  as char
    field bal34 as deci
    field lnprod as char

    field rating  as decimal
    field rating_ob  as decimal
    field valdesc  as char
    field valdesc_ob  as char
    field gl as char
    field rel as char
    field ofc as char
    field kod_buham as int
    field napr as char
    field zaldognum as char
    field zaldogdt as date
    /*field lntreb as char*/
    index ind1 is primary sts rdt lon name desc
    index ind2 cif kod.





def var fin as char.
def var rat as decimal.


def var v-sum as decimal no-undo init 0.
def var v-am2 as decimal no-undo init 0.
def var v-am3 as decimal no-undo init 0.
def var mesa as integer no-undo.


def var v-lonprnlevi as char no-undo initial "20;21".
def var v-lonprnlevi% as char no-undo initial "22;23".

find first txb.cmp no-lock no-error.
def var lst_grp as char no-undo.
def var v-grp as integer no-undo.
lst_grp = ''.
case v-reptype:
  when 1 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '2' and not txb.longrp.des matches '*МСБ*' then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 2 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '1' and (txb.longrp.longrp <> 90) and (txb.longrp.longrp <> 92) then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 3 then lst_grp = "90,92".
  when 4 then do:
    for each txb.longrp no-lock:
      if txb.longrp.des matches '*МСБ*' or txb.longrp.longrp = 70 or txb.longrp.longrp = 80
      or txb.longrp.longrp = 11 or txb.longrp.longrp = 21 then do:
        if lst_grp <> '' then lst_grp = lst_grp + ','.
        lst_grp = lst_grp + string(txb.longrp.longrp).
      end.
    end.
  end.
  when 5 then do:
    for each txb.longrp no-lock:
      if lst_grp <> '' then lst_grp = lst_grp + ','.
      lst_grp = lst_grp + string(txb.longrp.longrp).
    end.
  end.
  otherwise lst_grp = ''.
end case.

if g-ofc <> "superman" then do:
    hide message no-pause.
    message txb.cmp.name.
end.

do j = 1 to num-entries(lst_grp):
    v-grp = integer(entry(j,lst_grp)).

    for each txb.lon where txb.lon.grp = v-grp no-lock:

         if txb.lon.opnamt <= 0 then next.

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"1,7",yes,txb.lon.crc,output bilance). /* фактич остаток ОД*/

         /* индексированный ОД */

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"20,21",yes,txb.lon.crc,output bilancei).

         /* проценты */

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"2,9",yes,txb.lon.crc,output prc).

         /* индексиров %%*/
         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"22,23",yes,txb.lon.crc,output prci).

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"41",yes,txb.lon.crc,output v-prov_afn).
         v-prov_afn = - v-prov_afn.
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then v-prov_afn = v-prov_afn * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"6",yes,txb.lon.crc,output v-prov_od).
         v-prov_od = - v-prov_od.
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then v-prov_od = v-prov_od * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"36",yes,txb.lon.crc,output v-prov_prc).
         v-prov_prc = - v-prov_prc.
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then v-prov_prc = v-prov_prc * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"37",yes,1,output v-prov_pen).
         v-prov_pen = - v-prov_pen.

         v-zzall = 0.
         do i = 1 to 3:
           find first txb.crc where txb.crc.crc = i no-lock no-error.
           run lonbalcrc_txb ('lon',txb.lon.lon,datums,"19",yes,txb.crc.crc,output v-zz).

           find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= datums no-lock no-error.
           v-zzall = v-zzall + v-zz * txb.crchis.rate[1].
         end.


         prov = v-prov_od + v-prov_prc + v-prov_pen.


         /*Амортизация дисконта*/
         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"31",yes,txb.lon.crc,output v_amr_dk).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then v_amr_dk = v_amr_dk * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         /*Дисконт по займам*/
         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"42",yes,txb.lon.crc,output v_zam_dk).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then v_zam_dk = v_zam_dk * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.

         /*сумма в тыс. тенге (34 ур)*/
         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"34",yes,txb.lon.crc,output t_bal34).
         if txb.lon.crc <> 1 then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= datums no-lock no-error.
            if avail txb.crchis then t_bal34 = t_bal34 * txb.crchis.rate[1].
            else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         end.
         v_bal34 = - t_bal34.
         if txb.lon.lon = '005147811' Then do:
             run lonbalcrc_txb ('lon',txb.lon.lon,datums,"34",no,2,output t_bal34).
             find last txb.crchis where txb.crchis.crc = 2 and txb.crchis.rdt <= datums no-lock no-error.
             if avail txb.crchis then t_bal34 = t_bal34 * txb.crchis.rate[1].
               else message " Ошибка определения курса! cif=" + txb.lon.cif + " lon=" + txb.lon.lon + " crc=" + string(txb.lon.crc) view-as alert-box error.
         v_bal34 = v_bal34 - t_bal34.
         end.


         /* 31/05/2004 madiyar - пропускать кредиты с нулевыми остатком ОД, нулевыми процентами и нулевыми провизиями */
         if bilance + bilancei <= 0 and prc <= 0 and prov <= 0 and v-prov_afn <= 0 and v-zzall <= 0 and v_amr_dk = 0 and v_zam_dk = 0 and v_bal34=0 then next.

         run lonbalcrc_txb ('lon',txb.lon.lon,datums,"12",yes,1,output ppol).
         ppol = - ppol.


        find last txb.cif where txb.cif.cif = txb.lon.cif no-lock.
        find last txb.crc where txb.crc.crc = txb.lon.crc no-lock.


         dlong = txb.lon.duedt.
         if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
         if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].


         create wrk.
         assign
               wrk.cif = txb.cif.cif
               wrk.name = trim(txb.cif.prefix) + " " + trim(txb.cif.name)
               wrk.rdt = year(txb.lon.rdt)
               wrk.regdt = txb.lon.rdt
               wrk.ddt = dlong
               wrk.lon = txb.lon.lon
               wrk.grp = txb.lon.grp
               wrk.opnamt = txb.lon.opnamt
               wrk.balans = bilance
               wrk.balansi = bilancei
               wrk.crc = txb.lon.crc
               wrk.prem = txb.lon.prem
               wrk.bal1 = prc
               wrk.balprci = prci
               wrk.num = v-num

               wrk.amr_dk = v_amr_dk
               wrk.zam_dk = v_zam_dk
               wrk.bal34 =  v_bal34

               wrk.bal_afn = v-prov_afn
               wrk.bal_msfo = prov
               wrk.prov_od = v-prov_od
               wrk.prov_prc = v-prov_prc
               wrk.prov_pen = v-prov_pen
               wrk.bal4 = v-zzall
               /*wrk.bal5 = txb.lonsec1.secamt*/
               wrk.bal11 = ppol.

        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg then wrk.isdt = txb.lnscg.stdat.

        find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        if avail txb.loncon then do:
            wrk.lcnt_dk = txb.loncon.lcnt.
            find first txb.ofc where txb.ofc.ofc = txb.loncon.pase-pier no-lock no-error.
            if not avail txb.ofc then wrk.ofc = "[" + txb.loncon.pase-pier + "]".
            else do:
                v-ofcname = trim(txb.ofc.name).
                wrk.ofc = entry(1,v-ofcname," ").
                if num-entries(v-ofcname," ") > 1 then wrk.ofc = wrk.ofc + " " + caps(substring(entry(2,v-ofcname," "),1,1)) + ".".
                if num-entries(v-ofcname," ") > 2 then wrk.ofc = wrk.ofc + caps(substring(entry(3,v-ofcname," "),1,1)) + ".".
            end.
        end.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'finsost1' and kdlonkl.rdt <= datums no-lock no-error.
        if avail kdlonkl then wrk.valdesc = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        find last kdlonkl where kdlonkl.bank = s-ourbank and kdlonkl.kdcif = txb.lon.cif and kdlonkl.kdlon = txb.lon.lon and kdlonkl.kod = 'obesp1' and kdlonkl.rdt <= datums no-lock no-error.
        if avail kdlonkl then wrk.valdesc_ob = kdlonkl.val1 + " - " + kdlonkl.valdesc.

        /* Рейтинг*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnrate' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrk.kodd = txb.codfr.code.
            wrk.rate = txb.codfr.name[1].
        end.

        /* Продукт*/
        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnprod' no-lock no-error.
        if avail txb.sub-cod then
            find first txb.codific where txb.codific.codfr = txb.sub-cod.d-cod no-lock no-error.
        if avail txb.codific then
            find first txb.codfr where txb.codfr.codfr = txb.codific.codfr and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
        if avail txb.codfr then do:
            wrk.lnprod = txb.codfr.name[1].
        end.

        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= datums use-index lonhar-idx1 no-lock no-error.
        if avail txb.lonhar then find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.

        if avail txb.lonstat then wrk.sts = txb.lonstat.prc.
        else wrk.sts = 0.


         find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = 'ecdivis' no-lock no-error.

         if avail txb.sub-cod then wrk.ecdiv = txb.sub-cod.ccode.
         else wrk.ecdiv = "--n/a--".

/* marinav */
         wrk.gl = substr(string(txb.lon.gl),1,4).
         if substr(txb.cif.geo,3,1) = '1' then wrk.gl = wrk.gl + '1'.
                                          else wrk.gl = wrk.gl + '2'.

         find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = 'secek' no-lock no-error.
         if available txb.sub-cod then wrk.gl = wrk.gl + txb.sub-cod.ccode.
                                  else wrk.gl = wrk.gl + '0'.

         case txb.lon.crc:
              when 1 then wrk.gl = wrk.gl + '1'.
              when 2 or  when 3 then wrk.gl = wrk.gl + '2'.
              otherwise wrk.gl = wrk.gl + '3'.
         end case.

/* особые отношения с банком */

         find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         if avail txb.cif then do:
            if /*txb.cif.jss*/ txb.cif.bin <> '' then do:
                    find first prisv where prisv.rnn = /*txb.cif.jss*/ txb.cif.bin and prisv.rnn <> '' no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.

                    else do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.
                    else wrk.rel = "Не связанное лицо".
                    end.
                end.
                if /*txb.cif.jss*/ txb.cif.bin = '' then do:
                    if num-entries(trim(txb.cif.name),' ') > 0 then nm = entry(1,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 1 and entry(2,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(2,trim(txb.cif.name),' ').
                    if num-entries(trim(txb.cif.name),' ') > 2 and entry(3,trim(txb.cif.name),' ') <> '' then nm = nm + ' ' + entry(3,trim(txb.cif.name),' ').
                    find first prisv where trim(prisv.name) = nm no-lock no-error.
                    if avail prisv then do:
                         find first txb.codfr where txb.codfr.codfr = "affil" and txb.codfr.code = prisv.specrel no-lock.
                         if avail txb.codfr then wrk.rel = txb.codfr.name[1].
                         if not avail txb.codfr then wrk.rel = 'Нет такого справочника'.
                    end.
                    else wrk.rel = "Не связанное лицо".
                end.
         end.
         /*if avail txb.sub-cod then do:
            if txb.sub-cod.ccode = '1' then wrk.lntreb = txb.sub-cod.ccode.
                                       else wrk.lntreb = '0'.
         end.
         else wrk.lntreb = "--n/a--".*/

         v-num = v-num + 1.

         v-sum = 0.
         def buffer b-lonsec1 for txb.lonsec1.
         for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
            v-sum = txb.lonsec1.secamt.
            find first wrk where wrk.cif = txb.cif.cif and wrk.kod = 0 no-lock no-error.
            if not avail wrk then do:

                create wrk.
                assign
    	            wrk.cif = txb.cif.cif
    	            wrk.name = trim(txb.cif.prefix) + " " + trim(txb.cif.name)
            	    wrk.lon = txb.lon.lon
    	            wrk.crc = txb.lon.crc
    	            wrk.rdt = year(txb.lon.rdt)
    	            wrk.regdt = txb.lon.rdt
    	            wrk.ddt = dlong.

                    if avail txb.lonstat then wrk.sts = txb.lonstat.prc.
            end.
            wrk.kod = txb.lonsec1.lonsec.
           /*aigul*/
            find last b-lonsec1 where b-lonsec1.lon = txb.lon.lon and b-lonsec1.lonsec = 2 no-lock no-error.
              if available b-lonsec1 then wrk.kod_buham = 2.
              else do:
                 find last b-lonsec1 where b-lonsec1.lon = txb.lon.lon no-lock no-error.
                 if available b-lonsec1 then wrk.kod_buham = b-lonsec1.lonsec.
                 else wrk.kod_buham = 4.
             end.
            /**/

            wrk.crcz = txb.lonsec1.crc.
            wrk.v-name = trim(entry(1,txb.lonsec1.prm,'&')).
            wrk.v-addr = trim(entry(1,txb.lonsec1.vieta,'&')).
            wrk.v-zal = trim(txb.lonsec1.pielikums[1]).
            wrk.zaldognum = trim(txb.lonsec1.numdog).
            wrk.zaldogdt = txb.lonsec1.dtdog.

            /* перевод валюты в тенге */
            v-zzall2 = txb.lonsec1.secamt.
            if txb.lonsec1.crc <> 1 then do:
                find last txb.crchis where txb.crchis.crc = txb.lonsec1.crc and txb.crchis.rdt <= datums no-lock no-error.
                if avail txb.crchis then v-zzall2 = v-zzall2 * txb.crchis.rate[1].
            end.
            wrk.bal5 = v-zzall2.
            wrk.num = v-num.
            v-num = v-num + 1.
         end. /* for each txb.lonsec1 */

        /* Отраслевая направленность займа */
        find first txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = "lntgt_1" no-lock no-error.
        if avail txb.sub-cod then do:
            find first txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod and txb.codfr.code = txb.sub-cod.ccode no-lock no-error.
            if avail txb.codfr then wrk.napr = trim(txb.codfr.name[1]).
        end.

    end. /* for each txb.lon */
end. /* do j = 1 to */

