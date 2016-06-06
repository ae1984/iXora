/* lb102.p
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

/* ИЗМЕНЕНИЯ :

   21.02.2003 nadejda   если нет деталей платежа - перейти просто на следующую строку 
   08.04.2003 nadejda   для всех команд "unix rm" добавлен параметр -f
        18.01.2005 sasco     убрал поле SEND
        18.01.2005 sasco     вернул поле SEND
        09.01.2006 suchkov   детали платежа 412 символов
*/

def var mt102sum as decimal .
def var num102 as int init 0 .
def var v-ks as char .  /* v-ba */
def var v-ks1 as char .  /* v-ba */
def shared var g-today as date . 
def shared var g-ofc as cha .     
def new shared var v-text as cha . 
def buffer u-remtrz for remtrz . 
def var l-atm as log initial false . 
def var rrr as log extent 255 initial true .
def var vvv as cha.
def var p-tax as log initial true . 
def var r-bic as cha. 
def var asim as int .
def var v-iii as cha extent 6 .
def var v-bb as cha . 
def var v-date as date.
def buffer t-bankl for bankl.
def shared var vvsum as deci . 
def shared var nnsum as int . 
def var v-i as decimal . 
def var i as int. 
def var vsim as cha .
def shared var vnum as int .
def var t-summ like remtrz.amt .
def var v-tmp as  cha . 
def var eii as int . 
def var v_num as int . 
def var t-n as int .
def var v-unidir as cha .
def var v-lbmfo as cha .
def var exitcod as cha .
def var v-sqn as cha .
def var buf as cha .
def var ii as int . 
def var r-sqn like remtrz.remtrz . 
def var v-ob as cha .
def var v-on as cha .
def var v-bn as cha .
def var v-dt as cha .
def var v-ri as cha .
def var v-racc as cha . 
def var t-bn as cha .
def var t-on as cha .
def var t-amt as cha .
def var ourbic as cha .
def var lbbic as cha .
def var amttot like remtrz.payment .
def var cnt as int .
def var a-amttot like remtrz.payment .
def var a-cnt as int .
def var i1 as int .
def var n as int .
def var regs as cha .
def var filenum as int .
def var daynum as cha .
def var ourbank as cha .
define variable vdetpay as character .
def stream main .
def stream second .
def stream atma . 
def var v-tnum as char.
def var v-clecod as cha. 
def stream prot . 

find first sysc where sysc.sysc = "lbterm" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи lbterm в файле sysc".
  run lgps.
end.
v-tnum = trim(sysc.chval).                     
find first sysc where sysc.sysc = "clecod" no-lock no-error.
if not avail sysc then do :
  v-text = "Нет записи clecod в файле sysc".
    run lgps.
  end.
 v-clecod = trim(sysc.chval).

FUNCTION myCustomer RETURNS character (INPUT t-on as character, 
  t-acc as character, t-com as character) .
def var t-bn as cha .
def var v-on as cha .
/*
def var v-ks as char .      /* v-ba */ 
def var v-ks1 as char . */  /* v-ba */
def var v-vks as cha . 
v-ks = trim(t-acc) .
repeat:
 if substr(v-ks,1,1) = "/" then v-ks = trim(substr(v-ks,2)).
 else leave.
end.
if index(v-ks,"/") ne 0 then do :
 v-ks = trim(v-ks) + "/<stop>/" .
 v-tmp = "" . 
 ii = 2 . 
 v-ks1 = "" . 
 do while entry(ii,v-ks,"/") ne "<stop>" :
  v-ks1 = entry(ii,v-ks,"/").
  ii = ii + 1.
 end.
 v-tmp = "".
 if ii > 2 then 
  do i = 1 to ii - 2 :
   v-tmp  = v-tmp + entry(i,v-ks,"/") . 
  end.  
 else  
  v-tmp = entry(1,v-ks,"/") .
 v-ks = v-tmp . 
