/* r-lnday2.p
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
        17/06/2004 madiar - расчетная часть вынесена из r-lnday.p
 * BASES
        BANK COMM TXB
 * CHANGES
        29/10/2004 madiyar - статус юр/физ определяется по признаку "сектор экономики"
        01/11/2004 madiyar - для третьего отчета заполняется таблица port
        17/11/2004 madiyar - изменение расчетов - для третьего отчета все собирается в массивы sumport и kolport
        19/11/2004 madiyar - индексы
        13/12/2004 madiyar - добавил количество списанных кредитов
        19/01/2005 madiyar - добавил подсчет количества всех кредитов с выдачами (не только новых)
        01/02/2005 madiyar - убрал индексированные уровни из ОД
        24/03/2005 madiyar - добавил 4-ый отчет, формируется таблица port2
        30/03/2005 madiyar - подправил подсчет новых выданных и полностью погашенных кредитов (учел кредитные линии)
        06/09/2005 madiyar - теперь все считается по курсу за день операции, а не за конец периода
        03/10/2005 madiyar - во временной таблице добавил поля для сумм в KZT по курсу за день операции
        28/03/2006 madiyar - пропускаем записи в истории, для которых не находятся кредиты
        29/03/2006 madiyar - в детализированный отчет добавил группу кредита, ставку и признак "краткоср/долгоср"
        10/10/2006 madiyar - no-undo
        11/10/2006 madiyar - убрал лишнее поле port.city
        16/04/2007 madiyar - поменял название "БД" на "Экспресс-кредиты"
        22/07/2009 madiyar - вариант по непросроченным + комиссия
        01.09.2011 damir   - добавил входной параметр p-namebank.
        04.07.2012 damir   - добавил конвертацию crc <> 1 в тенге по просьбе МИДЛ-ОФИС.
        05.07.2012 kapar   - включил новые группы
*/

def input parameter dt1        as date no-undo.
def input parameter dt2        as date no-undo.
def input parameter p-namebank as char no-undo.

def shared var s-prosr as logi.

def var s-bank as char no-undo.

def var bilance as deci no-undo extent 2.
def var sumport as deci no-undo extent 30.
def var kolport as int no-undo extent 30.
/*
1-10 - ЮЛ, 11-12 - ФЛ, 21-30 - БД
1 - Портфель на dt1
2 - Портфель на dt2
3 - Выдано (кол - новых, сум - все)
4 - Всего погашено за период (lnsch)
5 - Полностью погашено за период (lnsch)
6 - Частично погашено за период (lnsch)
7 - Списано за период (bilance)
8 - Выдано (кол - все, сум - не используется)
*/
def var i_start as int no-undo.
def var vnebal as deci no-undo extent 2.
def var bb as deci no-undo.
kolport = 0. sumport = 0.

def var llon like txb.lon.lon.

def buffer b-jl for txb.jl.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-bank = txb.sysc.chval.

def shared temp-table crover_vyd no-undo
    field bank   as   char
    field prname as   char
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field gua    like txb.lon.gua
    field crc    like txb.lon.crc
    field opnamt as   deci
    field paid   as   deci
    field paidt  as   deci
    field who    like txb.lnscg.who
    field urfiz  as   integer
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary paid bank urfiz
    index ind2 paid urfiz bank crc cif.

def shared temp-table crover_pog no-undo
    field bank   as   char
    field prname as   char
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field gua    like txb.lon.gua
    field crc    like txb.lon.crc
    field opnamt as   deci
    field sum1   like txb.lon.opnamt
    field sum2   like txb.lon.opnamt
    field sum1t  like txb.lon.opnamt
    field sum2t  like txb.lon.opnamt
    field who    like txb.lnsch.who
    field urfiz  as   integer
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary sum1 sum2 bank urfiz
    index ind2 bank lon who
    index ind3 sum1 sum2 urfiz bank crc cif.

