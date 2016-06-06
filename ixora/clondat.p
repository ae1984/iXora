/* clondat.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Остатки на депозитных счетах по ОСТАВШЕМУСЯ сроку
 * RUN
        
 * CALLER
        clonsb.p
 * SCRIPT
        
 * INHERIT

 * MENU
        8-2-14-10
 * BASES
        BANK COMM TXB
 * AUTHOR
        09.04.2004 valery данный отчет является клоном отчета 1sb.p
 * CHANGES
*/


def input parameter p-bank as char.

def shared var v-dtb as date.
def shared var v-dte as date.
def shared var v-secek as char extent 2.
def shared var v-norezid as logical.

def var v-dt as date.
def var v-ostb0   as deci.
def var v-procb0  as deci.
def var v-oste0   as deci.
def var v-proce0  as deci.
def var v-ostb   as deci.
def var v-procb  as deci.
def var v-cr     as deci.
def var v-proccr as deci.
def var v-dr     as deci.
def var v-procdr as deci.
def var v-oste   as deci.
def var v-proce  as deci.

def var v-sum   as deci.
def var v-proc  as deci.
def var i as integer.
def var n as integer.
def var p as integer.

def var v-stroka as integer.
def var v-god as decimal.
def var v-mc as decimal.
def var v-days as integer.




def shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field stroka as integer
  field sum as deci extent 4
  field sumfin as deci extent 4
  field proc as deci extent 4
  field procavg as deci extent 4
  index main is primary unique punkt stroka clnsts
  index stroka clnsts stroka .



def temp-table t-accs
  field aaa as char
  field crc like txb.crc.crc
  field stroka as integer
  field clnsts as integer
  index main is primary unique crc aaa.

/*
def temp-table t-jl  
  field jh like txb.jh.jh
  field ln like txb.jl.ln
  field jdt as date
  field crc like txb.crc.crc
  field gl like txb.gl.gl
  field acc like txb.jl.acc
  field dc as char
  field sum as decimal
  index main is primary unique acc dc gl jh ln.
*/

hide message no-pause.
message p-bank " Начало обработки...".


def shared temp-table t-gl 
  field gl like txb.gl.gl
  field glstr as char
  field stroka as integer
  field crc like txb.gl.crc
  index main is primary unique stroka gl.

/*
for each t-gl:
  do v-dt = v-dtb to v-dte:
    for each txb.jl where txb.jl.jdt = v-dt and txb.jl.gl = t-gl.gl no-lock use-index jdt:
      find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.

      
      if (txb.jh.party begins "Storn") or
         (txb.jl.rem[1] begins "O/D PROTECT" or txb.jl.rem[1] begins "O/D PAYMENT") or
         txb.jl.lev <> 1 then next.
         

      create t-jl.
      assign t-jl.jh  = txb.jl.jh 
             t-jl.ln  = txb.jl.ln 
             t-jl.jdt = txb.jl.jdt
             t-jl.crc = txb.jl.crc
             t-jl.gl  = txb.jl.gl 
             t-jl.acc = txb.jl.acc
             t-jl.dc  = txb.jl.dc 
             t-jl.sum = if txb.jl.dc = "d" then txb.jl.dam else txb.jl.cam.

    end.
  end.
end.

hide message no-pause.
message p-bank " Проводки за период собраны...".
*/


for each t-gl:
  for each txb.aaa where txb.aaa.gl = t-gl.gl no-lock:
    if aaa.regdt > v-dte then next.
    if txb.aaa.sta = "c" and txb.aaa.cltdt <= v-dtb then next.

    if not v-norezid then do:
      /* нерезиденты в отчете не нужны */
      find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
      if substr(txb.cif.geo, 3, 1) <> "1" then next.
    end.


    i = 0.
    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and 
         txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
    if avail txb.sub-cod then do:
      i = lookup(txb.sub-cod.ccode, v-secek[1]).
      if i > 0 then i = 1.
      else do:
        i = lookup(txb.sub-cod.ccode, v-secek[2]).
        if i > 0 then i = 2.
      end.
    end.
    else i = 0.

    if i = 0 then next.

    v-stroka = t-gl.stroka.
    if v-stroka = 4 then do:
      /* если это юрлицо, и это счет-гарантия, и на день отчета гарантия просрочена => строка "до востребования" */
      if i = 1 and t-gl.glstr = "2223" and txb.aaa.expdt <= v-dte then v-stroka = 2.
      else do:
        /* для срочных депозитов - деление на строки по срокам вклада */
        if txb.aaa.expdt = ? then do: v-stroka = 10. end.
        else do:
          
          v-days = txb.aaa.expdt - v-dtb.
          v-mc = v-days / 30.
          v-god = v-days / 365.


          if v-god <= 1 then do:
            if v-mc <= 1               then v-stroka = v-stroka + 1.
            if v-mc > 1 and v-mc <= 3  then v-stroka = v-stroka + 2.
            if v-mc > 3 and v-mc <= 6  then v-stroka = v-stroka + 3.
            if v-mc > 6 then v-stroka = v-stroka + 4.
          end.
          else do:
            if v-god <= 5 then v-stroka = v-stroka + 5.
                          else v-stroka = v-stroka + 6.
          end.
        end.
      end.
    end.

    do transaction on error undo, return:
      create t-accs.
      assign t-accs.aaa = txb.aaa.aaa
             t-accs.stroka = v-stroka
             t-accs.clnsts = i
             t-accs.crc = txb.aaa.crc.

    end.
  end.

  hide message no-pause.
  message p-bank " Счета " t-gl.gl " собраны...".

