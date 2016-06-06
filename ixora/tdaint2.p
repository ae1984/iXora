/* tdaint2.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* tdaint.p
*/

/*
{mainhead.i TDINT0}  /*  INT PAY TDA ACCOUNT  */
*/

def shared var g-aaa like aaa.aaa.
def shared var g-today as date.
def shared var g-lang as char.


define buffer b-aaa for aaa.
define var grobal  like aaa.cbal.
define var avabal  like aaa.cbal.
define var intrat  as dec format "zzz.9999" decimals 4.
define var mtddb   like aaa.cbal.
define var mtdcr   like aaa.cbal.
define var ytdint  like aaa.cbal.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
define var voldacc as dec decimals 2.
define var vintpay as log label "PAY INTEREST?".

define var vpenalty like jl.dam label "PENALTY".
define var v-payment like jl.dam label "Summa of payment".
define var v-int like jl.dam .
define var v-accr like jl.dam .
define var v-err as log.
define var v-print as log.
def var v-taxrate like pri.rate format ">9.99%".
def var v-taxamt like jl.dam.
def var v-geo as int.

define new shared var srem as char format "x(50)" extent 2.


define var vans as log format "Да/Нет".



def var qaaa like aaa.aaa.
def new shared var vled like led.led init "CDA".
define new shared var s-aaa like aaa.aaa.
define new shared var s-aax as int.
define new shared var s-amt as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
define new shared var s-stn as int.
define new shared var s-intr as log initial true.
define new shared var s-force as log.
define new shared var s-jh like jh.jh.
define new shared var s-regdt as date.
define new shared var s-bal as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
define new shared var s-aah as int.
def var vplt as dec decimals 2 format "zz9.99%".
def var vpay as log format "НАЛИЧНЫЕ/СЧЕТ" .

def var v-param as char.
def var vdel as char initial "^".
def var v-templ as char.
def var rcode as int.
def var rdes as char.
def var ja as log format "Да/Нет".
def var vou-count as int.
def var i as int.





{tdaint.f}

outer:
repeat:
  clear frame aaa.
  if keyfunction(lastkey) eq "end-error" then return.
  if g-aaa eq "" then update qaaa with frame aaa.
                 else display g-aaa @ qaaa with frame aaa.
  /* editing: {gethelp.i} end. */
  find aaa where aaa.aaa = qaaa.
  find cif of aaa no-lock.
  s-aaa = qaaa.
  run aaa-aas.
  find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
  no-lock no-error.
  if available aas then do: pause.
  undo,retry. end.
  find lgr where lgr.lgr eq aaa.lgr no-lock.
  if lgr.led ne "CDA"
  then do:
         bell.
         {mesg.i 8212}.
         undo, retry.
       end.

  if aaa.sta eq "M"
  then do:
         bell.
         {mesg.i 8818}.
         undo, retry.
       end.

  if aaa.cr[2] le aaa.dr[2]
  then do:
         bell.
         {mesg.i 0217}.
         undo, retry.
       end.

  if lgr.lookaaa eq true
  then do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq aaa.pri no-error.
         intrat = pri.rate + aaa.rate.
         end.
         else intrat = aaa.rate.
       end.
  else do:
         if aaa.pri ne "F" then do:
         find pri where pri.pri eq lgr.pri.
         intrat = pri.rate + lgr.rate.
         end.
         else intrat = lgr.rate.
       end.

  grobal = aaa.cr[1] - aaa.dr[1].
  avabal = aaa.cbal.
  ytdint = aaa.dr[2].
  /*
  (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
  */
  mtddb = aaa.dr[1] - aaa.mdr[1].
  mtdcr = aaa.cr[1] - aaa.mcr[1].
  if g-today lt aaa.expdt then vplt = 100.
  else vplt = 0.
  find crc of aaa.
  display
     cif.cif  crc.code
     trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname qaaa
     cif.tel aaa.sta
     grobal aaa.hbal
     avabal aaa.accrued
     intrat
     ytdint
     cif.pss
     aaa.lstdb aaa.ddt
     aaa.lstcr aaa.cdt
     aaa.regdt aaa.expdt vplt
     vpenalty
     vpay
     with frame aaa.

  v-accr = aaa.accrued.
  v-accr = aaa.cr[2] - aaa.dr[2].
  
  update vplt with frame aaa.
  vpenalty = aaa.accrued * vplt / 100.
  update vpenalty with frame aaa.

  v-payment = v-accr - vpenalty.
  v-print = no.
  
  update /* vpay */  v-payment with frame aaa.
  
  v-geo = integer(cif.geo).
  v-taxrate = 0.
  if length(cif.geo) gt 0 then
  v-geo = integer(substring(cif.geo,length(cif.geo),1)). else v-geo = 0.
  if (v-geo eq 2 or v-geo eq 3)
  and substring(cif.lgr,1,1) eq "Y" then do:
    find sysc where sysc.sysc eq "TAXNR%" no-lock no-error.
    if available sysc then v-taxrate = sysc.deval. else v-taxrate = 0.
    /*
    find aax where aax.lgr eq aaa.lgr and aax.ln eq 85 no-lock no-error.
    if available aax then v-taxrate = aax.pct.
    */
  end.

 /* update  v-taxrate with frame aaa.
  v-taxamt = v-payment * v-taxrate / 100.00 .
  update v-taxamt validate(v-taxamt ge 0 ,"") with frame aaa.*/
  /*
  update v-print with frame aaa.
  */
  v-print = yes.
  {mesg.i 0895} update vans.
  if vans eq false then next.
  v-int = v-payment + vpenalty.


