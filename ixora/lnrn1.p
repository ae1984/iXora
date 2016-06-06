/* lnrn1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Управленческий отчет по кредитному портфелю
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
        21/07/2009 madiyar - скопировал из lnaudit1.p с изменениями
 * BASES
        BANK COMM TXB
 * CHANGES
        30/07/2009 madiyar - подправил расчет фактических просрочек
        31/07/2009 madiyar - консолидированный отчет в разрезе филиалов
        03/08/2009 madiyar - штрафы считались за дату, а не на дату, исправил
        04/08/2009 galina - добавила столбцы по признакам клиента для физ.лиц
        04/09/2009 galina - добавила отчет по признакам клиента для физ лиц.
        07/09/2009 galina - добавила колонку "Поступления на счет"
        12/01/2010 madiyar - добавил сегмент и схему; исправил формат отчета
        28/01/2010 galina - добавила движимое и недвижимое имущество, счета в БВУ
        01/02/2010 galina - добавила описание в столбцы по недвижимости
        03/02/2010 galina - выводим записи по имуществу и счетам в БВУ черезе символ ";"
        17/02/2010 madiyar - добавил начисл. %, ком. долг и сумму на счете
        02/03/2010 madiyar - поправил поиск lonhar
        21/09/2010 galina - поменяла формат ввода для движимого имущества
        02/06/2011 madiyar - дата выдачи, дата договора
        02/08/2011 dmitriy - добавлено поле rate в wrk, заполняется B,C,D,E - по фин.состоянию кдиента
                           - если фин.сост. не заполнено, то заполняется автоматом (KZT - стабильное, USD - удовл.)
*/


def input parameter d1 as date no-undo.
def shared var v-reptype as integer no-undo. /* 1 - юр, 2 - физ (без БД), 3 - только БД, 4 - все */
def shared var g-ofc as char.
def shared var g-today as date.
def shared var d-rates as deci no-undo extent 20.
def var bilance as decimal format '->,>>>,>>>,>>9.99' no-undo.
def var proc as deci no-undo.
def var pol_proc as deci no-undo.
def var prov as deci no-undo.
def var city as char no-undo.
def var v-prov_prcf as deci no-undo.
def var v-days_f as integer no-undo.

def var dn1 as integer no-undo.
def var dn2 as integer no-undo.

def var qq as deci no-undo.
def var chk as logi no-undo init no.
def var v-gr_id as integer no-undo.
def buffer b-jl for txb.jl.

/* группы кредитов юридических лиц */
def var lst_grp as char no-undo init ''.
def var i as integer no-undo.
def var v-grp as integer no-undo.

def buffer bjl for txb.jl.

case v-reptype:
  when 1 then do:
    for each txb.longrp no-lock:
      if substr(string(txb.longrp.stn),1,1) = '2' then do:
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
      if lst_grp <> '' then lst_grp = lst_grp + ','.
      lst_grp = lst_grp + string(txb.longrp.longrp).
    end.
  end.
  otherwise lst_grp = ''.
end case.

def var s-ourbank as char no-undo.
def var v-bankname as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).
if s-ourbank = "txb00" then v-bankname = "ЦО".
else do:
    find first txb.cmp no-lock no-error.
    if avail txb.cmp then v-bankname = entry(1,txb.cmp.addr[1]).
end.

def shared temp-table wrk1 no-undo
  field rep_id as int
  field bank as char
  field bank_name as char
  field id as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  field polprc as deci /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  field polpen as deci /* полученные штрафы */
  index idx is primary rep_id bank id.

def buffer b-wrk1 for wrk1.

