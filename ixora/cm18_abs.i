/* cm18_abs.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/


/***************************************************************************************/
function GetCRC returns char (input currency as integer).
  def var code as char format "x(3)".
  def buffer b-crc for crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
   if code = "RUB" then code = "RUR".
  return code.
end function.
/****************************************************************************************/
function GetSafeARP returns char (input v-safe as char, input v-crc as integer).
   def var v-arp as char.
   for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
     find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-safe no-lock no-error.
     if avail sub-cod then do:
         v-arp = arp.arp.
     end.
   end.
   return v-arp.
end function.
/****************************************************************************************/
function GetSafeARPbal returns deci (input v-safe as char, input v-crc as integer).
   def var v-bal as deci.
   for each arp where arp.gl = 100500 and arp.crc = v-crc no-lock.
     find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-safe no-lock no-error.
     if avail sub-cod then do:
        v-bal = arp.dam[1] - arp.cam[1].
     end.
   end.
   return v-bal.
end function.
/****************************************************************************************/
function GetCashOfc returns deci (input v-cr as char, input v-ofc as char, input dt as date).
  def buffer b-crc for crc.
  def var v-crc as int.
  def var t-cr as char.
  if v-cr = "RUR" then t-cr = "RUB".
  else t-cr = v-cr.
   find first b-crc where b-crc.code = t-cr no-lock no-error.
   if avail b-crc then v-crc = b-crc.crc.
   else v-crc = 0.
   find first cashofc where cashofc.whn = dt and cashofc.ofc  = v-ofc and cashofc.sts = 2 and cashofc.crc = v-crc no-lock no-error.
   if avail cashofc then do:
      return cashofc.amt.
   end.
   else return 0.
end function.
/**************************************************************************************************/
function SetCashOfc returns deci (input v-oper as int,input v-crc as int, input v-ofc as char, input v-dt as date, input amount as deci).
   find first cashofc where cashofc.whn = v-dt and cashofc.crc = v-crc and cashofc.sts = 2 and cashofc.ofc = v-ofc no-error.
   if avail cashofc then do:
     if v-oper = 3 or v-oper = 10 then cashofc.amt = cashofc.amt - amount.
     else cashofc.amt = cashofc.amt + amount. /*операция 4*/
   end.
   else do:
     create cashofc.
     cashofc.ofc = v-ofc.
     cashofc.whn = v-dt.
     cashofc.crc = v-crc.
     cashofc.sts = 2.
     cashofc.amt = amount.
  end.
  return amount.
end function.
/**************************************************************************************************/
procedure SelectSafe:
  def input param s-ourbank as char.
  def input param v-dep as int.
  def output param v-safe as char.

   def var CsList as char.
   for each comm.cslist where comm.cslist.bank = s-ourbank and comm.cslist.info[1] = string(v-dep) no-lock:
     if length(CsList) > 0 then CsList = CsList + "," + comm.cslist.nomer.
     else CsList = comm.cslist.nomer.
   end.
   if num-entries(CsList) > 1 then do:
      CsList = replace(CsList,",","|").
      run sel1("Сейф для операции", CsList).
      v-safe = return-value.
   end.
   else do:
      v-safe = CsList.
   end.
end procedure.
/****************************************************************************************/
procedure CheckConfig:
   def input  param p-ofc  as char.
   def input  param p-ip   as char.
   def output param p-safe as char.
   def output param p-side as char.
   def output param inst   as log.
   def output param rez    as log.
   rez = false.
   inst = false.

  find first comm.csofc where comm.csofc.ofc = p-ofc no-lock no-error.
  if avail comm.csofc then do:
    find first comm.cslist where comm.cslist.nomer = comm.csofc.nomer no-lock no-error.
    if avail comm.cslist then do:
      if comm.cslist.work[1] <> p-ip and comm.cslist.work[2] <> p-ip then do:
        message "Неразрешено работать с ЭК с этого компьютера!~n" + p-ip  view-as alert-box.
        return.
      end.
      if comm.cslist.work[1] = p-ip then do:
        p-side = "L".
        if comm.cslist.side[1] <> "" then inst = true.
      end.
      else do:
        p-side = "R".
        if comm.cslist.side[2] <> "" then inst = true.
      end.
      p-safe = comm.cslist.nomer.
      rez = true.
      return.
    end.
    else do:
       message "Не найден ЭК" + p-safe + "!" view-as alert-box.
       return.
    end.
  end.
  else do:
    message "Вы не привязаны к ЭК!" view-as alert-box.
    return.
  end.

end procedure.
/****************************************************************************************/
function GetTrxSumm returns deci (input v-crc as integer, input v-trx as integer).
  find first jl where jl.jh = v-trx and jl.crc = v-crc and jl.gl = 100500  no-lock no-error.
  if avail jl then return jl.cam - jl.dam.
  else return 0.
end function.
/****************************************************************************************/
function GetTypeOper returns integer (input savedata as deci extent 10, input loaddata as deci extent 10).
   def var i as int.
   def var pos as int init 0.
   def var oper as int init 0.
   repeat i = 1 to 10:
     if savedata[i] <> loaddata[i] then do:
       pos = pos + 1.
       if savedata[i] > loaddata[i] then oper = 3.
       else oper = 4.
     end.
   end.
   if pos > 1 then return 10.
   else return oper.
end function.
/****************************************************************************************/
procedure SetKassPl:
  def input param v-sysc as char.
  def input param v-jh as int.
  def input param v-sim as int.
  find first sysc where sysc.sysc = v-sysc no-lock no-error.
  if avail sysc then do:
    for each jl where jl.jh = v-jh no-lock:
        if (jl.gl = sysc.inval or jl.gl = 100100) and jl.crc = 1 then
        do: /* проставляем код кассплана  */
            create jlsach .
            jlsach.jh = v-jh.
            if jl.dc = "D" then jlsach.amt = jl.dam . else jlsach.amt = jl.cam .
            jlsach.ln = jl.ln .
            jlsach.lnln = 1.
            jlsach.sim = v-sim .
        end.
    end.
    release jlsach.
  end.
end procedure.
/****************************************************************************************/
