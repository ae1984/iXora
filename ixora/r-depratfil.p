/* r-depratfil.p
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
*/

/* r-depratfil.p 
   Расчетная часть сводного отчета о депозитах - остатки и средневзвеш.ставки вознаграждения по валютам
   Вызывается из r-deprat.p

   Создан : 27.05.2003 Надежда Лысковская

*/

def input parameter p-bank as char.

def shared var v-dt as date.


def shared temp-table t-gl 
  field gl as integer
  field vostr as logical
  field sum as deci format "zzz,zzz,zzz,zzz,zz9.99"
  field sumval as deci format "zzz,zzz,zzz,zzz,zz9.99"
  index gl is primary unique gl.

def shared temp-table t-sums 
  field clnsts as char
  field crc as integer
  field crccode as char
  field srok as integer
  field sum as decimal format "zzz,zzz,zzz,zzz,zz9.99"
  field rate as decimal format "zz9.999999"
  index main is primary clnsts srok crc.

def var v-srok as integer.
def var v-kurs as deci.
def var v-bal as deci.
def var v-rate as deci.
def var v-clnsts as char.

for each t-gl:
  hide message no-pause.
  message p-bank "Обрабатывается счет ГК " t-gl.gl.

  for each txb.aaa where (txb.aaa.gl = t-gl.gl) and (txb.aaa.regdt <= v-dt) no-lock break by txb.aaa.crc:
    if first-of (txb.aaa.crc) then do:
      find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= v-dt no-lock no-error.
      if avail txb.crchis then v-kurs = txb.crchis.rate[1].
      else do:
         hide message no-pause.
         message p-bank "no crc!" txb.aaa.crc. pause.
         find txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
         v-kurs = txb.crc.rate[1].
      end.
    end.

    if txb.aaa.sta = "c" and txb.aaa.cltdt <= v-dt then next.

    if t-gl.vostr then v-srok = 0.
    else do:
      if txb.aaa.expdt - txb.aaa.regdt > 365 then v-srok = 2. 
                                     else v-srok = 1.
    end.

    /* остаток на заданную дату */
    find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-dt no-lock no-error.
    if avail txb.aab then do:
      v-bal = txb.aab.bal.
      v-rate = txb.aab.rate.
    end.
    else do: 
      hide message no-pause.
      message p-bank "no aab!". pause 2.
      v-bal = txb.aaa.cr[1] - txb.aaa.dr[1]. 
      v-rate = txb.aaa.rate.
      if v-bal <> 0 then do: 
        message txb.aaa.aaa txb.aaa.regdt v-bal. pause.
      end. 
    end.

    if txb.aaa.crc <> 1 then do:
      v-bal = v-bal * v-kurs.
    end.

    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
    if not avail txb.sub-cod or txb.sub-cod.ccode = "msc" then do:
      hide message no-pause.
      message p-bank "Нет сектора экономики" txb.aaa.cif ", счет" txb.aaa.aaa "остаток" v-bal. 
      pause 5. 
      next.
    end.

    if txb.sub-cod.ccode = "9" then v-clnsts = "1". 
                               else v-clnsts = "0".

    find t-sums where t-sums.clnsts = v-clnsts and t-sums.crc = txb.aaa.crc and t-sums.srok = v-srok no-error.
    if not avail t-sums then do:
      create t-sums.
      assign t-sums.clnsts = v-clnsts
             t-sums.crc = txb.aaa.crc
             t-sums.srok = v-srok.
    end.

    t-sums.sum = t-sums.sum + v-bal.
    t-sums.rate = t-sums.rate + v-bal * v-rate.

  end.

end.

hide message no-pause.