end.
else
 v-ks1 = "" . 
 v-ks1 = trim(v-ks1).
  i = 1 .
  t-bn = "" .
  do while entry(i,regs,"!") <> "" :
   n = index(t-on,entry(i,regs,"!")) .
   if n <> 0 then do :
    t-bn = "/RNN/" + substring(t-on, n + length(entry(i,regs,"!")), 
      index(t-on," ",
      n + length(entry(i,regs,"!"))) - n - length(entry(i,regs,"!"))) .
     substring(t-on, n , index(t-on," ",n + length(entry(i,regs,"!"))) - n)
       = "" .
    leave .
   end .
   i = i + 1 .
  end .
  
  if t-bn = "" and remtrz.sbank = ourbank then do :
   find first aaa where aaa.aaa = t-acc no-lock no-error .
   if avail aaa then do :
    find first cif where cif.cif = aaa.cif no-lock no-error .
    if avail cif then
      t-bn = "/RNN/" + cif.jss .
   end .
  end .
  t-bn = replace(t-bn," ","") .
  t-bn = replace(t-bn,".","") .
  if trim(t-bn) = "/RNN/" or length(t-bn) > 19
  then t-bn = "" .

  /*
  eii = integer(substr(t-bn,6,6)) + integer(substr(t-bn,12)) no-error .
  if  t-com = "50" and not (length(t-bn) = 17 and not error-status:error 
      and index(t-bn,"-") eq 0 
      and index(t-bn,".") eq 0 and index(t-bn,",") eq 0 ) then p-tax = false . 
   
  if t-bn = "" and not trim(remtrz.rcvinfo[1]) begins "/TAX/" 
      and t-com = "50" then do:
       put stream second unformatted remtrz.remtrz " " source skip
      "  " + t-com + "  " + t-on /* format "x(74)" */ skip .        
      end.
   */
  /*
  if trim(v-ks1) ne "" then do:
    eii = integer(substr(v-ks1,1,6)) + integer(substr(v-ks1,7)) no-error .
    if not (length(v-ks1) > 6 and not error-status:error and 
      index(v-ks1,"-") = 0
      and index(v-ks1,".") eq 0 and index(v-ks1,",") eq 0 ) 
      then v-ks = v-ks + "-" + v-ks1 . 
   end.
    */
  if trim(v-ks) ne "" then 
   v-on = ":" + t-com + (if t-com = "50" then ":/D/" else ":" )
   + replace(v-ks," ","")  + chr(10) .
  else 
   v-on = ":" + t-com + ":" .
  do while substring(t-on,1,1) = "-" or substring(t-on,1,1) = ":" 
    or substring(t-on,1,1) = " " :
    substring(t-on,1,1) = "" .
   if t-on = "" then leave .
  end.
  v-on = v-on + substring(t-on,1,35) + chr(10) .
  do while substring(t-on,36,1) = "-" or substring(t-on,36,1) = ":" 
   or substring(t-on,36,1) = " " or substring(t-on,36,1) = "/" : 
    substring(t-on,36,1) = "" . 
    if substring(t-on,36,1) = "" then leave . 
  end.
  if substring(t-on,36,35) <> "" 
    then v-on = v-on + substring(t-on,36,35) + chr(10) .
  if t-com = "59" then do:
   do while substring(t-on,71,1) = "-" or substring(t-on,71,1) = ":"
     or substring(t-on,71,1) = " " or substring(t-on,71,1) = "/" :
      substring(t-on,71,1) = "" .
     if substring(t-on,71,1) = "" then leave .
   end.
   if substring(t-on,71,35) <> "" then 
    v-on = v-on + substring(t-on,71,35) + chr(10) .
  end.
/*  
   eii = integer(substr(v-ks1,1,6)) + integer(substr(v-ks1,7)) no-error .
   if length(v-ks1) = 11 and not error-status:error and index(v-ks1,"-") = 0
      and index(v-ks1,".") eq 0 and index(v-ks1,",") eq 0 then 
   t-bn = "/SUB/" + replace(v-ks1," ","") + t-bn .  */ 
                                                                              
  if trim(t-bn) <> "" and trim(t-bn) ne "/" then
   v-on = v-on + t-bn + chr(10) .                                  
/*  if index(v-on,"/SUB/") eq 0 and t-com = "59" then p-tax = false . */ 

/*  v-on = replace(v-on," ",""). */ 
  if t-com = "50" then 
   do:
    find first aaa where aaa.aaa = t-acc no-lock no-error .
    if avail aaa then do :
       find first sub-cod where sub-cod.sub = "cln" 
        and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnchf"   
         no-lock no-error .
        if avail sub-cod then 
          v-on = v-on + "/CHIEF/" + trim(sub-cod.rcode) + chr(10) .
       find first sub-cod where sub-cod.sub = "cln" 
        and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnbk"   
         no-lock no-error .
        if avail sub-cod then 
          v-on = v-on  +  "/MAINBK/" + trim(sub-cod.rcode) 
          + chr(10) .
      end.
  end.

  RETURN v-on . 
END FUNCTION . /* myCustomer */

find first clrdoc where clrdoc.rdt = g-today and clrdoc.pr = vnum 
  no-lock no-error.
/******************/

if not  available clrdoc then do:
    Message "There isn't clearing # " + string(vnum) + " in clrdoc file " .
    pause . 
    return .
   end.
find sysc where sysc.sysc = "lbto" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBTO in sysc file !! ".
 message v-text .
 /*  run lgps. */ 
 return .
end.
v-unidir = sysc.chval .

find sysc where sysc.sysc = "lbmfo" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record LBMFO in sysc file !! ".
  message v-text .
  return .
 end.
