/* vou_word.p
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
        29.06.2005 dpuchkov.
 * CHANGES
         07.12.2011 Luiza - как vou_bank2.p, но выводит в word
         23.08.2012 evseev - переход на ИИН/БИН
         01/11/2012 madiyar - 1858 -> 1858,1859,2858,2859
*/

{global.i}
{comm-txb.i}
{yes-no.i}
{chbin.i}
{convgl.i "bank"}

def input parameter oper_Ok as int. /*valery 26/05/2004*/

def input parameter v-nm as integer.  /*1-приходный 2-расходный*/

def input parameter v-info as char format "x(50)".
/*ja-eknp*/
def var KOd as char format "x(2)".
def var KBe as char format "x(2)".
def var KNP as char format "x(3)".
def var eknp_bal as deci.
/* ja-eknp */

def var KOd_ as char format "x(2)".
def var KBe_ as char format "x(2)".
def var KNP_ as char format "x(3)".
def var KOd_1 as char format "x(2)".
def var KBe_1 as char format "x(2)".
def var KNP_1 as char format "x(3)".
def var KOd_2 as char format "x(2)".
def var KBe_2 as char format "x(2)".
def var KNP_2 as char format "x(3)".

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
define var ln1 as int.
define var ln2 as int.
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
find sysc where sysc.sysc = "CASHGL" no-lock.
v-cashgl = sysc.inval.

def var v-cashgl500 as integer.
find sysc where sysc.sysc = "CASHGL500" no-lock.
v-cashgl500 = sysc.inval.

find ofc where ofc.ofc = jh.who no-lock no-error.
v-point = ofc.regno / 1000 - 0.5.
find point where point.point = v-point no-lock no-error.

for each jl of jh no-lock:
    if jl.gl <> 603600 and jl.gl <> 653600 then do: /* Luiza  */
       create ljl.
       buffer-copy jl to ljl.
       dtreg = jl.jdt. /* jl.whn. 29.11.2003 nadejda */
    end.
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
/*output to vou.img page-size 0.*/
define stream rep.
output stream rep to cas.htm.

def var v-bankbin as char.
find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if v-bin then v-bankbin = sysc.chval. else v-bankbin = cmp.addr[2].

put stream rep space(25) "ОПЕРАЦИОННЫЙ ОРДЕР" skip .
put stream rep
"========================================================================"
    skip
    cmp.name space(23)
    dtreg format "99/99/9999" " " string(time,"HH:MM") skip
    "БИН" + v-bankbin + "," + cmp.addr[3] format "x(60)" skip.
put stream rep  point.name skip.
put stream rep  point.addr[1] skip.
put stream rep  string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" +
    "Dok.Nr." + trim(refn) +
    "   /" + ofc.name  format "x(78)" skip.
put stream rep
"========================================================================"
    skip.


vcash = false.
xdam = 0. xcam = 0.
for each ljl of jh use-index jhln no-lock
break by ljl.crc by ljl.ln:
    find crc where crc.crc eq ljl.crc no-lock.
    find gl of ljl no-lock.

/*ja-eknp*/
    if not ljl.rem[1] begins "Комиссия за:" then do:
        eknp_bal = eknp_bal + ljl.dam - ljl.cam.
        run GetEKNP(s-jh, ljl.ln, ljl.dc, input-output KOd, input-output KBe, input-output KNP).
    end.
/*ja-eknp*/

    if KOd + KBe + KNP <> "" and KOd_ + KBe_ + KNP_ = "" and (ljl.gl = v-cashgl or ljl.gl = v-cashgl500 or ljl.gl = obmenGL2) then do:
       KOd_ = KOd. KBe_ = KBe. KNP_ = KNP.
    end.
    if KBe_ = "" then KBe_ = KBe.

    if (ljl.gl = v-cashgl or ljl.gl = v-cashgl500) or ((ljl.gl = obmenGL2) and (substring(ljl.rem[1],1,5) = 'Обмен')) or
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
    put stream rep /*ljl.ln */ ljl.gl " "  gl.sname format "x(20)" " " ljl.acc format "x(21)" " " crc.code " " xamt format ">>>,>>>,>>9.99" " " xco skip.
         /*with down width 132 frame jlprt no-label no-box*/
