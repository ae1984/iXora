/* vip_dok.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        печать документов по выписке
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-4-11
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование 
        11.09.2003 nadejda  - проверка на VIP-категорию клиента и отказ в выписке, если по этой категории выписки смотреть нельзя
        15.09.2003 nataly   - изменен фрейм при выводе сумм (не отображалась последняя запись)
        02.12.2003 nadejda  - убрано условие поиска проводки по счету ГК субсчета - из-за перехода на новые счета ГК
        01.04.2004 dpuchkov - добавил ограничение на просмотр выписок пользователей
        08.04.2004 dpuchkov - запись удачных попыток
        25.08.2006 dpuchkov - оптимизация 
*/


{mainhead.i}

define var o_err  as log init false. /* Customer's Account  */
define variable s-hacc like aaa.aaa initial ?.
def new shared var s-cif like cif.cif. 

def var in_cif like cif.cif                   no-undo.
def var in_acc like aaa.aaa                   no-undo.
def var in_jh   as char init ""               no-undo.
def var in_ln   as char init ""               no-undo.
def var crccode like crc.code                 no-undo.
def var p_mem   as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
def var p_memf  as char init "" format "x"    no-undo.  /* " Мемориальный ордер" Put mem.ord.                */
def var p_pld   as char init "" format "x"    no-undo.  /*   Дебетовое платежное поручениеPut plat.por. deb. */
def var p_uvd   as char init "" format "x"    no-undo.  /*   Кредитовое уведомление Put plat.por. deb.       */
def var v-ok    as log                        no-undo.
def var in_command as char init "prit"        no-undo.
def var in_destination as char init "dok.img" no-undo.
def var partkom as char                       no-undo. 
def var vans    as log init true              no-undo.
def var m-rtn   as log                        no-undo.
def new shared var flg1 as log.
def var s-rem   as char                       no-undo.
def var v-cifname as char format "x(40)"      no-undo.


{st_chkcif.i}

form s-cif  label    "  Код" help " Код клиента (F2 - поиск по счету, наименованию и т.д)" validate (chkcif (s-cif), v-msgerr) skip
     v-cifname label "  Имя" skip
     s-hacc   label  " Счет" help " Номер текущего счета клиента (F2 - список счетов)" validate (can-find (aaa where aaa.aaa = s-hacc and aaa.cif = s-cif no-lock), " Счет не найден или принадлежит другому клиенту!") 
with side-label 1 column centered overlay frame cif.


do transaction:                                                          
   update s-cif with frame cif.
   find cif where cif.cif = s-cif no-lock no-error.
   display trim(trim(cif.prefix) + " " + trim(cif.name)) @ v-cifname with frame cif. 
   pause 0.
   in_cif = s-cif.
   s-hacc = "".   /*"ALL".*/              
   update s-hacc with side-label frame cif.
   in_acc = s-hacc.
end.                                  


  find last cifsec where cifsec.cif = cif.cif no-lock no-error.
  if avail cifsec then
  do:
     find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = s-cif
          ciflog.sectime = time
          ciflog.menu = "2.4.11 Печать документов по выписке".
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
            ciflogu.menu = "2.4.11 Печать документов по выписке" .
       end.
  end.



def var dat1 as date format "99/99/9999".
def var dat2 as date format "99/99/9999". 
form "Отчетный период с " dat1 " по " dat2 with no-label centered.   

do on error undo,retry on endkey undo,return.
dat1 = g-today - 1.
dat2= g-today - 1. 
update dat1 validate(dat1 < g-today,
"Начало периода не может быть позже чем закрытый день").
update dat2 validate(dat2 <g-today and dat2 >= dat1, 
"Конец периода не может быть позже чем закрытый день/начало периода").
     find sysc where sysc.sysc eq "BEGDAY" no-lock no-error. 
     if available sysc and dat1 < sysc.daval  
     then do: message "Начало периода не может быть позже чем "  sysc.daval. 
              undo,retry. 
     end.

end.


 find first jl where jl.jdt GE dat1  AND  jl.jdt LE dat2 and jl.acc EQ s-hacc use-index jdt  no-lock no-error.
 if not avail jl then do:
   message " "  " ОБОРОТОВ НЕТ ". pause 3 no-message.  next.
 end.
 find aaa where aaa.aaa=s-hacc no-lock.