def shared temp-table bd_vyd no-undo
    field bank   as   char
    field prname as   char
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field crc    like txb.lon.crc
    field paid   like txb.lon.opnamt
    field duedt  like txb.lon.duedt
    field who    like txb.lnsch.who
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary paid bank
    index ind2 paid crc bank cif.

def shared temp-table bd_pog no-undo
    field bank   as   char
    field prname as   char
    field cif    like txb.lon.cif
    field lon    like txb.lon.lon
    field crc    like txb.lon.crc
    field sum1   like txb.lon.opnamt
    field sum2   like txb.lon.opnamt
    field sum3   like txb.lon.opnamt
    field duedt  like txb.lon.duedt
    field who    like txb.lnsch.who
    field grp    as   integer
    field prem   as   deci
    field krdo   as   logical
    index ind is primary sum1 sum2 bank
    index ind2 bank lon who
    index ind3 sum1 sum2 crc bank cif.

def shared temp-table port no-undo
    field bank         as   char
    field ln           as   integer
    field sts          as   char
    field kol1         as   integer
    field sum1         as   deci
    field kol2         as   integer
    field sum2         as   deci
    field kol_vyd_all  as   integer
    field kol_vyd      as   integer
    field sum_vyd      as   deci
    field kol_pog      as   integer
    field sum_pog      as   deci
    field sum_pog_full as   deci
    field sum_pog_part as   deci
    field sum_spis     as   deci
    field kol_spis     as   integer
    index ind is primary bank ln.

define shared temp-table port2 no-undo
  field bank as character
  field ids_name as character
  field urfiz as integer
  field crc like txb.crc.crc
  field coun as integer extent 4
  field sum as decimal extent 4
  index idx is primary bank urfiz crc.

def var dlong as date no-undo.

/* 1. выданные кредиты и овердрафты */

hide message no-pause.
message " Обработка " + s-bank + " - Выдача ".


llon = ''.
for each txb.lnscg where (txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2) and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0
                         and txb.lnscg.flp > 0 no-lock break by txb.lnscg.lng:
  find first txb.lon where txb.lon.lon = txb.lnscg.lng no-lock no-error.
  if not avail txb.lon then next.
  find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
  find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnscg.stdat no-lock no-error.
  if not (txb.lon.grp = 90 or txb.lon.grp = 92) then do:
     find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
     create crover_vyd.
     crover_vyd.bank = p-namebank.
     crover_vyd.prname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
     crover_vyd.cif = txb.cif.cif.
     crover_vyd.lon = txb.lon.lon.
     crover_vyd.gua = txb.lon.gua.
     crover_vyd.crc = txb.lon.crc.
     crover_vyd.opnamt = txb.lon.opnamt.
     crover_vyd.paid = txb.lnscg.paid.
     crover_vyd.paidt = txb.lnscg.paid * txb.crchis.rate[1].
     crover_vyd.who = txb.lnscg.who.
     if txb.sub-cod.ccode = '9' then crover_vyd.urfiz = 1.
     else crover_vyd.urfiz = 0.
     crover_vyd.grp = txb.lon.grp.
     crover_vyd.prem = txb.lon.prem.
     if substring(string(txb.lon.gl,"999999"),4,1) = '1' then crover_vyd.krdo = yes.
     else crover_vyd.krdo = no.
     if txb.sub-cod.ccode = '9' then do:
       sumport[13] = sumport[13] + txb.lnscg.paid * txb.crchis.rate[1].
       if llon <> txb.lon.lon then kolport[18] = kolport[18] + 1.
     end.
     else do:
       sumport[3] = sumport[3] + txb.lnscg.paid * txb.crchis.rate[1].
       if llon <> txb.lon.lon then kolport[8] = kolport[8] + 1.
     end.
  end.
  else
  if txb.lon.grp = 90 or txb.lon.grp = 92 then do:
     find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
     create bd_vyd.
     bd_vyd.bank = p-namebank.
     bd_vyd.prname = trim(txb.cif.name).
     bd_vyd.cif = txb.lon.cif.
     bd_vyd.lon = txb.lon.lon.
     bd_vyd.crc = txb.lon.crc.
     bd_vyd.paid = txb.lnscg.paid.
     bd_vyd.duedt = txb.lon.duedt.
     bd_vyd.who = txb.lnscg.who.
     bd_vyd.grp = txb.lon.grp.
     bd_vyd.prem = txb.lon.prem.
     if substring(string(txb.lon.gl,"999999"),4,1) = '1' then bd_vyd.krdo = yes.
     else bd_vyd.krdo = no.
     sumport[23] = sumport[23] + txb.lnscg.paid * txb.crchis.rate[1].
     if llon <> txb.lon.lon then kolport[28] = kolport[28] + 1.
  end.

  llon = txb.lon.lon.

