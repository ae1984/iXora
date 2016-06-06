/* vip_str.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Выписка (Capital) по счетам клиентов
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-4-10
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
        11.09.2003 nadejda - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
        01.09.2004 dpuchkov - ограничение на просмотр выписки
        01.09.2004 dpuchkov -  запись удачных попыток в лог
        18.08.2006 dpuchkov - оптимизация
        20.09.2010 k.gitalov - изменил вывод данных
*/


{mainhead.i}

def var o_err  as log init false                     no-undo. /* Customer's Account  */
def var v-print as log init true                     no-undo.
def var s-hacc like aaa.aaa initial ?                no-undo.
def new shared var s-cif like cif.cif. 
def var in_cif like cif.cif                          no-undo. 
def var in_acc like aaa.aaa                          no-undo.
def var p_vip   as char init "1" format "x"          no-undo. /* "Выписка".  put vipiska   */
def var p_mem   as char init "" format "x"           no-undo. /* " Мемориальный ордер" Put mem.ord.  */
def var p_memf   as char init "" format "x"          no-undo. /* " Мемориальный ордер" Put mem.ord.  */
def var p_pld   as char init "" format "x"           no-undo. /* Дебетовое платежное поручениеPut plat.por. deb.   */
def var p_plc   as char init "" format "x"           no-undo. /* Кредитовое платежное поручение.  Put plat.por. kred.  */
def var in_jh as char init ""                        no-undo.
def var in_ln as char init ""                        no-undo.
def var v-ok as log                                  no-undo.
def var in_command as char init "prit"               no-undo.
def var in_destination as char init "vipiska.img"    no-undo.
def var partkom as char                              no-undo.
def var log_path        as character format "x(150)" no-undo.
def var ost like aaa.cbal                            no-undo.  
def new shared var flg1 as log.
def var hostmy   as char format "x(15)"              no-undo.
def var dirc     as char format "x(15)"              no-undo.
def var v-result   as char format "x(15)"            no-undo.
def var v-cifname as char format "x(40)"             no-undo.

def var v-dat as date.

{st_chkcif.i}

form  s-cif  label    "  Код" help " Код клиента (F2 - поиск по счету, наименованию и т.д)" validate (chkcif (s-cif), v-msgerr) skip
      v-cifname label "  Имя" skip
      s-hacc   label  " Счет" help " Номер текущего счета клиента (F2 - список счетов)" validate (can-find(aaa where (aaa.aaa = s-hacc and aaa.cif = s-cif) no-lock) or s-hacc = "ALL" or s-hacc = "", " Нет такого счета !!!")  
with side-label row 3 centered frame cif.

/*  do transaction:                                                          */
     update s-cif with frame cif.
     find cif where cif.cif = s-cif no-lock no-error.
     display trim(trim(cif.prefix) + " " + trim(cif.name)) @ v-cifname with frame cif. 
     pause 0.
     in_cif = s-cif.
     s-hacc = "ALL".              
     update s-hacc with frame cif.
     in_acc = s-hacc.
/*  end.                                  */


  find last cifsec where cifsec.cif = s-cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = s-cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = s-cif
          ciflog.sectime = time
          ciflog.menu = "2.4.10 Выписка (Capital)".
          return.
     end.
     else
       do:
          create ciflogu.
          assign
            ciflogu.ofc = g-ofc
            ciflogu.jdt = today
            ciflogu.sectime = time
            ciflogu.cif = s-cif
            ciflogu.menu = "2.4.10 Выписка (Capital)" .
       end.
  end.




def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999". 
form "Отчетный период с " dat1 " по " dat2 with no-label centered.   

do on error undo,retry on endkey undo,return.
    dat1 = g-today - 1 .
    dat2= g-today - 1 . 
    update dat1 validate(dat1 < g-today, "Начало периода не может быть позже чем закрытый день").
    update dat2 validate(dat2 <g-today and dat2 >= dat1, "Конец периода не может быть позже чем закрытый день/начало периода").
    find sysc where sysc.sysc eq "BEGDAY" no-lock no-error. 
    if available sysc and dat1 < sysc.daval then do: 
       message "Начало периода не может быть позже чем "  sysc.daval. 
       undo,retry. 
    end.

