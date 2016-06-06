/* uvou_bank.p
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
        23/09/03 nataly для проводок типа jh.sub = 'cif' была добавлена инициализация даты
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        24.05.2004 nadejda - убран логин офицера из распечатки
        02/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{comm-txb.i}
{chbin.i}
{convgl.i "bank"}

define input parameter kuda_vivodim as character.
def input parameter v-nm as integer.  /*1-приходный 2-расходный*/
def input parameter v-info as char format "x(50)".
/*define input parameter doc_num      as character.*/

/*ja-eknp*/
def var KOd as char format "x(2)".
def var KBe as char format "x(2)".
def var KNP as char format "x(3)".
def var eknp_bal as deci.
/*ja-eknp*/

def var KOd_ as char format "x(2)".
def var KBe_ as char format "x(2)".
def var KNP_ as char format "x(3)".

define buffer d_crc for crc.
define buffer c_crc for crc.

define variable bas_crc like crc.crc initial 1.
define variable v_doc   as character format "x(10)".
define variable dtreg   as date format "99/99/9999".
define variable refn    as character.
define variable vcode   as character format "x(3)".

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define new shared temp-table remfile
   field rem as character.


def var ss as int.
def var vi as int.
define  shared  var s-jh like jh.jh .
define buffer bjl for jl.
def var vcash as log.
define var vdb as cha format "x(9)" label " ".
define var vcr as cha format "x(9)" label " ".
define var vdes  as cha format "x(32)" label " ". /* chart of account desc */
define var vname as cha format "x(30)" label " ". /* name of customer */
define var vrem as cha format "x(55)" extent 7 label " ".
define var vamt like jl.dam extent 7 label " ".
define var vext as cha format "x(40)" label " ".
define var vtot like jl.dam label " ".
define var vcontra as cha format "x(53)" extent 5 label " ".
define var vpoint as int.
define var inc as int.
define var tdes like gl.des.
define var tty as cha format "x(20)".
define var vconsol as log.
define var vcif as cha format "x(6)" label " ".
define var vofc like ofc.ofc label  " ".
def var vcrc like crc.code label " ".

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.

define variable s_payment as character.


{x-jlvou.f}

define variable vv-cif like cif.cif.
define new shared temp-table ljl like jl.

def  var v-ln as log.
find jh where jh.jh eq s-jh no-lock no-error.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.
for each jl of jh no-lock:
   create ljl.
   buffer-copy jl to ljl.
end.
/*23/09/03 nataly*/
if jh.sub eq "cif" then do:
   dtreg = jh.jdt.
end.
/*23/09/03 nataly*/
if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find joudoc where joudoc.docnum = v_doc no-lock.
   dtreg = joudoc.whn.
   refn  = joudoc.num.

   find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".
end.
if jh.sub eq "rmz" then do:
   v_doc = jh.ref.
   find remtrz where remtrz.remtrz eq v_doc no-lock.
   dtreg = remtrz.rdt.
   refn = substring (remtrz.sqn, 19).
   find aaa where aaa.aaa eq remtrz.dracc no-lock no-error.
   if available aaa then do:
      find cif of aaa no-lock.
      vv-cif = cif.cif.
   end.
   else vv-cif = "".
end.
if jh.sub eq "ujo" then do:
   v_doc = jh.ref.
   find ujo where ujo.docnum eq v_doc no-lock no-error.
   dtreg = ujo.whn.
   refn = ujo.num.
   vv-cif = jh.cif.
end.
output to vou1.img page-size 0.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put
"============================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(time,"HH:MM") skip
    "БИН" + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put point.name skip.
put point.addr[1] skip.
put string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
    "Dok.Nr." + trim(refn) +
    "   /" + ofc.name format "x(78)" skip.
put
"============================================================================="
    skip.


vcash = false.
xdam = 0. xcam = 0.
for each ljl of jh use-index jhln no-lock break by ljl.crc by ljl.ln :
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

/*ja-eknp*/
    eknp_bal = eknp_bal + ljl.dam - ljl.cam.
    run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