end.

/* 1 - выданные кредиты и овердрафты - end */

/* 2. погашенные кредиты и овердрафты */

hide message no-pause.
message " Обработка " + s-bank + " - Погашение ".

for each txb.lnsch where (txb.lnsch.stdat >= dt1 and txb.lnsch.stdat <= dt2) and txb.lnsch.flp > 0 no-lock:

      find first txb.lon where txb.lon.lon = txb.lnsch.lnn no-lock no-error.
      if not avail txb.lon then next.
      run lonbal_txb('lon',txb.lon.lon,dt2,"1,7",yes,output bilance[2]).

      if s-prosr then do:
          run lonbalcrc_txb('lon',txb.lon.lon,txb.lnsch.stdat,"7",no,txb.lon.crc,output bilance[2]).
          if bilance[2] > 0 then next.
      end.

      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsch.stdat no-lock no-error.
      if not (txb.lon.grp = 90 or txb.lon.grp = 92) then do:
         find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
         find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         create crover_pog.
         crover_pog.bank = p-namebank.
         crover_pog.prname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
         crover_pog.cif = txb.lon.cif.
         crover_pog.lon = txb.lon.lon.
         crover_pog.gua = txb.lon.gua.
         crover_pog.crc = txb.lon.crc.
         crover_pog.opnamt = txb.lon.opnamt.
         crover_pog.who = txb.lnsch.who.
         if txb.sub-cod.ccode = '9' then crover_pog.urfiz = 1.
         else crover_pog.urfiz = 0.
         crover_pog.grp = txb.lon.grp.
         crover_pog.prem = txb.lon.prem.
         if substring(string(txb.lon.gl,"999999"),4,1) = '1' then crover_pog.krdo = yes.
         else crover_pog.krdo = no.
         crover_pog.sum1 = txb.lnsch.paid.
         crover_pog.sum1t = txb.lnsch.paid * txb.crchis.rate[1].
         if txb.sub-cod.ccode = '9' then do:
           sumport[14] = sumport[14] + txb.lnsch.paid * txb.crchis.rate[1].
           if bilance[2] <= 0 then sumport[15] = sumport[15] + txb.lnsch.paid * txb.crchis.rate[1].
           else sumport[16] = sumport[16] + txb.lnsch.paid * txb.crchis.rate[1].
         end.
         else do:
           sumport[4] = sumport[4] + txb.lnsch.paid * txb.crchis.rate[1].
           if bilance[2] <= 0 then sumport[5] = sumport[5] + txb.lnsch.paid * txb.crchis.rate[1].
           else sumport[6] = sumport[6] + txb.lnsch.paid * txb.crchis.rate[1].
         end.
      end.
      else
      if txb.lon.grp = 90 or txb.lon.grp = 92 then do:
         dlong = txb.lon.duedt.
         if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
         if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].
         find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
         create bd_pog.
         bd_pog.bank = p-namebank.
         bd_pog.prname = trim(txb.cif.name).
         bd_pog.cif = txb.lon.cif.
         bd_pog.lon = txb.lon.lon.
         bd_pog.crc = txb.lon.crc.
         bd_pog.duedt = dlong.
         bd_pog.who = txb.lnsch.who.
         bd_pog.grp = txb.lon.grp.
         bd_pog.prem = txb.lon.prem.
         if substring(string(txb.lon.gl,"999999"),4,1) = '1' then bd_pog.krdo = yes.
         else bd_pog.krdo = no.
         bd_pog.sum1 = bd_pog.sum1 + txb.lnsch.paid * txb.crchis.rate[1].
         sumport[24] = sumport[24] + txb.lnsch.paid * txb.crchis.rate[1].
         if bilance[2] <= 0 then sumport[25] = sumport[25] + txb.lnsch.paid * txb.crchis.rate[1].
         else sumport[26] = sumport[26] + txb.lnsch.paid * txb.crchis.rate[1].
    end.

