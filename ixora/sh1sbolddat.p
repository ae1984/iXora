/* sh1sbolddat.p
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

/* sh1sbdat.p
   Расшифровка к 1-СБ по старому варианту - по филиалам

   13.05.2003 nadejda
*/

def input parameter p-bank as char.

def shared var v-dtb as date.
def shared var v-dte as date.
def var v-dt as date.

def shared temp-table t-data
  field clnsts as integer
  field stroka as integer
  field itog as logical init no
  field kr as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field ost as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field kr% as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  field ost% as deci extent 3 format "zzz,zzz,zzz,zz9.99"
  index main is primary unique stroka clnsts.


def temp-table t-accs
  field aaa as char
  field gl like txb.gl.gl
  field crc like txb.crc.crc
  index main is primary unique crc aaa.

def temp-table t-jl like txb.jl.

hide message no-pause.
message p-bank " Начало...".

do v-dt = v-dtb to v-dte:
  for each txb.jh where txb.jh.jdt = v-dt no-lock, 
      each txb.jl where txb.jl.jh = txb.jh.jh no-lock:

    if not (txb.jh.party begins "Storn") and 
       not (txb.jl.rem[1] begins "O/D PROTECT" or txb.jl.rem[1] begins "O/D PAYMENT") and 
       txb.jl.dc = "c" and
       txb.jl.lev = 1 then do:

      create t-jl.
      buffer-copy txb.jl to t-jl.
    end.
  end.
end.

hide message no-pause.
message p-bank " Проводки за период собраны...".


/* ЮР ЛИЦА  */

/* до востребования */
find t-data where t-data.clnsts = 1 and t-data.stroka = 2 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 1
         t-data.stroka = 2.
end.
run findaccs1("2211").
run acceptsum.




/* краткосрочные */
find t-data where t-data.clnsts = 1 and t-data.stroka = 4 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 1
         t-data.stroka = 4.
end.
run findaccs1("2215").
run acceptsum.
/* краткосрочные гарантии */
run findaccs2("2223", 1).
run acceptsum.
/* условные загоняем в срочные */
run findaccs2("2219", 1).
run acceptsum.



/* долгосрочные */
find t-data where t-data.clnsts = 1 and t-data.stroka = 5 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 1
         t-data.stroka = 5.
end.
run findaccs1("2217").
run acceptsum.
/* долгосрочные гарантии */
run findaccs2("2223", 2).
run acceptsum.
/* условные загоняем в срочные */
run findaccs2("2219", 2).
run acceptsum.


/* ФИЗ ЛИЦА  */

/* до востребования */
find t-data where t-data.clnsts = 2 and t-data.stroka = 2 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 2
         t-data.stroka = 2.
end.
run findaccs1("2211").
run acceptsum.


/* краткосрочные */
find t-data where t-data.clnsts = 2 and t-data.stroka = 4 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 2
         t-data.stroka = 4.
end.
run findaccs1("2215").
run acceptsum.
/* краткосрочные гарантии */
run findaccs2("2223", 1).
run acceptsum.
/* условные загоняем в срочные */
run findaccs2("2219", 1).
run acceptsum.


/* долгосрочные */
find t-data where t-data.clnsts = 2 and t-data.stroka = 5 no-error.
if not avail t-data then do:
  create t-data.
  assign t-data.clnsts = 2
         t-data.stroka = 5.
end.
run findaccs1("2217").
run acceptsum.
/* долгосрочные гарантии */
run findaccs2("2223", 2).
run acceptsum.
/* условные загоняем в срочные */
run findaccs2("2219", 2).
run acceptsum.




/**************************************************************************************/

def var v-secek as char extent 2 init ["6,7,8", "9"].

procedure findaccs1.
  def input parameter p-gl as char.

  for each t-accs. delete t-accs. end.

  for each txb.crchs where txb.crchs.Hs = "H" no-lock:
    c-aaa1:
    for each txb.aaa where txb.aaa.crc = txb.crchs.crc no-lock:
      if not (string(txb.aaa.gl) begins p-gl) or (txb.aaa.sta = "c" and txb.aaa.cltdt < v-dtb) then next c-aaa1.

      find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
      if substr(txb.cif.geo, 3, 1) = "2" then next c-aaa1.

      find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
      if lookup(txb.sub-cod.ccode, v-secek[t-data.clnsts]) = 0 then next c-aaa1.
       
      create t-accs.
      assign t-accs.aaa = txb.aaa.aaa
             t-accs.gl = txb.aaa.gl
             t-accs.crc = txb.aaa.crc.
    end.
  end.

  hide message no-pause.
  message p-bank " Счета " p-gl " собраны...".

