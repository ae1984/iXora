/* vou_bank.p
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
          4/7/2001 попрaвлен поиск в печати (раньше дико тормозило)
          5/12/2001 sasco - настройка принтера из ofc.mday[2]
          25/02/2002 - для не JOU и не RMZ : dtreg берется из jl
          12/05/2002 - ja - added code fragments for EKNP printing
          30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
          09.09.2003 sasco - добавил печать БКС
          23.10.2003 sasco - для пополнения карточек вызывается БКС BWX а не TRX
          29.11.2003 nadejda - дата при печати берется опердень
          07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
          17.05.2004 nadejda - добавила условие для печати касс.ордера, если использована касса в пути РКО (sub-cod = obmen1002)
          20.05.2004 nadejda - запрос на печать операционного ордера, т.к. они теперь не обязательные
          24.05.2004 nadejda - убран логин офицера из распечатки
          26.05.2004 valery - добавлен входной параметр, по которому если 0 - то не печатаем операционный ордер, если 1, то печатаем операционный ордер,
                                если 2 то спрашиваем, печатать или не печатать
          30.07.2004 saltanat - добавила передаваемые значения для процедуры jl-prcd(KOd_, KBe_, KNP_).
          24.11.09 marinav - увеличена форма
          06.01.10   marinav - вывод фамилии РНН паспорта КНП
          23.02.2010 marinav - в БКС передать примечание из jl
          24/05/2011 madiyar - отражение КОД и КНП в кассовом ордере
          25/05/2011 madiyar - подправил отражение КОД и КНП в кассовом ордере
          26/05/2011 madiyar - еще раз подправил отражение КОД и КНП в кассовом ордере
          27.05.2011 damir - отправил старые программы.
          31/05/2011 madiyar - отражение КОД и КНП в кассовом ордере по обменным операциям
          01.07.2011 damir - добавил стр.283 - 307, добавил передаваемые значения в jl-prcd3, если опер Дт - 1 Кт - 5, и Дт - 2 Кт - 5
                             подтянуть v-remark1 и v-remark2(новые переменные).....
          05.07.2011 damir - добавил входной параметр в jl-prcd3.
          11.07.2011 damir - добавил if not avail
          13.07.2011 damir - изменен алгоритм расчета и отражения кодов в расходном кассовом ордере(старый закоментил),
                             отражение кодов в обменных операциях(расходник).
          26.07.2011 damir - отображение кодов в расходнике для шаблонов uni0204,uni0205
          09.09.2011 aigul - вывод КОД КБЕ КНП в ордерах
          12.09.2011 aigul - вывод КОД КБЕ КНП в ордерах только в 2-2-3,6-5-2,6-5-5
          21.09.2011 aigul - полправила вывод примечания за комиссию в joudoc 1-5 и 2-5
          18/11/2011 evseev - переход на ИИН/БИН
          23.08.2012 evseev - переход на ИИН/БИН
          01/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{chbin.i}
{convgl.i "bank"}

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


{x-jlvou.f}

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

if jh.sub eq "jou" then do:
   v_doc = jh.ref.
   find first joudoc where joudoc.docnum = v_doc no-lock.
   if avail joudoc then do:
        dtreg = joudoc.whn.
        refn  = joudoc.num.
        v-remark1 = joudoc.remark[1].
        find first tarif2 where tarif2.num + tarif2.kod = joudoc.comcode no-lock no-error.
        if avail tarif2 then v-remark2 = tarif2.pakalp.
        else v-remark2 = "".
   end.
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

output to vou.img page-size 0.

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

    /*
    if KOd + KBe + KNP <> "" and KOd_ + KBe_ + KNP_ = "" and (ljl.gl = v-cashgl or ljl.gl = obmenGL2) then do:
       KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.
    end.
    if KBe_ = "" then KBe_ = KBe.
    */

    /*if ljl.gl = v-cashgl or ljl.gl = obmenGL2 then do:
        if KOd <> '' then KOd_ = KOd.
        if KBe <> '' then KBe_ = KBe.
        if KNP <> '' then KNP_ = KNP.
    end.
    if KBe_ = "" then KBe_ = KBe.*/

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
    disp ljl.ln ljl.gl gl.sname ljl.acc format "x(21)" crc.code xamt xco
         with down width 132 frame jlprt no-label no-box.
