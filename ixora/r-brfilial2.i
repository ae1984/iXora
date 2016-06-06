/* r-brfilial2.i
 * MODULE
        Программы общего назначения
 * DESCRIPTION
        Запуск отчетов по текущему филиалу или в ЦО - выбор консолидированный/филиалы
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        01.04.2004 nadejda
 * CHANGES
       23/01/2006 nataly убрала расчет по кодам доходов,расходов, если считаем приложение 2(ЗП)
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


find sysc where sysc.sysc = "ourbnk" no-lock no-error.
find txb where txb.consolid and txb.bank = sysc.chval no-lock no-error.

if not txb.is_branch then do:
  {sel-filial.i}  
end.
else do:
  v-select = txb.txb + 2.
end.

if v-pril <> '02' then do:
for each txb where txb.consolid and 
         (if v-select = 1 then true else txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
    run {&proc}.
end.
    
if connected ("txb")  then disconnect "txb".
end.

def var v-bankname as char.

if v-select = 1 then do:
  find first cmp no-lock no-error.
  v-bankname = cmp.name + "<br>Консолидированный отчет".
end.
else do:
  find txb where txb.consolid and txb.txb = v-select - 2 no-lock no-error.
  v-bankname = txb.name.
end.

