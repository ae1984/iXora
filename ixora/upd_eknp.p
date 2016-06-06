/* upd_eknp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
	Общийй отчет по проведенным кассовым операциям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK 
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/05/09 marinav
 * CHANGES
*/


def var v-knp as char.
def var v-jl as integer.
update v-jl.

find first jh where jh.jh = v-jl no-lock no-error.
if avail jh then do:
   if jh.sub = 'ujo' or jh.sub = 'jou' then do:
   
for each jl where jl.jh = v-jl no-lock.
    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln  = jl.ln and trxcods.codfr = "spnpl"  no-lock no-error.
     if not avail trxcods then do:
          create trxcods.
          assign trxcods.trxh = jl.jh trxcods.trxln = jl.ln trxcods.codfr = "spnpl" .
     end.
end.
   


find first jl where jl.jh = v-jl and jl.ln = 1 no-lock no-error.
  
    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln  = jl.ln and trxcods.codfr = "locat" no-lock no-error.
    if not avail trxcods then do:
        create trxcods.
        assign trxcods.trxh = jl.jh trxcods.trxln  = jl.ln trxcods.codfr = "locat" .
    end.
    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln  = jl.ln and trxcods.codfr = "secek" no-lock no-error.
    if not avail trxcods then do:
        create trxcods.
        assign trxcods.trxh = jl.jh trxcods.trxln = jl.ln trxcods.codfr = "secek" .
    end.
                                
find first jl where jl.jh = v-jl and jl.ln ne 1 and (jl.sub = 'dfb' or jl.sub = 'arp' or jl.sub = 'cif') no-lock no-error.        
if avail jl then do:                                                                                                             
    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln  = jl.ln and trxcods.codfr = "locat" no-lock no-error.
    if not avail trxcods then do:
         create trxcods.
         assign trxcods.trxh = jl.jh trxcods.trxln  = jl.ln trxcods.codfr = "locat" .
    end.
    find first trxcods where trxcods.trxh = jl.jh and trxcods.trxln  = jl.ln and trxcods.codfr = "secek" no-lock no-error.
    if not avail trxcods then do:
         create trxcods.
         assign trxcods.trxh = jl.jh trxcods.trxln = jl.ln trxcods.codfr = "secek" .
    end.
end.                          
 
v-knp = ''.  
  for each trxcods where trxcods.trxh =  jl.jh exclusive-lock.
      if trxcods.codfr = 'spnpl' and trxcods.code = '' then trxcods.code = v-knp.
      displ trxcods .
      update trxcods.code.
      if trxcods.codfr = 'spnpl' then v-knp = trxcods.code.                
   end.
                  
end.
else message 'Не ваш документ'.
end.              
else message "нет такого документа ".

