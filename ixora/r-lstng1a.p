/* r-lstng1a.p
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
        09/02/05 marinav Остатки берутся из histrxbal
        15.07.08 marinav - добавились сроки 1-7 дней, 7-10 дней , 2-3 года, 3-5 лет
        18.08.09 marinav - добавлен счет 221330
*/


def shared var g-today as date.


define shared temp-table depf 
           field gl like bank.gl.gl
           field des like bank.gl.des
           field fu as character 
           field v-name as character extent 11
           field v-name1 as character extent 11
           field v-name2 as character extent 11
           field v-name11 as character extent 11
           field v-name99 as character extent 11
           field v-summ1 as decimal extent 11
           field v-rate1 as decimal extent 11
           field v-summ1-cred as decimal extent 11
           field v-summ2 as decimal extent 11
           field v-rate2 as decimal extent 11
           field v-summ2-cred as decimal extent 11
           field v-summ11 as decimal extent 11
           field v-rate11 as decimal extent 11
           field v-summ11-cred as decimal extent 11
           field v-summ99 as decimal extent 11
           field v-rate99 as decimal extent 11
           field v-summ99-cred as decimal extent 11
           index idx_depf is primary gl.


def var v-bnk as char.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
v-bnk = txb.sysc.chval.

def var v-glsjur as char init "221510,221710,221910,222310,222330,222340,222361".
def var v-vostrjur as char init "220310,221110,222110,222140,222150".

def var v-glsfiz as char init "220620,221520,220720,221720,220820,220830,220840,221920,222320,222362,221330".
def var v-vostrfiz as char init "220320,220420,220520,221120,221130,221140,220920,222120,222130,222160".

def var v-txb as integer format "99".
def var v-num as integer init 11.
def var i as integer.
def var v-summ as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ-cred as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ1 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ1-cred as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ2 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ2-cred as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ11 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ11-cred as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ99 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summ99-cred as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-summall as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-rate as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-rate1 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-rate2 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-rate11 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-rate99 as deci extent 11 init [0,0,0,0,0,0,0,0,0,0,0].
def var v-names as char extent 11 init [" <=7дн   "," 7дн-1мес"," 1-3 мес "," 3-6 мес "," 6-9 мес "," 9-12мес "," 1-2 года "," 2-3 лет  "," 3-5 лет"," >5 лет","всего "].
def var v-bal as deci.
def var v-balrate as decimal.
def var v-sumcred as deci.
def var v-name as char.
def var v-dtc as date.
def var v-header as char init "                     остаток  сред.ставка      кред.поступ." format "x(70)".
define shared variable v-dt as date.
define shared variable v-dt0 as date.


find first txb.cmp no-lock no-error.
v-txb = txb.cmp.code.

def stream depos.
output stream depos to value("depos" + v-bnk + ".txt").
put stream depos 
  " " v-bnk skip(1)
  " Отчетная дата   " v-dt skip(2).


def stream depos1.
output stream depos1 to value("depos1" + v-bnk + ".txt").

def stream depos2.
output stream depos2 to value("depos2" + v-bnk + ".txt").


put stream depos 
  "ЮР. ЛИЦА" skip.

for each txb.aaa where 
    (lookup(string(txb.aaa.gl), v-glsjur) > 0 or lookup(string(txb.aaa.gl), v-vostrjur) > 0)
    no-lock break by txb.aaa.gl by txb.aaa.crc:

  if first-of(txb.aaa.gl) then do:
    hide message no-pause.
    message v-bnk " JUR GL " txb.aaa.gl.

    do i = 1 to v-num: 
      v-summ1[i] = 0. 
      v-summ1-cred[i] = 0.
      v-rate1[i] = 0.

      v-summ2[i] = 0. 
      v-summ2-cred[i] = 0.
      v-rate2[i] = 0.

      v-summ11[i] = 0. 
      v-summ11-cred[i] = 0.
      v-rate11[i] = 0.

      v-summ99[i] = 0. 
      v-summ99-cred[i] = 0.
      v-rate99[i] = 0.
    end.
  end.
  if first-of (txb.aaa.crc) then
    do i = 1 to v-num: 
      v-summ[i] = 0. 
      v-summ-cred[i] = 0.
      v-rate[i] = 0.
    end.

  /* обрабатываем только нужные счета */
  if txb.aaa.regdt < v-dt /*and (txb.aaa.sta <> "c" or (txb.aaa.sta = "c" and txb.aaa.cltdt >= v-dt))*/ then do:

    /* кредитовые поступления в заданный период */
    v-sumcred = 0.
