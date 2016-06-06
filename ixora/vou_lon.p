/* vou_lon.p
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
       24.05.2004 nadejda - убран логин офицера из распечатки
       30.07.2004 saltanat - добавила передаваемые значения для процедуры jl-prcdl(KOd_, KBe_, KNP_).
       14/06/2005 madiar - номер транзакции берется не из shared переменной, а из входного параметра
                           к имени файла добавляется второй входной параметр
       29.09.2006 u00568 Evgeniy - по тз 469 пусть печатает чек бкс по 100200
       23.08.2012 evseev - переход на ИИН/БИН
       01/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{chbin.i}
{convgl.i "bank"}

def input parameter v-jh like jh.jh.
def input parameter v-add as char.
def shared var s-lon like lon.lon.

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
def var dtime as int.

define new shared temp-table wf
   field wsub like jl.subled
   field wacc like jl.acc
   field wcif like aaa.cif.

define new shared temp-table remfile
   field rem as character.


def var ss as int.
def var vi as int.
def var vi0 as int.
/*define  shared   var s-jh like jh.jh .*/
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
def var v-ccrc like crc.crc.
def var v-dcrc like crc.crc.
def var vib as int.
def var vis as int.
def var v-cashamt as log initial no.

def var xamt like fun.amt.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
{x-jlvou.f}

define variable vv-cif like cif.cif.

define new shared temp-table ljl like jl.

define variable s_payment as character.

find jh where jh.jh eq v-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.
find sysc where sysc.sysc = "CASHGL".
find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
   create ljl.
   buffer-copy jl to ljl.
end.

   v_doc = jh.ref.
   dtreg = jh.jdt.
   dtime = jh.tim.
   refn  = "".

   find lon where lon.lon  eq s-lon no-lock no-error.
   if available lon then do:
      find cif of lon no-lock.
      vv-cif = cif.cif.
      refn = lon.lon.
   end.
   else vv-cif = "".

output to value("vou" + v-add + ".img") page-size 0.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put
"============================================================================="
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(dtime,"HH:MM") skip
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
for each ljl of jh use-index jhln break by ljl.crc by ljl.ln:
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

/*ja-eknp*/
    eknp_bal = eknp_bal + ljl.dam - ljl.cam.
    run GetEKNP(v-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
/*ja-eknp*/

    KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.

    if ljl.gl = sysc.inval then do:
        vcash = true.
        if ljl.trx begins "lon" then v-cashamt = yes.
    end.
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
   else if ljl.subled eq "lon" then do:
      find first wf where wf.wsub eq "lon" and wf.wacc eq ljl.acc no-error.
      if not available wf then do:
         find lon where lon.lon eq ljl.acc no-lock.
         if lon.gl eq ljl.gl then do:
             create wf.
             wf.wsub = "lon".
             wf.wacc = ljl.acc.
             wf.wcif = lon.cif.
         end.
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
v-dcrc = bas_crc.
v-ccrc = bas_crc.
for each ljl of jh no-lock:
    if isConvGL(ljl.gl) then do:
        if ljl.crc ne bas_crc then do:
            if ljl.dc eq "D" then v-ccrc = ljl.crc.
            else v-dcrc = ljl.crc.
            conve = true.
        end.
    end.
end.

if conve then do:
    find d_crc where d_crc.crc eq v-dcrc no-lock.
    find c_crc where c_crc.crc eq v-ccrc no-lock.
    vib = 4.
    vis = 5.
    if v-cashamt then do:
        vib = 2.
        vis = 3.
    end.


    if bas_crc ne d_crc.crc then put "  " +
        d_crc.des + " - курс покупки " +
        string(d_crc.rate[vib],"zzz,999.9999") +
        " " + vcode + "/ " + trim (string (d_crc.rate[9], "zzzzzzz")) + " " +
        d_crc.code format "x(80)" skip.

    if bas_crc ne c_crc.crc then put "  " +
        c_crc.des + " - курс продажи " +
        string(c_crc.rate[vis],"zzz,999.9999") +
        " " + vcode + "/ " + trim (string (c_crc.rate[9], "zzzzzzz")) + " " +
        c_crc.code format "x(80)" skip.
end.

for each remfile :
delete remfile.
end.

find ljl where ljl.jh eq jh.jh and ljl.ln = 1 no-error.
if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5])
ne ""   then do:
    if index(ljl.rem[5],"/ПОЛУЧАТЕЛЬ/") ne 0
    or index(ljl.rem[5],"/ПЛАТЕЛЬЩИК/") ne 0
    then vi0 = 4.
    else vi0 = 5.
    do vi = 1 to vi0 :
        ss = 1.
        repeat:
            if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
                create remfile.
                if vi eq 1 and ss eq 1 then
                remfile.rem =
                "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                else
                remfile.rem =
                "          " + trim(substring(ljl.rem[vi],ss,60)).
            end.
            else leave.
            ss = ss + 60.
        end.
    end.
end.
        /* arp ili cif */
/*
for each wf:
    if wf.wsub eq "cif" then do:
        find cif where cif.cif eq wf.wcif no-lock.
        create remfile.
        remfile.rem = "     " + wf.wacc + " " +
           trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.            end.
    else
    if wf.wsub eq "arp" then do:
        find arp where arp.arp eq wf.wacc no-lock.
        find sub-cod where sub-cod.d-cod eq "arprnn" and
        sub-cod.acc eq wf.wacc no-lock no-error.
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
*/
for each remfile:
   put unformatted remfile.rem skip.
end.

END.



if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(2).

if not vcash then put
"Менеджер:                  Контролер:"
skip(3).

output close.


unix silent prit -t value("vou" + v-add + ".img").
/*
unix joe vou.img.
*/
pause 0.

if vcash = true then do:
   v-jh = jh.jh.
   run jl-prcdl(KOd_, KBe_, KNP_).  /* 30.07.04 saltanat - включила передаваемые значения */
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