/*ja-eknp*/
    if eknp_bal = 0 then do:
       if KOd + KBe + KNP <> "" then do:
          put stream rep  "КОд " KOd " КВе " KBe " КНП " KNP skip.
       end.
        KOd = "". KBe = "". KNP = "".
    end.
/*ja-eknp*/
    if last-of(ljl.crc) then do:
       if KOd + KBe + KNP <> "" then do:
          put stream rep " " skip.
          put stream rep  "КОд " KOd " КВе " KBe " КНП " KNP skip.
       end.

       put stream rep  vcha2 xdam format ">>>,>>>,>>>,>>9.99" " " crc.code skip vcha3 xcam format ">>>,>>>,>>>,>>9.99"  " " crc.code skip.
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
/*------------------------------------Дамир, Код,Кбе,Кнп для приходных ордеров---------------------------------------------------*/
def var i as inte init 0.
for each jl where jl.jh = s-jh and jl.dc = "d" and (jl.gl = v-cashgl or jl.gl = v-cashgl500 or jl.gl = obmenGL2) no-lock:
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
        if i = 2 then do: /*если два приходника, присвоить коды параметрам KOd_2, KBe_2, KNP_2*/
            if KOd + KBe + KNP <> "" then do:
                KOd_2 = KOd. KBe_2 = KBe. KNP_2 = KNP.
            end.
            if KBe_2 = "" then KBe_2 = KBe.
        end.
    end.
end.
if i = 0 then do:
    assign KOd_1 = "" KBe_1 = "" KNP_1 = "" KOd_2 = "" KBe_2 = "" KNP_2 = "".
end.
if i = 1 then do:
    assign KOd_2 = "" KBe_2 = "" KNP_2 = "".
end.
/*--------------------------------------------------------------------------------------------------------------------------------*/

/*------------------------Дамир, Код,Кбе,Кнп для расходных ордеров----------------------------------------------------------------*/
for each jl where jl.jh = s-jh and jl.dc = "c" and (jl.gl = v-cashgl or jl.gl = v-cashgl500 or jl.gl = obmenGL2) no-lock:
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
/*--------------------------------------------------------------------------------------------------------------------------------*/


DO:

put stream rep  "--------------------------------------"
    "-----------------------------------" skip(0).


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


if joudoc.brate <> 1 and conve then put stream rep "  " +
    d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
    " " + vcode + "/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
    d_crc.code format "x(80)" skip.

if joudoc.srate <> 1  and conve then put stream rep "  " +
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
              remfile.rem = "     " + wf.wacc + " " +
                  trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
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
           remfile.rem = "     " + wf.wacc + " " +
              trim(trim(cif.prefix) + " " + trim(cif.name)) + " " + cif.jss.
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
   put stream rep  unformatted remfile.rem skip.
end.

END.



if vcash = true then put stream rep  skip(2).

else put stream rep  "======================================"
         "===========================================" skip(3).


def var v-prx as logical.
define frame f_cu
    pipl.name     label "ВНОСИТЕЛЬ " skip
    pipl.passp  label "ПАСПОРТ  "
    with row 8 centered overlay side-labels.

if avail cif then do:
   find last pipl where pipl.cif = cif.cif no-lock no-error.
   if avail pipl then do:
      find last aaa where aaa.aaa = joudoc.cracc no-lock no-error.
      if not avail aaa then do:
      find last aaa where aaa.aaa = joudoc.dracc no-lock no-error.
      end.

      if avail aaa then do:
         if lookup(aaa.lgr, "A34,A35,A36" ) <> 0 then do:
            if yes-no ('', 'Плательщиком является вноситель ?') then do:
            put stream rep  "Произвел операцию:  " skip.
            put stream rep  "ФИО:     "pipl.name format "x(45)"skip.
            put stream rep  "РНН:     "   pipl.jss skip.
            put stream rep  "Паспорт: " pipl.passp skip.
         end.

         end.
      end.
   end.