/*ja-eknp*/

    KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.

    if (ljl.gl = sysc.inval) or (ljl.gl = 100200) then vcash = true.

    if ljl.dam ne 0 then do:
       xamt = ljl.dam.
       xdam = xdam + ljl.dam.
       xco  = "DR".
    end.
    else do:
       xamt = ljl.cam.
       xcam = xcam + ljl.cam.
       xco = "CR".
    end.
    disp ljl.ln ljl.gl gl.sname ljl.acc format "x(16)" crc.code xamt xco
         with down width 132 frame jlprt no-label no-box.
/*ja-eknp*/
    if eknp_bal = 0 then do:
       if KOd + KBe + KNP <> "" then do:
          put "КОд " KOd " КВе " KBe " КНП " KNP skip.
       end.
       KOd = "". KBe = "". KNP = "".
    end.
/*ja-eknp*/
    if last-of(ljl.crc) then do:
       put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.
       xcam = 0. xdam = 0.
    end.

   if ljl.subled eq "arp" then do:
      find first wf where wf.wsub eq "arp" and wf.wacc eq ljl.acc no-error.
      if not available wf then do:
         create wf.
         wf.wsub = "arp".
         wf.wacc = ljl.acc.
      end.
   end.
   else if ljl.subled eq "cif" then do:
      find first wf where wf.wsub eq "cif" and wf.wacc eq ljl.acc no-error.
      if not available wf then do:
         find aaa where aaa.aaa eq ljl.acc no-lock.
         create wf.
         wf.wsub = "cif".
         wf.wacc = ljl.acc.
         wf.wcif = aaa.cif.
      end.
   end.
end.

DO:

put "--------------------------------------"
    "----------------------------------------" skip(0).


/*********** KURSS **************/
define variable conve as logical.

conve = false.
for each ljl of jh no-lock:
    if isConvGL(ljl.gl) then do:
       conve = true.
       leave.
    end.
end.

if conve and jh.sub eq "jou" then do:
    find joudoc where joudoc.docnum eq v_doc no-lock.
    find d_crc where d_crc.crc eq joudoc.drcur no-lock.
    find c_crc where c_crc.crc eq joudoc.crcur no-lock.

    if bas_crc ne d_crc.crc then put "  " +
        d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
        " " + vcode + "/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
        d_crc.code format "x(80)" skip.

    if bas_crc ne c_crc.crc then put "  " +
        c_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
        " " + vcode + "/ " + trim (string (joudoc.sn, "zzzzzzz")) + " " +
        c_crc.code format "x(80)" skip.
end.
v-ln = false.

for each ljl of jh where ljl.ln = 1 use-index jhln
no-lock break by ljl.crc by ljl.ln :
   v-ln = true.
 if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5])
 ne ""   then do vi = 1 to 5 :

     if vi = 1 then do:
        ss = 1.
        repeat:
           if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
              create remfile.
              remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
           end.
           else leave.
           ss = ss + 60.
        end.
     end. /*if vi =1*/
     else if (trim(ljl.rem[vi]) ne "" ) then do:
        create remfile.
        remfile.rem = "     " + trim(ljl.rem[vi]).
     end.
    if vi = 5 then do:
      /* arp ili cif */
        for each wf:
           if wf.wsub eq "cif" then do:
              find cif where cif.cif eq wf.wcif no-lock.
              create remfile.
              if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.bin).
              else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.jss).
           end.
           else if wf.wsub eq "arp" then do:
              find arp where arp.arp eq wf.wacc no-lock.
/* 4/7/2001          find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc no-lock no-error.*/
              find sub-cod where sub-cod.d-cod eq "arprnn" and
                                       sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
              if available sub-cod then do:
                 create remfile.
                 remfile.rem =
                      "     " + wf.wacc + " " + trim(arp.des) + " " + sub-cod.rcode.
              end.
              else do:
                 create remfile.
                 remfile.rem = "     " + wf.wacc + " " + arp.des.
              end.
           end.
        end.
     end. /*if vi = 5*/
  end.  /* do  i =1 to 5*/
  else do:
     /* arp ili cif */
     for each wf:
        if wf.wsub eq "cif" then do:
           find cif where cif.cif eq wf.wcif no-lock.
           create remfile.
           if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.bin).
           else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.jss).
        end.
        else if wf.wsub eq "arp" then do:
           find arp where arp.arp eq wf.wacc no-lock.