end.




hide message no-pause.
message p-bank " Окончание обработки...".


for each t-accs break by t-accs.stroka by t-accs.clnsts by t-accs.crc:
  if first-of(t-accs.crc) then do:
    v-ostb0   = 0. 
    v-procb0  = 0.
    v-oste0   = 0. 
    v-proce0  = 0.
    v-cr     = 0.
    v-proccr = 0.
    v-dr     = 0.
    v-procdr = 0.
  end.

/*
  /* найти проводки по счету за период */
  for each t-jl where t-jl.acc = t-accs.aaa no-lock use-index main break by t-jl.dc:
    if t-jl.crc = 1 then v-sum = t-jl.sum.
                    else run crc2kzt (t-jl.crc, t-jl.jdt, t-jl.sum, output v-sum).
    
    accumulate v-sum (sub-total by t-jl.dc).
    
    find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= t-jl.jdt no-lock no-error.
    if avail txb.aab and txb.aab.rate > 0 then do:
      v-proc = v-sum * txb.aab.rate.
      accumulate v-proc (sub-total by t-jl.dc).
    end.

    if last-of (t-jl.dc) then do:
      if t-jl.dc = "c" then do:
        v-cr = v-cr + (accum sub-total by t-jl.dc v-sum).
        v-proccr = v-proccr + (accum sub-total by t-jl.dc v-proc).
      end.
      else do:
        v-dr = v-dr + (accum sub-total by t-jl.dc v-sum).
        v-procdr = v-procdr + (accum sub-total by t-jl.dc v-proc).
      end.
    end.
  end.


  /* остатки на начало */
  find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt < v-dtb no-lock no-error.
  if avail txb.aab and txb.aab.bal > 0 then do:
    v-ostb0 = v-ostb0 + txb.aab.bal.
    v-procb0 = v-procb0 + txb.aab.bal * txb.aab.rate.
  end.
*/
  /* остатки на конец */
  find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= v-dte no-lock no-error.
  if avail txb.aab and txb.aab.bal > 0 then do:
    v-oste0 = v-oste0 + txb.aab.bal.
    v-proce0 = v-proce0 + txb.aab.bal * txb.aab.rate.
  end.
  
  if last-of(t-accs.crc) then do:
    if t-accs.crc = 1 then do:
      v-ostb   = v-ostb0.
      v-procb  = v-procb0. 
      v-oste   = v-oste0.
      v-proce  = v-proce0.

      n = 1.
    end.
    else do:
/*
      run crc2kzt (t-accs.crc, v-dtb - 1, v-ostb0, output v-ostb).
      run crc2kzt (t-accs.crc, v-dtb - 1, v-procb0, output v-procb).
*/  
      run crc2kzt (t-accs.crc, v-dte, v-oste0, output v-oste).

      if t-accs.crc = 2 then n = 2. 
      if t-accs.crc = 3 then n = 3.
      if t-accs.crc = 4 then n = 4.
    end.


    do p = 4 to 4 transaction on error undo, return:
      find t-data where t-data.punkt = p and t-data.clnsts = t-accs.clnsts and t-data.stroka = t-accs.stroka no-error.
      if not avail t-data then do:
        create t-data.
        assign t-data.punkt = p
               t-data.clnsts = t-accs.clnsts 
               t-data.stroka = t-accs.stroka.
      end.

      case p :
/*
        when 1 then do:
          t-data.sum[n] = t-data.sum[n] + v-ostb.
          t-data.proc[n] = t-data.proc[n] + v-procb.
        end.
        when 2 then do:
          t-data.sum[n] = t-data.sum[n] + v-cr.
          t-data.proc[n] = t-data.proc[n] + v-proccr.
        end.
        when 3 then do:
          t-data.sum[n] = t-data.sum[n] + v-dr.
          t-data.proc[n] = t-data.proc[n] + v-procdr.
        end.
*/
        when 4 then do:
          t-data.sum[n] = t-data.sum[n] + v-oste.
        end.
      end case.
    end.

  end.
end.

hide message no-pause.
message p-bank " Обработка закончена".




/**************************************************************************************/


procedure crc2kzt.
  def input parameter        c-from    like txb.crc.crc.
  def input parameter        c-date    as date.
  def input parameter        v-from    as decimal decimals 10.
  def output parameter       v-to      as decimal decimals 10.

  find last txb.crchis where txb.crchis.rdt <= c-date and txb.crchis.crc = c-from no-lock no-error.
  if avail txb.crchis then v-to = v-from * txb.crchis.rate[1].
                      else v-to = 0.               

end procedure.

