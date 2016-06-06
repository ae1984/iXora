/* remview.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       18.12.2005 tsoy     - добавил время создания платежа.
*/

/* remview.p
   просмотр оригинала платежки
   изменения от 20.03.2001
   - печать платежек входящих тенговых платежей (источник LBI)
*/   

def shared var s-remtrz like remtrz.remtrz .
def new shared var m-sqn as char .
def temp-table b-remtrz  like remtrz . 
def var tra as char.
def var v-field as cha .
def var v-sender like remtrz.sbank .
def var v-sqn like remtrz.sqn  .
def var v-lbin as cha .
def var v-lbina as cha.


/*
s-remtrz = "RMZ003502A ".  
*/
find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.

if available remtrz then do: 

 if remtrz.source = "PNJ" then do :
   find sysc where sysc.sysc = "psjarc" no-lock no-error .
   if not avail sysc or sysc.chval = "" then do:
     message " ERROR !!! There isn't record PSARC in sysc file !! ".
     pause.
     return .
   end.
      trim(remtrz.remtrz) + "." + substr(trim(remtrz.t_sqn),1,10).
   unix value("joe -rdonly  " + trim(sysc.chval) + "/" + 
   trim(remtrz.remtrz) + "." + trim(remtrz.t_sqn) ) .

 end.

 if remtrz.source = "LBI" then do:
  find sysc where sysc.sysc = "lbin" no-lock no-error .
  if not avail sysc or sysc.chval = "" then do:
    message "Отсутствует запись LBIN в таблице SYSC!".
    return .
  end.
  v-lbin = sysc.chval.

  find sysc where sysc.sysc = "LBINA" no-lock no-error .
  if not avail sysc or sysc.chval = "" then do:
    message " ERROR !!! There isn't record LBINA in sysc file !! ".
    return .
  end.
  v-lbina = sysc.chval.
  
      
 if search
 (v-lbin + entry (1,remtrz.ref,"/")) =
 v-lbin  + entry (1,remtrz.ref,"/")
 then
  unix value("joe -rdonly  " + v-lbin  + entry (1,remtrz.ref,"/")) .
 else do :
  if search
   (v-lbina + entry (3,remtrz.ref,"/") + ".Z") =
    v-lbina + entry (3,remtrz.ref,"/") + ".Z"
  then do.
     unix value ("uttview1 " + v-lbina + entry (3,remtrz.ref,"/") + ".Z" +
     " " + entry (1,remtrz.ref,"/") ) .
     def var otv as logical init no.
     pause 0 before-hide.
     run yn('Внимание!','','Печатать платеж?','',output otv).
     if otv then  unix value ('prit ' + entry (1,remtrz.ref,"/") ) .
        unix value ('rm -f ' + entry (1,remtrz.ref,"/") ) .
     pause before-hide.
  end.
end. 
 
 end.  /*  LBI    */
 
 if remtrz.source = 'H' and  remtrz.t_sqn ne "" then do:
  tra = trim(remtrz.t_sqn).
  display "Ж Д И Т Е !" with centered frame www . pause 0 .
  unix silent value("larc -s " + tra + " -F f >  tmpqq_ps.img ").
  hide frame www.
  unix ps_less tmpqq_ps.img.
  end.
  else 
  if remtrz.source = 'H' then
  do:
   Message  " Транспортная ссылка пуста! " .  pause .
 end .

 if remtrz.source = 'SW' and  remtrz.t_sqn ne "" then do:
    tra = trim(remtrz.t_sqn).
    display "Ж Д И Т Е !" with centered frame www . pause 0 .
    unix silent value("swiarc " + tra + " | swtrans -1 >  tmpqq_ps.img ").
    hide frame www.
    run menu-prt('tmpqq_ps.img').
