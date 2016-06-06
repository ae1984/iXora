/* psarc.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Поиск входящих платежей по различным параметрам
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-7-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        17.11.2003 nadejda  - добавила поиск по номеру платежки

       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        16.11.09 marinav формат 20-го поля

*/



{lgps.i "new"}

def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical.
m_pid = "PS_" .                            
u_pid = "psarc".

def var vdtall as cha initial "ALL" label "1ДатаВал" . 
def var v-source like remtrz.source label "Источник" .
def var v-pid like que.pid label "Код".  
def var v-acc like remtrz.sacc label "Счет Кредита" .
def var v-crc like remtrz.fcrc label "Валюта " initial 1 . 
def var v-typeps as char format "x(3)" label "Тип".
def var v-bankl like remtrz.sbank label "БанкО".
def var v-sqn like remtrz.sqn label "Ссыл.N".
def var v-amtf like remtrz.payment label "Сумма C".
def var v-amtt like remtrz.payment label "По ".
def var v-rdtf like remtrz.rdt label "Дата регистрации    C  ".
def var v-rdtt like remtrz.rdt label " По ".
def var v-valdtf like remtrz.valdt1 label " С  ".
def var v-valdtt like remtrz.valdt1 label " По ".
def var v-rsub like remtrz.rsub label "Приз.пол".
def var v-npp as integer label "N платеж.поруч." format ">>>>>>>>9".

def new shared var tra like remtrz.t_sqn.
def new shared var s-remtrz like remtrz.remtrz.
def new shared var s-remtrzR like remtrz.remtrz label "Платеж".
def var v-sname like cif.sname.
def var pr as log .
def var ans as log.
def new shared var i as integer.
def new shared var suma like remtrz.amt.
def new shared var sump like remtrz.payment.
def new shared temp-table wrem
    field remtrz like remtrz.remtrz
    field ref like remtrz.ref
    field amt like remtrz.amt
    field crc like remtr.fcrc label  "CRC". 
def temp-table wre
    field remtrz like remtrz.remtrz
    field ref like remtrz.ref
    field amt like remtrz.amt
    field crc like remtr.fcrc label  "CRC".

v-option = "psarc".

form skip v-typeps skip(0) v-source skip(0)
     v-pid skip(1) 
     v-bankl skip v-sqn skip(1)
     v-npp skip
     v-acc space(5) v-rsub skip(1)
     v-rdtf space(5) v-rdtt skip
     vdtall v-valdtf space(5) v-valdtt skip(1)
     v-crc skip
     v-amtf space(5) v-amtt skip
     with frame arc side-label row 5  centered .


 {mainhead.i}

   v-rdtf = g-today.
   v-valdtf = g-today.
   v-crc = 0.
   v-amtf = 0.
   v-bankl = "ALL".
   v-typeps = "ALL".
   v-acc = "ALL".
   v-pid = "ALL".
   v-source = "ALL" .
   vdtall = "ALL"  .
   v-rsub = "ALL".

repeat:

v-sqn = "ALL".
vdtall = "ALL" . 
update s-remtrzR with frame rem side-label row 3  centered .

s-remtrz = s-remtrzR.

if s-remtrz = "" then do on error undo , retry :

 update v-typeps with frame arc.
       if v-typeps ne "ALL" then do  :
           find ptyp where ptyp.ptype = caps(v-typeps) no-lock no-error.
           if not available ptyp then do :
             Message "Неверный тип платежа !" . pause.
             undo, retry.
           end.
       end.
 update v-source   help 
   "O-исх.вал.ЦО I-вх.ручн SW-SWIFT Pxx-KZTпункт H-homebank A-филиал LON-кредит"
   with frame arc.
       if v-source ne "ALL" then do :
        find first remtrz where remtrz.source = caps(v-source) no-lock
         no-error.   
        if not available remtrz then do :
        Message "Неверный источник  !" . pause.
        undo, retry.
       end.
  end.


 update v-pid with frame arc.
 update v-bankl with frame arc.
       if v-bankl ne "ALL" then do :
         v-bankl = caps(v-bankl) . 
         v-bankl = trim(v-bankl) . 
         find bankl where bankl.bank = caps(v-bankl) no-lock no-error.
         if not available bankl then do :
             Message " Неверный код банка !". pause.
            undo, retry.
         end.
       end.


 update v-sqn v-npp   v-acc with frame arc.
/* 
 if v-pid = "2L" then do :
*/
   find sysc where sysc.sysc = "PS_SUB" no-lock no-error .
   update v-rsub 
      validate (( CAPS(v-rsub) = "ALL" or lookup(v-rsub,sysc.chval) ne 0 or 
      v-rsub = "" ), "")
       with frame arc.
