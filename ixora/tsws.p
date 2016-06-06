/* tsws.p
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

/*
 KOVAL 
 Поиск в Black List of OFAC
 22.11.02
 
*/

{global.i}
{functions-def.i}

function trefex returns char (tmp as char).
  tmp = trim(caps(tmp)).
  tmp=REPLACE(tmp," ","").
  tmp=REPLACE(tmp,",","").
  tmp=REPLACE(tmp,"%","").
  tmp=REPLACE(tmp,"+","").
  tmp=REPLACE(tmp,"-","").
  tmp=REPLACE(tmp,"$","").
  tmp=REPLACE(tmp,"*","").
  tmp=REPLACE(tmp,'"','').
  tmp=REPLACE(tmp,"'","").
  tmp=REPLACE(tmp,"(","").
  tmp=REPLACE(tmp,")","").
  tmp=REPLACE(tmp,"#","").
  tmp=REPLACE(tmp,"@","").
  tmp=REPLACE(tmp,"!","").
  tmp=REPLACE(tmp,"|","").
  tmp=REPLACE(tmp,"/","").
  tmp=REPLACE(tmp,"\\","").
  return tmp.
end.

function tstc returns logical (tmp as char, s as char).
 def var l as logical init false.
 l=false.
 if tmp <> ? or tmp <> "?" or trim(tmp) <> '' then do:
	  if index (trefex(tmp),s)>0 then l=true.
/*  put unformatted "**" tmp " " s " " string(l) skip.*/
 end.
 else l=false.
 return l.
end.

def var v-str as char format "x(65)".
def var v-tst as char.
def var v-err as logical init false.
def var i as integer init 0.

update " Поиск : " v-tst format "x(65)" no-label with centered frame vtst.
clear frame vtst no-pause.

v-tst = trefex(v-tst).

Hide message. pause 0.
message "Идет поиск " + v-tst + " ...".

output to rpt.img.
put unformatted 
FirstLine(1,1) skip 
FirstLine(2,1) skip(1) .

for each swblsdn no-lock.
 v-err=false.
 if tstc(swblsdn.SDN_Name,v-tst)   then v-err=true.
 if tstc(swblsdn.SDN_Type,v-tst)   then v-err=true.
 if tstc(swblsdn._Title,v-tst)     then v-err=true.
 if tstc(swblsdn.Call_sign,v-tst)  then v-err=true.
 if tstc(swblsdn.GRT,v-tst)        then v-err=true.
 if tstc(swblsdn.Vess_flag,v-tst)  then v-err=true.
 if tstc(swblsdn.Vess_owner,v-tst) then v-err=true.

 for each swbladd where swbladd.ent_num=swblsdn.ent_num no-lock.
 	if tstc(swbladd.Address,v-tst)     then v-err=true.
 	if tstc(swbladd.City,v-tst)        then v-err=true.
 	if tstc(swbladd.Country,v-tst)     then v-err=true.
 	if tstc(swbladd.Add_remarks,v-tst) then v-err=true.
 end.

 for each swblalt where swblalt.ent_num=swblsdn.ent_num no-lock.
 	if tstc(swblalt.alt_name,v-tst)    then v-err=true.
 	if tstc(swblalt.alt_remarks,v-tst) then v-err=true.
 end.

 if v-err then do:
 	i = i + 1.
 	put unformatted "(" swblsdn.ent_num "):".
 	if trim(swblsdn.SDN_Name)<>?   then put unformatted "  " swblsdn.SDN_Name skip.
 	if trim(swblsdn.SDN_Type)<>?   then put unformatted "  " swblsdn.SDN_Type skip.
 	if trim(swblsdn._Title)<>?     then put unformatted "  " swblsdn._Title skip.
 	if trim(swblsdn.Call_sign)<>?  then put unformatted "  " swblsdn.Call_sign skip.
 	if trim(swblsdn.GRT)<>?        then put unformatted "  " swblsdn.GRT skip.
 	if trim(swblsdn.Vess_flag)<>?  then put unformatted "  " swblsdn.Vess_flag skip.
 	if trim(swblsdn.Vess_owner)<>? then put unformatted "  " swblsdn.Vess_owner skip.

 	find first swbladd where swbladd.ent_num=swblsdn.ent_num no-lock no-error.
 	if avail swbladd then put unformatted "  *Адреса: " skip.
        for each swbladd where swbladd.ent_num=swblsdn.ent_num no-lock.
 		if trim(swbladd.Address)<>?     then put unformatted "    " swbladd.Address skip.
	 	if trim(swbladd.City)<>?        then put unformatted "    " swbladd.City    skip.
	 	if trim(swbladd.Country)<>?     then put unformatted "    " swbladd.Country  skip.
	 	if trim(swbladd.Add_remarks)<>? then put unformatted "    " swbladd.Add_remarks skip.
	end.

 	find first swbladd where swblalt.ent_num=swblsdn.ent_num no-lock no-error.
 	if avail swbladd then put unformatted "  *Альтернативная информация: " skip.
	for each swblalt where swblalt.ent_num=swblsdn.ent_num no-lock.
 		if trim(swblalt.alt_name)<>?    then put unformatted "    " swblalt.alt_name skip.
	 	if trim(swblalt.alt_remarks)<>? then put unformatted "    " swblalt.alt_remarks skip.
	end.
 	put unformatted skip.
 end.

end.

put unformatted fill("-",79) skip
"Всего найдено записей :" i skip(1).

output close. pause 0.
Hide message. pause 0.

if i>0 then run menu-prt('rpt.img').
       else message "Ничего не найдено..." view-as alert-box.