/*    unix ps_less tmpqq_ps.img. */
 end.
 else
    if remtrz.source = 'SW' then
    do:
    Message  " Транспортная ссылка пуста! " .  pause .
 end .


 if remtrz.source = 'A' and  remtrz.t_sqn ne "" then do:
  tra = trim(remtrz.t_sqn).
  display "Ж Д И Т Е !" with centered frame www1 . pause 0 .
  

  input through value("larc -F s -s " + string(tra) ) . 
  import v-field .
  if substr(v-field,34,3) ne "10A" then
  do:
     input close .
     return .
  end .

 repeat :
  import v-field .
  if v-field = ":C5:" then leave .
 end .
 
 if v-field ne ":C5:"
 then do:
  return .
 end.
  for each b-remtrz. 
   delete b-remtrz . 
  end . 
  
  import v-sender v-sqn .
  create b-remtrz . 
  b-remtrz.rtim = time.
  import b-remtrz .   
  input close . 
  hide frame www1 . 

  find first crc where crc.crc = b-remtrz.tcrc no-lock.

        display  /* "Klients:" substring(v-sender,9)   */
        "Dok.:" substr(b-remtrz.sqn,19)
       "Datums:" b-remtrz.rdt
        "Valdt:" b-remtrz.valdt2
        skip
        "Summa:" b-remtrz.payment crc.code 
         skip                                  
         "50"
  "52 " at 40 /* v-F52 format "x(1)" at 42 */ 
  b-remtrz.ordinsact at 46 format "x(35)" skip
 b-remtrz.ordcst[1] at 5 format "x(35)" 
 b-remtrz.ordins[1] at 46 format "x(35)" skip
 b-remtrz.ordcst[2] at 5 format "x(35)" 
 b-remtrz.ordins[2] at 46 format "x(35)" skip
 b-remtrz.ordcst[3] at 5 format "x(35)" 
 b-remtrz.ordins[3] at 46 format "x(35)" skip
 b-remtrz.ordcst[4] at 5 format "x(35)" 
 b-remtrz.ordins[4] at 46 format "x(35)" skip
 "59" b-remtrz.racc at 5 format "x(35)"           
 "57 " at 40 b-remtrz.rbank at 46 format "x(35)" skip
 b-remtrz.bn[1] at 5 format "x(35)" b-remtrz.actins[1] at 46 format "x(35)" skip
 b-remtrz.bn[2]  at 5 format "x(35)" b-remtrz.actins[2] at 46 format "x(35)"  skip
 substr(b-remtrz.bn[3],1,35) at 5 format "x(35)" 
 b-remtrz.actins[3] at 46 format "x(35)" skip
 substr(b-remtrz.bn[3],36) format "x(35)" 
 b-remtrz.actins[4] at 46 format "x(35)" skip         
 "70" b-remtrz.detpay[1] at 5 format "x(35)"
 "72" at 40
 b-remtrz.rcvinfo[1] at 46 format "x(35)" skip
 b-remtrz.detpay[2] at 5 format "x(35)" 
 b-remtrz.rcvinfo[2] at 46 format "x(35)" skip
 b-remtrz.detpay[3] at 5 format "x(35)" 
 b-remtrz.rcvinfo[3] at 46 format "x(35)" skip
 b-remtrz.detpay[4] at 5 format "x(35)" 
 b-remtrz.rcvinfo[4] at 46 format "x(35)" skip
 "71 " 
 b-remtrz.bi  format "x(35)" skip
 WITH overlay frame b no-box no-label no-underline.
 pause . 
        /*
  output to tmpqq_ps.img.

  hide frame www.
  unix ps_less tmpqq_ps.img.    */
  end.
  else 
  if remtrz.source = 'A' then
  do:
  Message  " Транспортная ссылка пуста! " .  pause .
 end .
  


   if remtrz.source = 'SVL' then do:
    m-sqn = substr(remtrz.sqn,9,8).
    run SVL_view. 
   end.

   if remtrz.source = "IBH" then do :
    if remtrz.t_sqn = "" then do :
     message  " Транспортная ссылка пуста! " .  
     pause .
     return .
    end .
    find sysc where sysc.sysc = "IBHOST" no-lock no-error .
    if not avail sysc or sysc.chval = "" then do :
     message "Отсутствует запись UNIARH в таблице SYSC!" .
     pause .
     return .
    end .
    if not connected("ib") then
     connect value(sysc.chval) no-error .
    if not connected("ib") then do :
     message "Отсутствует соединение с базой данных Интернет Оффиса!" .
     pause .
    end .
    else do :
     run IBHview_ps(integer(remtrz.t_sqn)) .
    end .
   end .
end.