end.





/*Добавлено*/
if v-info <> "" then do:
def var i_x as integer init 0.
repeat:
  i_x = i_x + 1.
  put stream rep  unformatted " ".
  if i_x = 78 - (length(v-info) + 14) then leave.
  if i_x > 100 then leave.
end.
  put stream rep " " skip.
  put stream rep  unformatted v-info " _____________" skip .
end.
else do:
  if avail cif then do:
      i_x = 0.
      repeat:
         i_x = i_x + 1.
         put stream rep  unformatted " ".
         if i_x = 78 - (length(cif.name) + 14) then leave.
         if i_x > 100 then leave.
      end.
      put stream rep " " skip.
      put stream rep  unformatted  cif.name " _____________" skip .
  end.
end.


  put stream rep  skip(2).

find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
if avail acheck then do:
   put stream rep  "--------------------------------------"
       "----------------------------------------" skip(0).
  find last ofc where ofc.ofc = g-ofc.

    if v-nm = 1 then
       put stream rep  "                     ПРИХОДНЫЙ НОМЕР  "  g-today   "  " s-jh /*  format "99/99/99" */ skip.
    else
       put stream rep  "                     РАСХОДНЫЙ НОМЕР  "  g-today   "  " s-jh /*  format "99/99/99" */ skip.

   put stream rep  "                     " skip .
   put stream rep  unformatted "                     " trim(string(acheck.num,'x(80)'))  skip .
   put stream rep  "                     " skip .
/*aaaaaaaaa*/
def var xin1  as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99"  label "ПРИХОД ".
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

def var ocas500 as int.
find bf-sysc where bf-sysc.sysc = "CASHGL500" no-lock no-error.
ocas500 = bf-sysc.inval.

find first jh where jh.jh = s-jh  no-lock no-error.

