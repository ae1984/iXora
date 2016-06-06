/* vou_bank3.p
 * MODULE
        Формирование ордеров при разгрузки терминалов
 * DESCRIPTION
        Формирование ордеров при разгрузки терминалов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        voucher.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        jl-prcd1.p
 * MENU
        5-1-13
 * AUTHOR
        19.05.06 ten
 * CHANGES
        18/11/2011 evseev - переход на ИИН/БИН
        23.08.2012 evseev - переход на ИИН/БИН
        01/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{chbin.i}
{convgl.i "bank"}

def input parameter oper_Ok as int.


/*ja-eknp*/
def var KOd as char format "x(2)" .
def var KBe as char format "x(2)" .
def var KNP as char format "x(3)" .
def var eknp_bal as deci no-undo.
/*ja-eknp*/

def var KOd_ as char format "x(2)" no-undo.
def var KBe_ as char format "x(2)" no-undo.
def var KNP_ as char format "x(3)" no-undo.

define buffer d_crc for crc.
define buffer c_crc for crc.

define variable bas_crc like crc.crc initial 1 no-undo.
define variable v_doc   as character format "x(10)" no-undo.
define variable dtreg   as date format "99/99/9999" no-undo.
define variable refn    as character no-undo.
define variable vcode   as character format "x(3)" no-undo.

define new shared temp-table wf no-undo
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define new shared temp-table remfile no-undo
   field rem as character.


def var ss as int no-undo.
def var vi as int no-undo.
define  shared   var s-jh like jh.jh no-undo.
define buffer bjl for jl .
def var vcash as log no-undo.
define var vdb as cha format "x(9)" label " " no-undo.
define var vcr as cha format "x(9)" label " " no-undo.
define var vdes  as cha format "x(32)" label " " no-undo. /* chart of account desc */
define var vname as cha format "x(30)" label " " no-undo. /* name of customer */
define var vrem as cha format "x(55)" extent 7 label " " no-undo.
define var vamt like jl.dam extent 7 label " " no-undo.
define var vext as cha format "x(40)" label " " no-undo.
define var vtot like jl.dam label " " no-undo.
define var vcontra as cha format "x(53)" extent 5 label " " no-undo.
define var vpoint as int no-undo.
define var inc as int no-undo.
define var tdes like gl.des no-undo.
define var tty as cha format "x(20)" no-undo.
define var vconsol as log no-undo.
define var vcif as cha format "x(6)" label " " no-undo.
define var vofc like ofc.ofc label  " " no-undo.
def var vcrc like crc.code label " " no-undo.

def var xamt like fun.amt no-undo.
def var xdam like jl.dam no-undo.
def var xcam like jl.cam no-undo.
def var xco as char format "x(2)" label "" no-undo.
def var vcha2 as cha format "x(50)" no-undo.
def var vcha3 as cha format "x(50)" no-undo.
def var vcha1 as cha format "x(65)" no-undo.
def new shared var v-point like point.point.
def var l-prn as logical init "no" format "да/нет" no-undo.
{x-jlvou.f}

define variable vv-cif like cif.cif no-undo.
define new shared temp-table ljl like jl.

define variable s_payment as character no-undo.

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.

define variable obmenGL2 as integer.
find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

def var v-cashgl as integer.
find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
   create ljl.
   buffer-copy jl to ljl.
   dtreg = jl.jdt. /* jl.whn. 29.11.2003 nadejda */
end.

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

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

output to vou.img page-size 0.


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
    "   /" + ofc.name  format "x(78)" skip.
put
"============================================================================="
    skip.


vcash = false.
xdam = 0. xcam = 0.
for each ljl of jh use-index jhln no-lock
break by ljl.crc by ljl.ln:
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

/*ja-eknp*/
    eknp_bal = eknp_bal + ljl.dam - ljl.cam.
    run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
/*ja-eknp*/

    KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.

    if (ljl.gl = v-cashgl) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or
       ((ljl.gl = obmenGL2) and can-find (sub-cod where sub-cod.sub = "arp"
                         and sub-cod.acc = ljl.acc
                         and sub-cod.d-cod = "arptype"
                         and sub-cod.ccode = "obmen1002" no-lock))
     then vcash = true.

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
find first ljl of jh no-lock.

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


