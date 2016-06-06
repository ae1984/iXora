/* r-2stng1a.p
 * MODULE
        Временная структура по депозитам на дату
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
        8-2-14-1
 * AUTHOR
        22/10/04 sasco
 * CHANGES
        16/11/04 sasco Просмотр данных по Г/К по филиалам
        19/01/2005 marinav Добавились начисленные проценты
        08/02/05 marinav Остатки берутся из histrxbal
        07/09/06 marinav - добавлен в поиск по trxlevgl параметр subled для индекса
        10/06/09 marinav - отдельно отчет по нерезидентам
        18.08.09 marinav - добавлен счет 221330
        29.04.10 marinav - добавились сроки  1-2 года, 2-3
        20.12.2012 Lyubov - ТЗ № 1452, добавила счета ГК: 220330,220331,220430,220431,222110, и соот-но поиск по таблице arp-счетов
        21.12.2012 Lyubov - убрала забытый message
*/


def shared var g-today as date.

define shared temp-table depf
           field gl like bank.gl.gl
           field glr like bank.gl.gl
           field des like bank.gl.des
           field fu as character
           field v-name1 as character extent 12
           field v-name2 as character extent 12
           field v-name11 as character extent 12
           field v-name99 as character extent 12
           field v-summ1 as decimal extent 12
           field v-rate1 as decimal extent 12
           field v-summ1-cred as decimal extent 12
           field v-summ1-pr as decimal extent 12
           field v-summ2 as decimal extent 12
           field v-rate2 as decimal extent 12
           field v-summ2-cred as decimal extent 12
           field v-summ2-pr as decimal extent 12
           field v-summ11 as decimal extent 12
           field v-rate11 as decimal extent 12
           field v-summ11-cred as decimal extent 12
           field v-summ11-pr as decimal extent 12
           field v-summ99 as decimal extent 12
           field v-rate99 as decimal extent 12
           field v-summ99-cred as decimal extent 12
           field v-summ99-pr as decimal extent 12
           index idx_depf is primary gl.

def shared var prz as int.

def var v-bnk as char.

define temp-table taaa
            field aaa like txb.aaa.aaa
            field gl  like txb.aaa.gl
            field glr like txb.aaa.gl
            field crc like txb.aaa.crc
            field cdt as date
            index idx_taaa is primary gl crc.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
v-bnk = txb.sysc.chval.

def var v-vostrjur as char init "220310,221110,222110,222140,222150,222110,220330,220331".
def var v-vostrfiz as char init "220530,220320,220420,220520,221120,221130,221140,220920,222120,222130,222160,220430,220431".
def var v-glsjur as char init "222110,220330,220331,221510,221710,221910,222310,222330,222340,222361,220310,221110,222110,222140,222150".
def var v-glsfiz as char init "220530,220620,221520,220720,221720,220820,220830,220840,221920,222320,222362,220320,220420,220520,221120,221130,221140,220920,222120,222130,222160,221330,220430,220431".
/*
def var v-vostrjur as char init "222110,220330,220331".
def var v-vostrfiz as char init "220430,220431".
def var v-glsjur as char init "222110,220330,220331".
def var v-glsfiz as char init "220430,220431".
*/
def var v-txb as integer format "99".
def var v-num as integer init 12.
def var i as integer.
def var v-summ as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ1 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ1-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ1-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ2 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ2-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ2-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ11 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ11-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ11-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ99 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ99-cred as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summ99-pr as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-summall as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate1 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate2 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate11 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-rate99 as deci extent 12 init [0,0,0,0,0,0,0,0,0,0,0,0].
def var v-names as char extent 12 init [" <= 7 дн "," 7дн-1мес "," 1-2 мес "," 2-3 мес "," 3-6 мес "," 6-9 мес "," 9-12мес "," 1-2 года "," 2-3 лет "," 3-5 лет  "," >5 лет","всего "].
def var v-bal as deci.
def var v-balpr as deci.
def var v-balrate as decimal.
def var v-sumcred as deci.
def var v-name    as char.
def var v-dtc     as date.
def var v-rgdt    as date.
def var v-exdt    as date.
def var v-crc     as inte.
def var v-aaa     as char.
def var v-gl      as inte.
def var v-rat     as deci.
def var v-sub     as char.
def var v-header  as char init "                     остаток  сред.ставка      кред.поступ." format "x(70)".
define shared variable v-dt as date.
define shared variable v-dt0 as date.