/*    do v-dtc = txb.aaa.regdt to v-dt - 1:
      c-jl:
      for each txb.jl where txb.jl.jdt = v-dtc  and txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl no-lock:
        if txb.jl.lev = 1 and txb.jl.dc = "c" and not (txb.jl.rem[1] begins "O/D PROTECT" or txb.jl.rem[1] begins "O/D PAYMENT") then do:
          if txb.jl.crc = 1 then v-sumcred = v-sumcred + txb.jl.cam.
          else do:
            find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.crchis then v-sumcred = v-sumcred + txb.jl.cam * txb.crchis.rate[1].
            else do:
               message "no crc! " txb.jl.jdt txb.jl.crc. pause.
               find txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
               v-sumcred = v-sumcred + txb.jl.cam * txb.crc.rate[1].
            end.
          end.
        end.
      end.
    end.
  */  
    /* остаток на заданную дату */
    find last txb.histrxbal where txb.histrxbal.subled = 'CIF' and txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.level = 1
                                  and txb.histrxbal.dt < v-dt no-lock no-error.
        if avail txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                               else v-bal = 0.

    find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt < v-dt no-lock no-error.
    if avail txb.aab then do: 
/*      v-bal = txb.aab.bal.*/
      v-balrate = txb.aab.rate.
    end.
    else do: 