for each ljl of jh where ljl.ln = 1 use-index jhln
no-lock
break by ljl.crc by ljl.ln:
 if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi = 1 to 5 :

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

        /* arp ili cif */
        for each wf:
           if wf.wsub eq "cif" then do:
              find cif where cif.cif eq wf.wcif no-lock.
              create remfile.
              if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
              else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
           end.
           else if wf.wsub eq "arp" then do:
              find arp where arp.arp eq wf.wacc no-lock.
/*            find sub-cod where sub-cod.d-cod eq "arprnn" and
                                       sub-cod.acc eq wf.wacc no-lock no-error.*/
              find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
              if available sub-cod then do:
                 create remfile.
                 remfile.rem =
                      "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
              end.
              else do:
                 create remfile.
                 remfile.rem = "     " + wf.wacc + " " + arp.des.
              end.
           end.
        end.
     end.
     else if (trim(ljl.rem[vi]) ne "" ) then do:
        create remfile.
        remfile.rem = "     " + trim(ljl.rem[vi]).
     end.
  end.  /* do */
  else do:
     /* arp ili cif */
     for each wf:
        if wf.wsub eq "cif" then do:
           find cif where cif.cif eq wf.wcif no-lock.
           create remfile.
           if v-bin then remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
           else remfile.rem = "     " + wf.wacc + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
        end.
        else if wf.wsub eq "arp" then do:
           find arp where arp.arp eq wf.wacc no-lock.
/*           find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc no-lock no-error.*/
              find sub-cod where sub-cod.d-cod eq "arprnn" and
                         sub-cod.acc eq wf.wacc and sub-cod.sub = 'arp' no-lock no-error.
           if available sub-cod then do:
              create remfile.
              remfile.rem =
                    "     " + wf.wacc + " " + arp.des + " " + sub-cod.rcode.
           end.
           else do:
              create remfile.
              remfile.rem = "     " + wf.wacc + " " + arp.des.
           end.
        end.
     end.
  end.
end. /* for each */

for each remfile:
   put unformatted remfile.rem skip.
end.

END.



if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(3).

put
"                                                              " skip
"                                                              " skip
"Менеджер                    Контролер                    Кассир                    " skip(1).

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
if vcash = false then
do:
   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if ofc.mday[2] = 1 then put skip(14).
   else put skip(1).
end.

output close.

/***********************Вопрос на тему печати операционного ордера**************************/
def var v-prtorder as logical init "no" format "да/нет".

if oper_Ok = 2 then v-prtorder = true.


if v-prtorder then do:  /*если true, то печатаем*/
  unix silent prit -t vou.img.
  pause 0.
end.
/*********************************************************************************************/

if vcash = true then do:
   s-jh = jh.jh.
   pause.
   run jl-prcd1(KOd_, KBe_, KNP_).  /* 30.07.04 saltanat - включила передаваемые значения */
end.

s_payment = ''.

if jh.sts = 6 then do:
  def var v-iscash as logical.
  find first ljl of jh where ljl.gl = sysc.inval no-lock no-error.
  v-iscash = avail ljl.

  for each ljl of jh no-lock:
    if (ljl.gl = v-cashgl) or (ljl.gl = 100300) or
       ((ljl.gl = obmenGL2)
           and not v-iscash
           and can-find (sub-cod where sub-cod.sub = "arp"
                         and sub-cod.acc = ljl.acc
                         and sub-cod.d-cod = "arptype"
                         and sub-cod.ccode = "obmen1002" no-lock)) then do:
      find first remfile no-lock no-error.
      find first crc where crc.crc = ljl.crc no-lock no-error.
      s_payment = s_payment + string(jh.jh) + "#" + substr(remfile.rem,11) + "#" + string(ljl.dam + ljl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
    end.
  end.
  s_payment = right-trim(s_payment,"|").
  if s_payment <> '' then do:
     if jh.party = "BWX" then run bks (s_payment,"BWX").
                         else run bks (s_payment,"TRX").
  end.
end.

pause 0.

   for each ljl :
    delete ljl.
   end.
   for each wf :
    delete wf.
   end.
   for each remfile :
   delete remfile.
   end.


