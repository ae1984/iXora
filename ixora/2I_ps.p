/* 2I_ps.p
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

 {global.i}
 {lgps.i}

define var v-cashgl like gl.gl.
define var v-psingl like gl.gl.
define var v-psingl1 like gl.gl.
def var chkbal like jl.dam.

find sysc where sysc.sysc eq "RMCASH" no-lock.
v-cashgl = sysc.inval.

 {trxln.i "new"}

 find first que where que.pid = m_pid and que.con = "W"
 use-index fprc no-lock no-error.
 if not avail que then return . 

    run x-jhnewps.

do transaction :
 find jh where jh.jh = s-jh exclusive-lock . 
 find first que where que.pid = m_pid and que.con = "W"
   use-index fprc  exclusive-lock no-error.
 if avail que then
  do:
   que.dw = today.
   que.tw = time.
   que.con = "P".
   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .

   if remtrz.valdt1 gt g-today   then
   do: v-text = remtrz.remtrz +  " 1 дата валютирования не сегодня !! " .
    run lgps.
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.pvar = "".
    que.rcod = "3".
    find jh where jh.jh = s-jh exclusive-lock . delete jh .
    return .
   end.

   find first jl where jl.jh = remtrz.jh1 no-lock no-error  .
   if not avail jl then remtrz.jh1 = ? .

   if remtrz.jh1 ne ?  then
   do: v-text = remtrz.remtrz +  " 1 TRX = " + string(remtrz.jh1)  +
   " have been already done . " .
    run lgps.
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.pvar = "100".
    que.rcod = "1".
    find jh where jh.jh = s-jh exclusive-lock . delete jh .
    return .
   end.

   if remtrz.drgl eq ? or remtrz.drgl = 0 then
   do: v-text = remtrz.remtrz +  
         " ошибка счета Г/К дебета ! . " .
         run lgps.
         que.dp = today.
         que.tp = time.
         que.con = "F".
         que.pvar = "100".
         que.rcod = "1".
         find jh where jh.jh = s-jh exclusive-lock.
         delete jh .
    return .
    end.
  find first gl where gl.gl = remtrz.drgl no-lock . 
  if gl.sub = "cif" then do: 
    find first aaa where aaa.aaa = remtrz.dracc exclusive-lock no-wait
      no-error .
   if not avail aaa  then  
    do:            
         que.pid = m_pid. 
         que.df = today.
         que.tf = time.
         que.con = "W".
         find jh where jh.jh = s-jh exclusive-lock.
         delete jh .
         return .
    end.
  end.

find sysc where sysc.sysc eq "PSINGL"  no-lock.
if remtrz.fcrc ne 1 then
v-psingl = sysc.inval.
else
v-psingl = int(trim(sysc.chval)).

   if
      substr(remtrz.rsub,1,1) > "0" and
      substr(remtrz.rsub,1,1) <= "9" and
      substr(remtrz.rsub,2,1) >= "0" and
      substr(remtrz.rsub,2,1) <= "9" and
      substr(remtrz.rsub,3,1) >= "0" and
      substr(remtrz.rsub,3,1) <= "9" and
      substr(remtrz.rsub,4,1) >= "0" and
      substr(remtrz.rsub,4,1) <= "9" and
      substr(remtrz.rsub,5,1) >= "0" and
      substr(remtrz.rsub,5,1) <= "9" and
      substr(remtrz.rsub,6,1) >= "0" and
      substr(remtrz.rsub,6,1) <= "9"
      then  do:
      v-psingl  = integer(substr(remtrz.rsub,1,6)) .
      find first gl where gl.gl = v-psingl no-lock no-error .
    if not avail gl then
     do:
      v-text = remtrz.remtrz +
      " счет Г/К " + string(v-psingl) + " не найден ! Проверьте настройки ".
      run lgps.
      que.dp = today.
      que.tp = time.
      que.con = "F".
      que.pvar = "200".
      que.rcod = "1".
      find jh where jh.jh = s-jh exclusive-lock . delete jh .
      return .
      end.
   end.

   /*
     v-text = "I start process ... " +  que.remtrz . run lgps.
   */
 /*  Beginning of main program body */