def shared temp-table wrk no-undo
    field bank as char
    field gl like txb.lon.gl
    field name as char
    field cif like txb.lon.cif
    field lon like txb.lon.lon
    field grp like txb.lon.grp
    field crtype as char
    field plan as integer
    field bankn as char
    field crc like txb.crc.crc
    field rdt like txb.lon.rdt
    field isdt as date
    field duedt like txb.lon.duedt
    field dprolong as date
    field prolong as int
    field opnamt as deci
    field opnamt_kzt as deci
    field ostatok as deci
    field prosr_od as deci

    field dayc_od as int
    field fdayc_od as int
    field fdayc_od2 as int

    field dayop as int
    field sumop as deci
    field mpayment as deci

    field n_prov as deci
    field ind_od as deci
    field ostatok_kzt as deci
    field prosr_od_kzt as deci
    field prem as deci
    field nach_prc as deci
    field pol_prc as deci
    field prosr_prc as deci

    field aaabal as deci
    field ostatok_aaa as deci
    field comdolg as deci

    field dayc_prc as int
    field fdayc_prc as int

    field nach_prc_kzt as deci
    field pol_prc_kzt as deci
    field prosr_prc_kzt as deci
    field prosr_prc_zabal as deci
    field prosr_prc_zab_kzt as deci
    field prcdt_last as date
    field penalty as deci
    field penalty_zabal as deci
    field penalty_pol as deci

    field rezprc like txb.lonstat.prc
    field rezsum as deci
    field sumdohod as deci
    field finsost as char
    field rate as char
    field sxem_pog as char

    field num_dog like txb.loncon.lcnt  /* номер договора */
          /*galina*/
    field rest as char
    field crpur as char
    field hwoker as char
    field nostn as char
    field indbus as char
    field realp as char
    field movp as char
    field acc as char
    field speni as deci
    field speni_bal as deci
    field openi as deci
    index ind is primary bank cif.

def shared temp-table wrk2 no-undo
  field rep_id as int
  field priz_id as char
  field bank as char
  field bank_name as char
  field id as int
  field kol as int
  field od as deci /* ОД */
  field odp as deci /* просроченный ОД */
  field nachprc as deci /* начисленные проценты в тенге */
  /*field polprc as deci*/ /* полученные проценты в тенге */
  field prosrprc as deci /* просроченные проценты в тенге */
  field nachprcz as deci /* начисленные вне баланса проценты в тенге */
  field pen as deci /* штрафы */
  field penz as deci /* штрафы вне баланса */
  /*field polpen as deci*/ /* полученные штрафы */
  index idx is primary rep_id priz_id bank id.


find first txb.cmp no-lock no-error.
if avail txb.cmp then city = entry(1,txb.cmp.addr[1]).

/*
hide message no-pause.
message " Обрабатывается база " + city + " ".
*/

def var v_speni as deci no-undo.
def var v_speni_bal as deci no-undo.
def var v_openi as deci no-undo.


output to 1.txt.

find last txb.cls where txb.cls.whn < d1 and txb.cls.del no-lock no-error.
if avail txb.cls and month(txb.cls.whn) <> month(d1) then chk = yes.

