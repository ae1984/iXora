/* astnalp.p
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

/*

*/


{mainhead.i}

def new shared var v-fil like sub-cod.ccode.
def var v-fild like codfr.name[1].
def var helptmp as char.
def var vib1 as int.

define variable v-ast like ast.ast.
define variable v-gl like ast.gl.
define variable v-fag like ast.fag.
define variable otv as logical format "да/нет".
define var vmc1 like ast.ldd format "99/99/9999".
define var vmc2 like ast.ldd format "99/99/9999".
define variable vib as integer format "9".
define variable am8 like astjln.dam.
define variable am10 like astjln.cam.
define variable s31 like astjln.cam.
define variable s33 like astjln.cam.
define variable s38 like astjln.cam.
define variable s425 like astjln.cam.
define variable s54 like astjln.cam.
define variable s56 like astjln.cam.
define variable s57 like astjln.cam.
define variable am9 like astjln.cam.
define variable vfagn like fagn.naim.
define variable vgln like gl.des.
def var vop as log format "да/нет" init "да".
def var vibk as integer format "z" init 3.
def temp-table    a  field ast like ast.ast
                      field fag like ast.fag
                      field gl  like ast.gl
                      field dat as date
                      field ss like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field s33 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s31 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s38 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s425 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s57 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s56 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s54 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field sb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ns like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field nb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ass like astatl.atl format "zzz,zzz,zz9.99-" 
                      field ab like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am8 like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am10 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9p like astatl.atl format "zzz,zzz,zz9.99-"

                      field dam as decimal
                      field cam as decimal


                      field amrN as decimal format "zzz,zzz,zz9.99-"
                      field amrR as decimal format "zzz,zzz,zz9.99-"
                      field rdt like ast.rdt
                      field rnn as char format 'x(12)'

/*                      field amort like ast.amt[1]*/

                      index ast is primary gl fag ast.

def temp-table    agl field gl  like ast.gl
                      field ss like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field s33 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s31 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s38 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s425 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s57 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s56 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field s54 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field sb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ns like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field nb like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ass like astatl.atl format "zzz,zzz,zz9.99-" 
                      field ab like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am8 like astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am10 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9 like astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9p like astatl.atl format "zzz,zzz,zz9.99-"

                      field dam as decimal
                      field cam as decimal
 

                      field amrR as decimal format "zzz,zzz,zz9.99-"
                      field rnn as char format 'x(12)'
                      index ast is primary gl.

def temp-table arnn
               field rnn as char format 'x(12)'. 
define variable last_rnn as char format 'x(12)'. 

define variable v01 as decimal.
define variable v02 as decimal.

define variable v07 as decimal.
define variable v08 as decimal.

define variable v14 as decimal.
define variable v15 as decimal.

define variable v10 as decimal. /* среднегодовое значение по поступлениям */
define variable v17 as decimal. /* среднегодовое значение по выбытиям */
define variable divisor as integer init 4.

procedure annual_ave:
  define input parameter pAst as char.
  define variable pAmountAll as decimal.
  
  define variable pAmount as decimal.
  define variable icnt as integer.
  define variable vmc  as date.
  define variable astamort like ast.amt[1].
  define variable pFO as logical.
  define variable pOrigCost as decimal.
  define variable pOrigAmort as decimal.

  /*output to 'log.txt' append.*/