/* ----------- 1 - line  -------------------------- */

   jl-gl  = remtrz.drgl.
   jl-crc = remtrz.fcrc.
   jl-acc = remtrz.dracc.
   jl-dam = remtrz.amt.
   jl-cam = 0 .
   jl-rem[1] =  remtrz.remtrz + " " + 
   trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2])
   +  ' ' + trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]).
   jl-rem[2] = substr(remtrz.ord,1,35).
   jl-rem[3] = substr(remtrz.ord,36,70).
   jl-rem[4] = substr(remtrz.ord,71).

   run x-jlpnps.
   if not rcode  then
   do:
    que.pvar = "10".  /*  Error 1st line of TRX */
    v-text = " Ошибка 1 линии 1 проводки pvar = " + que.pvar + " " +
    rdes + " " + remtrz.remtrz + " " + remtrz.dracc .
    run lgps.
    que.dp = today.
    que.tp = time.
    que.con = "F".
    if rdes matches "*CIF субсчет*не хватает остатка*" then que.rcod = "2".
     else que.rcod = "1" .
     /*
    for each jl where jl.jh = s-jh exclusive-lock .
     delete jl.
    end.  */
    run x-jlpnp22.
    find jh where jh.jh = s-jh exclusive-lock . delete jh .

    return .
   end.

/* ----------- 2 - line  -------------------------- */

 jl-gl = v-psingl.
 jl-crc = remtrz.fcrc.
 jl-acc = "".
 jl-dam = 0 .
 jl-cam = remtrz.amt.
 jl-rem[1] =  remtrz.remtrz + " " + 
 trim(remtrz.detpay[1]) + ' ' + trim(remtrz.detpay[2])
 +  ' ' + trim(remtrz.detpay[3]) + ' ' + trim(remtrz.detpay[4]).
 
 run x-jlpnps.
 if not rcode  then
  do: v-text = " Ошибка 2 линии 1 проводки - " +
    rdes + " " + remtrz.remtrz + " " + string(jl-gl) .
    run lgps.
    que.dp = today.
    que.tp = time.
    que.con = "F".
    que.pvar = "20".  /*  Error 2nd line of TRX  */
    que.rcod = "1".
    /*
    for each jl where jl.jh = s-jh exclusive-lock .
     delete jl.
    end.    */
    run x-jlpnp22.
    find jh where jh.jh = s-jh exclusive-lock . delete jh .
    return .
  end.

remtrz.info[10] = string(v-psingl) .
if remtrz.info[9] eq "" then  remtrz.info[9]  = string(g-today) + " " + 
  remtrz.scbank .



 find jh where jh.jh = s-jh exclusive-lock .
 jh.party = remtrz.remtrz .

/*     decrease  nbal  correction    */

  find first nbal where nbal.dfb = remtrz.dracc and
     nbal.plus = remtrz.valdt1 - g-today exclusive-lock no-error .
  if avail nbal then
   do:
     nbal.inwbal = nbal.inwbal - remtrz.amt .
     if nbal.inwbal = 0 and nbal.outbal = 0 then delete nbal .
   end.

/*        end nbal                */

   /*  End of program body */
   v-text = string(s-jh) + " 1 проводка " + remtrz.remtrz +
   " " + remtrz.dracc + " " + string(remtrz.amt) + " Валюта = " +
   string(remtrz.fcrc) + "-> " + string(v-psingl) .
   run lgps.
   que.dp = today.
   que.tp = time.
   que.con = "F".
/*   if remtrz.crgl ne 0
     then   */
       que.rcod = "0".
/*     else que.rcod = "4".     */
   remtrz.jh1 = s-jh.
   find first jh where jh.jh = remtrz.jh1 exclusive-lock.
   chkbal = 0.
   for each jl of jh  exclusive-lock .
    if jl.dam > 0 then chkbal = chkbal + jl.dam .
    else chkbal = chkbal - jl.cam .
    jl.sts = 6 .
   end .
   jh.sts = 6 .
   if chkbal ne 0 then 
   do:
    v-text = 
    remtrz.remtrz + " Ошибка ! Несбалансированная проводка ! ".
    que.rcod = "1".
    run lgps.
   end.
  end.
 end.
