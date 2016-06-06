/* checkdebt.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        17/02/2011 evseev - уведомление о задолженности
 * BASES
        BANK COMM TXB
 * CHANGES
*/

define shared var g-today  as date.

def temp-table wrk no-undo
  field dt as date
  field ost as deci
  field od as deci
  field prc as deci
  field koms as deci
  field fin as decimal
  index idx is primary dt.
def temp-table wrk1 no-undo
  field contr as char label 'Договор' format 'x(21)'
  field debtkzt as decimal label 'Сумма задолжности'
  field crccodekzt as char
  field debtcrc as char label 'Сумма задолжности'
  field crccode as char
  field monpay as decimal label 'Ежем.платеж'
  field crccode1 as char.


Procedure checkdebt.
def input parameter dt as date.
def input parameter acc as char.
def input parameter commis as char.
def input parameter dbn as char.

define variable debt as decimal.
def var debtcrc as decimal.
define variable debtkzt as decimal.

def var debtaaa as decimal.
def var evmnpay as decimal.

def var mes1 as char.
define frame mess.
define frame mess1.
define frame mess2.

def var v-sum1 as deci no-undo.
def var v-sum as deci no-undo.
def var v-itogo as deci no-undo extent 3.

if lookup(commis,'401,403,436') = 0 then return.
      for each wrk exclusive-lock:
        delete wrk.
      end.
      for each wrk1 exclusive-lock:
        delete wrk1.
      end.


find first {&file}.aaa where {&file}.aaa.aaa = acc no-lock no-error.
if avail {&file}.aaa then do:
  for each {&file}.bxcif where {&file}.bxcif.cif = aaa.cif:
    ACCUMULATE {&file}.bxcif.amount (TOTAL).
  end.
  debtaaa = (accum total {&file}.bxcif.amount).
  for each {&file}.lon where {&file}.lon.aaa = {&file}.aaa.aaa no-lock:
    find first {&file}.loncon where {&file}.loncon.lon = {&file}.lon.lon no-lock no-error.
    if avail {&file}.loncon then do:
      for each {&file}.lnsch where {&file}.lnsch.lnn = {&file}.lon.lon and {&file}.lnsch.flp = 0 and {&file}.lnsch.f0 > 0 no-lock:
          find first wrk where wrk.dt = {&file}.lnsch.stdat exclusive-lock no-error.
          if not avail wrk then do:
             create wrk.
                 assign wrk.dt = {&file}.lnsch.stdat.
          end.
          wrk.ost = v-sum.
          wrk.od = {&file}.lnsch.stval.
          v-sum = v-sum - {&file}.lnsch.stval.
          v-itogo[1] = v-itogo[1] + wrk.od.
      end.

      for each {&file}.lnsci where {&file}.lnsci.lni = {&file}.lon.lon and {&file}.lnsci.flp = 0 and {&file}.lnsci.f0 > 0 no-lock:
          find first wrk where wrk.dt = {&file}.lnsci.idat exclusive-lock no-error.
          if not avail wrk then do:
             create wrk.
               assign wrk.dt = {&file}.lnsci.idat.
          end.
          wrk.prc = {&file}.lnsci.iv-sc.
          v-itogo[2] = v-itogo[2] + wrk.prc.
      end.

      for each wrk exclusive-lock:
          if wrk.od = 0 and wrk.prc <> 0 then wrk.ost = v-sum1.
             v-sum1 = v-sum1 - wrk.od.
          end.
          if avail {&file}.lons then do:
             for each {&file}.lnscs where {&file}.lnscs.lon = {&file}.lon.lon and {&file}.lnscs.sch no-lock:
             find first wrk where wrk.dt = {&file}.lnscs.stdat exclusive-lock no-error.
             if not avail wrk then do:
                create wrk.
                assign wrk.dt = {&file}.lnscs.stdat.
             end.
             wrk.koms = {&file}.lnscs.stval.
             v-itogo[3] = v-itogo[3] + wrk.koms.
          end.
      end.
      find last wrk where wrk.dt <= dt no-lock no-error.
      if avail wrk then evmnpay = wrk.od + wrk.prc + wrk.koms.
      else evmnpay = 0.
      for each wrk exclusive-lock:
        delete wrk.
      end.

      find first {&file}.crc where {&file}.crc.crc = {&file}.lon.crc no-lock no-error.
      debt = 0.
      if dbn = 'txb' then
         run lonbalcrc_txb('lon',{&file}.lon.lon, dt,'1,7',yes,{&file}.lon.crc,output debt).
      else  run lonbalcrc('lon',{&file}.lon.lon, dt,'1,7',yes,{&file}.lon.crc,output debt).
      if debt <> 0 then do:
         if dbn = 'txb' then
            run lonbalcrc_txb('lon',{&file}.lon.lon, dt,'4,5,7,9,16',yes,1,output debtkzt).
         else run lonbalcrc('lon',{&file}.lon.lon, dt,'4,5,7,9,16',yes,1,output debtkzt).
         if {&file}.lon.crc <> 1 then do:
            if dbn = 'txb' then
               run lonbalcrc_txb('lon',{&file}.lon.lon, dt,'4,5,7,9,16',yes,{&file}.lon.crc,output debtcrc).
            else run lonbalcrc('lon',{&file}.lon.lon, dt,'4,5,7,9,16',yes,{&file}.lon.crc,output debtcrc).
         end.

         create wrk1.
           wrk1.contr = {&file}.loncon.lcnt.
           wrk1.debtkzt = debtkzt.
           wrk1.crccodekzt = 'KZT'.
           if debtcrc <> 0 then do:
              wrk1.debtcrc = string(debtcrc,'>>>,>>>,>>9.99').
              wrk1.crccode = {&file}.crc.code.
           end.
           else do:
              wrk1.debtcrc = '              '.
              wrk1.crccode = '   '.
           end.
           wrk1.monpay = evmnpay.
           wrk1.crccode1 = {&file}.crc.code.
      end.
    end.
  end.
end.


if commis = '403' then do:
  if  debtaaa = 0 then
     mes1 = 'Задолженность по счету (счетам) отсутствует'.
     else mes1 = 'У данного клиента имеется задолженность по счету (счетам) в размере ' + String (debtaaa ,'>>>,>>>,>>9.99-') + 'тенге'.
  message mes1 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
end.

if commis = '401' or commis = '436' then do:
  if  debtaaa = 0 then
     mes1 = 'Задолженность по счету (счетам) отсутствует~n~n'.
  else mes1 = 'У данного клиента имеется задолженность по счету (счетам) в размере ' + String (debtaaa ,'>>>,>>>,>>9.99-') + 'тенге~n~n'.
  mes1 =  mes1 + 'Договор                        Сумма задолженности        Ежем.платеж      ~n'.
  mes1 =  mes1 + '---------------------+-----------------+-----------------+-----------------~n'.
  for each wrk1 no-lock:
    mes1 =  mes1 + string(trim(wrk1.contr),'x(21)') + '|' + string(wrk1.debtkzt,'>>>,>>>,>>9.99') + wrk1.crccodekzt + '|'
            + wrk1.debtcrc + wrk1.crccode + '|' + string(wrk1.monpay,'>>>,>>>,>>9.99') + wrk1.crccode1 + '~n'.
  end.
  message mes1 VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
end.

end. /*procedure*/