/*  put unformatted skip "-------------------*" skip.*/
  find ast where ast.ast = pAst no-lock no-error.
  if ast.amt[1] = 0 
     then astamort = (ast.amt[3] + ast.salv) / ast.noy / 12.
     else astamort = ast.amt[1].
  
  pFO = true.
  pAmountAll = 0.
  pAmount    = 0.
  pOrigCost  = 0.

  do icnt = 1 to 13:
     case icnt:
     when 13  then 
          do:
             vmc = date(1,1,year(vmc1) + 1).
             find last astatl where astatl.ast = a.ast and astatl.dt < vmc and month(astatl.dt) = 12 
                           and year(astatl.dt) = year(vmc) - 1 no-lock no-error.
          end.
     when 1 then 
          do:
             vmc = date(1,1,year(vmc1)).
             find last astatl where astatl.ast = a.ast and astatl.dt < vmc no-lock no-error.
          end.

     otherwise
          do:
             vmc = date(icnt,1,year(vmc1)).
             find last astatl where astatl.ast = a.ast and astatl.dt < vmc and month(astatl.dt) = icnt - 1 
                                and year(astatl.dt) = year(vmc) no-lock no-error.
          end.
     end case.
     if avail astatl then 
        do:
           if icnt = 1 then
              do:
                 pOrigCost = ast.amt[3] + ast.salv.
                 pOrigAmort = pOrigCost / ast.noy / 12.
              end.  
           pFO = false.
           pAmount = astatl.atl - pOrigCost.
/*           put unformatted a.ast '| ' pAmount ' | ' + string(icnt) skip.*/
           if pAmount = 0 then leave.
           pAmountAll = pAmountAll + pAmount.

        end.
     else 
        do:
           if not pFO then 
              do:
                 pAmount = pAmount - astamort - pOrigAmort. 
/*                 put unformatted a.ast '| ' pAmount ' | ' + string(icnt) + '*' skip.*/
                 pAmountAll = pAmountAll + pAmount.
              end.
        end.
  end. 
/*  put unformatted skip "-------------------*" skip.*/
/*  output close.*/
  if a.dam <> 0 then v10 = v10 + pAmountAll.
  if a.cam <> 0 then v17 = v17 + pAmountAll.
end procedure.


procedure find_rnn:
   find ast where ast.ast = a.ast no-lock no-error.
   find codfr where codfr.codfr = 'sproftcn' and codfr.code = ast.attn no-lock no-error.
   if avail codfr then 
      do:
         a.rnn = codfr.name[5].
         if last_rnn <> a.rnn then 
            do:
               find arnn where arnn.rnn = a.rnn no-lock no-error.
               if a.rnn <> '' then
               do:
                 if not avail arnn 
                    then 
                      do:
                         create arnn. 
                         arnn.rnn = a.rnn.
                         last_rnn = a.rnn.
                      end.
               end.
            end.
      end.
end procedure.

/*vmc1 = 12/01/02. vmc2 = 12/31/02.*/
/*vmc1 = 01/01/03. vmc2 = 02/13/03.*/
update "Введите дату отчета начало" vmc1 no-label "окончание" vmc2 no-label.



if year(vmc1) <> year(vmc2) then do: message "Ошибка, данные выдаются за один год" view-as alert-box title "". quit. end.

for each ast:
 if vmc2<g-today then do:   
   Find last astatl where astatl.ast =ast.ast and astatl.dt < vmc2 + 1
               use-index astdt no-lock no-error.
   if available astatl then do:
       create a.
       a.ast = astatl.ast.
       a.fag = astatl.fag.
       find fagn where fagn.fag=astatl.fag no-lock no-error.
       if avail fagn then do: /*a.pkop = fagn.pkop*/ end.
       a.gl = astatl.agl.
       a.ab = astatl.atl.
       a.sb = astatl.icost.
       a.nb = astatl.nol.
       a.rdt = ast.rdt.
       run find_rnn.
      end.
  end.
  else do:  /* vmc2=g-today */
     if ast.dam[1] - ast.cam[1] <>0 then do:
       create a.
       a.ast = ast.ast.
       a.fag = ast.fag.
       find fagn where fagn.fag=ast.fag no-lock no-error.
       if avail fagn then do: /*a.pkop = fagn.pkop*/ end.
       a.gl = ast.gl.
       a.sb = ast.dam[1] - ast.cam[1].
       a.nb = ast.cam[3] - ast.dam[3].
       a.ab = a.sb - a.nb.
       a.rdt = ast.rdt.
       run find_rnn.
     end. 
   end.
