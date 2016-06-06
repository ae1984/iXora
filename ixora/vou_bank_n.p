/* vou_bank_n.p
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
        24/04/2007 madiyar - скопировал из vou_bank.p с изменением - не печатать по умолчанию кассовые ордера
 * BASES
        bank
 * CHANGES
       25.01.10   marinav - вывод фамилии РНН паспорта КНП
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


def var ss1 as int.
def var vi1 as int.
define  shared   var s-jh like jh.jh .
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
def new shared var v-pointa like point.point.
def var l-prn as logical init "no" format "да/нет".
{x-jlvou.f}

define variable vv-cif like cif.cif.
define new shared temp-table ljl like jl.

define variable s_payment as character.

find jh where jh.jh eq s-jh no-lock.
find crc where crc.crc eq 1 no-lock.
vcode = crc.code.

define variable obmenG2 as integer.
find sysc where sysc.sysc = "904kas" no-lock.
if avail sysc then obmenG2 = sysc.inval. else obmenG2 = 100200.

def var v-cashgl as integer.
find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-pointa = ofc.regno / 1000 - 0.5.
find point where point.point = v-pointa no-lock no-error.

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

    if (ljl.gl = v-cashgl) or ((ljl.gl = obmenG2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or
       ((ljl.gl = obmenG2) and can-find (sub-cod where sub-cod.sub = "arp"
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
 if trim(ljl.rem[1] + ljl.rem[2] + ljl.rem[3] + ljl.rem[4] + ljl.rem[5]) ne ""   then do vi1 = 1 to 5 :

     if vi1 = 1 then do:
        ss1 = 1.
        repeat:
           if (trim(substring(ljl.rem[vi1],ss1,60)) ne "" ) then do:
              create remfile.
              remfile.rem = "Примечан.:" + trim(substring(ljl.rem[vi1],ss1,60)).
           end.
           else leave.
           ss1 = ss1 + 60.
        end.

        /* arp ili cif */
        for each wf:
           if wf.wsub eq "cif" then do:
              find cif where cif.cif eq wf.wcif no-lock.
              create remfile.
              if v-bin then remfile.rem = "     " + wf.wacc + " " +  trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.bin.
              else remfile.rem = "     " + wf.wacc + " " +  trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
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
     else if (trim(ljl.rem[vi1]) ne "" ) then do:
        create remfile.
        remfile.rem = "     " + trim(ljl.rem[vi1]).
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

output close.

/***********************Вопрос на тему печати операционного ордера**************************/
def var v-prtorder as logical init "no" format "да/нет".

/*********************************************************************************************/

          def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД ".
          def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  ".
          def var sxin  like xin.
          def var sxout like xout.
          def var intot  like xin.
          def var outtot like xout.

          define variable rnn    as character format "x(20)".
          define variable vv-type like cif.type.
          define variable drek   as character extent 10 format "x(90)".
          define variable drek1  as character extent 8 format "x(90)".

          find jh where jh.jh eq s-jh no-lock no-error.
          dtreg = jh.whn.

          xin  = 0.
          xout = 0.
          vv-type = "".
          if jh.sub eq "jou" then do:
             v_doc = jh.ref.
             find joudoc where joudoc.docnum eq v_doc no-lock no-error.
             refn  = joudoc.num.
             dtreg = joudoc.whn.
             find aaa where aaa.aaa eq joudoc.dracc no-lock no-error.
             if available aaa then do:
                find cif of aaa no-lock.
                vv-cif = cif.cif.
                vv-type = cif.type.
             end.
             else do:
                vv-cif = "".
             end.

             drek[1] =
                 "Менеджер:                  Контролер:                       Кассир:".
             drek[2] = "Внес :    " + joudoc.info.
             drek[3] = "Получил : " + joudoc.info.
             if joudoc.passp eq ? then drek[4] = "Паспорт : ".
             else do:
                  if string(joudoc.passpdt) = ? then
                     drek[4] = "Паспорт : " + joudoc.passp.
                  else
                     drek[4] = "Паспорт : " + joudoc.passp + "  " + string(joudoc.passpdt).
             end.

             if v-bin then drek[5] = "ИИН     : " + joudoc.perkod.
             else drek[5] = "РНН     : " + joudoc.perkod.

             if vv-type = 'P' then do:
             drek[6] = "Подтверждаю: данная операция не связана с предпринимательской деятельностью, ".
             drek1[1] = "осуществлением мною валютных операций, требующих получения лицензии, " .
             drek1[2] = "регистрационного свидетельства, свидетельства об уведомлении, оформления " .
             drek1[3] = "паспорта сделки. " .
             drek1[4] = "Я согласен с предоставлением информации о данном платеже в " .
             drek1[5] = "правоохранительные органы и  Национальный Банк по их требованию. ".
             end.
             else drek[6] = "".
             drek[7] = "Подпись : ".
          end.

          if jh.party = "CAS" then do:
             drek[1] = "".
             drek[4] = "Менеджер:                  Контролер:                       Кассир:".
             drek[5] = "." .   /* не стирать точку!  а то кассиры растерзают из-за отсутствия пустой строчки*/
             drek[6] = "Внес:     " .
             drek[7] = "".
          end.

          drek[8] = "КОД : " + KOd  .
          drek[9] = "КБе : " + KBe .
          drek[10] = "КНП : " + KNP .

          output to vou.img page-size 0 append.

          {jl-prcd.f}

          output close.

s_payment = ''.

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