/*  4/7/2001
           find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc no-lock no-error.*/
           find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.

           if available sub-cod then do:
              create remfile.
              remfile.rem =
                    "     " + wf.wacc + " " + trim(arp.des) + " " + sub-cod.rcode.
           end.
           else do:
              create remfile.
              remfile.rem = "     " + wf.wacc + " " + trim(arp.des).
           end.
        end.
     end.
  end.
end. /* for each */

/* 16/01/01 ----------------------*/
 if not v-ln then do :
 for each ljl of jh where ljl.ln = 2  use-index jhln
  no-lock break by ljl.crc by ljl.ln :
   v-ln = true.
 if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5])
 ne ""   then do vi = 1 to 5 :

     if vi = 1 then do:
        ss = 1.
        repeat:
           if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
              create remfile.
              remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
           end.
           else leave.
           ss = ss + 60.
        end.
     end. /*if vi =1*/
     else if (trim(ljl.rem[vi]) ne "" ) then do:
        create remfile.
        remfile.rem = "     " + trim(ljl.rem[vi]).
     end.
     if vi = 5 then do:
         /* arp ili cif */
     for each wf:
           if wf.wsub eq "cif" then do:
              find cif where cif.cif eq wf.wcif no-lock.
              create remfile.
              if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.bin).
              else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + trim(cif.jss).
           end.
           else if wf.wsub eq "arp" then do:
              find arp where arp.arp eq wf.wacc no-lock.
/* 4/7/2001          find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc no-lock no-error.*/
              find sub-cod where sub-cod.d-cod eq "arprnn" and
                                       sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
              if available sub-cod then do:
                 create remfile.
                 remfile.rem =
                      "     " + wf.wacc + " " + trim(arp.des) + " " + sub-cod.rcode.
              end.
              else do:
                 create remfile.
                 remfile.rem = "     " + wf.wacc + " " + trim(arp.des).
              end.
           end.
        end.

      end. /*if vi =5 */
   end.  /* do v1=1 to 5*/
 end. /*ljl*/
end. /* not v-ln */




for each remfile:
   put unformatted remfile.rem skip.
end.

END.



if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(3).

/*output to vou3.img page-size 0.*/
put
"Менеджер ................ Контролер ................" skip(1).


/* 9.11.2001 by sasco - прогонка принтера на 14 строк, чтоб вручную не парить*/
if not vcash then
do:
   find first ofc where ofc.ofc = g-ofc no-lock.
   if ofc.mday[2] = 1 then put skip(14).
   else put skip(1).
end.


if avail cif then do:
  def var i_x as integer init 0.
  repeat:
     i_x = i_x + 1.
     put unformatted " ".
     if i_x = 78 - (length(cif.name) + 14) then leave.
     if i_x > 100 then leave.
  end.
  put unformatted  cif.name " _____________" skip .
end.
  put skip(5).


/*ПЕЧАТЬ КОРЕШКА*/
find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
if avail acheck then do:
  find last ofc where ofc.ofc = g-ofc.
   put "" skip. put "" skip. put "" skip. put "" skip. put "" skip. put "" skip. put "" skip. put "" skip.

  put "--------------------------------------"
       "----------------------------------------" skip(0).

    if v-nm = 1 then
       put "                     ПРИХОДНЫЙ НОМЕР  "  g-today "  " string(s-jh)  /* format "99/99/99"*/ skip.
    else
       put "                     РАСХОДНЫЙ НОМЕР  "  g-today "  " string(s-jh) /* format "99/99/99"*/ skip.
   put "                     " skip .
   put "                     " trim(string(acheck.num,'x(80)'))  " ("string(acheck.n1)")" skip .
   put "                     " skip .

/*aaaaaaaaa*/
def var xin1  as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99" label "ПРИХОД ".
def var xout1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99" label "РАСХОД  ".
def var sxin1  like xin1.
def var sxout1 like xout1.
def var v-dca as char.
def var v-crca as char.
define variable obmGL2 as integer.
define variable ocas as integer.

