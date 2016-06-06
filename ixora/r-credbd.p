/* r-credbd.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Отчет ДКА по кредитам, выд-ым по программе БД
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-4-9-2
 * AUTHOR
        05/02/2007 Natalya D.
 * BASES
        bank
 * CHANGES
        20/04/2007 madiyar - добавил из новой библиотеки
*/

{global.i}
def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var d as date no-undo.
def var v-dep as int no-undo.
def temp-table dosye no-undo
    field lon as char
    field cif as char
    field name as char
    field opndt as date
    field ofc-n as char
    field ofc-l as char
    field spf as char
    field sing as char format "x(1)".


update dt1 label ' Укажите дату с ' format '99/99/9999' dt2 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

do d = dt1 to dt2 :
 for each lonres where lonres.jdt = d and lonres.dc = 'd' no-lock.
     if lookup(lonres.trx,'lon0001,lon0002,lon0003,lon0004,lon0005,lon0006,lon0052') = 0 then next.
     
     find lon where lon.lon = lonres.lon and (lon.grp = 90 or lon.grp = 92) no-lock no-error.
     if not avail lon then next.
     find cif where cif.cif = lon.cif no-lock no-error.
     if not avail cif then next.
     find last ofc where ofc.ofc = lonres.who no-lock no-error. 
     v-dep = ofc.regno mod 1000.
     find first ppoint where ppoint.depart = v-dep no-lock no-error.
     if not avail ofc and not avail ppoint then next.
     find last sub-cod where sub-cod.sub = 'LON' and sub-cod.d-cod = 'docbd' and sub-cod.acc = lon.lon 
                         and sub-cod.ccode = '01' no-lock no-error.
     if avail sub-cod then next.
     create dosye.            
            dosye.lon = lon.lon.
            dosye.cif = lon.cif.
            dosye.name = cif.name.
            dosye.opndt = lonres.jdt.
            dosye.ofc-n = ofc.name.
            dosye.ofc-l = ofc.ofc.
            dosye.spf = ppoint.name.            
 end.
end.  

def var cust-list as character view-as selection-list single size 70 by 9 label "  Кредиты по программе 'Быстрые деньги', " /*+ "выданные за период с " + string(dt1) + " по " + string(dt2)*/ .
define variable ok-status as logical.
def var data as char extent 9999.
def var ar as int init 0.
def var bstring as char init "".

display "    nn    ФИО Заемщика     Дата выд  Менеджер    СПФ         Отметка" with frame sel-frame.

form
  cust-list
  with frame sel-frame.

on default-action of cust-list
   do:
      if substring(cust-list:screen-value,length(cust-list:screen-value, "CHARACTER"),1) <> "x" then
        message "Принять досье?"
              view-as alert-box question buttons yes-no-cancel
                      title "" update choice as logical.
      else return.
      case choice:
         when true then
          DO:
            ar = integer(substring(cust-list:screen-value,1,index(cust-list:screen-value , ". "))).
            find dosye where dosye.cif = entry(1,data[ar]) and dosye.lon = entry(2,data[ar]) no-lock no-error.
            find current dosye exclusive-lock no-error.
            dosye.sing = "+".            
            find current dosye no-lock no-error.

            run AddToSubCod (dosye.lon, yes).
            message "досье принято." view-as alert-box information buttons ok.
            if (trim(substring(cust-list:screen-value,length(cust-list:screen-value) - 1,length(cust-list:screen-value))) = '-')
              or (trim(substring(cust-list:screen-value,length(cust-list:screen-value) - 1,length(cust-list:screen-value))) = '+')
            then cust-list:replace(substring(cust-list:screen-value,1,length(cust-list:screen-value) - 1) + '+', cust-list:lookup(cust-list:screen-value)).
            else cust-list:replace(cust-list:screen-value + " +", cust-list:lookup(cust-list:screen-value)).
            
          end.
         when false then
          do:
             ar = integer(substring(cust-list:screen-value,1,index(cust-list:screen-value , ". "))).
            find dosye where dosye.cif = entry(1,data[ar]) and dosye.lon = entry(2,data[ar]) no-lock no-error.
            find current dosye exclusive-lock no-error.
            dosye.sing = "-".            
            find current dosye no-lock no-error.

            run AddToSubCod (dosye.lon, no).
            message "Досье не принято." view-as alert-box information buttons ok.

            if trim(substring(cust-list:screen-value,length(cust-list:screen-value) - 1,length(cust-list:screen-value))) = '+' 
             or (trim(substring(cust-list:screen-value,length(cust-list:screen-value) - 1,length(cust-list:screen-value))) = '-')
            then cust-list:replace(substring(cust-list:screen-value,1,length(cust-list:screen-value) - 1) + '-', cust-list:lookup(cust-list:screen-value)).
            else cust-list:replace(cust-list:screen-value + " -", cust-list:lookup(cust-list:screen-value)).
          end.
         end.
   end.

for each dosye no-lock break by dosye.spf by dosye.ofc-l:
  ar = ar + 1.
  ok-status = cust-list:add-last(string(ar,"9999") + ". " + string(dosye.name,'x(16)') + "  " + string(dosye.opndt) 
            + "  " + dosye.ofc-l + "  " + string(dosye.spf,'x(15)') + " " + string(dosye.sing,'x(1)')).
  data[ar] = dosye.cif + "," + dosye.lon.
end.

enable cust-list with frame sel-frame.

wait-for window-close of current-window.  


procedure AddToSubCod.

define input parameter p-lon like lon.lon.
define input parameter p-yn as log.

def var p-cod as char.

if p-yn then p-cod = '01'.
else p-cod = '02'.

 find last codific where codific.codfr = 'docbd' no-lock no-error.
 if avail codific then do:
   find last codfr where codfr.codfr = codific.codfr and code = p-cod no-lock no-error.
   if avail codfr then do:

     find last sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = p-lon and sub-cod.d-cod = codfr.codfr exclusive-lock no-error.
     if avail sub-cod then 
        assign sub-cod.ccode = p-cod
               sub-cod.rdt = today.
     else do:
        create sub-cod.
        assign sub-cod.sub = 'lon'
               sub-cod.acc = p-lon
               sub-cod.d-cod = 'docbd'
               sub-cod.ccode = p-cod
               sub-cod.rdt = today. 
     end. 
     release sub-cod.
     create hissc.
     assign hissc.acc = p-lon
            hissc.sub = 'lon'
            hissc.d-cod = 'docbd'
            hissc.rdt = g-today
            hissc.ccode = p-cod
            hissc.rcode = ''
            hissc.who = g-ofc
            hissc.tim = time.  
   end.
 end. 
end procedure.
