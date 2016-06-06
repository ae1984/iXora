/* printvou_bank.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        06.03.2012 damir - changing copy's vou_bank.p
        12.03.2012 damir - перекомпиляция, добавил примечание.
*/

{global.i}

{chbin.i}
def input parameter oper_Ok as int. /*valery 26/05/2004*/
/*ja-eknp*/
def var KOd as char format "x(2)".
def var KBe as char format "x(2)".
def var KNP as char format "x(3)".
def var eknp_bal as deci.
/*ja-eknp*/

def var KOd_ as char format "x(2)".
def var KBe_ as char format "x(2)".
def var KNP_ as char format "x(3)".
def var KOd_1 as char format "x(2)".
def var KBe_1 as char format "x(2)".
def var KNP_1 as char format "x(3)".
def var KOd_2 as char format "x(2)".
def var KBe_2 as char format "x(2)".
def var KNP_2 as char format "x(3)".
def var ln1 as inte init 0.
def var ln2 as inte init 0.
def var v-remark1 as char.
def var v-remark2 as char.


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
define  shared   var s-jh like jh.jh .
def new shared var g-officer like ofc.ofc.
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

def var xamt like jl.dam.
def var xdam like jl.dam.
def var xcam like jl.cam.
def var xco as char format "x(2)" label "".
def var vcha2 as cha format "x(50)".
def var vcha3 as cha format "x(50)".
def var vcha1 as cha format "x(65)".
def new shared var v-point like point.point.
def var l-prn as logical init "no" format "да/нет".

define variable vv-cif like cif.cif.
define new shared temp-table ljl like jl.

define variable s_payment as character.

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.

define variable obmenGL2 as integer.
find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

def var v-cashgl as integer.

DEF var v-remtrz as char.
def var v-kod as char.
find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.
for each jl of jh no-lock:
   if jl.ln = 1 then v-remtrz =  substr(jl.rem[1],1,10).
   create ljl.
   buffer-copy jl to ljl.
   dtreg = jl.jdt. /* jl.whn. 29.11.2003 nadejda */
end.

for each ljl of jh use-index jhln no-lock
break by ljl.crc by ljl.ln:
    if (ljl.gl = v-cashgl) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or
       ((ljl.gl = obmenGL2) and can-find (sub-cod where sub-cod.sub = "arp"
                         and sub-cod.acc = ljl.acc
                         and sub-cod.d-cod = "arptype"
                         and sub-cod.ccode = "obmen1002" no-lock))
     then vcash = true.
end.

for each ljl of jh where ljl.ln = 1 use-index jhln
no-lock
break by ljl.crc by ljl.ln:
 if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi = 1 to 5 :

     if vi = 1 then do:
        ss = 1.
        repeat:
           if (trim(substring(ljl.rem[vi],ss,60)) ne "" ) then do:
               find joudoc where joudoc.docnum eq v_doc no-lock no-error.
               if avail joudoc then do:
                   if (joudoc.dracctype = "1" and joudoc.cracctype = "5") or (joudoc.dracctype = "2" and joudoc.cracctype = "5") then do:
                       /*create remfile.
                       remfile.rem = "zПримечан.:" + v-remark1 + " " + v-remark2.*/
                       create remfile.
                       remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).

                   end.
                   else do:
                       create remfile.
                       remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
                   end.
               end.
               if not avail joudoc then do:
                   create remfile.
                   remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi],ss,60)).
               end.
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


/*----------------------Дамир, Код,Кбе,Кнп для приходных ордеров---------------------------------------*/
def var i as inte init 0.
for each jl where jl.jh = s-jh and jl.dc = "D" and (jl.gl = v-cashgl or jl.gl = obmenGL2) no-lock:
    i = i + 1. /*подсчет кол-ва приходных ордеров*/
    assign ln1 = 0 ln2 = 0.
    ln1 = jl.ln.
    ln2 = ln1 + 1.
    assign KOd = "" KBe = "" KNP = "".
    for each ljl where ljl.jh = s-jh and (ljl.ln = ln1 or ljl.ln = ln2) no-lock:
        run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
        if i = 1 then do: /*если один приходник, присвоить коды параметрам KOd_1, KBe_1, KNP_1*/
            if KOd + KBe + KNP <> "" then do:
                KOd_1 = KOd. KBe_1 = KBe. KNP_1 = KNP.
            end.
            if KBe_1 = "" then KBe_1 = KBe.
        end.
        if i = 2 then do:  /*если два приходника, присвоить коды параметрам KOd_2, KBe_2, KNP_2*/
            if KOd + KBe + KNP <> "" then do:
                KOd_2 = KOd. KBe_2 = KBe. KNP_2 = KNP.
            end.
            if KBe_2 = "" then KBe_2 = KBe.
        end.
    end.
end.
if i = 0 then do: /*Если нету отправить пустые параметры*/
    assign KOd_1 = "" KBe_1 = "" KNP_1 = "" KOd_2 = "" KBe_2 = "" KNP_2 = "".
end.
if i = 1 then do: /*Если есть только одна отправить пустые параметры*/
    assign KOd_2 = "" KBe_2 = "" KNP_2 = "".
end.
/*-----------------------------------------------------------------------------------------------------*/

/*------------------------Дамир, Код,Кбе,Кнп для расходных ордеров-------------------------------------*/
for each jl where jl.jh = s-jh and jl.dc = "c" and (jl.gl = v-cashgl or jl.gl = obmenGL2) no-lock:
    assign ln1 = 0 ln2 = 0.
    ln2 = jl.ln.
    ln1 = ln2 - 1.
    assign KOd = "" KBe = "" KNP = "".
    for each ljl where ljl.jh = s-jh and (ljl.ln = ln1 or ljl.ln = ln2) no-lock:
        run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
        if KOd + KBe + KNP <> "" then do:
            KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.
        end.
        if KBe_ = "" then KBe_ = KBe.
    end.
end.
/*-----------------------------------------------------------------------------------------------------*/

/*------Если обменная операция,то присвоить KOd_ KBe_ KNP_, значения которые есть в приходном----------*/
find first jl where jl.jh = s-jh and (substring(jl.rem[1],1,5) = 'Обмен') no-lock no-error.
if avail jl then do:
    if KOd_1 + KBe_1 + KNP_1 <> "" then do:
        assign KOd_ =  KOd_1  KBe_ = KBe_1  KNP_ = KNP_1.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------*/

find first jl where jl.jh = s-jh and (jl.trx = "uni0204" or jl.trx = "uni0205") no-lock no-error.
if avail jl then do:
    if KOd_1 + KBe_1 + KNP_1 <> "" then do:
        assign KOd_ =  KOd_1  KBe_ = KBe_1  KNP_ = KNP_1.
    end.
end.

/*---------------------------------------------------------------------------------------------------------------------*/
if vcash = true then do:
   s-jh = jh.jh.
   message s-jh view-as alert-box.
   run printjl-prcd3(KOd_, KBe_, KNP_, KOd_1, KBe_1, KNP_1, KOd_2, KBe_2, KNP_2, s-jh).  /* 30.07.04 saltanat - включила передаваемые значения */
end.


for each ljl :
    delete ljl.
end.
for each wf :
    delete wf.
end.
for each remfile :
    delete remfile.
end.