v-lbmfo = sysc.chval .

 find sysc where sysc.sysc = "regstr" no-lock no-error .
 if avail sysc then 
  regs = sysc.chval .
  regs = regs + "!" .
 
 find sysc where sysc.sysc = "ourbnk" no-lock no-error .
 if not avail sysc or sysc.chval = "" then do:
  message " There isn't record OURBNK in sysc file !! " .
  return .
 end.
 ourbank = sysc.chval.

 find first sysc where sysc.sysc begins "swicod" no-lock no-error .
 if not avail sysc then do :
  message " There isn't SWICOD record in sysc  " .  
  return .
 end .
 ourbic = sysc.chval .

 find first bankl where bankl.bank = v-lbmfo no-lock no-error .
 if not avail bankl then do:
  message " There isn't " + v-lbmfo +  " bank  code in bankl file " . 
  pause . 
  return . 
 end.
 lbbic = substring(bankl.bic,3) .                                  

unix silent value("/bin/rm -f " + v-unidir + "p*.eks " 
  + v-unidir + "*.err " + v-unidir +  "m*.eks  &> /dev/null ") .

do transaction :
 amttot = 0 .
 daynum = string(g-today - date(12,31,year(g-today) - 1),"999") .
 filenum = 1 + vnum * 100.
 output stream main to value("/tmp/ttt.eks") .
 output stream prot to value(v-unidir + "m" + daynum + 
   string(vnum * 100,"9999") + ".eks") .
 
 /*
  output stream second to value(v-unidir + "words.eks") .
 */

 for each clrdoc where clrdoc.rdt = g-today /* and clrdoc.bank = "900"  */ 
   and clrdoc.pr = vnum use-index dtba no-lock ,
   first remtrz where remtrz.remtrz = clrdoc.rem no-lock ,
   first bankl where bankl.bank = remtrz.rbank /* and bankl.bic <> "" 
   and bankl.bic <> ? */ no-lock break by clrdoc.bank  . 

/*  p-tax = true .  */ 

   /*  Beginning of main program body */

  find crc where crc.crc = remtrz.tcrc no-lock no-error.
  find first t-bankl where t-bankl.bank = remtrz.scbank no-lock no-error.
  v-bb = "" . 
  v-on = myCustomer("/NAME/" + remtrz.ord + " " , remtrz.sacc, "50" ) .
  v-bn = myCustomer("/NAME/" + remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3] + 
    " ", remtrz.ba, "59" ) .
  
  v-dt = ":70:/NUM/" + substr(remtrz.sqn,19) + 
  chr(10) + "/DATE/" + substr(string(year(remtrz.valdt1)),3,2) + 
  string(month(remtrz.valdt1),"99") + string(day(remtrz.valdt1),"99") + 
  chr(10) + "/SEND/07" + chr(10) + "/VO/01" + 
  chr(10) + "/KNP/000" + chr(10) + "/PSO/01" + chr(10) + "/PRT/50" +
  chr(10).
   
  if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then  
    v-dt = v-dt + "/BCLASS/" + v-ks1 + chr(10)  .

    /*
    trim(substr(remtrz.ba,index(remtrz.ba,"/",2) + 1)) + chr(10). */ 

 v-dt = v-dt + "/ASSIGN/" . 

     vdetpay = "" .
     do ii = 1 to 4:
        vdetpay = vdetpay + trim(remtrz.detpay[ii]).
     end.

     if vdetpay <> "" then do:
       if length (vdetpay) > 62 then do:
          if length (vdetpay) > 132 then do:
             if length (vdetpay) > 202 then do:
                if length (vdetpay) > 272 then do:
                   if length (vdetpay) > 342 then do:
                      if length (vdetpay) > 412 then
                        v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343,70) .
                   else v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273,70) 
                          + chr(10) + substring (vdetpay,343).
                   end.
                   else v-dt = v-dt + substring (vdetpay,1,62) 
                          + chr(10) + substring (vdetpay,63,70) 
                          + chr(10) + substring (vdetpay,133,70) 
                          + chr(10) + substring (vdetpay,203,70) 
                          + chr(10) + substring (vdetpay,273).
                end.
                else v-dt = v-dt + substring (vdetpay,1,62) 
                       + chr(10) + substring (vdetpay,63,70) 
                       + chr(10) + substring (vdetpay,133,70) 
                       + chr(10) + substring (vdetpay,202).
             end.
             else v-dt = v-dt + substring (vdetpay,1,62) 
                    + chr(10) + substring (vdetpay,63,70) 
                    + chr(10) + substring (vdetpay,133).
          end.
          else v-dt = v-dt + substring (vdetpay,1,62) + chr(10) + substring (vdetpay,63).
       end.
       else v-dt = v-dt + vdetpay .
     end.
     v-dt = v-dt + chr(10).



  if v-dt = ":70:" then v-dt = "" .  
  t-amt = trim(string(remtrz.payment,"zzzzzzzzzzzzzzz9.99-")) .
  if index(t-amt,".") > 0 then
   substring(t-amt,index(t-amt,"."),1) = "," .

  /*Налог  
  
  if not p-tax then v-ri = replace(v-ri,"/TAX/","").    /*   ?????   */
  if v-ri begins ":72:/TAX/" then do: 
   v-date = date(substr(remtrz.info[9],1,8)) no-error . 
   if error-status:error then v-date = g-today .
   v-tmp =  string(year(v-date),"9999") + string(month(v-date),"99") +
     string(day(v-date),"99") .
    v-ri = ":72:/TAX/" + chr(10) + "/ACPTDATE/" + v-tmp + chr(10) .