/*
    update " Команда печати :"  in_command with frame c1 no-label centered. 
    repeat:
       update "                          Выписка :" p_vip skip
              "               Мемориальный ордер :" p_mem skip
              " Мемориальный ордер + счет-фактура:" p_memf skip
              "    Дебетовое платежное поручение :" p_pld skip
              "   Кредитовое платежное поручение :" p_plc 
              with frame c2 centered no-label title " 1 - печатать /пробел или 0 - не печатать".
       if  not (p_vip = "1" or p_mem="1" or p_memf="1" or p_pld="1" or p_plc="1")
       then undo,retry.  
       leave.
    end.
    */
end.

unix silent rm -f value("vipiska.img").  


v-ok= false.
for each aaa where aaa.cif EQ s-cif  NO-LOCK:
    if not (aaa.aaa EQ s-hacc OR s-hacc EQ "" OR s-hacc EQ "ALL") then next. 
    find lgr where lgr.lgr = aaa.lgr no-lock.
    if lgr.led = "oda" then next.
    in_acc = aaa.aaa.
 
    do v-dat = dat1 to dat2:
       find first jl where jl.acc=in_acc and jl.jdt = v-dat use-index acc no-lock no-error.
       if avail jl then leave.
    end.

    if not avail jl then do:
       find last aab where aab.aaa = in_acc and aab.fdt le dat1 no-lock no-error.
       if avail aab then ost = aab.bal.
       else ost = aaa.cbal.                
       find last aab where aab.aaa = aaa.craccnt and aab.fdt le dat1 no-lock no-error.
       if avail aab then ost = ost + aab.bal.
       else ost = ost + aaa.cbal.
       message "СЧЕТ " in_acc " ОБОРОТОВ НЕТ. ОСТАТОК  " ost. pause 10.  next.
    end.

    display " формирование отчета по счету " in_acc with frame c3 no-label . pause 0.
    run vip(in_acc,dat1,dat2,p_vip,p_mem,p_memf,p_pld,p_plc,output o_err).
    v-ok = true.
end.
  
if o_err then do:
   find sysc where sysc.sysc = "VIPLOG" no-lock no-error.
   if available sysc then  
      log_path = trim(sysc.chval) + "/vip.log".
   else 
      log_path = "vip.log".
   hide frame c2 no-pause.
   hide frame c1 no-pause.
   hide frame c3 no-pause. 
   message " Смотрите протокол ошибок. " log_path. 
   message " Есть записи в протоколе ошибок.  ПЕЧАТАТЬ ВЫПИСКУ ? " view-as alert-box question buttons yes-no title "" update v-print.
end.

if not v-ok then return. 

hide all.
run menu-prt( in_destination ).

/*
if not v-print then return. 

if opsys <> "UNIX" then return "0".

if in_command <> ? then do:
   partkom = in_command + " " + in_destination.
end.
else do:
   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if available ofc and ofc.expr[3] <> "" 
   then do:
      partkom = ofc.expr[3] + " " + in_destination.
   end.
   else return "0".
end.


if in_command matches "*file*" then do:
   dirc = "c:/vipiski.txt".
   input through askhost.
   repeat:
     import hostmy.
   end.
   input close.

   unix silent un-dos vipiska.img vipiska.txt.
   input through value("rcp vipiska.txt " + hostmy + ":" + dirc + ";echo $?" ).
   repeat:
     import v-result.
   end.
   input close.
   if v-result <> "0" then message skip " Произошла ошибка при копировании файла vipiska.txt~nв" dirc skip(1) view-as alert-box button ok title " ОШИБКА ! ".
end. 
else do:
  unix silent value(partkom).
end.
pause 0.
*/
