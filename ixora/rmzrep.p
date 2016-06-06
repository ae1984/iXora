/* rmzrep.p
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
        02/11/2006 - suchkov
 * CHANGES
        15/11/2006 - suchkov - мелкие доработки
*/

{get-dep.i}
define variable tamacc as character initial "000076261,000076960,250076725,260076326,270076967,290076048,002076751,030076668,310076201,003076417,003076048".
define variable vnames as character initial "Клиентские обычные платежи,Клиентские интернет платежи,Клиентские сканированные платежи,Пенсионные 076 физ.лиц,
Пенсионные платежи юр.лиц,Социальные платежи физ.лиц,Социальные платежи юр.лиц,Налоговые платежи,Таможенные платежи,Платежи АЛСЕКО,Платежи ИВЦ,Прочие платежи" .
define variable vdate1 as date label "Начало периода".
define variable vdate2 as date label "Конец периода".
define variable ib   as logical .
define variable vknp as character.
define variable vfil as character.
define variable i as int initial 0. 
define variable vdep as integer  .
define variable vtype as integer .
define temp-table t-rmz 
	field type as integer 
	field cover as integer 
	field fil  as character 
	field dep  as integer initial 1
	field nu   as integer initial 0
	field amt  as decimal initial 0.

vdate2 = today - 1 .
update "C " vdate1 " по " vdate2 with centered .

for each remtrz where valdt2 >= vdate1 and valdt2 <= vdate2 no-lock .
if remtrz.source = "LBI" or remtrz.fcrc <> 1 or remtrz.jh2 = ? or remtrz.cover = 5 or not remtrz.sbank begins "TXB" then next .
if remtrz.sbank begins "TXB" and remtrz.rbank begins "TXB" then next .

assign vtype = 1 vdep = 1 vfil = remtrz.sbank .
if can-find(last ofchis where ofchis.ofc = remtrz.rwho no-lock) then vdep = get-dep(remtrz.rwho, remtrz.rdt).
if remtrz.source = "IBH" then do:
      find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
	if not available aaa then do:
		message "Внимание! Не найден счет " remtrz.dracc view-as alert-box.
		next .
	end.
      find cif of aaa no-lock no-error.
      assign vdep = integer(cif.jame) mod 1000 vtype = 2 .
end.
if remtrz.source = "SCN" then vtype = 3 .
find sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and d-cod = "eknp" no-lock no-error .
if not available sub-cod then do:
	message "Обнаружен RMZ без справочника - " remtrz.remtrz view-as alert-box.
	next .
end.
vknp = substring (sub-cod.rcode,7,3).
if vknp = "010" or vknp = "019" or vknp = "013" then
if substring (remtrz.sacc,4,3) = "076" then vtype = 4 .
				       else vtype = 5 .
if vknp = "012" or vknp = "017" then
if substring (remtrz.sacc,4,3) = "076" then vtype = 6 .
				       else vtype = 7 .
find last tax where tax.senddoc = remtrz.remtrz no-lock no-error .
if avail tax and tax.txb = 0 then vtype = 8 .
if index(tamacc,remtrz.sacc) > 0 then vtype = 9.
if remtrz.sacc = "000904786" then vtype = 10.
if remtrz.sacc = "000904883" then vtype = 11.
if remtrz.sacc = "001076668" or remtrz.sacc = "003904589" then vtype = 12.
if vfil <> "TXB00" then do:
        find first txb where txb.bank = vfil and txb.consolid no-lock .
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
	run checkrmzfil(substring(remtrz.sqn,7,10), output ib) .
        if connected ("txb") then disconnect "txb".
	if ib then vtype = 2 .
end.

find first t-rmz where t-rmz.type = vtype and t-rmz.dep = vdep and t-rmz.cover = remtrz.cover and t-rmz.fil = vfil no-error .
if not available t-rmz then create t-rmz .
assign
t-rmz.nu = t-rmz.nu + 1 
t-rmz.cover = remtrz.cover 
t-rmz.fil = vfil
t-rmz.type = vtype
t-rmz.amt = t-rmz.amt + remtrz.amt 
t-rmz.dep = vdep .

end.



output to rep.txt .
put unformatted "С " vdate1 " по " vdate2 skip .

for each t-rmz where t-rmz.nu > 0 break by t-rmz.fil by t-rmz.dep by t-rmz.cover by t-rmz.type .
  find ppoint where ppoint.depart = t-rmz.dep no-lock no-error.
  if not available ppoint then message t-rmz.dep view-as alert-box.
  if first-of (t-rmz.fil) then do:
	find bankl where bankl.bank = t-rmz.fil no-lock .
	put unformatted skip bankl.name skip .
  end.
  put "       " entry(t-rmz.type,vnames) format "x(32)" 
      t-rmz.nu format ">>>>>>" 
      t-rmz.amt format ">>>,>>>,>>>,>>>,>>>.99" 
      if t-rmz.cover = 2 then "  Гросс" else "  Клиринг" format "x(9)".
  put skip .
      i = i + t-rmz.nu .
end.

put skip "ИТОГО:                                 " i format ">>>>>>" .
                                    
output close .

run menu-prt("rep.txt").