end procedure.


procedure findaccs2.
  def input parameter p-gl as char.
  def input parameter p-srok as integer.

  for each t-accs. delete t-accs. end.

  for each txb.crchs where txb.crchs.Hs = "H" no-lock:
    c-aaa2:
    for each txb.aaa where txb.aaa.crc = txb.crchs.crc no-lock:
      if not (string(txb.aaa.gl) begins p-gl) or (txb.aaa.sta = "c" and txb.aaa.cltdt < v-dtb) then next c-aaa2.

      if not ((txb.aaa.expdt - txb.aaa.regdt <= 365 and p-srok = 1) or 
              (txb.aaa.expdt - txb.aaa.regdt > 365 and p-srok = 2)) then next c-aaa2.

      find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
      if substr(txb.cif.geo, 3, 1) = "2" then next c-aaa2.

      find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
      if lookup(txb.sub-cod.ccode, v-secek[t-data.clnsts]) = 0 then next c-aaa2.
        
      create t-accs.
      assign t-accs.aaa = txb.aaa.aaa
             t-accs.gl = txb.aaa.gl
             t-accs.crc = txb.aaa.crc.
    end.
  end.

  hide message no-pause.
  message p-bank " Счета " p-gl " собраны...".

end procedure.

procedure acceptsum.
  def var v-sum as deci.
  def var v-summa as deci.
  def var v-sumkr as deci.
  def var v-sumkrrate as deci.
  def var v-sumost as deci.
  def var v-sumostrate as deci.
  def var v-sumost1 as deci.
  def var v-sumostrate1 as deci.

  for each t-accs break by t-accs.crc:
    if first-of(t-accs.crc) then do:
      v-sumkr = 0. 
      v-sumkrrate = 0.
      v-sumost = 0.
      v-sumostrate = 0.
    end.

    /* найти кредитовые поступления по счету за период */
    for each t-jl where t-jl.acc = t-accs.aaa no-lock:
      if t-jl.gl = t-accs.gl then do:
        run crc2kzt (t-jl.crc, t-jl.jdt, t-jl.cam, output v-sum).
        v-sumkr = v-sumkr + v-sum.

        find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= t-jl.jdt no-lock no-error.
        if avail txb.aab and txb.aab.rate > 0 then
          v-sumkrrate = v-sumkrrate + v-sum * txb.aab.rate.
      end.
    end.

    /* остатки */
    find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= v-dte no-lock no-error.
    if avail txb.aab and txb.aab.bal > 0 then do:
      v-sumost = v-sumost + txb.aab.bal.
      v-sumostrate = v-sumostrate + txb.aab.bal * txb.aab.rate.
    end.

    
    if last-of(t-accs.crc) then do:
      run crc2kzt (t-accs.crc, v-dte, v-sumost, output v-sumost1).
      run crc2kzt (t-accs.crc, v-dte, v-sumostrate, output v-sumostrate1).

      case t-accs.crc:
        when 2 then do: 
            t-data.kr[1] = t-data.kr[1] + v-sumkr.
            t-data.kr%[1] = t-data.kr%[1] + v-sumkrrate.
            t-data.ost[1] = t-data.ost[1] + v-sumost1.
            t-data.ost%[1] = t-data.ost%[1] + v-sumostrate1.
          end.
        when 3 then do:
            t-data.kr[2] = t-data.kr[2] + v-sumkr.
            t-data.kr%[2] = t-data.kr%[2] + v-sumkrrate.
            t-data.ost[2] = t-data.ost[2] + v-sumost1.
            t-data.ost%[2] = t-data.ost%[2] + v-sumostrate1.
          end.
        otherwise do:
            t-data.kr[3] = t-data.kr[3] + v-sumkr.
            t-data.kr%[3] = t-data.kr%[3] + v-sumkrrate.
            t-data.ost[3] = t-data.ost[3] + v-sumost1.
            t-data.ost%[3] = t-data.ost%[3] + v-sumostrate1.
          end.
      end case.
      
    end.
  end.

end.


procedure crc2kzt.
  def input parameter        c-from    like txb.crc.crc.
  def input parameter        c-date    as date.
  def input parameter        v-from    as decimal decimals 2 
                                       format "->>,>>>,>>>,>>>,>>9.99".
  def output parameter       v-to      as decimal decimals 2
                                       format "->>,>>>,>>>,>>>,>>9.99".

  find last txb.crchis where txb.crchis.rdt <= c-date and txb.crchis.crc = c-from no-lock no-error.
  if avail txb.crchis then v-to = v-from * txb.crchis.rate[1].
                      else v-to = 0.               

end procedure.