end.

for each txb.lnsci where (txb.lnsci.idat >= dt1 and txb.lnsci.idat <= dt2) and txb.lnsci.fpn = 0 and txb.lnsci.flp > 0 no-lock:

      find first txb.lon where txb.lon.lon = txb.lnsci.lni no-lock no-error.
      if not avail txb.lon then next.

      if s-prosr then do:
        run lonbalcrc_txb('lon',txb.lon.lon,txb.lnsci.idat,"7",no,txb.lon.crc,output bilance[2]).
        if bilance[2] > 0 then next.
      end.

      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lnsci.idat no-lock no-error.
      if not (txb.lon.grp = 90 or txb.lon.grp = 92) then do:
         find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
         find first crover_pog where crover_pog.bank = p-namebank and crover_pog.lon = txb.lon.lon and crover_pog.who = txb.lnsci.who use-index ind2 no-error.
         if not avail crover_pog then do:
           find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
           create crover_pog.
           crover_pog.bank = p-namebank.
           crover_pog.prname = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
           crover_pog.cif = txb.lon.cif.
           crover_pog.lon = txb.lon.lon.
           crover_pog.gua = txb.lon.gua.
           crover_pog.crc = txb.lon.crc.
           crover_pog.who = txb.lnsci.who.
           if txb.sub-cod.ccode = '9' then crover_pog.urfiz = 1.
           else crover_pog.urfiz = 0.
           crover_pog.grp = txb.lon.grp.
           crover_pog.prem = txb.lon.prem.
           if substring(string(txb.lon.gl,"999999"),4,1) = '1' then crover_pog.krdo = yes.
           else crover_pog.krdo = no.
         end.
         crover_pog.sum2 = crover_pog.sum2 + txb.lnsci.paid-iv.
         crover_pog.sum2t = crover_pog.sum2t + txb.lnsci.paid-iv * txb.crchis.rate[1].
      end.
      if txb.lon.grp = 90 or txb.lon.grp = 92 then do:
         find first bd_pog where bd_pog.bank = p-namebank and bd_pog.lon = txb.lon.lon and bd_pog.who = txb.lnsci.who use-index ind2 no-error.
         if not avail bd_pog then do:
           dlong = txb.lon.duedt.
           if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
           if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].
           find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
           create bd_pog.
           bd_pog.bank = p-namebank.
           bd_pog.prname = trim(txb.cif.name).
           bd_pog.cif = txb.lon.cif.
           bd_pog.lon = txb.lon.lon.
           bd_pog.crc = txb.lon.crc.
           bd_pog.duedt = dlong.
           bd_pog.who = txb.lnsci.who.
           bd_pog.grp = txb.lon.grp.
           bd_pog.prem = txb.lon.prem.
           if substring(string(txb.lon.gl,"999999"),4,1) = '1' then bd_pog.krdo = yes.
           else bd_pog.krdo = no.
         end.
         bd_pog.sum2 = bd_pog.sum2 + txb.lnsci.paid-iv * txb.crchis.rate[1].
      end.

end.