do i = 1 to num-entries(lst_grp):
    v-grp = integer(entry(i,lst_grp)).
    for each txb.lon where txb.lon.grp = v-grp no-lock:

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",no,txb.lon.crc,output bilance).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9",no,txb.lon.crc,output proc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"12",no,1,output pol_proc).
        pol_proc = - pol_proc.
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"3,6",no,txb.lon.crc,output prov).
        prov = - prov.
        if txb.lon.crc <> 1 then prov = round(prov * d-rates[txb.lon.crc],2).

        /* пропускаем если ОД=0 и нач.проценты=0 */
        if bilance <= 0 and proc <= 0 and prov <= 0 and pol_proc <= 0 then next.

        create wrk.
        assign wrk.bank = txb.cmp.name
               wrk.gl = txb.lon.gl.

        v_speni = 0.
        for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= d1 and txb.lonres.lev = 5 no-lock:
           if txb.lonres.dc = 'c' then do:
              find first txb.jl where txb.jl.jh = txb.lonres.jh and txb.jl.dc = 'D' no-lock no-error.
              if avail txb.jl then do:
                 if txb.jl.gl = 788000 then do:
                    find first txb.b-jl where txb.b-jl.jh = txb.jl.jh and txb.b-jl.ln = txb.jl.ln + 1 no-lock no-error.
                    if avail txb.b-jl and txb.b-jl.gl = 718000 then v_speni = v_speni + txb.jl.dam.
                 end.
              end.
           end.
        end.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"30",no,1,output v_speni_bal).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"33",no,1,output v_openi).

        wrk.speni = v_speni.
        wrk.speni_bal = v_speni_bal.
        wrk.openi = v_openi.


        find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
        if avail txb.cif then do:
           wrk.name = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
           if txb.cif.type = 'p' then do:

              find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkrst' use-index dcod no-lock no-error.
              if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                find first txb.codfr where txb.codfr.codfr = 'pkrst' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                if avail txb.codfr then wrk.rest = txb.codfr.name[1].
                else wrk.rest = '-'.
              end.
              else wrk.rest = '-'.

              find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkpur' use-index dcod no-lock no-error.
              if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                find first txb.codfr where txb.codfr.codfr = 'pkpur' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                if avail txb.codfr then wrk.crpur = txb.codfr.name[1].
                else wrk.crpur = '-'.
              end.
              else wrk.crpur = '-'.

              find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'hwoker' use-index dcod no-lock no-error.
              if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                find first txb.codfr where txb.codfr.codfr = 'hwoker' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                if avail txb.codfr then wrk.hwoker = txb.codfr.name[1].
                else wrk.hwoker = '-'.
              end.
              else wrk.hwoker = '-'.

              find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'nonstn' use-index dcod no-lock no-error.
              if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                find first txb.codfr where txb.codfr.codfr = 'nonstn' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                if avail txb.codfr then wrk.nostn = txb.codfr.name[1].
                else wrk.nostn = '-'.
              end.
              else wrk.nostn = '-'.

              find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'indbus' use-index dcod no-lock no-error.
              if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                find first txb.codfr where txb.codfr.codfr = 'indbus' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
                if avail txb.codfr then wrk.indbus = txb.codfr.name[1].
                else wrk.indbus = '-'.
              end.
              else wrk.indbus = '-'.
           end.
  /**/
           for each txb.property where txb.property.cif = txb.cif.cif no-lock:
             if txb.property.type = 'real' then do:
               if wrk.realp <> '' then wrk.realp = wrk.realp + '; '.
               wrk.realp = wrk.realp + 'Исх.номер ' + txb.property.outnum + ' дата '.
               if txb.property.outdt <> ? then wrk.realp = wrk.realp + string(txb.property.outdt,'99/99/9999').
               else wrk.realp = wrk.realp + ' (не указана)'.
               wrk.realp = wrk.realp + ' Вход.номер ответа ' + txb.property.innum + ' дата '.
               if txb.property.indt <> ? then wrk.realp = wrk.realp + string(txb.property.indt,'99/99/9999').
               else wrk.realp = wrk.realp + ' (не указана)'.
               if property.des <> '' then wrk.realp = wrk.realp + ' Сведения о наличии имущества: ' + txb.property.des.
             end.
             if txb.property.type = 'mov' then do:
               if wrk.movp <> '' then wrk.movp = wrk.movp + '; '.
               wrk.movp = wrk.movp + 'Гос.номер: ' + txb.property.info[1] + ' Цвет: ' + txb.property.info[2] + ' Марка: ' + txb.property.info[3] + ' Год выпуска: ' + txb.property.info[4] + ' Примечание: ' + txb.property.des.
