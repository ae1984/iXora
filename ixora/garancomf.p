/* garancomf.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Отчет по амортизации комиссии по гарантиям сбор данных
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
         Вызывается из программы garancom.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06/09/2013 galina galina по ТЗ 1779
 * BASES
        BANK TXB COMM
 * CHANGES
*/

def shared var v-dat    as date no-undo.
def shared var v-rate   as deci no-undo extent 3.
def shared var v-name as char no-undo extent 3.

define shared var g-today  as date.

def shared  temp-table temp
     field filial     as   char
     field name       like txb.cif.sname
     field numgar     as   char
     field gl         as   char
     field curr       as   char
     field sumgar     like txb.garan.sumtreb
     field sumgarkzt  like txb.garan.sumtreb
     field dtfrom     like txb.aaa.regdt
     field dtto       like txb.aaa.expdt
     field sumkom     like txb.garan.sumkom
     field sumkomostB like txb.garan.sumkom /*Остаток несамортизированной комиссии на балансе 286920*/
     field sumkomostC like txb.garan.sumkom /*Остаток несамортизированной комиссии (расчетная величина)*/
     field sumkomostR like txb.garan.sumkom /*Остаток несамортизированной комиссии разница между расчетной и реальной суммой*/.

def var v-bank   as char no-undo.
def var v-bankn  as char no-undo.
def var v-amortcomB as deci no-undo.
def var v-amortcomC as deci no-undo.
def var v-jl as int no-undo.

function get_amt returns deci (p-acc as char, p-gl as integer, p-lev as integer, p-dt as date, p-sub as char, p-crc as integer).
  def var v-amt as deci.
  v-amt = 0.
  if p-dt < g-today then do:
    find last txb.histrxbal where txb.histrxbal.subled = p-sub and txb.histrxbal.acc = p-acc and txb.histrxbal.level = p-lev and txb.histrxbal.crc = p-crc and txb.histrxbal.dt <= p-dt  no-lock no-error.
    if avail txb.histrxbal then do:
      find txb.gl where txb.gl.gl  = p-gl no-lock no-error.
      if avail txb.gl then do:
          if txb.gl.type eq "A" or txb.gl.type eq "E" then
               v-amt = txb.histrxbal.dam - txb.histrxbal.cam.
          else v-amt = txb.histrxbal.cam - txb.histrxbal.dam.
      end.
    end.

  end.
  if p-dt = g-today then do:
    find first txb.trxbal where txb.trxbal.subled = p-sub and txb.trxbal.acc = p-acc and txb.trxbal.level = p-lev and txb.trxbal.crc = p-crc no-lock no-error.
    if avail txb.trxbal then do:
      find txb.gl where txb.gl.gl  = p-gl no-lock no-error.
      if avail txb.gl then do:
          if txb.gl.type eq "A" or txb.gl.type eq "E" then
               v-amt = txb.trxbal.dam - txb.trxbal.cam.
          else v-amt = txb.trxbal.cam - txb.trxbal.dam.
      end.
    end.
  end.
  v-amt = round(v-amt,2).
  return v-amt.
end.


v-bank = ''.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
v-bank = trim(txb.sysc.chval).

v-bankn = ''.
find first comm.txb where comm.txb.bank = v-bank no-lock no-error.
if avail comm.txb then v-bankn = comm.txb.info.


for each txb.garan where txb.garan.dtfrom < v-dat and txb.garan.dtto > v-dat no-lock:
    if txb.garan.jh = 0 then next.
    find first txb.jh where txb.jh.jh = txb.garan.jh no-lock no-error.
    if not avail txb.jh then next.

    v-jl = 0.
    find first txb.jl where txb.jl.jh = txb.jh.jh and  txb.jl.dc = 'C' and txb.jl.gl = 286920 no-lock no-error.
    if avail txb.jl then v-jl = 286920.

    if v-jl = 0 then do:
        find first txb.jl where txb.jl.jh = txb.jh.jh and txb.jl.dc = 'C' and txb.jl.acc = txb.garan.garan and txb.jl.lev = 30 no-lock no-error.
        if avail txb.jl then v-jl = 286930.
        if v-jl = 0 then next.
    end.

    find first txb.cif where txb.cif.cif = txb.garan.cif no-lock no-error.
    if not avail txb.cif then next.
    find first txb.aaa where txb.aaa.aaa = txb.garan.garan no-lock no-error.
    if not avail txb.aaa then next.
    if txb.garan.dtto = ? then next.
    if txb.garan.sumkom = 0 then next.
    if get_amt(txb.garan.garan,txb.aaa.gl,7,v-dat - 1, "cif", txb.garan.crc)  = 0 then next.
    create temp.
    assign temp.filial = v-bankn
           temp.numgar = txb.garan.garnum
           temp.sumgar = txb.garan.sumtreb
           temp.dtfrom = txb.garan.dtfrom
           temp.dtto = txb.garan.dtto
           temp.gl = string(txb.aaa.gl)
           temp.name = txb.cif.sname.

    if txb.garan.crc <> 1 then do:
        temp.curr = v-name[txb.garan.crc - 1].
        temp.sumgarkzt = round(txb.garan.sumtreb * v-rate[txb.garan.crc - 1],2).
    end.
    else do:
        temp.sumgarkzt = txb.garan.sumtreb.
        temp.curr = 'KZT'.
    end.
    if txb.garan.crc2 <> 1 then temp.sumkom = round(txb.garan.sumkom * v-rate[txb.garan.crc - 1],2).
    else temp.sumkom = txb.garan.sumkom.
    if txb.garan.dtto < v-dat then temp.sumkomostC = 0.
    else do:
        v-amortcomC = 0.
        v-amortcomC = temp.sumkom /(temp.dtto - temp.dtfrom).
        v-amortcomC = v-amortcomC * (v-dat - temp.dtfrom).
        temp.sumkomostC = round(temp.sumkom - v-amortcomC,2).
    end.
    if v-jl = 286920 then do:
        v-amortcomB = 0.
        for each txb.jl where txb.jl.jdt < v-dat and txb.jl.jdt >= txb.garan.dtfrom and txb.jl.dc = 'D' and txb.jl.gl = 286920 no-lock.
            /*if index(txb.jl.rem[1],txb.garan.garnum) = 0 and index(txb.jl.rem[2],txb.garan.garnum) = 0 then next.*/
            if LOOKUP(trim(txb.garan.garnum),txb.jl.rem[1],' ') = 0 and LOOKUP(trim(txb.garan.garnum),txb.jl.rem[2],' ') = 0 then next.
            if index(txb.jl.rem[1],string(txb.garan.dtfrom)) = 0 and index(txb.jl.rem[2],string(txb.garan.dtfrom)) = 0 then next.
            if index(txb.jl.rem[1],'сторно') <> 0 or index(txb.jl.rem[2],'сторно') <> 0 then next.
            if index(txb.jl.rem[1],'Доходы по амортизации') = 0 and index(txb.jl.rem[2],'Доходы по амортизации') = 0 then next.
            if txb.jl.crc <> 1 then v-amortcomB = round(v-amortcomB + txb.jl.dam * v-rate[txb.garan.crc - 1],2).
            else v-amortcomB = round(v-amortcomB + txb.jl.dam,2).
        end.
        temp.sumkomostB = round(temp.sumkom - v-amortcomB,2).
    end.
    else temp.sumkomostB = get_amt(txb.garan.garan,txb.aaa.gl,30,v-dat - 1, "cif", txb.garan.crc).
    temp.sumkomostR = round(temp.sumkomostB - temp.sumkomostC,2).
end.