for each txb.jl where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 and txb.jl.gl = 460712 and txb.jl.dc = 'C' no-lock:
    find first b-jl where b-jl.jh = txb.jl.jh and b-jl.ln = txb.jl.ln - 1 no-lock no-error.
    if avail b-jl and b-jl.sub = 'cif' then do:
        find first txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
        if not avail txb.aaa then next.
        find first txb.lon where txb.lon.cif = txb.aaa.cif and txb.lon.aaa = txb.aaa.aaa no-lock no-error.
        if not avail txb.lon then next.
        find first bd_pog where bd_pog.bank = p-namebank and bd_pog.lon = txb.lon.lon and bd_pog.who = txb.jl.who use-index ind2 no-error.
        if not avail bd_pog then do:
            find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= b-jl.jdt no-lock no-error.
            dlong = txb.lon.duedt.
            if txb.lon.ddt[5] <> ? then dlong = txb.lon.ddt[5].
            if txb.lon.cdt[5] <> ? then dlong = txb.lon.cdt[5].
            find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
            create bd_pog.
            bd_pog.bank = p-namebank.
            bd_pog.prname = trim(txb.cif.name).
            bd_pog.cif = txb.lon.cif.
            bd_pog.lon = txb.lon.lon.
            bd_pog.crc = txb.lon.crc.
            bd_pog.duedt = dlong.
            bd_pog.who = txb.jl.who.
            bd_pog.grp = txb.lon.grp.
            bd_pog.prem = txb.lon.prem.
            if substring(string(txb.lon.gl,"999999"),4,1) = '1' then bd_pog.krdo = yes.
            else bd_pog.krdo = no.
        end.
        bd_pog.sum3 = bd_pog.sum3 + txb.jl.cam * txb.crchis.rate[1].
    end.
end.

/* 2 - погашенные кредиты и овердрафты - end */

/* 3. портфель */

hide message no-pause.
message " Обработка " + s-bank + " - Портфель ".

def var v-urfiz as integer.
def var dt_prolong as date.