for each jl of jh  use-index jhln where jl.gl = ocas or jl.gl = ocas500 or (jl.gl = obmGL2  and ((jl.trx begins "opk")
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
          put stream rep  unformatted "                     Вал: " v-crca " ПРИХОД: " sxin1 format "zzz,zzz,zzz,zzz,zz9.99" skip.
       end. else
       if jl.dc eq "C" then do:
          find last crc where crc.crc = jl.crc no-lock no-error.
          if avail crc then do:
             v-crca = crc.code.
          end.
          put stream rep  unformatted "                     Вал: " v-crca " РАСХОД: " sxout1 format "zzz,zzz,zzz,zzz,zz9.99"  skip.
       end.
       sxin1 = 0. sxout1 = 0.
    end.
end.

   put stream rep  "                     " skip .
   put stream rep  "                     Менеджер: " ofc.name "  " ofc.ofc skip.


if comm-txb() = "TXB00" and ofc.regno mod 1000 = 1 then do: /*Только Алматы ЦО*/
   put stream rep  "                     " skip .
   put stream rep  unformatted "                     НОМЕР ОЧЕРЕДИ - " trim(string(acheck.n1,'x(10)'))   skip .
end.


   put stream rep  "--------------------------------------"
       "-----------------------------------" skip(0).
/*aaaaaaaaa*/
  put stream rep  skip(1).
end.


/*output close.*/




/*if vcash = true then do:
   s-jh = jh.jh.
   run vou_word1(KOd_, KBe_, KNP_).
end.*/
output stream rep close.

unix silent cptwin cas.htm winword.

s_payment = ''.

/*if jh.sts = 6 then do:
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
end.*/

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

procedure vou_word1:

/* vou_word1.p
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
        01.06.2011 Luiza -  как jl-prcd.p но выводит в word

*/

def input parameter KOd as char.
def input parameter KBe as char.
def input parameter KNP as char.

define variable v_doc as character format "x(10)".

/*def shared var s-jh like jh.jh.*/
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ПРИХОД ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "РАСХОД  ".
def var sxin  like xin.
def var sxout like xout.
def var intot  like xin.
def var outtot like xout.



define variable rnn    as character format "x(20)".
define variable vv-cif like cif.cif.
define variable vv-type like cif.type.
define variable refn   as character.
define variable dtreg  as date format "99/99/9999".
define variable drek   as character extent 10 format "x(90)".
define variable drek1  as character extent 8 format "x(90)".



find jh where jh.jh eq s-jh no-lock no-error.
dtreg = jh.jdt.

xin  = 0.
xout = 0.
vv-type = "".

define variable conve as logical.

conve = false.
find sysc where sysc.sysc eq "BUYGL" no-lock.
for each ljl of jh no-lock:
    if ljl.gl eq sysc.inval then do:
       conve = true.
       leave.
    end.
end.

if jh.sub eq "jou"  then do:
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

   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :    " + joudoc.info.
   drek[3] = "Получил : " + joudoc.info.
   if joudoc.passp eq ? then drek[4] = "Паспорт : ".
   else do:
        if string(joudoc.passpdt) = ? then
           drek[4] = "Паспорт : " + joudoc.passp.
        else
           drek[4] = "Паспорт : " + joudoc.passp + "  " + string(joudoc.passpdt).
   end.

   drek[5] = "РНН     : " + joudoc.perkod.

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

   /**************************************************************************/
   if conve = true then do:
      drek[1] = "Кассир:".
      if joudoc.info = "" then assign drek[2] = "" drek[3] = "" drek[4] = "".
   end.


end.

if jh.sub eq "rmz"  then do:
   v_doc = jh.ref.
   find remtrz where remtrz.remtrz eq v_doc no-lock no-error.
   refn  = remtrz.ref.
   dtreg = remtrz.rdt.

   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[2] = "Внес :    " + remtrz.ordcst[1].
   drek[3] = "Получил : " + remtrz.ordcst[1].
   if index(remtrz.ord, "/RNN/") <= 0 then drek[5] = "РНН     : " + substring(remtrz.ord,5,12).

   drek[6] = "".
   drek[7] = "Подпись : ".

   /**************************************************************************/
   if conve = true then do:
      drek[1] = "Кассир:".
   end.


end.

/* sasco - для пополнений пластиковых карточек */
if jh.party = "BWX" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то карточники растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Клиент:     " .
   drek[7] = "".
end.

if jh.party = "CAS" then do:
   drek[1] = "".
   drek[4] = "Менеджер:                  Контролер:                       Кассир:".
   drek[5] = "." .   /* не стирать точку!  а то кассиры растерзают из-за отсутствия пустой строчки*/
   drek[6] = "Внес:     " .
   drek[4] = "Паспорт : " .
   drek[7] = "".
end.

if jh.party = "MXP" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :".
   find first remfile. find next remfile. find next remfile.
   drek[2] = "Внес :    " + remfile.rem.
   drek[3] = "Получил : " + remfile.rem.
   find next remfile.
   drek[4] = "Паспорт : " + remfile.rem.
   find first translat where translat.jh = jh.jh no-lock no-error.
   if avail translat then drek[5] = "РНН :  " + translat.rnn.
   find first r-translat where r-translat.jh = jh.jh no-lock no-error.
   if avail r-translat then drek[5] = "РНН :  " + r-translat.acc.

end.

if jh.party = "" then do:
   drek[1] = "Менеджер:                  Контролер:                       Кассир:".
   drek[7] = " Подпись :" .
   drek[2] = "Внес :    " .
   drek[3] = "Получил : " .
   drek[4] = "Паспорт : " .

end.

drek[8] = "КОД : " + KOd  .
drek[9] = "КБе : " + KBe .
drek[10] = "КНП : " + KNP .

/*output to vou.img page-size 0.*/
/*define stream rep.
output stream rep to cas1.htm.*/



def var vi as inte.
def var ss as inte.

def var v-datastr as char format "x(20)".
def var v-datastrkz as char format "x(20)".

/*----------------------06.06.01-----------------------------------*/
def var        decAmount like xin.
def var        strAmount as char format "x(80)".
def var        temp as char.
def var        strTemp as char.
def var        str1 as char format "x(80)".
def var        str2 as char format "x(80)".
/*-------------------------------------------------------------*/


/*----------------------27.08.01-----------------------------------*/
def var        decAmountT like xin.
def buffer drate for crc.
/*-----------------------------------------------------------------*/

define variable obmenGL2 as integer.
define variable v-opkkas as char.
def var v-iscash as logical.

find sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find point where point.point = v-point no-lock no-error.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
def buffer bb-sysc for sysc.
find bb-sysc where bb-sysc.sysc = "CASHGL500" no-lock no-error.

find ofc where ofc.ofc = jh.who no-lock no-error.


sxin = 0.
sxout = 0.

find first ljl of jh where ljl.gl = sysc.inval or ljl.gl = bb-sysc.inval no-lock no-error.
v-iscash = avail ljl.

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval or ljl.gl = bb-sysc.inval) no-lock.

       if ljl.dc eq "D" then put stream rep  skip(3) space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1).
       else if ljl.dc eq "C" then  put stream rep  skip(3) space(20) "РАСХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(1).
       run pkdefdtstr(dtreg, output v-datastr, output v-datastrkz).
       put stream rep  unformatted string (jh.jh) + "/" + v_doc + "/" +
          "Dok.Nr." + trim(refn) + " /" + ofc.name +
          " /" + trim(v-datastr) skip.

       put stream rep "========================================================================" skip.
       put stream rep "ВАЛЮТА                                      ПРИХОД                РАСХОД" skip.
       put stream rep  unformatted fill ("-", 72) skip.

    find crc of ljl.
    if ljl.dam gt 0 then do:
        xin = ljl.dam.
        xout = 0.
        intot = intot + xin.
    end.
    else do:
        xin = 0.
        xout = ljl.cam.
        outtot = outtot + xout.
    end.

    put stream rep  crc.des xin xout skip.

    if ljl.dc eq "D" then put stream rep  unformatted skip
          space(22) "ИТОГО ПРИХОД" ljl.dam format "z,zzz,zzz,zz9.99" skip(1).
    else if ljl.dc eq "C" then put stream rep  unformatted skip
          space(43) "ИТОГО РАСХОД" ljl.cam format "z,zzz,zzz,zz9.99" skip(1).

    /*-------------------------------06.06.01---------------------------------------*/
     if ljl.dam = 0 then decAmount = ljl.cam. else decAmount = ljl.dam.
     put stream rep  'Сумма прописью: '.  /*skip(2).*/
     temp = string (decAmount).
     if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then
        temp = substring(temp,2,1) + "0".
     end.
     else temp = "00".

     strTemp = string(truncate(decAmount,0)).

     run Sm-vrd(input decAmount, output strAmount).
     run sm-wrdcrc(input strTemp,input temp,input crc.crc,output str1,output str2).
     strAmount = strAmount + " " + str1 + " " + temp + " " + str2.



     if length(strAmount) > 80
        then do:
            str1 = substring(strAmount,1,80).
            str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
            put stream rep  str1 skip str2 skip(0).
        end.
        else  put stream rep  strAmount skip(0).


    /*------------------------------------------------------------------------------*/

    /*----------------------27.08.01------------------------------------------------*/
    if crc.crc <> 1 then
     do:

      find first drate where drate.crc = crc.crc no-lock no-error.
      if avail drate then
         do:
           decAmountT = decAmount * drate.rate[1].
         end.

       temp = string (decAmountT).
       if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
          temp = substring(temp, length(temp) - 1, 2).
          if num-entries(temp,".") = 2 then
          temp = substring(temp,2,1) + "0".
       end.
       else temp = "00".

       strTemp = string(truncate(decAmountT,0)).

       run Sm-vrd(input decAmountT, output strAmount).
       run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
       strAmount = "(" + strAmount + " " + str1 + " " + temp + " " + str2 + ")".

       if length(strAmount) > 80
          then do:
              str1 = substring(strAmount,1,80).
              str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
              put stream rep  str1 skip str2 skip(0).
          end.
          else  put stream rep  strAmount skip(0).
     end.
    /*------------------------------------------------------------------------------*/