/*   */
  Find last astatl where astatl.ast = ast.ast  and astatl.dt < vmc1
                use-index astdt no-lock no-error.
  if available astatl then do:
      find first a where a.ast = astatl.ast and a.fag = astatl.fag
                          and a.gl = astatl.agl use-index ast no-error.
      if not available a then do: 
        create a.
        a.ast = astatl.ast.
        a.fag = astatl.fag.
        a.gl = astatl.agl.
        a.rdt = ast.rdt.
        run find_rnn.
        find fagn where fagn.fag = ast.fag no-lock no-error.
        if avail fagn then do: /*a.pkop = fagn.pkop*/ end. 
       end.
      a.ass = astatl.atl.
      a.ss = astatl.icost.
      a.ns = astatl.nol.
  end.
end.   


For each astjln no-lock where astjln.ajdt > vmc1 - 1 and  astjln.ajdt < vmc2 + 1 and
       substr(astjln.atrx,1,1) ne "r" use-index astdt 
    break by astjln.agl by astjln.afag  by astjln.aast:   

  if astjln.atrx eq "0" then next.
  

 if /*substring(astjln.apriz,1,1)="A" and*/ substring(astjln.atrx,1,1)="9" then
      am8=am8 + astjln.c[3] - astjln.d[3].
 else do:
  create a.
   a.dat=astjln.ajdt.
   a.ast = astjln.aast.
   a.fag = astjln.afag.
   run find_rnn.
   find fagn where fagn.fag=astjln.afag no-lock no-error.
   if avail fagn then do: /*a.pkop = fagn.pkop*/ end.
   a.gl = astjln.agl.

  if substring(astjln.atrx,1,1)="1" then do:
      a.s31=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
  end.
  else
  if substring(astjln.atrx,1,1)="3" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
  end.
  else
  if substring(astjln.atrx,1,1)="8" then do:
      a.s57=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
 end.
 else
 if substring(astjln.atrx,1,1)="2" or
    substring(astjln.atrx,1,1)="5" 
                    then do:
      a.s57=astjln.d[1] - astjln.c[1].
      a.am9=astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
 end.
  if substring(astjln.atrx,1,1)="p" then do:
      a.s38  =astjln.d[1] - astjln.c[1].
      a.am9p =astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
 end.
 else
  if substring(astjln.atrx,1,1)="4" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
  end.
  else
  if substring(astjln.atrx,1,1)="6" then do:
      a.s56  =astjln.c[1] - astjln.d[1].
      a.am10 =astjln.d[3] - astjln.c[3].
      a.dam=a.dam + astjln.d[1].
      a.cam=a.cam + astjln.c[1].
 end.
 else
/*  if substring(astjln.atrx,1,1)="7" then do:
      a.s57 =astjln.d[1] - astjln.c[1].
      a.am9 =astjln.c[3] - astjln.d[3].
 end.*/
                             
 end.

 if last-of(astjln.aast) then do:
   
   Find first a where a.ast =astjln.aast and a.fag=astjln.afag and
                      a.gl  =astjln.agl and a.dat=? use-index ast
                      no-error .
   if not available a then do:
       create a.
       a.ast = astjln.aast.
       a.fag = astjln.afag.
       run find_rnn.
       find fagn where fagn.fag=astjln.afag no-lock no-error.
       if avail fagn then do: /*a.pkop = fagn.pkop*/ end.
       a.gl = astjln.agl.
       a.ab = 0.
       a.sb = 0.
       a.nb = 0.
   end.   
   a.am8 =am8.
   am8=0. 
 end. 
End.

for each a where a.dat = ?:
   if a.ss=0 and a.ns=0 and a.ass=0 and a.s31=0 and a.s56=0 and a.s33=0 and
      a.s57=0 and a.s54=0 and a.s38=0 and a.s425=0 and a.am9=0 and a.am10=0 and
      a.am8=0 and a.sb=0 and a.nb=0 and a.ab=0 then delete a.
End.

for each arnn /*where arnn.rnn = '600700040924' '600800022446'*/ by arnn.rnn:

for each a where a.rnn = arnn.rnn /*'600900000014'*/ break by a.gl:
  accumulate a.ss   (sub-total by a.gl). 
  accumulate a.sb   (sub-total by a.gl).
  accumulate a.ns   (sub-total by a.gl).
  accumulate a.nb   (sub-total by a.gl).
  accumulate a.ass  (sub-total by a.gl).
  accumulate a.ab   (sub-total by a.gl).
  accumulate a.am8  (sub-total by a.gl).
  accumulate a.am9  (sub-total by a.gl).
  accumulate a.am9p (sub-total by a.gl).
  accumulate a.am10 (sub-total by a.gl).
  accumulate a.s31  (sub-total by a.gl).
  accumulate a.s33  (sub-total by a.gl).
  accumulate a.s38  (sub-total by a.gl).
  accumulate a.s425 (sub-total by a.gl).
  accumulate a.s54  (sub-total by a.gl).
  accumulate a.s56  (sub-total by a.gl).
  accumulate a.s57  (sub-total by a.gl).
  accumulate a.dam  (sub-total by a.gl).
  accumulate a.cam  (sub-total by a.gl).
  if last-of(a.gl) then
     do:
         create agl.
/*         PUT "  " a.gl format "zzzzz9" " "  */
         agl.gl = a.gl.
         agl.ss = accum sub-total by a.gl a.ss. /*  format "zzzzzzzzzzz9.99-"*/
         agl.s31 = accum sub-total by a.gl a.s31. /* format "zzzzzzzzzzz9.99-"*/
         agl.s38 = accum sub-total by a.gl a.s38. /* format "zzzzzzzzzzz9.99-"*/
         agl.s57 = accum sub-total by a.gl a.s57. /* format "zzzzzzzzzzz9.99-" */
         agl.s56 = accum sub-total by a.gl a.s56. /* format "zzzzzzzzzzz9.99-"  */
      
         agl.s33 = accum sub-total by a.gl a.s33. /* format "zzzzzzzz9.99-"      */
         agl.s425 = accum sub-total by a.gl a.s425. /* format "zzzzzzzz9.99-"      */
         agl.s54 = accum sub-total  by a.gl a.s54. /* format "zzzzzzzz9.99-"       */
      
         agl.sb = accum sub-total   by a.gl a.sb.  /* format "zzzzzzzzzzz9.99-" "|" */
         agl.ns = accum sub-total   by a.gl a.ns.  /* format "zzzzzzzzzzz9.99-"      */
         agl.am8 = accum sub-total  by a.gl a.am8. /* format "zzzzzzzzzzz9.99-"       */
         agl.am9 = accum sub-total  by a.gl a.am9. /* format "zzzzzzzzzzz9.99-"        */
         agl.am10 = accum sub-total by a.gl a.am10.  /* format "zzzzzzzzzzz9.99-"       */
         agl.nb = accum sub-total   by a.gl a.nb. /* format "zzzzzzzzzzz9.99-"  "|"      */
         agl.ass = accum sub-total  by a.gl a.ass. /*  format "zzzzzzzzzzz9.99-"          */
         agl.ab = accum sub-total   by a.gl a.ab.  /* format "zzzzzzzzzzz9.99-".           */
         agl.dam = accum sub-total  by a.gl a.dam.
         agl.cam = accum sub-total  by a.gl a.cam.

/*         Put trim(vgln)  format "x(17)" skip.*/
     end.      
end. /*for each a where a.rnn = arnn.rnn*/

v01 = 0. v02 = 0. v07 = 0. v08 = 0. v14 = 0. v15 = 0.


/* ищем среднегодовое значение стоимости средств*/
v10 = 0. v17 = 0.

for each a where (a.dam <> 0 or a.cam <> 0) and a.rnn = arnn.rnn /* '600900000014' and a.ast = '20000006'*/ break by a.ast:
    if first-of(a.ast) 
       then run annual_ave(input a.ast).
end. /* for each a break by a.ast: */

v10 = v10 / 13.
v17 = v17 / 13.

divisor = 4.

divisor = divisor - (trunc(month(vmc2) / 4,0) + 1).
if divisor = 0 then divisor = 1.