/* sasco - убрал проверку на большую сумму */
/*  if v-int gt v-accr then v-int = v-accr. */ 

  vintpay = true.

  s-jh = 0.
  do transaction on error undo,retry:
      v-templ = "cda0001" /*"cif0001"*/ .  /*выплата %% со 2-го на 1-ый*/
      v-param = string(v-int) + vdel
      + aaa.aaa + vdel + string(lgr.autoext,"999").
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).


      if rcode ne 0 then do:
         message rdes.
         pause.
         undo,retry.
      end.
    if vpenalty ne 0 then do:
      v-templ = "cda0004". /*возврат % по депозиту*/
      v-param = string(vpenalty) + vdel
      + aaa.aaa + vdel + string(vpenalty * crc.rate[1] / crc.rate[9]).
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).


      if rcode ne 0 then do:
         message rdes.
         pause.
         undo,retry.
      end.
     
    end.

    /*
    if v-payment ne 0 and vpay then do:
      v-templ = "cif0005". /*овердрафт*/
      v-param = string(vpenalty) + vdel
      + aaa.aaa.
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).

      if rcode ne 0 then do:
         message rdes.
         pause.
         undo,retry.
      end.
    end.
    */

    if v-taxamt gt 0 then do:
      v-templ = "cda0002". /*налог нерезидентов*/
      v-param = string(v-taxamt) + vdel
      + aaa.aaa.
      run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa ,
      output rcode, output rdes, input-output s-jh).

      if rcode ne 0 then do:
         message rdes.
         pause.
         undo,retry.
      end.
    end. /* v-taxamt ge 0 */

  if v-accr = v-int then
  aaa.accrued = 0. else aaa.accrued = aaa.accrued - v-int.
end.
displ s-jh with frame aaa.
    if s-jh ne 0 then do :

    find jh where jh.jh = s-jh.

    /* pechat vauchera */
    ja = no.
    vou-count = 1. /* kolichestvo vaucherov */

    do on endkey undo:
        message "Печатать ваучер ?" update ja.
        if ja
        then do:
             message "Сколько ?" update vou-count.
            if vou-count > 0 and vou-count < 10 then do:
                find first jl where jl.jh = s-jh no-error.
                if available jl 
                then do:
                    {mesg.i 0933} s-jh.
                    s-jh = jh.jh.
                    do i = 1 to vou-count:
                        run x-jlvou.
                    end.
                
                    run trxsts(input s-jh,input 5, output rcode, output rdes).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                    end.    
                end.  /* if available jl */
                else do:
                    message "Can't find transaction " s-jh view-as alert-box.
                    return.
                end.
            end.  /* if vou-count > 0 */
        end. /* if ja */
        pause 0.
    end.
    pause 0.
    ja = no.
    message "Штамповать ?" update ja.
    if ja
    then do:
        run trxsts(input s-jh,input 6, output rcode, output rdes).
        if rcode ne 0 then do:
            message rdes.
             pause.
        end.    
    end.


  end.

end.