if joudoc.brate <> 1  and conve then put stream rep "  " +
    d_crc.des + " - курс покупки " + string (joudoc.brate,"zzz,999.9999") +
    " " + vcode + "/ " + trim (string (joudoc.bn, "zzzzzzz")) + " " +
    d_crc.code format "x(80)" skip.

if joudoc.srate <> 1  and conve then put stream rep "  " +
    c_crc.des + " - курс продажи " + string (joudoc.srate,"zzz,999.9999") +
    " " + vcode + "/ " + trim (string (joudoc.sn, "zzzzzzz")) + " " +
    c_crc.code format "x(80)" skip.
           put stream rep  skip(1) drek[1] format "x(75)" skip(1).

           if ljl.dc eq "D" and length (trim (drek[2])) ne 0 then put stream rep  drek[2] skip.
           if ljl.dc eq "C" and length (trim (drek[3])) ne 0 then put stream rep  drek[3] skip.
           if length (trim (drek[4])) ne 0 then put stream rep  drek[4] skip(1).
           if length (trim (drek[5])) ne 0 then put stream rep  drek[5] skip.
           /* ------ 05/06/2002 ------ */
           /* if ljl.dc eq "C" then put stream rep  drek[6] skip. - надо печатать и на приходном, и на расходном ордерах */

      if ljl.dc eq "D" then do: /*Приходный кассоввый ордер*/
           if length (trim (drek[6]))  ne 0 then put stream rep  drek[6]  skip.
           if length (trim (drek1[1])) ne 0 then put stream rep  drek1[1] skip.
           if length (trim (drek1[2])) ne 0 then put stream rep  drek1[2] skip.
           if length (trim (drek1[3])) ne 0 then put stream rep  drek1[3] skip.
           if length (trim (drek1[4])) ne 0 then put stream rep  drek1[4] skip.
           if length (trim (drek1[5])) ne 0 then put stream rep  drek1[5] skip.
      end.
           /* ------ 05/06/2002 ------ */
       put stream rep  skip.
       if not ljl.rem[1] begins "Комиссия за:" then do:
            run GetEKNP(s-jh, ljl.ln + 1, "C", input-output KOd, input-output KBe, input-output KNP).

            if KOd + KBe + KNP <> "" then  put stream rep "КОД "  + KOd skip  "Кбе " + KBe skip "КНП "  + KNP .
        end.
       put stream rep  skip(1).
       if length (trim (drek[7])) ne 0 then put stream rep  drek[7] .
       put stream rep  skip.
       put stream rep  "========================================================================"  skip.

       /*if ljl.rem[1] begins "Комиссия" then*/ put stream rep  unformatted "Примеч: " + ljl.rem[1] skip.
      /* else do:
           for each remfile:
               put stream rep  unformatted remfile.rem skip.
           end.
       end.*/
       put stream rep  skip.

end.

/* by sasco */
put stream rep  "========================================================================"   skip.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if ofc.mday[2] = 1 then put stream rep  skip.
else put stream rep  skip.

pause 0.
end procedure.