/*               wrk.movp = wrk.movp + 'Исх.номер ' + txb.property.outnum + ' дата '.
               if txb.property.outdt <> ? then wrk.movp = wrk.movp + string(txb.property.outdt,'99/99/9999').
               else wrk.movp = wrk.movp + ' (не указана)'.
               wrk.movp = wrk.movp + ' Вход.номер ответа ' + txb.property.innum + ' дата '.
               if txb.property.indt <> ? then wrk.movp = wrk.movp + string(txb.property.indt,'99/99/9999').
               else wrk.movp = wrk.movp + ' (не указана)'.
               if property.des <> '' then wrk.movp = wrk.movp + ' Сведения о наличии имущества: ' + txb.property.des.*/

             end.
             if txb.property.type = 'acc' then do:
               if wrk.acc <> '' then wrk.acc = wrk.acc + '; '.
               wrk.acc = wrk.acc + 'Наименование банка ' + txb.property.info[1] + ' Номер счета ' + txb.property.info[2].
             end.
           end.
        end.
        else wrk.name = "НЕ НАЙДЕН".

        assign wrk.cif = txb.lon.cif
               wrk.lon = txb.lon.lon
               wrk.grp = txb.lon.grp
               wrk.plan = txb.lon.plan
               wrk.bankn = city
               wrk.crc = txb.lon.crc
               wrk.rdt = txb.lon.rdt
               wrk.duedt = txb.lon.duedt
               wrk.pol_prc_kzt = pol_proc.

        find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.flp > 0 no-lock no-error.
        if avail txb.lnscg then wrk.isdt = txb.lnscg.stdat.

         /*Сумма чистого дохода, Финансовое состояние*/
        find first txb.ciffinsost where txb.ciffinsost.cif = txb.lon.cif no-lock no-error.
        if avail txb.ciffinsost then do:
         wrk.sumdohod = txb.ciffinsost.sumdohod.
         wrk.finsost = txb.ciffinsost.finsost.
        end.

        /*Схема погашения*/
        find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = 'LON' and sub-cod.d-cod = 'lnpog' use-index dcod no-lock no-error.
        if avail txb.sub-cod then do:
          find first txb.codfr where txb.codfr.codfr = 'lnpog' and txb.codfr.code = txb.sub-cod.ccod no-lock no-error.
          if avail txb.codfr then
            wrk.sxem_pog = txb.codfr.name[1].
          else do:
            find first txb.codfr where txb.codfr.codfr = 'lnpog' and txb.codfr.code = 'msc' no-lock no-error.
            if avail txb.codfr then
              wrk.sxem_pog = txb.codfr.name[1].
          end.
        end. else do:
          find first txb.codfr where txb.codfr.codfr = 'lnpog' and txb.codfr.code = 'msc' no-lock no-error.
          if avail txb.codfr then
            wrk.sxem_pog = txb.codfr.name[1].
        end.

        /* При просрочке более 60 дней - критическое */
        find first txb.londebt where txb.londebt.lon = txb.lon.lon no-lock no-error.
        if avail txb.londebt then do:
         if days_od>60 then
            wrk.finsost = 'Kритическое'.
        end.

        if wrk.finsost = "Стабильное" then wrk.rate = "B".
        else if wrk.finsost = "Удовлетворительное" then wrk.rate = "C".
        else if wrk.finsost = "Неудовлетворительное" then wrk.rate = "D".
        else if wrk.finsost = "Нестабильное" then wrk.rate = "E".
        else if wrk.finsost = "Kритическое" then wrk.rate = "E".
        else if wrk.finsost = "" then do:
            if wrk.crc = 1 then do:
                wrk.finsost = "Стабильное".
                wrk.rate = "B".
            end.
            if wrk.crc = 2 then do:
                wrk.finsost = "Удовлетворительное".
                wrk.rate = "C".
            end.
        end.

        find first txb.sub-cod where txb.sub-cod.sub = 'lon' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnsegm' no-lock no-error.
        if avail txb.sub-cod then wrk.crtype = txb.sub-cod.ccode.

        find first txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
        if avail txb.loncon then wrk.num_dog = txb.loncon.lcnt.

        if txb.lon.ddt[5] <> ? then do:
            wrk.dprolong = txb.lon.ddt[5].
            if txb.lon.ddt[5] >= d1 then wrk.prolong = 1.
        end.
        if txb.lon.cdt[5] <> ? then do:
            wrk.dprolong = txb.lon.cdt[5].
            if txb.lon.cdt[5] >= d1 then wrk.prolong = 2.
        end.
        if txb.lon.duedt >= d1 then wrk.prolong = 0.

        wrk.opnamt = txb.lon.opnamt.
        wrk.opnamt_kzt = txb.lon.opnamt * d-rates[txb.lon.crc].

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"1,7",no,txb.lon.crc,output wrk.ostatok).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"7",no,txb.lon.crc,output wrk.prosr_od).

        wrk.ostatok_kzt = wrk.ostatok * d-rates[txb.lon.crc].
        wrk.prosr_od_kzt = wrk.prosr_od * d-rates[txb.lon.crc].

        find last txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat < d1 no-lock no-error.
        if avail txb.ln%his then wrk.prem = txb.ln%his.intrate.
        else wrk.prem = txb.lon.prem.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"2,9",no,txb.lon.crc,output wrk.nach_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"9",no,txb.lon.crc,output wrk.prosr_prc).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"4",no,txb.lon.crc,output wrk.prosr_prc_zabal).

        wrk.dayc_od = 0. wrk.dayc_prc = 0. v-prov_prcf = 0.
        if (wrk.prosr_od > 0) or (wrk.prosr_prc > 0) or (chk) then do:
            run lndayspr_txb(txb.lon.lon,d1,no,output wrk.dayc_od,output wrk.dayc_prc).
            run lndaysprf_txb(txb.lon.lon,d1,no,output wrk.fdayc_od,output wrk.fdayc_prc).

            find last txb.jl where txb.jl.sub = "cif" and txb.jl.acc = txb.lon.aaa and txb.jl.lev = 1 and txb.jl.dc = "C" no-lock no-error.
            if avail txb.jl then do:
                wrk.dayop = d1 - txb.jl.jdt - 1.
                for each bjl where bjl.jdt = txb.jl.jdt and bjl.sub = "cif" and bjl.acc = txb.lon.aaa and bjl.lev = 1 and bjl.dc = "C" no-lock:
                    wrk.sumop = wrk.sumop + bjl.cam.
                end.
            end.
        end.

        if wrk.ostatok > 0 then do:
            if wrk.fdayc_od > wrk.fdayc_prc then v-days_f = wrk.fdayc_od. else v-days_f = wrk.fdayc_prc.
            if v-days_f = 0 then v-gr_id = 1.
            else
            if v-days_f < 31 then v-gr_id = 2.
            else
            if v-days_f < 61 then v-gr_id = 3.
            else
            if v-days_f < 91 then v-gr_id = 4.
            else
            if v-days_f < 181 then v-gr_id = 5.
            else
            if v-days_f < 361 then v-gr_id = 6.
            else v-gr_id = 7.

            find first wrk1 where wrk1.rep_id = 1 and wrk1.bank = s-ourbank and wrk1.id = v-gr_id no-error.
            if not avail wrk1 then do:
                create wrk1.
                assign wrk1.rep_id = 1
                       wrk1.bank = s-ourbank
                       wrk1.bank_name = v-bankname
                       wrk1.id = v-gr_id.
            end.

            wrk1.kol = wrk1.kol + 1.
            if txb.lon.crc = 1 then assign wrk1.od = wrk1.od + wrk.ostatok wrk1.odp = wrk1.odp + wrk.prosr_od.
            else do:
                wrk1.od = wrk1.od + wrk.ostatok * d-rates[txb.lon.crc].
                wrk1.odp = wrk1.odp + wrk.prosr_od * d-rates[txb.lon.crc].
            end.

            if wrk.dayc_od > wrk.dayc_prc then v-days_f = wrk.dayc_od. else v-days_f = wrk.dayc_prc.
            if v-days_f = 0 then v-gr_id = 1.
            else
            if v-days_f < 31 then v-gr_id = 2.
            else
            if v-days_f < 61 then v-gr_id = 3.
            else
            if v-days_f < 91 then v-gr_id = 4.
            else
            if v-days_f < 181 then v-gr_id = 5.
            else
            if v-days_f < 361 then v-gr_id = 6.
            else v-gr_id = 7.

            find first b-wrk1 where b-wrk1.rep_id = 2 and b-wrk1.bank = s-ourbank and b-wrk1.id = v-gr_id no-error.
            if not avail b-wrk1 then do:
                create b-wrk1.
                assign b-wrk1.rep_id = 2
                       b-wrk1.bank = s-ourbank
                       b-wrk1.bank_name = v-bankname
                       b-wrk1.id = v-gr_id.
            end.

            b-wrk1.kol = b-wrk1.kol + 1.
            if txb.lon.crc = 1 then assign b-wrk1.od = b-wrk1.od + wrk.ostatok b-wrk1.odp = b-wrk1.odp + wrk.prosr_od.
            else do:
                b-wrk1.od = b-wrk1.od + wrk.ostatok * d-rates[txb.lon.crc].
                b-wrk1.odp = b-wrk1.odp + wrk.prosr_od * d-rates[txb.lon.crc].
            end.
        end.

        /* расчет ежемесячного платежа */
        wrk.mpayment = 0.

        run day-360(txb.lon.rdt,lon.duedt - 1,360,output dn1,output dn2).
        wrk.mpayment = round(txb.lon.opnamt * 30 / dn1, 2).
        if txb.lon.prem = 0 then do:
            find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = txb.lon.lon no-lock no-error.
            if avail pkanketa then wrk.mpayment = wrk.mpayment + round(txb.lon.opnamt * pkanketa.rateq / 1200,2).
        end.
        else wrk.mpayment = wrk.mpayment + round(txb.lon.opnamt * txb.lon.prem / 1200,2).
        find first txb.tarifex2 where txb.tarifex2.aaa = txb.lon.aaa and txb.tarifex2.cif = txb.lon.cif and txb.tarifex2.str5 = "195" and txb.tarifex2.stat = 'r' no-lock no-error.
        if avail txb.tarifex2 then wrk.mpayment = wrk.mpayment + txb.tarifex2.ost.

        if (wrk.prosr_od > 0) then do:
            qq = wrk.prosr_od / round(txb.lon.opnamt * 30 / dn1, 2).
            qq = round(qq,0).
            wrk.fdayc_od2 = qq.
        end.

        if wrk.fdayc_od > wrk.fdayc_prc then v-days_f = wrk.fdayc_od. else v-days_f = wrk.fdayc_prc.
        if (txb.lon.plan = 4) or (txb.lon.plan = 5) then do:
            if txb.lon.crc = 1 then do:
                if v-days_f < 7 then v-prov_prcf = 0.
                else
                if v-days_f >= 7 and v-days_f <= 30 then v-prov_prcf = 50.
                else v-prov_prcf = 100.
            end.
            if txb.lon.crc = 2 then do:
                if v-days_f >= 7 then v-prov_prcf = 100. else v-prov_prcf = 20.
            end.
        end.

        for each txb.bxcif where txb.bxcif.cif = txb.lon.cif and txb.bxcif.aaa = txb.lon.aaa and txb.bxcif.type = "195" no-lock:
            wrk.comdolg = wrk.comdolg + bxcif.amount.
        end.

        wrk.n_prov = round(wrk.ostatok_kzt * v-prov_prcf / 100,2).

        wrk.nach_prc_kzt = wrk.nach_prc * d-rates[txb.lon.crc].
        wrk.prosr_prc_kzt = wrk.prosr_prc * d-rates[txb.lon.crc].
        wrk.prosr_prc_zab_kzt = wrk.prosr_prc_zabal * d-rates[txb.lon.crc].

        find last txb.lnsci where txb.lnsci.lni = txb.lon.lon and txb.lnsci.idat < d1 and txb.lnsci.flp > 0 and txb.lnsci.f0 = 0 no-lock no-error.
        if avail txb.lnsci then wrk.prcdt_last = txb.lnsci.idat.

        run lonbalcrc_txb('lon',txb.lon.lon,d1,"16",no,1,output wrk.penalty).
        run lonbalcrc_txb('lon',txb.lon.lon,d1,"5",no,1,output wrk.penalty_zabal).

        run lonbalcrc_txb('cif',txb.lon.aaa,d1,"1",no,txb.lon.crc,output wrk.ostatok_aaa).
        wrk.ostatok_aaa = - wrk.ostatok_aaa.
        /*расчет суммы поступлений за время существования кредита*/
        for each txb.jl where txb.jl.acc = txb.lon.aaa and txb.jl.dc = 'C' and txb.jl.jdt >= txb.lon.rdt and txb.jl.jdt <= g-today no-lock use-index accdcjdt:
          if txb.jl.jdt = txb.lon.rdt then do:
            find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
            if avail b-jl and b-jl.acc = txb.lon.lon then next.
          end.
          wrk.aaabal = wrk.aaabal + txb.jl.cam.
        end.
        /*
        for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.lev = 16 and txb.lonres.dc = 'c' no-lock:
            find first txb.jl where txb.jl.
        end.
        */
        for each txb.jl where txb.jl.acc = txb.lon.lon and txb.jl.dc = 'C' and txb.jl.jdt >= txb.lon.rdt and txb.jl.jdt < d1 and txb.jl.lev = 16 no-lock:
            find first bjl where bjl.jh = txb.jl.jh and bjl.ln = txb.jl.ln - 1 no-lock no-error.
            if bjl.sub = 'CIF' then wrk.penalty_pol = wrk.penalty_pol + txb.jl.cam.
        end.

        if wrk.ostatok > 0 then do:
            assign wrk1.nachprc = wrk1.nachprc + wrk.nach_prc_kzt
                   wrk1.polprc = wrk1.polprc + wrk.pol_prc_kzt
                   wrk1.prosrprc = wrk1.prosrprc + wrk.prosr_prc_kzt
                   wrk1.nachprcz = wrk1.nachprcz + wrk.prosr_prc_zab_kzt
                   wrk1.pen = wrk1.pen + wrk.penalty
                   wrk1.penz = wrk1.penz + wrk.penalty_zabal
                   wrk1.polpen = wrk1.polpen + wrk.penalty_pol.
            assign b-wrk1.nachprc = b-wrk1.nachprc + wrk.nach_prc_kzt
                   b-wrk1.polprc = b-wrk1.polprc + wrk.pol_prc_kzt
                   b-wrk1.prosrprc = b-wrk1.prosrprc + wrk.prosr_prc_kzt
                   b-wrk1.nachprcz = b-wrk1.nachprcz + wrk.prosr_prc_zab_kzt
                   b-wrk1.pen = b-wrk1.pen + wrk.penalty
                   b-wrk1.penz = b-wrk1.penz + wrk.penalty_zabal
                   b-wrk1.polpen = b-wrk1.polpen + wrk.penalty_pol.

            if txb.cif.type = 'p' then do:

                if wrk.fdayc_od > wrk.fdayc_prc then v-days_f = wrk.fdayc_od. else v-days_f = wrk.fdayc_prc.
                if v-days_f = 0 then v-gr_id = 1.
                else
                if v-days_f < 31 then v-gr_id = 2.
                else
                if v-days_f < 61 then v-gr_id = 3.
                else
                if v-days_f < 91 then v-gr_id = 4.
                else
                if v-days_f < 181 then v-gr_id = 5.
                else
                if v-days_f < 361 then v-gr_id = 6.
                else v-gr_id = 7.

                find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'hwoker' use-index dcod no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:
                    find first wrk2 where wrk2.rep_id = 1 and wrk2.priz_id = txb.sub-cod.ccod and wrk2.bank = s-ourbank and wrk2.id = v-gr_id no-error.
                    if not avail wrk2 then do:
                        create wrk2.
                        assign wrk2.rep_id = 1
                               wrk2.priz_id = txb.sub-cod.ccod
                               wrk2.bank = s-ourbank
                               wrk2.bank_name = v-bankname
                               wrk2.id = v-gr_id.
                    end.

                    wrk2.kol = wrk2.kol + 1.
                    if txb.lon.crc = 1 then assign wrk2.od = wrk2.od + wrk.ostatok wrk2.odp = wrk2.odp + wrk.prosr_od.
                    else do:
                        wrk2.od = wrk2.od + wrk.ostatok * d-rates[txb.lon.crc].
                        wrk2.odp = wrk2.odp + wrk.prosr_od * d-rates[txb.lon.crc].
                    end.
                    assign wrk2.nachprc = wrk2.nachprc + wrk.nach_prc_kzt
                           wrk2.prosrprc = wrk2.prosrprc + wrk.prosr_prc_kzt
                           wrk2.nachprcz = wrk2.nachprcz + wrk.prosr_prc_zab_kzt
                           wrk2.pen = wrk2.pen + wrk.penalty
                           wrk2.penz = wrk2.penz + wrk.penalty_zabal.
                end.

                find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'nonstn' use-index dcod no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:

                    find first wrk2 where wrk2.rep_id = 3 and wrk2.priz_id = txb.sub-cod.ccod and wrk2.bank = s-ourbank and wrk2.id = v-gr_id no-error.
                    if not avail wrk2 then do:

                        create wrk2.
                        assign wrk2.rep_id = 3
                               wrk2.priz_id = txb.sub-cod.ccod
                               wrk2.bank = s-ourbank
                               wrk2.bank_name = v-bankname
                               wrk2.id = v-gr_id.
                    end.

                    wrk2.kol = wrk2.kol + 1.
                    if txb.lon.crc = 1 then assign wrk2.od = wrk2.od + wrk.ostatok wrk2.odp = wrk2.odp + wrk.prosr_od.
                    else do:
                        wrk2.od = wrk2.od + wrk.ostatok * d-rates[txb.lon.crc].
                        wrk2.odp = wrk2.odp + wrk.prosr_od * d-rates[txb.lon.crc].
                    end.
                    assign wrk2.nachprc = wrk2.nachprc + wrk.nach_prc_kzt
                           wrk2.prosrprc = wrk2.prosrprc + wrk.prosr_prc_kzt
                           wrk2.nachprcz = wrk2.nachprcz + wrk.prosr_prc_zab_kzt
                           wrk2.pen = wrk2.pen + wrk.penalty
                           wrk2.penz = wrk2.penz + wrk.penalty_zabal.

                end.

                find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = 'CLN' and sub-cod.d-cod = 'indbus' use-index dcod no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccod <> 'msc' then do:

                    find first wrk2 where wrk2.rep_id = 2 and wrk2.priz_id = txb.sub-cod.ccod and wrk2.bank = s-ourbank and wrk2.id = v-gr_id no-error.
                    if not avail wrk2 then do:

                        create wrk2.
                        assign wrk2.rep_id = 2
                               wrk2.priz_id = txb.sub-cod.ccod
                               wrk2.bank = s-ourbank
                               wrk2.bank_name = v-bankname
                               wrk2.id = v-gr_id.
                    end.

                    wrk2.kol = wrk2.kol + 1.
                    if txb.lon.crc = 1 then assign wrk2.od = wrk2.od + wrk.ostatok wrk2.odp = wrk2.odp + wrk.prosr_od.
                    else do:
                        wrk2.od = wrk2.od + wrk.ostatok * d-rates[txb.lon.crc].
                        wrk2.odp = wrk2.odp + wrk.prosr_od * d-rates[txb.lon.crc].
                    end.
                    assign wrk2.nachprc = wrk2.nachprc + wrk.nach_prc_kzt
                           wrk2.prosrprc = wrk2.prosrprc + wrk.prosr_prc_kzt
                           wrk2.nachprcz = wrk2.nachprcz + wrk.prosr_prc_zab_kzt
                           wrk2.pen = wrk2.pen + wrk.penalty
                           wrk2.penz = wrk2.penz + wrk.penalty_zabal.

                end.
            end. /*cif.type = 'p'*/
        end.


        find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt < d1 no-lock no-error.
        if avail txb.lonhar then do:
            find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
            if avail txb.lonstat then wrk.rezprc = txb.lonstat.prc.
        end.
        wrk.rezsum = prov.

    end. /* for each txb.lon */

end. /* do i = 1 to */

output close.