find first txb.cmp no-lock no-error.
v-txb = txb.cmp.code.

def stream depos.
output stream depos to value("depos" + v-bnk + ".txt").
put stream depos
  " " v-bnk skip(1)
  " Отчетная дата (до срока погашения)  " v-dt skip(2).


def stream depos1.
output stream depos1 to value("depos1" + v-bnk + ".txt").

def stream depos2.
output stream depos2 to value("depos2" + v-bnk + ".txt").

put stream depos "ЮР. ЛИЦА" skip.

for each taaa: delete taaa. end.


for each txb.aaa where lookup(string(txb.aaa.gl), v-glsjur) > 0  no-lock.
        find txb.sub-cod where txb.sub-cod.sub = "CIF" and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = "CLSA" no-lock no-error.
        if avail txb.sub-cod then
           if txb.sub-cod.ccode <> "MSC" and txb.sub-cod.rdt < v-dt then next.

        if prz = 2 then do:
           find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
           if substr(txb.cif.geo,3,1) = '1' then next. /*1-резидент, 2- нерезидент*/
        end.

        create taaa.
        assign taaa.aaa = txb.aaa.aaa
               taaa.gl = txb.aaa.gl
               taaa.crc = txb.aaa.crc.
        find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled = 'cif' and txb.trxlevgl.lev = 2 no-lock no-error.
        if avail txb.trxlevgl then taaa.glr = txb.trxlevgl.glr .
        if not avail txb.sub-cod then taaa.cdt = today + 1000.
        else do:
            if txb.sub-cod.ccode = "msc" then taaa.cdt = today + 1000.
            else taaa.cdt = txb.sub-cod.rdt.
        end.
end.

for each txb.arp where lookup(string(txb.arp.gl), v-glsjur) > 0  no-lock.
    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "CLSA" no-lock no-error.
    if avail txb.sub-cod then if txb.sub-cod.ccode <> "MSC" and txb.sub-cod.rdt < v-dt then next.

    create taaa.
    assign taaa.aaa = txb.arp.arp
           taaa.gl = txb.arp.gl
           taaa.crc = txb.arp.crc.
    find first txb.trxlevgl where txb.trxlevgl.gl = txb.arp.gl and txb.trxlevgl.subled = 'arp' no-lock no-error.
    if avail txb.trxlevgl then taaa.glr = txb.trxlevgl.glr .
    if not avail txb.sub-cod then taaa.cdt = today + 1000.
    else do:
         if txb.sub-cod.ccode = "msc" then taaa.cdt = today + 1000.
         else taaa.cdt = txb.sub-cod.rdt.
    end.
end.

