/* dreason.p
 * MODULE
        Удаление транзакции
 * DESCRIPTION
        Назначение: Выбор причины удаления транзакции и отправка на акцепт контролеру.
 * RUN
        trxdel.p
 * CALLER
        trxdel.p
 * SCRIPT
        trxdel.p
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        01.03.2005 saltanat
 * CHANGES
                  22/09/2011  Luiza  -  слово "Прагма"  заменила на "Иксора"
                  23/09/2011  Luiza  -  слово "АБИС"  заменила на "АБС"
*/
{global.i}
{comm-txb.i}

define input parameter s-jh like jl.jh .
def output parameter rcode as inte init -1.
def output parameter rdes as char init ''.

define variable v-reason as char.
define variable v-rec as char.
define variable v-fault as char.
define variable v-tem as char.
define variable v-mess as char.
define variable v-send as char.
define variable i as inte.
define variable v-titcd as char.
define variable v-bank as char.
define variable v-bnk as inte.

define temp-table tmp
  field id   as integer
  field pnk  as character
  field res  as character
  field des  as character
  field note as character
index idx id.

find first cmp.
v-bank = entry(1,cmp.addr[1]).

run create_table(1,'1','Клиента','','').
run create_table(2,'1','1.1','Отказ по инициативе клиента','Контролера').
run create_table(3,'1','1.2','Отказ после проверки Отдела контроля','Контролера').
run create_table(4,'1','1.3','Отказ  по инициативе Банка','Контролера').
run create_table(5,'1','1.4','Неожидаемый отказ клиента','Контролера').
run create_table(6,'2','Менеджера','','').
run create_table(7,'2','2.1','Ошибка менеджера','Контролера').
run create_table(8,'3','Прочие','','').
run create_table(9,'3','3.1','Технические причины','Контролера').
run create_table(10,'3','3.2','Сбой АБС Иксора','ДИТ-а').
run create_table(11,'3','3.3','Прочее','Контролера').

define frame fr
       v-reason format 'x(40)' no-label help 'F2-справочник'
                validate(can-find (tmp where tmp.des = v-reason and tmp.des ne '' no-lock),'Выберите пункт из справочника!')
with overlay centered row 8 title 'Выберите причину'.

on help of v-reason in frame fr do:
  find first tmp no-error.
  if not avail tmp then do:
    rcode = 54.
    rdes  = " Справочник пуст!: " +  string(s-jh,"zzzzzzz9").
    return.
  end.
  {itemlist.i
       &file = "tmp"
       &frame = "row 2 centered scroll 1 11 down overlay title 'Причины удаления транзакций менеджерами департаментов' "
       &where = " true "
       &flddisp = " tmp.pnk label 'N' format 'x(1)'
                    tmp.res label 'По вине' format 'x(10)'
                    tmp.des label 'Описание' format 'x(40)'
                    tmp.note label 'Акцепт' format 'x(10)'
                  "
       &chkey = "des"
       &chtype = "string"
       &index  = "idx"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
  }

  v-reason = tmp.des.

  if tmp.res begins '1' then v-fault  = 'Клиента'.
  else do:
       if tmp.res begins '2' then v-fault = 'Менеджера'.
       else v-fault = 'Прочее'.
  end.

  displ v-reason with frame fr.
end.

DO TRANSACTION ON ENDKEY undo,leave:

update v-reason with frame fr.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if not avail ofc then do:
   rcode = 54.
   rdes  = " Офицер не найден! : " +  string(s-jh,"zzzzzzz9").
   return.
end.

if trim(v-reason) = 'Сбой АБС iXora ' then v-titcd = '508'.
else v-titcd = ofc.titcd.

find first trxdel_aks_control where trxdel_aks_control.jh = s-jh no-error.
if not avail trxdel_aks_control then do:

   create trxdel_aks_control.
          trxdel_aks_control.jh     = s-jh.

end.
   assign trxdel_aks_control.sts    = 'd'
          trxdel_aks_control.bank   = string(ofc.dpt)
          trxdel_aks_control.dep    = v-titcd
          trxdel_aks_control.dop    = ofc.titcd
          trxdel_aks_control.reason = v-reason
          trxdel_aks_control.fault  = v-fault
          trxdel_aks_control.who    = g-ofc
          trxdel_aks_control.whn    = g-today
          trxdel_aks_control.tim    = time
          trxdel_aks_control.dwho   = g-ofc
          trxdel_aks_control.dwhn   = g-today
          trxdel_aks_control.dtim   = time.

     find trxdel_control_ofc where trxdel_control_ofc.dep = v-titcd no-lock no-error.
     if not avail trxdel_control_ofc then do:
        rcode = 54.
        rdes  = " По данному департаменту не заведен контролирующий! : " +  string(s-jh,"zzzzzzz9").
        return.
     end.

     do i = 1 to num-entries(trxdel_control_ofc.control_ofc):
        v-rec  = entry(i,trxdel_control_ofc.control_ofc) + '@metrocombank.kz'.
        v-send = g-ofc + '@metrocombank.kz'.
        v-tem  = 'Акцептование удаленной проводки'.
        v-mess = 'Нужно акцептовать удаление следующей проводки: ' + string(s-jh) + '. Удалил: ' + ofc.name + ', ' + string(g-today, '99/99/9999') + '. Филиал: ' + v-bank + '.'.
        run mail(v-rec, v-send, v-tem, v-mess, "", "", "").
     end.

     rcode = 0.
end.
hide frame fr.



procedure create_table.
define input parameter p-id as inte.
define input parameter p-pnk as char.
define input parameter p-res as char.
define input parameter p-des as char.
define input parameter p-note as char.

  create tmp.
  assign tmp.id = p-id
         tmp.pnk  = p-pnk
         tmp.res  = p-res
         tmp.des  = p-des
         tmp.note = p-note.
end procedure.