/*
 end.
  else v-rsub = "ALL".
*/

 update v-rdtf with frame arc.
  v-rdtt = v-rdtf.
  v-acc = trim(v-acc).
 
 update v-rdtt vdtall 
 help "ALL-Все платежи с Дата1, <space>-Введите период Дата1" with frame arc.
 if CAPS(vdtall) = "ALL" then do:
    v-valdtf = ?.
    v-valdtt = ?.
    display v-valdtf v-valdtt with frame arc.
 end.
 else do:
 if v-valdtf = ? then  v-valdtf = g-today. 
   update v-valdtf with frame arc.
 if v-valdtt = ? then  v-valdtt = g-today.
   update v-valdtt with frame arc.
 end.
 update v-crc help " 0 - Вся валюта " with frame arc.
       if v-crc ne 0 then do :
           find crc where crc.crc = v-crc no-lock no-error.
           if not available crc then do :
             Message "Неверный код валюты !" . pause.
             undo, retry.
           end.
       end.
       if v-amtt = 0 then v-amtt = 9999999999999.99 .  
 update v-amtf /* with frame arc.
       v-amtt = v-amtf.
       if v-amtt = 0 then v-amtt = 999999999999.99.
 update */ v-amtt validate (v-amtt >= v-amtt, "") with frame arc.

 for each wrem :
   delete wrem.
 end.
 i = 0 . 
 suma = 0 . sump = 0 .
 for each remtrz where (remtrz.ptype = v-typeps or v-typeps = "ALL") and
      (remtrz.source = v-source  or v-source = "ALL" ) and
      (remtrz.sbank = v-bankl or v-bankl = "ALL" ) and
      (remtrz.cracc = v-acc or v-acc = "ALL") and 
      (remtrz.rsub = v-rsub or v-rsub = "ALL") and
      (remtrz.sqn = v-sqn or v-sqn = "ALL" ) and
      ((trim(substr(remtrz.sqn, 19)) = string(v-npp)) or v-npp = 0) and
      remtrz.rdt >= v-rdtf and remtrz.rdt <= v-rdtt and
      (vdtall = "ALL" or 
      (remtrz.valdt1 >= v-valdtf and remtrz.valdt1 <= v-valdtt )) and
      (remtrz.fcrc = v-crc or v-crc = 0) and remtrz.amt >= v-amtf and
       remtrz.amt <= v-amtt  use-index rdt no-lock :
 find first que where que.remtrz = remtrz.remtrz no-lock no-error . 
 if avail que and ( que.pid = v-pid or v-pid = "ALL" ) then 
   do:   
      create wre.
      wre.remtrz = remtrz.remtrz.
      wre.ref = substr(remtrz.sqn,19).
      wre.amt = remtrz.amt.
      wre.crc = remtrz.fcrc . 
      i = i + 1.
      suma = suma + remtrz.amt. 
      sump = sump + remtrz.payment.
   end.
  end.

  if i = 0 then do :
    Message " Платеж не найден !!! ". pause.
    undo, retry.
  end.
  if i > 0 then do :
    do transaction :
      for each wre break by wre.amt :
        create wrem.
        wrem.remtrz = wre.remtrz.
        wrem.ref =  wre.ref.
        wrem.amt = wre.amt.
        wrem.crc = wre.crc.
        delete wre.
      end.
    end.         
    run rmla.
  end.   

  if s-remtrz = "" then undo, retry .
  find first wrem where wrem.remtrz = s-remtrz.

 repeat :
  s-remtrz = wrem.remtrz.
   run s-remtrzs.
  if keyfunction(lastkey) eq "END-ERROR" then do:
     hide all. bell. run rmla . 
     find first wrem where wrem.remtrz = s-remtrz.  
     if keyfunction(lastkey) eq "END-ERROR" then 
       leave. 
  end.
  if keyfunction(lastkey) eq "Cursor-up" then
    find prev wrem no-lock no-error.
  if keyfunction(lastkey) eq "Cursor-down" then
    find next wrem no-lock no-error.
  if not available wrem then do:
     hide all. bell. run rmla.                   
     find first wrem where wrem.remtrz = s-remtrz.  
     if keyfunction(lastkey) eq "END-ERROR" then 
     leave.
   end.
  end.     /*  repeat   */
 end.     /*   s-remtrz = ""    */
 else do :
  find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
  if not available remtrz then do :
      Message " Платежа " s-remtrz " не существует .". pause.
      undo, retry.
  end.
  run s-remtrzs.
 end.
 end.           /*  repeat  */
hide all.