for each txb.lon no-lock:

  if txb.lon.opnamt = 0 then next.
  run lonbal_txb('lon',txb.lon.lon,dt1,"1,7",no,output bilance[1]).
  run lonbal_txb('lon',txb.lon.lon,dt2,"1,7",yes,output bilance[2]).

  dt_prolong = txb.lon.duedt.
  if txb.lon.ddt[5] <> ? then dt_prolong = txb.lon.ddt[5].
  if txb.lon.cdt[5] <> ? then dt_prolong = txb.lon.cdt[5].

  if bilance[1] + bilance[2] > 0 then do:
     if txb.lon.grp = 90 or txb.lon.grp = 92 then do: i_start = 20. v-urfiz = 1. end.
     else do:
       find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
       if txb.sub-cod.ccode = '9' then do: i_start = 10. v-urfiz = 1. end. else do: i_start = 0. v-urfiz = 0. end.
     end.

     find first port2 where port2.bank = s-bank and port2.urfiz = v-urfiz and port2.crc = txb.lon.crc no-error.
     if not avail port2 then do:
       create port2.
       port2.bank = s-bank.
       port2.urfiz = v-urfiz.
       port2.crc = txb.lon.crc.
       find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
       port2.ids_name = if v-urfiz = 0 then "ЮР" + ' ' + txb.crc.code else "ФИЗ" + ' ' + txb.crc.code.
     end.

     if bilance[1] > 0 then do: /* портфель на dt1 */
       find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt < dt1 no-lock no-error.
       kolport[i_start + 1] = kolport[i_start + 1] + 1.
       sumport[i_start + 1] = sumport[i_start + 1] + bilance[1] * txb.crchis.rate[1].

       port2.coun[1] = port2.coun[1] + 1.
       port2.sum[1] = port2.sum[1] + bilance[1].
     end.

     if bilance[2] > 0 then do: /* портфель на dt2 */
       find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= dt2 no-lock no-error.
       kolport[i_start + 2] = kolport[i_start + 2] + 1.
       sumport[i_start + 2] = sumport[i_start + 2] + bilance[2] * txb.crchis.rate[1].

       port2.coun[2] = port2.coun[2] + 1.
       port2.sum[2] = port2.sum[2] + bilance[2].
     end.

     if bilance[1] > 0 and bilance[2] <= 0 then do:
       if caps(trim(txb.lon.gua)) <> 'CL' or (caps(trim(txb.lon.gua)) = 'CL' and dt_prolong >= dt1 and dt_prolong <= dt2) then do:
         kolport[i_start + 5] = kolport[i_start + 5] + 1. /* считаем количество только полностью погашенных кредитов */
         port2.coun[4] = port2.coun[4] + 1.
       end.
     end.
     if bilance[1] <= 0 and bilance[2] > 0 then do:
       if caps(trim(txb.lon.gua)) <> 'CL' or (caps(trim(txb.lon.gua)) = 'CL' and txb.lon.rdt >= dt1 and txb.lon.rdt <= dt2) then do:
         kolport[i_start + 3] = kolport[i_start + 3] + 1. /* считаем количество только новых кредитов */
         port2.coun[3] = port2.coun[3] + 1.
       end.
     end.

  end.
  else do: /* bilance[1] + bilance[2] = 0 - проверим, может кредит был выдан и сразу погашен внутри заданного периода */
     if dt1 - txb.lon.rdt > 30 or txb.lon.rdt > dt2 then next.

     find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and (txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2) and txb.lnscg.f0 > - 1
                        and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.
     if avail txb.lnscg and txb.lnscg.paid > 0 then do:
        if txb.lon.grp = 90 or txb.lon.grp = 92 then do: i_start = 20. v-urfiz = 1. end.
        else do:
          find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
          if txb.sub-cod.ccode = '9' then do: i_start = 10. v-urfiz = 1. end. else do: i_start = 0. v-urfiz = 0. end.
        end.

        find first port2 where port2.bank = s-bank and port2.urfiz = v-urfiz and port2.crc = txb.lon.crc no-error.
        if not avail port2 then do:
          create port2.
          port2.bank = s-bank.
          port2.urfiz = v-urfiz.
          port2.crc = txb.lon.crc.
          find first txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
          port2.ids_name = if v-urfiz = 0 then "ЮР" + ' ' + txb.crc.code else "ФИЗ" + ' ' + txb.crc.code.
        end.

        if caps(trim(txb.lon.gua)) <> 'CL' then do:
          kolport[i_start + 3] = kolport[i_start + 3] + 1.
          kolport[i_start + 5] = kolport[i_start + 5] + 1.
          port2.coun[3] = port2.coun[3] + 1.
          port2.coun[4] = port2.coun[4] + 1.
        end.
        else do:
          if dt_prolong >= dt1 and dt_prolong <= dt2 then do:
            kolport[i_start + 5] = kolport[i_start + 5] + 1.
            port2.coun[4] = port2.coun[4] + 1.
          end.
          if txb.lon.rdt >= dt1 and txb.lon.rdt <= dt2 then do:
            kolport[i_start + 3] = kolport[i_start + 3] + 1.
            port2.coun[3] = port2.coun[3] + 1.
          end.
        end.
     end.
  end.

  /* списание */
  /*
  vnebal = 0.
  find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 13 and txb.histrxbal.dt <= dt2 no-lock no-error.
  if avail txb.histrxbal then do:
    vnebal[2] = txb.histrxbal.dam.
    find last txb.histrxbal where txb.histrxbal.subled = 'lon' and txb.histrxbal.acc = txb.lon.lon and txb.histrxbal.level = 13 and txb.histrxbal.dt < dt1 no-lock no-error.
    if avail txb.histrxbal then vnebal[1] = txb.histrxbal.dam.
  end.
  if vnebal[2] - vnebal[1] > 0 then do:
      if txb.lon.grp = 90 or txb.lon.grp = 92 then i_start = 20.
      else do:
        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
        if txb.sub-cod.ccode = '9' then i_start = 10. else i_start = 0.
      end.
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= dt2 no-lock no-error.
      kolport[i_start + 7] = kolport[i_start + 7] + 1.
      sumport[i_start + 7] = sumport[i_start + 7] + (vnebal[2] - vnebal[1]) * txb.crchis.rate[1].
  end.
  */
  if txb.lon.grp = 90 or txb.lon.grp = 92 then i_start = 20.
  else do:
       find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
       if txb.sub-cod.ccode = '9' then i_start = 10. else i_start = 0.
  end.
  for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt >= dt1 and txb.lonres.jdt <= dt2 use-index jdt no-lock:
    if txb.lonres.lev <> 13 or txb.lonres.dc <> 'D' then next.
    find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.regdt <= txb.lonres.jdt no-lock no-error.
    kolport[i_start + 7] = kolport[i_start + 7] + 1.
    sumport[i_start + 7] = sumport[i_start + 7] + txb.lonres.amt * txb.crchis.rate[1].
  end.

