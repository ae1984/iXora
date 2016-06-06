/* adeltrx.p
 * MODULE
        Контроль документов
 * DESCRIPTION
        Контроль удаленных транзакции 
 * RUN
        П.м. 2-7-4
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        2-7-4
 * AUTHOR
        04.03.05 saltanat
 * CHANGES
        13.05.05 saltanat - Включила обработку кнопок при отсутствии записей.
        16/04/2008 madiyar - Расширил фрейм, увеличил поле с логином юзера на одно знакоместо
*/

{mainhead.i}
{yes-no.i}

define variable v-depart as char.
define variable v-fault as char.
define variable v-deplist as char.
define variable v-rec  as char init ''.
define variable v-send as char init ''.
define variable v-tem  as char init ''.
define variable v-mess as char init ''.
define variable v-aksk as char.

define buffer b-ofc for ofc.

define query q1 for trxdel_aks_control.

def browse b1 query q1 no-lock 
  display 
      trxdel_aks_control.jh label 'Транзакция'
      trxdel_aks_control.reason label 'Причина' format 'x(40)'
      trxdel_aks_control.fault label 'По вине' format 'x(12)'
      trxdel_aks_control.dwho label 'Удалил' format 'x(7)'
      trxdel_aks_control.dwhn label 'Дата уд.'  
  with 25 down separators single title " КОНТРОЛЬ УДАЛЕННЫХ ТРАНЗАКЦИЙ ". 

define frame f1
   b1 help "F1 - Акцепт, F8 - Запрет удаления, F4 - Выход"
with row 3 centered width 89.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if not avail ofc then do:
   message 'Офицер не найден!' view-as alert-box buttons ok.
   leave.
end.
 
on "go" of browse b1
do:
find current trxdel_aks_control exclusive-lock no-error. 
if not avail trxdel_aks_control then do:
   message 'Нет записей. Операция невозможна.' view-as alert-box buttons ok.
   return.
end.

if yes-no ("ВНИМАНИЕ", "Акцептовать удаление?")
then do:
  if trxdel_aks_control.sts ne 'd' then do: 
     if trxdel_aks_control.sts = 'a' then do:
        find b-ofc where b-ofc.ofc = trxdel_aks_control.awho no-lock no-error.
        if avail b-ofc then v-aksk = b-ofc.name.
        message 'Запись проконтролирована! Удаление акцептовано. Контролер: ' + v-aksk + ' от ' + string(trxdel_aks_control.awhn,'99/99/99') + '!' view-as alert-box buttons ok.
        open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0
                                                    and trxdel_aks_control.dwho ne g-ofc.
     end.   
     if trxdel_aks_control.sts = 'r' then do:
        find b-ofc where b-ofc.ofc = trxdel_aks_control.who no-lock no-error.
        if avail b-ofc then v-aksk = b-ofc.name.
        message 'Запись проконтролирована! Удаление запрещено. Контролер: ' + v-aksk + ' от ' + string(trxdel_aks_control.whn,'99/99/99') + '!' view-as alert-box buttons ok.
        open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
     end.  
     release trxdel_aks_control.
     return.
  end.
  assign 
     trxdel_aks_control.sts = 'a'
     trxdel_aks_control.awho = g-ofc
     trxdel_aks_control.awhn = g-today
     trxdel_aks_control.atim = time.
  v-rec  = trxdel_aks_control.dwho + '@metrobank.kz'.
  v-send = g-ofc + '@metrobank.kz'.
  v-tem  = 'Удаление проводки: ' + string(trxdel_aks_control.jh) + ' акцептовано'. 
  v-mess = 'Удаление проводки: ' + string(trxdel_aks_control.jh) + ' акцептовано. Акцептовал: ' + ofc.name + ', ' + string(g-today, '99/99/9999') + '.' .
  run mail(v-rec, v-send, v-tem, v-mess, "", "", "").   
  release trxdel_aks_control.
  open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
end.

end.

on "clear" of browse b1 
do:
   find current trxdel_aks_control exclusive-lock no-error.
   if not avail trxdel_aks_control then do:
      message 'Нет записей. Операция невозможна.' view-as alert-box buttons ok.
      return.
   end.

   if yes-no ("ВНИМАНИЕ", "Запретить удаление транзакции?")
   then do:
          if trxdel_aks_control.sts ne 'd' then do: 
             if trxdel_aks_control.sts = 'a' then do:
            find b-ofc where b-ofc.ofc = trxdel_aks_control.awho no-lock no-error.
                if avail b-ofc then v-aksk = b-ofc.name.
                message 'Запись проконтролирована! Удаление акцептовано. Контролер: ' + v-aksk + ' от ' + string(trxdel_aks_control.awhn,'99/99/99') + '!' view-as alert-box buttons ok.
                open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
         end.   
         if trxdel_aks_control.sts = 'r' then do:
                find b-ofc where b-ofc.ofc = trxdel_aks_control.who no-lock no-error.
                if avail b-ofc then v-aksk = b-ofc.name.
                message 'Запись проконтролирована! Удаление запрещено. Контролер: ' + v-aksk + ' от ' + string(trxdel_aks_control.whn,'99/99/99') + '!' view-as alert-box buttons ok.
                open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
         end. 
         release trxdel_aks_control.
         return.  
          end.
      assign 
          trxdel_aks_control.sts = 'r'        
          trxdel_aks_control.who = g-ofc   
          trxdel_aks_control.whn = g-today
          trxdel_aks_control.tim = time.
      v-rec  = trxdel_aks_control.dwho + '@metrobank.kz'.
      v-send = g-ofc + '@metrobank.kz'.
      v-tem  = 'Удаление проводки: ' + string(trxdel_aks_control.jh) + ' запрещено'. 
      v-mess = 'Удаление проводки: ' + string(trxdel_aks_control.jh) + ' запрещено. Запретил: ' + ofc.name + ', ' + string(g-today, '99/99/9999') + '.' .
      run mail(v-rec, v-send, v-tem, v-mess, "", "", "").   
      release trxdel_aks_control.
      open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
   end.
end.

on 'end-error' of browse b1 hide frame f1.

for each trxdel_control_ofc where lookup(g-ofc,trxdel_control_ofc.control_ofc) > 0 no-lock:
    v-deplist = v-deplist + if v-deplist = '' then trxdel_control_ofc.dep else ',' + trxdel_control_ofc.dep.
end.

open query q1 for each trxdel_aks_control where trxdel_aks_control.sts = 'd' and lookup(trxdel_aks_control.dep,v-deplist) > 0 and trxdel_aks_control.dwho ne g-ofc.
enable all with frame f1.
wait-for window-close of frame f1 focus browse b1.