/* --------------  Browse ------------------ */

define query q-alist for jl.
define browse b-alist query q-alist
display  
jl.acc column-label "Счет"  
jl.jdt column-label "Дата опер." format "99/99/9999"
jl.jh column-label "Проводка"
crccode column-label "   "
jl.dam column-label "ДЕБЕТ" format "->>>>,>>>,>>9.99"  
jl.cam column-label "КРЕДИТ" format "->>>>,>>>,>>9.99"  
 with 8 down.

/* with 2 down /*separators*/  size-chars 78 by 14.  */

define frame f-alist b-alist with size-char 80 by 14 centered overlay row 8 title 
"Список операций:  ENTER - печать документа". 

ON VALUE-CHANGED of b-alist in frame f-alist 
DO:
  in_acc = jl.acc. 
  in_jh  = string(jl.jh).
  in_ln =  string(jl.ln). 
  hide message no-pause. 
  s-rem = substring(trim(jl.rem[1]) + trim(jl.rem[2]) + trim(jl.rem[3]) + trim(jl.rem[4]) + trim(jl.rem[5]),1,150). 
  if s-rem matches '*долг*' then s-rem = substr(s-rem,6).
  message s-rem.
 
END.

ON DEFAULT-ACTION of b-alist in frame f-alist 
DO:
  vans=true.
  message "Печатать документ?" view-as alert-box question buttons Yes-No 
          title " ---  Печать  --- " update vans. /* as log init true. */ 
  if vans 
  then do:
       Run PrintD in This-Procedure.
       m-rtn = b-alist:REFRESH() in frame f-alist.
  end.
END.

     open query q-alist for each jl  where jl.jdt GE dat1  AND  jl.jdt LE dat2 and  jl.acc EQ s-hacc and jl.lev eq 1 use-index jdt  no-lock by jl.jdt by jl.cam by jl.dam.
     find crc where crc.crc=jl.crc no-lock.
     crccode=crc.code.
     enable all with frame f-alist.
     apply "VALUE-CHANGED" to b-alist in frame f-alist.
     wait-for end-error of frame f-alist .
     hide all no-pause.

Procedure PrintD:

  hide message no-pause.
  p_mem="".
  p_memf="".
  p_pld="".
  Define  Variable V-sel As Integer FORMAT "9".
  def var dok as char format "x(36)" extent 4 initial
                      [" 1. Мемориальный ордер                ",
                       " 2. Мемориальный ордер + счет-фактура ",
                       " 3. Платежное поручение               ",
                       " 4. Уведомление                       "].
  
     Form skip(1) dok[1] skip dok[2] skip dok[3] skip dok[4] With frame m CENTERED TITLE "ВЫБЕРИТЕ ВИД ДОКУМЕНТА" overlay no-labels row 10.

  Repeat on endkey undo,return:
         display dok with frame m.
         choose field dok auto-return  with frame m.
         v-sel=integer(substring(frame-value,1,2)).
         If V-sel eq 1 then p_mem="1".
         If V-sel eq 2 then p_memf="1".
         If V-sel eq 3 then p_pld="1".
         If V-sel eq 4 then p_uvd="1".

        update " Команда печати :"  in_command with frame c1 row 16 no-label centered overlay.
   leave.
  End.

unix silent rm -f value("dok.img").  

display " формирование документа по операции " in_jh with frame c3 no-label . pause 0.
run vipdokln(in_jh,in_ln,in_acc,p_mem,p_memf,p_pld,p_uvd,output o_err).
   if opsys <> "UNIX" 
   then return "0".
   if in_command <> ? 
   then do:
        partkom = in_command + " " + in_destination.
   end.
 
   else do:
        find first ofc where ofc.ofc = userid("bank") no-lock no-error.
        if available ofc and ofc.expr[3] <> "" 
        then do:
             partkom = ofc.expr[3] + " " + in_destination.
        end.
        else return "0".
   end.
   if flg1 then unix silent value(partkom).
   hide all no-pause.  
   view frame mainhead.
   view frame cif.
   pause 0.
End Procedure. 