for each taaa break by taaa.gl by taaa.crc:
    find first txb.aaa where txb.aaa.aaa = taaa.aaa no-lock no-error.
    if avail txb.aaa then do:
        v-rgdt = txb.aaa.regdt.
        v-exdt = txb.aaa.expdt.
        v-aaa  = txb.aaa.aaa.
        v-gl   = txb.aaa.gl.
        v-crc  = txb.aaa.crc.
        v-rat  = txb.aaa.rate.
        v-sub  = 'cif'.
    end.
    else do:
        find first txb.arp where txb.arp.arp = taaa.aaa no-lock no-error.
        if avail txb.arp then do:
            v-rgdt = txb.arp.rdt.
            v-exdt = txb.arp.spdt.
            v-aaa  = txb.arp.arp.
            v-gl   = txb.arp.gl.
            v-crc  = txb.arp.crc.
            v-rat  = 1.
            v-sub  = 'arp'.
        end.
        else next.
    end.


    if first-of(taaa.gl) then do:
        hide message no-pause.
        do i = 1 to v-num:
            v-summ1[i] = 0.
            v-summ1-cred[i] = 0.
            v-summ1-pr[i] = 0.
            v-rate1[i] = 0.

            v-summ2[i] = 0.
            v-summ2-cred[i] = 0.
            v-summ2-pr[i] = 0.
            v-rate2[i] = 0.

            v-summ11[i] = 0.
            v-summ11-cred[i] = 0.
            v-summ11-pr[i] = 0.
            v-rate11[i] = 0.

            v-summ99[i] = 0.
            v-summ99-cred[i] = 0.
            v-summ99-pr[i] = 0.
            v-rate99[i] = 0.
        end.
    end.

  if first-of (taaa.crc) then
    do i = 1 to v-num:
      v-summ[i] = 0.
      v-summ-cred[i] = 0.
      v-summ-pr[i] = 0.
      v-rate[i] = 0.
    end.

  /* обрабатываем только нужные счета */
  if v-rgdt < v-dt  then do:

    /* кредитовые поступления в заданный период */
    v-sumcred = 0.

    /* остаток на заданную дату */
    find last txb.histrxbal where txb.histrxbal.subled = v-sub and txb.histrxbal.acc = v-aaa and txb.histrxbal.level = 1 and txb.histrxbal.dt < v-dt no-lock no-error.
    if avail txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
    else v-bal = 0.

    find last txb.aab where txb.aab.aaa = v-aaa and txb.aab.fdt < v-dt no-lock no-error.
    if avail txb.aab then v-balrate = txb.aab.rate.
    else v-balrate = v-rat.

    /*найдем остаток на 2 уровне*/
    run lonbal_txb('cif', v-aaa, v-dt, '2', no, output v-balpr).
    v-balpr = - v-balpr .

    if v-crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = v-crc and txb.crchis.rdt < v-dt no-lock no-error.
        if avail txb.crchis then do:
            v-bal = v-bal * txb.crchis.rate[1].
            v-balpr = v-balpr * txb.crchis.rate[1].
        end.
        else do:
            message "no crc! " v-rgdt v-crc. pause.
            find txb.crc where txb.crc.crc = v-crc no-lock no-error.
            v-bal = v-bal * txb.crc.rate[1].
            v-balpr = v-balpr * txb.crc.rate[1].
        end.
    end.

    /* раскидать по срокам */
    if (v-exdt = ?) or (v-exdt - v-dt <= 7) or lookup(string(v-gl), v-vostrjur) > 0 then do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-summ-pr[1] = v-summ-pr[1] + v-balpr.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.
    else
    if  (v-exdt - v-dt > 7) and (v-exdt - v-dt <= 30) then do:
      v-summ[2] = v-summ[2] + v-bal.
      v-summ-cred[2] = v-summ-cred[2] + v-sumcred.
      v-summ-pr[2] = v-summ-pr[2] + v-balpr.
      v-rate[2] = v-rate[2] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 30 and v-exdt - v-dt <= 60 then do:
      v-summ[3] = v-summ[3] + v-bal.
      v-summ-cred[3] = v-summ-cred[3] + v-sumcred.
      v-summ-pr[3] = v-summ-pr[3] + v-balpr.
      v-rate[3] = v-rate[3] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 60 and v-exdt - v-dt <= 90 then do:
      v-summ[4] = v-summ[4] + v-bal.
      v-summ-cred[4] = v-summ-cred[4] + v-sumcred.
      v-summ-pr[4] = v-summ-pr[4] + v-balpr.
      v-rate[4] = v-rate[4] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 90 and v-exdt - v-dt <= 180 then do:
      v-summ[5] = v-summ[5] + v-bal.
      v-summ-cred[5] = v-summ-cred[5] + v-sumcred.
      v-summ-pr[5] = v-summ-pr[5] + v-balpr.
      v-rate[5] = v-rate[5] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 180 and v-exdt - v-dt <= 270 then do:
      v-summ[6] = v-summ[6] + v-bal.
      v-summ-cred[6] = v-summ-cred[6] + v-sumcred.
      v-summ-pr[6] = v-summ-pr[6] + v-balpr.
      v-rate[6] = v-rate[6] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 270 and v-exdt - v-dt <= 365 then do:
      v-summ[7] = v-summ[7] + v-bal.
      v-summ-cred[7] = v-summ-cred[7] + v-sumcred.
      v-summ-pr[7] = v-summ-pr[7] + v-balpr.
      v-rate[7] = v-rate[7] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 365 and v-exdt - v-dt <= 730 then do:
      v-summ[8] = v-summ[8] + v-bal.
      v-summ-cred[8] = v-summ-cred[8] + v-sumcred.
      v-summ-pr[8] = v-summ-pr[8] + v-balpr.
      v-rate[8] = v-rate[8] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 730 and v-exdt - v-dt <= 1095 then do:
      v-summ[9] = v-summ[9] + v-bal.
      v-summ-cred[9] = v-summ-cred[9] + v-sumcred.
      v-summ-pr[9] = v-summ-pr[9] + v-balpr.
      v-rate[9] = v-rate[9] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 1095 and v-exdt - v-dt <= 1826 then do:
      v-summ[10] = v-summ[10] + v-bal.
      v-summ-cred[10] = v-summ-cred[10] + v-sumcred.
      v-summ-pr[10] = v-summ-pr[10] + v-balpr.
      v-rate[10] = v-rate[10] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 1826 then do:
      v-summ[11] = v-summ[11] + v-bal.
      v-summ-cred[11] = v-summ-cred[11] + v-sumcred.
      v-summ-pr[11] = v-summ-pr[11] + v-balpr.
      v-rate[11] = v-rate[11] + v-bal * v-balrate.
    end.
    else do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-summ-pr[1] = v-summ-pr[1] + v-balpr.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.
  end.

  if last-of(taaa.crc) then do:
    do i = 1 to v-num - 1:
      v-summ[v-num] = v-summ[v-num] + v-summ[i].
      v-summ-cred[v-num] = v-summ-cred[v-num] + v-summ-cred[i].
      v-summ-pr[v-num] = v-summ-pr[v-num] + v-summ-pr[i].
      v-rate[v-num] = v-rate[v-num] + v-rate[i].
    end.

    case v-crc :
      when 1 then
        do i = 1 to v-num:
          v-summ1[i] = v-summ[i].
          v-summ1-cred[i] = v-summ-cred[i].
          v-summ1-pr[i] = v-summ-pr[i].
          v-rate1[i] = v-rate[i].
        end.
      when 2 then
        do i = 1 to v-num:
          v-summ2[i] = v-summ[i].
          v-summ2-cred[i] = v-summ-cred[i].
          v-summ2-pr[i] = v-summ-pr[i].
          v-rate2[i] = v-rate[i].
        end.
      when 3 then
        do i = 1 to v-num:
          v-summ11[i] = v-summ[i].
          v-summ11-cred[i] = v-summ-cred[i].
          v-summ11-pr[i] = v-summ-pr[i].
          v-rate11[i] = v-rate[i].
        end.
      otherwise
        do i = 1 to v-num:
          v-summ99[i] = v-summ99[i] + v-summ[i].
          v-summ99-cred[i] = v-summ99-cred[i] + v-summ-cred[i].
          v-summ99-pr[i] = v-summ99-pr[i] + v-summ-pr[i].
          v-rate99[i] = v-rate99[i] + v-rate[i].
        end.
    end case.
  end.

  if last-of(taaa.gl) then do:
    find txb.gl where txb.gl.gl = v-gl no-lock no-error.

    find depf where depf.gl = txb.gl.gl and depf.fu = "U" no-error.
    if not avail depf then create depf.

    assign depf.gl = txb.gl.gl
           depf.glr = taaa.glr
           depf.des = txb.gl.des
           depf.fu = "U".


    put stream depos  skip
        "-----------------------------------" skip(1)
        "ГК " txb.gl.gl "  " txb.gl.des skip
        "--------" skip.
    put stream depos skip(1) " KZT  " v-header skip.

    do i = 1 to v-num:
      if v-summ1[i] = 0 then v-rate1[i] = 0. else v-rate1[i] = v-rate1[i] / v-summ1[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ЮЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate1[i] format "zzz9.99"
             v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ1-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name1[i] = v-name.
      depf.v-summ1[i] = depf.v-summ1[i] + v-summ1[i].
      depf.v-rate1[i] = v-rate1[i].
      depf.v-summ1-cred[i] = v-summ1-cred[i].
      depf.v-summ1-pr[i] = depf.v-summ1-pr[i] + v-summ1-pr[i].

    end.

    put stream depos skip(1) " USD  " v-header skip.
    do i = 1 to v-num:
      if v-summ2[i] = 0 then v-rate2[i] = 0. else v-rate2[i] = v-rate2[i] / v-summ2[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ЮЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate2[i] format "zzz9.99"
             v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ2-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name2[i] = v-name.
      depf.v-summ2[i] = depf.v-summ2[i] + v-summ2[i].
      depf.v-rate2[i] = v-rate2[i].
      depf.v-summ2-cred[i] = v-summ2-cred[i].
      depf.v-summ2-pr[i] = depf.v-summ2-pr[i] + v-summ2-pr[i].

    end.

    put stream depos skip(1) " EUR  " v-header skip.
    do i = 1 to v-num:
      if v-summ11[i] = 0 then v-rate11[i] = 0. else v-rate11[i] = v-rate11[i] / v-summ11[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ЮЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate11[i] format "zzz9.99"
             v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ11-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name11[i] = v-name.
      depf.v-summ11[i] = depf.v-summ11[i] + v-summ11[i].
      depf.v-rate11[i] = v-rate11[i].
      depf.v-summ11-cred[i] = v-summ11-cred[i].
      depf.v-summ11-pr[i] = depf.v-summ11-pr[i] + v-summ11-pr[i].

    end.

    put stream depos skip(1) "ДР.ВАЛ" v-header skip.
    do i = 1 to v-num:
      if v-summ99[i] = 0 then v-rate99[i] = 0. else v-rate99[i] = v-rate99[i] / v-summ99[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ЮЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate99[i] format "zzz9.99"
             v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ99-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name99[i] = v-name.
      depf.v-summ99[i] = depf.v-summ99[i] + v-summ99[i].
      depf.v-rate99[i] = v-rate99[i].
      depf.v-summ99-cred[i] = v-summ99-cred[i].
      depf.v-summ99-pr[i] = depf.v-summ99-pr[i] + v-summ99-pr[i].

    end.

    do i = 1 to v-num:
      v-summall[i] = v-summall[i] + v-summ1[i] + v-summ2[i] + v-summ11[i] + v-summ99[i].
    end.

    put stream depos2 v-txb " 1 " v-gl " 1  ".
    do i = 1 to v-num:
      put stream depos2 v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate1[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.


    put stream depos2 v-txb " 1 " v-gl " 2  ".
    do i = 1 to v-num:
      put stream depos2 v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate2[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 1 " v-gl " 3  ".
    do i = 1 to v-num:
      put stream depos2 v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate11[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 1 " v-gl " 99 ".
    do i = 1 to v-num:
      put stream depos2 v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate99[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.
  end.
end.

do i = 1 to v-num:
  put stream depos1 v-summall[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
  v-summall[i] = 0.
end.
put stream depos1 skip.


put stream depos
  skip(2) "----------------------------------------------------------------------------------------------" skip(2)
  "ФИЗ. ЛИЦА" skip.

for each taaa: delete taaa. end.
for each txb.aaa where  lookup(string(txb.aaa.gl), v-glsfiz) > 0 no-lock:

    find txb.sub-cod where txb.sub-cod.sub = "CIF" and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = "CLSA"  no-lock no-error.
    if avail txb.sub-cod then
       if txb.sub-cod.ccode <> "MSC" and txb.sub-cod.rdt < v-dt then next.

    if prz = 2 then do:
           find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
           if substr(txb.cif.geo,3,1) = '1' then next. /*1-резидент, 2- нерезидент*/
    end.

    create taaa.
    assign taaa.aaa = txb.aaa.aaa
           taaa.gl = txb.aaa.gl
           taaa.crc = txb.aaa.crc .

    find first txb.trxlevgl where txb.trxlevgl.gl = txb.aaa.gl and txb.trxlevgl.subled = 'cif' and txb.trxlevgl.lev = 2 no-lock no-error.
    if avail txb.trxlevgl then taaa.glr = txb.trxlevgl.glr .
end.

for each txb.arp where lookup(string(txb.arp.gl), v-glsfiz) > 0  no-lock.
    find txb.sub-cod where txb.sub-cod.sub = "arp" and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "CLSA" no-lock no-error.
    if avail txb.sub-cod then
    if txb.sub-cod.ccode <> "MSC" and txb.sub-cod.rdt < v-dt then next.

    create taaa.
    assign taaa.aaa = txb.arp.arp
           taaa.gl = txb.arp.gl
           taaa.crc = txb.arp.crc.
    find first txb.trxlevgl where txb.trxlevgl.gl = txb.arp.gl and txb.trxlevgl.subled = 'ARP' no-lock no-error.
    if avail txb.trxlevgl then taaa.glr = txb.trxlevgl.glr .
    if not avail txb.sub-cod then taaa.cdt = today + 1000.
    else do:
         if txb.sub-cod.ccode = "msc" then taaa.cdt = today + 1000.
         else taaa.cdt = txb.sub-cod.rdt.
    end.
end.

for each taaa break by taaa.gl by taaa.crc:
    find first txb.aaa where txb.aaa.aaa = taaa.aaa no-lock no-error.
    if avail txb.aaa then do:
        v-rgdt = txb.aaa.regdt.
        v-exdt = txb.aaa.expdt.
        v-aaa  = txb.aaa.aaa.
        v-gl   = txb.aaa.gl.
        v-crc  = txb.aaa.crc.
        v-rat  = txb.aaa.rate.
        v-sub  = 'cif'.
    end.
    else do:
        find first txb.arp where txb.arp.arp = taaa.aaa no-lock no-error.
        if avail txb.arp then do:
            v-rgdt = txb.arp.rdt.
            v-exdt = txb.arp.spdt.
            v-aaa  = txb.arp.arp.
            v-gl   = txb.arp.gl.
            v-crc  = txb.arp.crc.
            v-rat  = 1.
            v-sub  = 'arp'.
        end.
        else next.
    end.

    if first-of(taaa.gl) then do:
        hide message no-pause.
        do i = 1 to v-num:
            v-summ1[i] = 0.
            v-summ1-cred[i] = 0.
            v-summ1-pr[i] = 0.
            v-rate1[i] = 0.

            v-summ2[i] = 0.
            v-summ2-cred[i] = 0.
            v-summ2-pr[i] = 0.
            v-rate2[i] = 0.

            v-summ11[i] = 0.
            v-summ11-cred[i] = 0.
            v-summ11-pr[i] = 0.
            v-rate11[i] = 0.

            v-summ99[i] = 0.
            v-summ99-cred[i] = 0.
            v-summ99-pr[i] = 0.
            v-rate99[i] = 0.
        end.
    end.

  if first-of (taaa.crc) then
    do i = 1 to v-num:
      v-summ[i] = 0.
      v-summ-cred[i] = 0.
      v-summ-pr[i] = 0.
      v-rate[i] = 0.
    end.


  /* обрабатываем только нужные счета */
  if v-rgdt < v-dt then do:

    /* кредитовые поступления в заданный период */

    v-sumcred = 0.

    /* остаток на заданную дату */
    find last txb.histrxbal where txb.histrxbal.subled = v-sub and txb.histrxbal.acc = v-aaa and txb.histrxbal.level = 1 and txb.histrxbal.dt < v-dt no-lock no-error.
    if avail txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
    else v-bal = 0.

    find last txb.aab where txb.aab.aaa = v-aaa and txb.aab.fdt < v-dt no-lock no-error.
    if avail txb.aab then v-balrate = txb.aab.rat.
    else v-balrate = v-rat.

    /*найдем остаток на 2 уровне*/
    run lonbal_txb('cif', v-aaa, v-dt, '2', no, output v-balpr).
    v-balpr = - v-balpr .

    if v-crc <> 1 then do:
        find last txb.crchis where txb.crchis.crc = v-crc and txb.crchis.rdt < v-dt no-lock no-error.
        if avail txb.crchis then do:
            v-bal = v-bal * txb.crchis.rate[1].
            v-balpr = v-balpr * txb.crchis.rate[1].
        end.
        else do:
            message "no crc! " v-rgdt v-crc. pause.
            find txb.crc where txb.crc.crc = v-crc no-lock no-error.
            v-bal = v-bal * txb.crc.rate[1].
            v-balpr = v-balpr * txb.crc.rate[1].
        end.
    end.

    /* раскидать по срокам */

    if (v-exdt = ?) or (v-exdt - v-dt <= 7) or lookup(string(v-gl), v-vostrfiz) > 0 then do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-summ-pr[1] = v-summ-pr[1] + v-balpr.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 7 and v-exdt - v-dt <= 30 then do:
      v-summ[2] = v-summ[2] + v-bal.
      v-summ-cred[2] = v-summ-cred[2] + v-sumcred.
      v-summ-pr[2] = v-summ-pr[2] + v-balpr.
      v-rate[2] = v-rate[2] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 30 and v-exdt - v-dt <= 60 then do:
      v-summ[3] = v-summ[3] + v-bal.
      v-summ-cred[3] = v-summ-cred[3] + v-sumcred.
      v-summ-pr[3] = v-summ-pr[3] + v-balpr.
      v-rate[3] = v-rate[3] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 60 and v-exdt - v-dt <= 90 then do:
      v-summ[4] = v-summ[4] + v-bal.
      v-summ-cred[4] = v-summ-cred[4] + v-sumcred.
      v-summ-pr[4] = v-summ-pr[4] + v-balpr.
      v-rate[4] = v-rate[4] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 90 and v-exdt - v-dt <= 180 then do:
      v-summ[5] = v-summ[5] + v-bal.
      v-summ-cred[5] = v-summ-cred[5] + v-sumcred.
      v-summ-pr[5] = v-summ-pr[5] + v-balpr.
      v-rate[5] = v-rate[5] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 180 and v-exdt - v-dt <= 270 then do:
      v-summ[6] = v-summ[6] + v-bal.
      v-summ-cred[6] = v-summ-cred[6] + v-sumcred.
      v-summ-pr[6] = v-summ-pr[6] + v-balpr.
      v-rate[6] = v-rate[6] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 270 and v-exdt - v-dt <= 365 then do:
      v-summ[7] = v-summ[7] + v-bal.
      v-summ-cred[7] = v-summ-cred[7] + v-sumcred.
      v-summ-pr[7] = v-summ-pr[7] + v-balpr.
      v-rate[7] = v-rate[7] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 365 and v-exdt - v-dt <= 730 then do:
      v-summ[8] = v-summ[8] + v-bal.
      v-summ-cred[8] = v-summ-cred[8] + v-sumcred.
      v-summ-pr[8] = v-summ-pr[8] + v-balpr.
      v-rate[8] = v-rate[8] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 730 and v-exdt - v-dt <= 1095 then do:
      v-summ[9] = v-summ[9] + v-bal.
      v-summ-cred[9] = v-summ-cred[9] + v-sumcred.
      v-summ-pr[9] = v-summ-pr[9] + v-balpr.
      v-rate[9] = v-rate[9] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 1095 and v-exdt - v-dt <= 1826 then do:
      v-summ[10] = v-summ[10] + v-bal.
      v-summ-cred[10] = v-summ-cred[10] + v-sumcred.
      v-summ-pr[10] = v-summ-pr[10] + v-balpr.
      v-rate[10] = v-rate[10] + v-bal * v-balrate.
    end.
    else
    if v-exdt - v-dt > 1826 then do:
      v-summ[11] = v-summ[11] + v-bal.
      v-summ-cred[11] = v-summ-cred[11] + v-sumcred.
      v-summ-pr[11] = v-summ-pr[11] + v-balpr.
      v-rate[11] = v-rate[11] + v-bal * v-balrate.
    end.
    else do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-summ-pr[1] = v-summ-pr[1] + v-balpr.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.

  end.

  if last-of(taaa.crc) then do:
    do i = 1 to v-num - 1:
      v-summ[v-num] = v-summ[v-num] + v-summ[i].
      v-summ-cred[v-num] = v-summ-cred[v-num] + v-summ-cred[i].
      v-summ-pr[v-num] = v-summ-pr[v-num] + v-summ-pr[i].
      v-rate[v-num] = v-rate[v-num] + v-rate[i].
    end.

    case v-crc :
      when 1 then
        do i = 1 to v-num:
          v-summ1[i] = v-summ[i].
          v-summ1-cred[i] = v-summ-cred[i].
          v-summ1-pr[i] = v-summ-pr[i].
          v-rate1[i] = v-rate[i].
        end.
      when 2 then
        do i = 1 to v-num:
          v-summ2[i] = v-summ[i].
          v-summ2-cred[i] = v-summ-cred[i].
          v-summ2-pr[i] = v-summ-pr[i].
          v-rate2[i] = v-rate[i].
        end.
      when 3 then
        do i = 1 to v-num:
          v-summ11[i] = v-summ[i].
          v-summ11-cred[i] = v-summ-cred[i].
          v-summ11-pr[i] = v-summ-pr[i].
          v-rate11[i] = v-rate[i].
        end.
      otherwise
        do i = 1 to v-num:
          v-summ99[i] = v-summ99[i] + v-summ[i].
          v-summ99-cred[i] = v-summ99-cred[i] + v-summ-cred[i].
          v-summ99-pr[i] = v-summ99-pr[i] + v-summ-pr[i].
          v-rate99[i] = v-rate99[i] + v-rate[i].
        end.
    end case.
  end.

  if last-of(taaa.gl) then do:
    find txb.gl where txb.gl.gl = v-gl no-lock no-error.
    put stream depos  skip
        "-----------------------------------" skip(1)
        "ГК " txb.gl.gl "  " txb.gl.des skip
        "--------" skip.

    find depf where depf.gl = txb.gl.gl and depf.fu = "F" no-error.
    if not avail depf then create depf.

    assign depf.gl = txb.gl.gl
           depf.glr = taaa.glr
           depf.des = txb.gl.des
           depf.fu = "F".


    put stream depos skip(1) " KZT   " v-header skip.

    do i = 1 to v-num:
      if v-summ1[i] = 0 then v-rate1[i] = 0. else v-rate1[i] = v-rate1[i] / v-summ1[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ФЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate1[i] format "zzz9.99"
             v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ1-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name1[i] = v-name.
      depf.v-summ1[i] = depf.v-summ1[i] + v-summ1[i].
      depf.v-summ1-pr[i] = depf.v-summ1-pr[i] + v-summ1-pr[i].
      depf.v-rate1[i] = v-rate1[i].
      depf.v-summ1-cred[i] = v-summ1-cred[i].

    end.

    put stream depos skip(1) " USD  " v-header skip.
    do i = 1 to v-num:
      if v-summ2[i] = 0 then v-rate2[i] = 0. else v-rate2[i] = v-rate2[i] / v-summ2[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ФЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate2[i] format "zzz9.99"
             v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ2-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name2[i] = v-name.
      depf.v-summ2[i] = depf.v-summ2[i] + v-summ2[i].
      depf.v-summ2-pr[i] = depf.v-summ2-pr[i] + v-summ2-pr[i].
      depf.v-rate2[i] = v-rate2[i].
      depf.v-summ2-cred[i] = v-summ2-cred[i].

    end.

    put stream depos skip(1) " EUR  " v-header skip.
    do i = 1 to v-num:
      if v-summ11[i] = 0 then v-rate11[i] = 0. else v-rate11[i] = v-rate11[i] / v-summ11[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ФЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate11[i] format "zzz9.99"
             v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ11-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name11[i] = v-name.
      depf.v-summ11[i] = depf.v-summ11[i] + v-summ11[i].
      depf.v-summ11-pr[i] = depf.v-summ11-pr[i] + v-summ11-pr[i].
      depf.v-rate11[i] = v-rate11[i].
      depf.v-summ11-cred[i] = v-summ11-cred[i].

    end.

    put stream depos skip(1) "ДР.ВАЛ" v-header skip.
    do i = 1 to v-num:
      if v-summ99[i] = 0 then v-rate99[i] = 0. else v-rate99[i] = v-rate99[i] / v-summ99[i].
      v-name = v-names[i].
      if i = v-num then v-name = v-name + "ФЛ ".
      put stream depos
             v-name format "x(12)"
             v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-rate99[i] format "zzz9.99"
             v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99"
             v-summ99-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name99[i] = v-name.
      depf.v-summ99[i] = depf.v-summ99[i] + v-summ99[i].
      depf.v-summ99-pr[i] = depf.v-summ99-pr[i] + v-summ99-pr[i].
      depf.v-rate99[i] = v-rate99[i].
      depf.v-summ99-cred[i] = v-summ99-cred[i].

    end.

    do i = 1 to v-num:
      v-summall[i] = v-summall[i] + v-summ1[i] + v-summ2[i] + v-summ11[i] + v-summ99[i].
    end.

    put stream depos2 v-txb " 2 " v-gl " 1  ".
    do i = 1 to v-num:
      put stream depos2 v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate1[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.


    put stream depos2 v-txb " 2 " v-gl " 2  ".
    do i = 1 to v-num:
      put stream depos2 v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate2[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 2 " v-gl " 3  ".
    do i = 1 to v-num:
      put stream depos2 v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate11[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 2 " v-gl " 99 ".
    do i = 1 to v-num:
      put stream depos2 v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate99[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-pr[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.
  end.
end.



do i = 1 to v-num:
  put stream depos1 v-summall[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
  v-summall[i] = 0.
end.
put stream depos1 skip.

output stream depos close.
output stream depos1 close.
output stream depos2 close.

/* run menu-prt ("depos" + v-bnk + ".txt"). */