/*ja-eknp*/

    if eknp_bal = 0 then do:
       if KOd + KBe + KNP <> "" then do:
          put "КОд " KOd " КВе " KBe " КНП " KNP skip.
       end.
        KOd = "". KBe = "". KNP = "".
    end.

/*ja-eknp*/
    if g-fname = "OUTRMZ" then do:
        if ljl.ln = 1 then do:
            find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
            if avail sub-cod then do:
                v-kod = "".
                v-kod = "КОД: " + substr(sub-cod.rcode,1,2) + " КБе: " + substr(sub-cod.rcode,4,2) + " КНП: " + substr(sub-cod.rcode,7,3).
            end.
        end.
        if ljl.ln = 2 then do:
            put unformatted v-kod skip.
        end.
        if ljl.ln = 3 then do:
            if ljl.acc <> "" then do:
                find first aaa where aaa.aaa = ljl.acc no-lock no-error.
                if avail aaa then do:
                    v-kod = "".
                    find first cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif and cif.geo = "021" then v-kod = "1".
                    if avail cif and cif.geo <> "021" then v-kod = "2".
                    find first sub-cod where sub-cod.acc = aaa.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "secek" no-lock no-error.
                    if avail sub-cod then v-kod = v-kod + sub-cod.ccode.
                end.
            end.
            else do:
                v-kod = "".
                find first sub-cod where sub-cod.acc = v-remtrz and sub-cod.ccod = "eknp" no-lock no-error.
                if avail sub-cod then v-kod = substr(sub-cod.rcode,1,2).
            end.
        end.
        if ljl.ln = 4 then do:
            put unformatted  "КОД: " + v-kod + " КБе: 14" + " КНП: 840" skip.
        end.
    end.
    if last-of(ljl.crc) then do:
       put vcha2 xdam crc.code skip vcha3 xcam crc.code skip.
       xcam = 0. xdam = 0.
       KOd = "". KBe = "". KNP = "".
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

for each remfile:
   put unformatted remfile.rem skip.
end.

END.



if vcash = true then put skip(2).

else put "======================================"
         "================================================" skip(3).

/* прогонка принтера, чтобы бумагу не выкручивать вручную */
if vcash = false then
do:
   find first ofc where ofc.ofc = g-ofc no-lock no-error.
   if ofc.mday[2] = 1 then put skip(14).
   else put skip(1).
end.
g-officer = g-ofc.
output close.

/***********************Вопрос на тему печати операционного ордера**************************/
def var v-prtorder as logical init "no" format "да/нет".

if oper_Ok = 2 then do: /*если входной параметр 2, то задаем вопрос*/
   message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder.
end.
else if  oper_Ok = 0 then  /*если входной параметр 0, то не печатаем*/
        do:
           v-prtorder = false.
        end.
	else v-prtorder = true. /*иначе, входной параметр равен 1, и переменную v-prtorder не меняем, т.е. печатаем операционный ордер*/


if v-prtorder then do:  /*если true, то печатаем*/
  unix silent prit -t vou.img.
  pause 0.
end.
/*********************************************************************************************/

if vcash = true then do:
   s-jh = jh.jh.
   message "Печатать кассовый ордер?" update l-prn.
   if l-prn then run jl-prcd3(KOd_, KBe_, KNP_, KOd_1, KBe_1, KNP_1, KOd_2, KBe_2, KNP_2, s-jh).  /* 30.07.04 saltanat - включила передаваемые значения */
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
      s_payment = s_payment + string(jh.jh) + "#" + ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5] + "#" + string(ljl.dam + ljl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
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