def buffer bf-sysc for sysc.
find bf-sysc where bf-sysc.sysc = "904kas" no-lock no-error.
if avail bf-sysc then obmGL2 = bf-sysc.inval. else obmGL2 = 100200.

find bf-sysc where bf-sysc.sysc = "CASHGL" no-lock no-error.
ocas = bf-sysc.inval.

find first jh where jh.jh = s-jh  no-lock no-error.

for each jl of jh  use-index jhln where jl.gl = ocas or (jl.gl = obmGL2  and ((jl.trx begins "opk")
                                              or (substring(jl.rem[1],1,5) = "Обмен")
                                              or (can-find (sub-cod where sub-cod.sub = "arp"
                                                                      and sub-cod.acc = jl.acc
                                                                      and sub-cod.d-cod = "arptype"
                                                                      and sub-cod.ccode = "obmen1002" no-lock)))) no-lock break by jl.crc by jl.dc:
    if jl.dam gt 0 then do:
        xin1 = jl.dam.
        xout1 = 0.
    end.
    else do:
         xin1 = 0.
         xout1 = jl.cam.
    end.
    sxin1 = sxin1 + xin1.
    sxout1 = sxout1 + xout1.

    if last-of(jl.dc) then do:
       if jl.dc eq "D" then do:
          find last crc where crc.crc = jl.crc no-lock no-error.
          if avail crc then do:
             v-crca = crc.code.
          end.
          put unformatted "                     Вал: " v-crca " ПРИХОД: " sxin1 format "zzz,zzz,zzz,zzz,zz9.99"  skip.
       end. else
       if jl.dc eq "C" then do:
          find last crc where crc.crc = jl.crc no-lock no-error.
          if avail crc then do:
             v-crca = crc.code.
          end.
          put unformatted "                     Вал: " v-crca " РАСХОД: " sxout1 format "zzz,zzz,zzz,zzz,zz9.99" skip.
       end.
       sxin1 = 0. sxout1 = 0.
    end.
end.

   put "                     " skip .
   put "                     Менеджер: " ofc.name "  " ofc.ofc skip.
if comm-txb() = "TXB00" and ofc.regno mod 1000 = 1 then do: /*Только Алматы ЦО*/
   put "                     " skip .
   put unformatted "                     НОМЕР ОЧЕРЕДИ - " trim(string(acheck.n1,'x(10)'))   skip .
end.
   put "--------------------------------------"
       "----------------------------------------" skip(0).
/*aaaaaaaaa*/

  put skip(1).
end.
/*Добавлено*/

/*ПЕЧАТЬ КОРЕШКА*/

  output close.

/*output close. */


/*unix silent prit -t vou.img.
  unix joe vou.img.*/

pause 0.

if vcash = true then do:
   s-jh = jh.jh.
   run ujl-prcd(input kuda_vivodim, KOd_, KBe_, KNP_).
end.

s_payment = ''.


if jh.sts = 6 then do:
for each jl where jl.jh = jh.jh and jl.jdt = jh.jdt and (jl.gl = 100100  or jl.gl = 100200  or jl.gl = 100300) no-lock:
    find first remfile no-lock no-error.
    find first crc where crc.crc = jl.crc no-lock no-error.
    s_payment = s_payment + string(jh.jh) + "#" + substr(remfile.rem,11) + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
end.
s_payment = right-trim(s_payment,"|").
if s_payment <> '' then run bks (s_payment,"TRX").
end.


pause 0.

/*
output to vou3.img page-size 0.
put
"Клиент ................ Менеджер ................ Контролер ................"
skip(1).

put
"Кассир ................" skip(1).

output close.
*/

if vcash = true then do:
   unix silent cat vou1.img vou2.img >vou.img.  end.
else do:
   unix silent cat vou1.img /*vou3.img*/ >vou.img.   end.

if kuda_vivodim eq "prit" then do:
   unix silent value (kuda_vivodim + " vou.img").   end.
else do:
   unix value (kuda_vivodim + " vou.img").   end.
   for each ljl :
    delete ljl.
   end.
   for each wf :
    delete wf.
   end.
   for each remfile :
   delete remfile.
   end.