/*      v-bal = 0.          */
      v-balrate = txb.aaa.rate.
    end.


    if txb.aaa.crc <> 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt < v-dt no-lock no-error.
      if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
      else do:
         message "no crc! " txb.aaa.regdt txb.aaa.crc. pause.
         find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
         v-bal = v-bal * txb.crc.rate[1].
      end.
    end.

    /* раскидать по срокам */

    if (txb.aaa.expdt = ?) or (txb.aaa.expdt - txb.aaa.regdt <= 7) or lookup(string(txb.aaa.gl), v-vostrjur) > 0 then do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 7 and txb.aaa.expdt - txb.aaa.regdt <= 30 then do:
      v-summ[2] = v-summ[2] + v-bal.
      v-summ-cred[2] = v-summ-cred[2] + v-sumcred.
      v-rate[2] = v-rate[2] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 30 and txb.aaa.expdt - txb.aaa.regdt <= 90 then do:
      v-summ[3] = v-summ[3] + v-bal.
      v-summ-cred[3] = v-summ-cred[3] + v-sumcred.
      v-rate[3] = v-rate[3] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 90 and txb.aaa.expdt - txb.aaa.regdt <= 180 then do:
      v-summ[4] = v-summ[4] + v-bal.
      v-summ-cred[4] = v-summ-cred[4] + v-sumcred.
      v-rate[4] = v-rate[4] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 180 and txb.aaa.expdt - txb.aaa.regdt <= 270 then do:
      v-summ[5] = v-summ[5] + v-bal.
      v-summ-cred[5] = v-summ-cred[5] + v-sumcred.
      v-rate[5] = v-rate[5] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 270 and txb.aaa.expdt - txb.aaa.regdt <= 365 then do:
      v-summ[6] = v-summ[6] + v-bal.
      v-summ-cred[6] = v-summ-cred[6] + v-sumcred.
      v-rate[6] = v-rate[6] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 365 and txb.aaa.expdt - txb.aaa.regdt <= 730 then do:
      v-summ[7] = v-summ[7] + v-bal.
      v-summ-cred[7] = v-summ-cred[7] + v-sumcred.
      v-rate[7] = v-rate[7] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 730 and txb.aaa.expdt - txb.aaa.regdt <= 1095 then do:
      v-summ[8] = v-summ[8] + v-bal.
      v-summ-cred[8] = v-summ-cred[8] + v-sumcred.
      v-rate[8] = v-rate[8] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 1095 and txb.aaa.expdt - txb.aaa.regdt <= 1826 then do:
      v-summ[9] = v-summ[9] + v-bal.
      v-summ-cred[9] = v-summ-cred[9] + v-sumcred.
      v-rate[9] = v-rate[9] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 1826 then do:
      v-summ[10] = v-summ[10] + v-bal.
      v-summ-cred[10] = v-summ-cred[10] + v-sumcred.
      v-rate[10] = v-rate[10] + v-bal * v-balrate.
    end.
    else do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.

  end.

  if last-of(txb.aaa.crc) then do:
    do i = 1 to v-num - 1: 
      v-summ[v-num] = v-summ[v-num] + v-summ[i].
      v-summ-cred[v-num] = v-summ-cred[v-num] + v-summ-cred[i].
      v-rate[v-num] = v-rate[v-num] + v-rate[i].
    end.

    case txb.aaa.crc :
      when 1 then 
        do i = 1 to v-num: 
          v-summ1[i] = v-summ[i].
          v-summ1-cred[i] = v-summ-cred[i].
          v-rate1[i] = v-rate[i].
        end.
      when 2 then 
        do i = 1 to v-num: 
          v-summ2[i] = v-summ[i].
          v-summ2-cred[i] = v-summ-cred[i].
          v-rate2[i] = v-rate[i].
        end.
      when 11 then 
        do i = 1 to v-num: 
          v-summ11[i] = v-summ[i].
          v-summ11-cred[i] = v-summ-cred[i].
          v-rate11[i] = v-rate[i].
        end.
      otherwise 
        do i = 1 to v-num: 
          v-summ99[i] = v-summ99[i] + v-summ[i].
          v-summ99-cred[i] = v-summ99-cred[i] + v-summ-cred[i].
          v-rate99[i] = v-rate99[i] + v-rate[i].
        end.
    end case.
  end.

  if last-of(txb.aaa.gl) then do:
    find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.

   

    find depf where depf.gl = txb.gl.gl and depf.fu = "U" no-error.
    if not avail depf then create depf.

    assign depf.gl = txb.gl.gl
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
             v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.


      depf.v-name1[i] = v-name.
      depf.v-summ1[i] = depf.v-summ1[i] + v-summ1[i].
      depf.v-rate1[i] = v-rate1[i].
      depf.v-summ1-cred[i] = v-summ1-cred[i].

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
             v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name2[i] = v-name.
      depf.v-summ2[i] = depf.v-summ2[i] + v-summ2[i].
      depf.v-rate2[i] = v-rate2[i].
      depf.v-summ2-cred[i] = v-summ2-cred[i].

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
             v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name11[i] = v-name.
      depf.v-summ11[i] = depf.v-summ11[i] + v-summ11[i].
      depf.v-rate11[i] = v-rate11[i].
      depf.v-summ11-cred[i] = v-summ11-cred[i].

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
             v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name99[i] = v-name.
      depf.v-summ99[i] = depf.v-summ99[i] + v-summ99[i].
      depf.v-rate99[i] = v-rate99[i].
      depf.v-summ99-cred[i] = v-summ99-cred[i].

    end.

    do i = 1 to v-num:
      v-summall[i] = v-summall[i] + v-summ1[i] + v-summ2[i] + v-summ11[i] + v-summ99[i].
    end.

    put stream depos2 v-txb " 1 " txb.aaa.gl " 1  ".
    do i = 1 to v-num:
      put stream depos2 v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate1[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.


    put stream depos2 v-txb " 1 " txb.aaa.gl " 2  ".
    do i = 1 to v-num:
      put stream depos2 v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate2[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 1 " txb.aaa.gl " 3  ".
    do i = 1 to v-num:
      put stream depos2 v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate11[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 1 " txb.aaa.gl " 99 ".
    do i = 1 to v-num:
      put stream depos2 v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate99[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
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

for each txb.aaa where 
    (lookup(string(txb.aaa.gl), v-glsfiz) > 0 or lookup(string(txb.aaa.gl), v-vostrfiz) > 0)
    no-lock break by txb.aaa.gl by txb.aaa.crc:

  if first-of(txb.aaa.gl) then do:
    hide message no-pause.
    message v-bnk " FIZ GL " txb.aaa.gl.

    do i = 1 to v-num: 
      v-summ1[i] = 0. 
      v-summ1-cred[i] = 0.
      v-rate1[i] = 0.

      v-summ2[i] = 0. 
      v-summ2-cred[i] = 0.
      v-rate2[i] = 0.

      v-summ11[i] = 0. 
      v-summ11-cred[i] = 0.
      v-rate11[i] = 0.

      v-summ99[i] = 0. 
      v-summ99-cred[i] = 0.
      v-rate99[i] = 0.
    end.
  end.

  if first-of (txb.aaa.crc) then
    do i = 1 to v-num: 
      v-summ[i] = 0. 
      v-summ-cred[i] = 0.
      v-rate[i] = 0.
    end.


  /* обрабатываем только нужные счета */
  if txb.aaa.regdt < v-dt /*and (txb.aaa.sta <> "c" or (txb.aaa.sta = "c" and txb.aaa.cltdt >= v-dt))*/ then do:

    /* кредитовые поступления в заданный период */
    
    v-sumcred = 0.
   /* do v-dtc = txb.aaa.regdt to v-dt - 1:
      c-jl:
      for each txb.jl where txb.jl.jdt = v-dtc and txb.jl.acc = txb.aaa.aaa and txb.jl.gl = txb.aaa.gl no-lock:
        if txb.jl.lev = 1 and txb.jl.dc = "c" and not (txb.jl.rem[1] begins "O/D PROTECT" or txb.jl.rem[1] begins "O/D PAYMENT") then do:
          if txb.jl.crc = 1 then v-sumcred = v-sumcred + txb.jl.cam.
          else do:
            find last txb.crchis where txb.crchis.crc = txb.jl.crc and txb.crchis.rdt <= txb.jl.jdt no-lock no-error.
            if avail txb.crchis then v-sumcred = v-sumcred + txb.jl.cam * txb.crchis.rate[1].
            else do:
               message "no crc! " txb.jl.jdt txb.jl.crc. pause.
               find txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
               v-sumcred = v-sumcred + txb.jl.cam * txb.crc.rate[1].
            end.
          end.
        end.
      end.
    end.
*/
    /* остаток на заданную дату */
    find last txb.histrxbal where txb.histrxbal.subled = 'CIF' and txb.histrxbal.acc = txb.aaa.aaa and txb.histrxbal.level = 1
                                  and txb.histrxbal.dt < v-dt no-lock no-error.
        if avail txb.histrxbal then v-bal = txb.histrxbal.cam - txb.histrxbal.dam.
                               else v-bal = 0.

    find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt < v-dt no-lock no-error.
    if avail txb.aab then do: 
/*      v-bal = txb.aab.bal.*/
      v-balrate = txb.aab.rate.
    end.
    else do: 
/*      v-bal = 0.          */
      v-balrate = txb.aaa.rate.
    end.


    if txb.aaa.crc <> 1 then do:
      find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt < v-dt no-lock no-error.
      if avail txb.crchis then v-bal = v-bal * txb.crchis.rate[1].
      else do:
         message "no crc! " txb.aaa.regdt txb.aaa.crc. pause.
         find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
         v-bal = v-bal * txb.crc.rate[1].
      end.
    end.

    /* раскидать по срокам */

    if (txb.aaa.expdt = ?) or (txb.aaa.expdt - txb.aaa.regdt <= 7) or lookup(string(txb.aaa.gl), v-vostrfiz) > 0 then do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 7 and txb.aaa.expdt - txb.aaa.regdt <= 30 then do:
      v-summ[2] = v-summ[2] + v-bal.
      v-summ-cred[2] = v-summ-cred[2] + v-sumcred.
      v-rate[2] = v-rate[2] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 30 and txb.aaa.expdt - txb.aaa.regdt <= 90 then do:
      v-summ[3] = v-summ[3] + v-bal.
      v-summ-cred[3] = v-summ-cred[3] + v-sumcred.
      v-rate[3] = v-rate[3] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 90 and txb.aaa.expdt - txb.aaa.regdt <= 180 then do:
      v-summ[4] = v-summ[4] + v-bal.
      v-summ-cred[4] = v-summ-cred[4] + v-sumcred.
      v-rate[4] = v-rate[4] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 180 and txb.aaa.expdt - txb.aaa.regdt <= 270 then do:
      v-summ[5] = v-summ[5] + v-bal.
      v-summ-cred[5] = v-summ-cred[5] + v-sumcred.
      v-rate[5] = v-rate[5] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 270 and txb.aaa.expdt - txb.aaa.regdt <= 365 then do:
      v-summ[6] = v-summ[6] + v-bal.
      v-summ-cred[6] = v-summ-cred[6] + v-sumcred.
      v-rate[6] = v-rate[6] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 365 and txb.aaa.expdt - txb.aaa.regdt <= 730 then do:
      v-summ[7] = v-summ[7] + v-bal.
      v-summ-cred[7] = v-summ-cred[7] + v-sumcred.
      v-rate[7] = v-rate[7] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 730 and txb.aaa.expdt - txb.aaa.regdt <= 1095 then do:
      v-summ[8] = v-summ[8] + v-bal.
      v-summ-cred[8] = v-summ-cred[8] + v-sumcred.
      v-rate[8] = v-rate[8] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 1095 and txb.aaa.expdt - txb.aaa.regdt <= 1826 then do:
      v-summ[9] = v-summ[9] + v-bal.
      v-summ-cred[9] = v-summ-cred[9] + v-sumcred.
      v-rate[9] = v-rate[9] + v-bal * v-balrate.
    end.
    else 
    if txb.aaa.expdt - txb.aaa.regdt > 1826 then do:
      v-summ[10] = v-summ[10] + v-bal.
      v-summ-cred[10] = v-summ-cred[10] + v-sumcred.
      v-rate[10] = v-rate[10] + v-bal * v-balrate.
    end.
    else do:
      v-summ[1] = v-summ[1] + v-bal.
      v-summ-cred[1] = v-summ-cred[1] + v-sumcred.
      v-rate[1] = v-rate[1] + v-bal * v-balrate.
    end.

  end.

  if last-of(txb.aaa.crc) then do:
    do i = 1 to v-num - 1: 
      v-summ[v-num] = v-summ[v-num] + v-summ[i].
      v-summ-cred[v-num] = v-summ-cred[v-num] + v-summ-cred[i].
      v-rate[v-num] = v-rate[v-num] + v-rate[i].
    end.

    case txb.aaa.crc :
      when 1 then 
        do i = 1 to v-num: 
          v-summ1[i] = v-summ[i].
          v-summ1-cred[i] = v-summ-cred[i].
          v-rate1[i] = v-rate[i].
        end.
      when 2 then 
        do i = 1 to v-num: 
          v-summ2[i] = v-summ[i].
          v-summ2-cred[i] = v-summ-cred[i].
          v-rate2[i] = v-rate[i].
        end.
      when 11 then 
        do i = 1 to v-num: 
          v-summ11[i] = v-summ[i].
          v-summ11-cred[i] = v-summ-cred[i].
          v-rate11[i] = v-rate[i].
        end.
      otherwise 
        do i = 1 to v-num: 
          v-summ99[i] = v-summ99[i] + v-summ[i].
          v-summ99-cred[i] = v-summ99-cred[i] + v-summ-cred[i].
          v-rate99[i] = v-rate99[i] + v-rate[i].
        end.
    end case.
  end.

  if last-of(txb.aaa.gl) then do:
    find txb.gl where txb.gl.gl = txb.aaa.gl no-lock no-error.
    put stream depos  skip 
        "-----------------------------------" skip(1)
        "ГК " txb.gl.gl "  " txb.gl.des skip 
        "--------" skip.



    find depf where depf.gl = txb.gl.gl and depf.fu = "F" no-error.
    if not avail depf then create depf.

    assign depf.gl = txb.gl.gl
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
             v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name1[i] = v-name.
      depf.v-summ1[i] = depf.v-summ1[i] + v-summ1[i].
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
             v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name2[i] = v-name.
      depf.v-summ2[i] = depf.v-summ2[i] + v-summ2[i].
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
             v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name11[i] = v-name.
      depf.v-summ11[i] = depf.v-summ11[i] + v-summ11[i].
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
             v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" skip.

      depf.v-name99[i] = v-name.
      depf.v-summ99[i] = depf.v-summ99[i] + v-summ99[i].
      depf.v-rate99[i] = v-rate99[i].
      depf.v-summ99-cred[i] = v-summ99-cred[i].

    end.

    do i = 1 to v-num:
      v-summall[i] = v-summall[i] + v-summ1[i] + v-summ2[i] + v-summ11[i] + v-summ99[i].
    end.

    put stream depos2 v-txb " 2 " txb.aaa.gl " 1  ".
    do i = 1 to v-num:
      put stream depos2 v-summ1[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate1[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ1-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.


    put stream depos2 v-txb " 2 " txb.aaa.gl " 2  ".
    do i = 1 to v-num:
      put stream depos2 v-summ2[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate2[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ2-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 2 " txb.aaa.gl " 3  ".
    do i = 1 to v-num:
      put stream depos2 v-summ11[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate11[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ11-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
    end.
    put stream depos2 skip.

    put stream depos2 v-txb " 2 " txb.aaa.gl " 99 ".
    do i = 1 to v-num:
      put stream depos2 v-summ99[i] format "-zzz,zzz,zzz,zzz,zz9.99"  " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-rate99[i] format "zzz9.99" " ".
    end.
    do i = 1 to v-num:
      put stream depos2 v-summ99-cred[i] format "-zzz,zzz,zzz,zzz,zz9.99" " ".
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

/*run menu-prt ("depos" + v-bnk + ".txt").*/