end . 

   */
  
  repeat:
   if substr(v-on,index(v-on,"/RNN/") + 4,1) = " " then 
      v-on = replace(v-on,"/RNN/ ","/RNN/") . 
      else leave . 
  end.                 
 if first-of(clrdoc.bank) then do:
      num102 = num102 + 1 .
      mt102sum = 0 .
  put stream main unformatted
  "\{1:" +  v-tnum + "\}" skip "\{2:I102" + 
  "SCLEAR00000N3020"  + "\}" skip "\{4:" 
       skip    
  ":20:"  
  substring(string(year(g-today)),3,2) month(g-today) format "99" day(g-today) format "99"
  "-" string(filenum,"9999") "-" string(num102) skip . 
  put stream main unformatted
  ":52B:" + trim(v-clecod)
    skip
    if remtrz.sbank ne remtrz.scbank then
    ":53C:" + trim(remtrz.scbank) + chr(10) else ""
        if remtrz.rbank ne remtrz.rcbank then
        ":54C:" + trim(remtrz.rcbank)  + chr(10) else ""
        ":57B:" + trim(remtrz.rbank)
        skip  .
      end . 
  find first u-remtrz where remtrz.remtrz = u-remtrz.remtrz exclusive-lock . 
  u-remtrz.t_sqn =  substring(string(year(g-today)),3,2) + 
  string(month(g-today),"99") +  string(day(g-today),"99")  +
  "-" + string(filenum,"9999") + "-" + string(num102) . 
  put stream main unformatted
  ":21:" remtrz.remtrz skip
  ":32B:"
      substring(string(year(g-today)),3,2) month(g-today)                             format "99" day(g-today) format "99"
      crc.code format "x(3)"
      t-amt
      skip
      caps(v-on) .
  mt102sum = mt102sum + remtrz.payment .
  put stream main unformatted
   caps(v-bn)
   caps(v-dt) . 

  if last-of(clrdoc.bank) then  do:
   t-amt = trim(string(mt102sum,"zzzzzzzzzzzzzzz9.99-")) .
     if index(t-amt,".") > 0 then
          substring(t-amt,index(t-amt,"."),1) = "," .
  put stream main unformatted
  ":32A:"
        substring(string(year(g-today)),3,2) month(g-today)
        format "99" day(g-today) format "99"
        crc.code format "x(3)"
        t-amt
        skip 
  "-}"  skip .
  end . 
   cnt = cnt + 1 .
   amttot = amttot + remtrz.payment .
   put stream prot unformatted cnt ":"
    trim(remtrz.remtrz)
    if index(remtrz.sqn,".",19) = 0 then
    caps(substring(remtrz.sqn,19))
              else
    caps(substring(remtrz.sqn,19,index(remtrz.sqn,".",19) - 19)) ":"
    v-ks ":" remtrz.payment " - " 
    substring(string(year(g-today)),3,2) month(g-today)                      
    format "99" day(g-today) format "99"
    "-" string(filenum,"9999") "-" string(num102) skip .
  end.    
 /*  for each clrdoc   */ 
  output stream main close .
  input through value("cat /tmp/ttt.eks >>" + v-unidir +
    "p" + daynum + string(filenum,"9999") + ".eks") .
  input close .
  input through value("/bin/rm -f /tmp/ttt.eks") .
  input close .
 end.

 v-text = "EKS Electronic messages as-of " + string(g-today) + 
 " was formed by " + g-ofc .
 run lgps .   

put stream prot unformatted "Total docs:" cnt skip
  "Total amount:" amttot skip .
output stream prot close .

 v-text = "EKS Electronic reestr as-of " + string(g-today) + " was formed by "
 + g-ofc + " Total docs: " + string(cnt)  
 + " Total amount: " + string(amttot)  .
  run lgps .

 if vvsum  = amttot and cnt = nnsum then  
 Message  " Ok ... " .  
 else Message " Сумма или кол-во док не равно CLRDOC ! " . 
 pause . 
 pause 0 .