end. /* for each txb.lon */

create port.
port.bank = s-bank.
port.ln = 1.
port.sts = "ЮЛ".
port.kol1 = kolport[1].
port.sum1 = sumport[1].
port.kol2 = kolport[2].
port.sum2 = sumport[2].
port.kol_vyd_all = kolport[8].
port.kol_vyd = kolport[3].
port.sum_vyd = sumport[3].
port.kol_pog = kolport[5]. /* полное погашение - кол-во */
port.sum_pog = sumport[4]. /* все погашение */
port.sum_pog_full = sumport[5]. /* полное погашение*/
port.sum_pog_part = sumport[6]. /* частичное погашение */
port.sum_spis = sumport[7]. /* списание ОД */
port.kol_spis = kolport[7].
create port.
port.bank = s-bank.
port.ln = 2.
port.sts = "ФЛ".
port.kol1 = kolport[11].
port.sum1 = sumport[11].
port.kol2 = kolport[12].
port.sum2 = sumport[12].
port.kol_vyd_all = kolport[18].
port.kol_vyd = kolport[13].
port.sum_vyd = sumport[13].
port.kol_pog = kolport[15]. /* полное погашение - кол-во */
port.sum_pog = sumport[14]. /* все погашение */
port.sum_pog_full = sumport[15]. /* полное погашение*/
port.sum_pog_part = sumport[16]. /* частичное погашение */
port.sum_spis = sumport[17]. /* списание ОД */
port.kol_spis = kolport[17].
create port.
port.bank = s-bank.
port.ln = 3.
port.sts = "Экспресс-кредиты".
port.kol1 = kolport[21].
port.sum1 = sumport[21].
port.kol2 = kolport[22].
port.sum2 = sumport[22].
port.kol_vyd_all = kolport[28].
port.kol_vyd = kolport[23].
port.sum_vyd = sumport[23].
port.kol_pog = kolport[25]. /* полное погашение - кол-во */
port.sum_pog = sumport[24]. /* все погашение */
port.sum_pog_full = sumport[25]. /* полное погашение*/
port.sum_pog_part = sumport[26]. /* частичное погашение */
port.sum_spis = sumport[27]. /* списание ОД */
port.kol_spis = kolport[27].
create port.
port.bank = s-bank.
port.ln = 4.
port.sts = "ИТОГО".
port.kol1 = kolport[1] + kolport[11] + kolport[21].
port.sum1 = sumport[1] + sumport[11] + sumport[21].
port.kol2 = kolport[2] + kolport[12] + kolport[22].
port.sum2 = sumport[2] + sumport[12] + sumport[22].
port.kol_vyd_all = kolport[8] + kolport[18] + kolport[28].
port.kol_vyd = kolport[3] + kolport[13] + kolport[23].
port.sum_vyd = sumport[3] + sumport[13] + sumport[23].
port.kol_pog = kolport[5] + kolport[15] + kolport[25]. /* полное погашение - кол-во */
port.sum_pog = sumport[4] + sumport[14] + sumport[24]. /* все погашение */
port.sum_pog_full = sumport[5] + sumport[15] + sumport[25]. /* полное погашение*/
port.sum_pog_part = sumport[6] + sumport[16] + sumport[26]. /* частичное погашение */
port.sum_spis = sumport[7] + sumport[17] + sumport[27]. /* списание ОД */
port.kol_spis = kolport[7] + kolport[17] + kolport[27].

/* 3 - портфель - end. */