for each agl:
  if agl.gl = 165200 or agl.gl = 165300 or agl.gl = 165420 or agl.gl = 165440 
     then 
       do:
          v01 = v01 + agl.ass.
          v07 = v07 + agl.dam.
          v14 = v14 + agl.cam.
       end.

  if agl.gl = 165910 
     then 
       do:
          v02 = agl.ass.
          v08 = v08 + agl.dam.
          v15 = v15 + agl.cam.
       end.
end.


output to 'astnalp.html'.

{html-title.i &stream = " " &title = "Форма 701.00" &size-add = " "}

put unformatted 
   "<P align = ""center""><FONT size=5 face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Расчет текущих платежей по налогу на имущество<BR>" "</B></FONT></P>" skip.

find taxnk where taxnk.rnn = arnn.rnn no-lock no-error.
if avail taxnk then put unformatted taxnk.name skip.
               else put unformatted 'Неизвестный налоговый комитет ' arnn.rnn skip.

put unformatted "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.


put unformatted "<TR> <TD ALIGN=CENTER COLSPAN=6> <FONT size=4> Исчисление текущих платежей по налогу на имущество </FONT> </TD>" "</TR>" skip.
put unformatted "<TR> <TD ALIGN=CENTER > Остаточная стоимость основных средств на начало налогового периода " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость нематериальных активов на начало налогового периода " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость основных средств и нематериальных активов на начало налогового периода " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Ставка налога %" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уплате за отчетный налоговый период" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уплате по срокам 20 февраля. 20 мая. 20 августа. 20 ноября. " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > 701.00.001 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.002 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.003 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.004 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.005" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.006 " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > " string(v01,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v02,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v01 + v02,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " 1 "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string((v01 + v02) / 100,"zzz,zzz,zzz,zz9.99")"</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string((v01 + v02) / 100 / 4,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "</TR>"  skip.
put unformatted "</TABLE> <BR>" skip.

put unformatted "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put unformatted "<TR> <TD ALIGN=CENTER COLSPAN=7> <FONT size=4> Исчисление текущих платежей по приобретенным основным средстам и нематериальным активам </FONT> </TD>" "</TR>" skip.
put unformatted "<TR> <TD ALIGN=CENTER > Первоначальная (остаточная) стоимость приобретенных основных средств" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Первоначальная (остаточная) стоимость приобретенных нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Первоначальная (остаточная) стоимость приобретенных основных средств и нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Среднегодовая стоимость основных средств и нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Ставка налога %" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уплате приобретенным основным средствам и нематериальным активам за отчетный налоговый период. " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уплате по срокам 20 февраля. 20 мая. 20 августа. 20 ноября. " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > 701.00.007 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.008 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.009 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.010 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.011" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.012 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.013 " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > " string(v07,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v08,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v07 + v08,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v10,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " 1 "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v10 / 100,"zzz,zzz,zzz,zz9.99")"</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v10 / 100 / divisor,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "</TR>"  skip.
put unformatted "</TABLE> <BR>" skip.

put unformatted "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put unformatted "<TR> <TD ALIGN=CENTER COLSPAN=7> <FONT size=4> Исчисление текущих платежей по выбывшим основным средстам и нематериальным активам </FONT> </TD>" "</TR>" skip.
put unformatted "<TR> <TD ALIGN=CENTER > Остаточная стоимость выбывающих основных средств" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость выбывающих нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость выбывающих основных средств и нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Среднегодовая стоимость основных средств и нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Ставка налога %" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уменьшению. " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма текущих платежей подлежащих уменьшению по выбывшим основным средствам и нематериальным активам по срокам 20 февраля. 20 мая. 20 августа. 20 ноября. " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > 701.00.014 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.015 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.016 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.017 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.018" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.019 " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > 701.00.020 " "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > " string(v14,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v15,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v14 + v15,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v17,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " 1 "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v17 / 100,"zzz,zzz,zzz,zz9.99")"</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(v17 / 100 / divisor,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "</TR>"  skip.
put unformatted "</TABLE>" skip.


{html-end.i " "}
output close.            

unix silent value("cptwin astnalp.html iexplore").
for each agl:
    delete agl.
end.

pause 0.

end. /*for each arnn.*/
