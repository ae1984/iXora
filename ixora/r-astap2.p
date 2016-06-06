/* r-astap2.p
 * MODULE
        Основные средства
 * DESCRIPTION
        Отчет - Обороты основных средств
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
	
 * MENU
        8-1-4-"
 * BASES
        BANK TXB
 * AUTHOR
        27/04/10 marinav
 * CHANGES
*/


define shared var g-today  as date.
def shared stream m-out.
def input parameter vmc1 as date  .
def input parameter vmc2 as date  .
def input parameter v-fag like txb.ast.fag .
def input parameter v-gl like txb.ast.gl.
def input parameter v-ast like txb.ast.ast.
def input parameter vib as integer format "9" .
def input parameter vibk as integer format "9" .

define variable adam like txb.astjln.dam.
define variable acam like txb.astjln.cam.
define variable vfagn like txb.fagn.naim.
define variable vgln like txb.gl.des.

 def temp-table   a   field ast like txb.ast.ast 
                      field fag like txb.ast.fag
                      field gl  like txb.ast.gl
                      field dam like txb.astjln.dam format "zzzzzz,zzz,zz9.99-"
                      field cam like txb.astjln.cam format "zzzzzz,zzz,zz9.99-"
                      field satl like txb.astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field batl like txb.astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field sdata like txb.astatl.dt
                      field bdata like txb.astatl.dt
                      field pkop like txb.fagn.pkop
                      index ast is primary gl fag ast.  

For each txb.ast where (if vib=1 then txb.ast.ast = v-ast 
              else (if vib=2 then txb.ast.fag = v-fag                       
              else (if vib=3 then txb.ast.gl  = v-gl
              else true))) no-lock: 
              
   if vmc2 < g-today then do:   
     Find last txb.astatl where txb.astatl.ast =txb.ast.ast and txb.astatl.dt <= vmc2 use-index astdt no-lock no-error.
      if available txb.astatl then do:
       create a.
       a.ast = txb.astatl.ast.
       a.fag = txb.astatl.fag.
       find txb.fagn where txb.fagn.fag=txb.astatl.fag no-lock no-error.
       if avail txb.fagn then a.pkop = txb.fagn.pkop.
       a.gl = txb.astatl.agl.
       a.batl = txb.astatl.icost.
      end.
   end.
   else do:  /* vmc2=g-today */
     if txb.ast.dam[1] - txb.ast.cam[1] <>0 then do:
       create a.
       a.ast = txb.ast.ast.
       a.fag = txb.ast.fag.
       find txb.fagn where txb.fagn.fag=txb.ast.fag no-lock no-error.
       if avail txb.fagn then a.pkop = txb.fagn.pkop.
       a.gl = txb.ast.gl.
       a.batl = txb.ast.dam[1] - txb.ast.cam[1].
     end.
   end.
end.   
For each txb.astjln where txb.astjln.ajdt >= vmc1   and  txb.astjln.ajdt <= vmc2  and 
    txb.astjln.atrx ne "0" and substr(txb.astjln.atrx,1,1) ne "r"  and 
    (if vib=1 then txb.astjln.aast = v-ast 
              else (if vib=2  then txb.astjln.afag = v-fag                       
              else (if vib=3 then txb.astjln.agl = v-gl
              else true))) use-index dtajh break by txb.astjln.agl  by txb.astjln.afag  by txb.astjln.aast: 
             
 adam= adam + txb.astjln.d[1].
 acam= acam + txb.astjln.c[1].
 if last-of(txb.astjln.aast) then do:
   
   Find first a where a.ast =txb.astjln.aast and a.fag=txb.astjln.afag and a.gl  =txb.astjln.agl no-error.
   if not available a then do:
       create a.
       a.ast = txb.astjln.aast.
       a.fag = txb.astjln.afag.
       find txb.fagn where txb.fagn.fag=txb.astjln.afag no-lock no-error.
       if avail txb.fagn then a.pkop = txb.fagn.pkop.
       a.gl = txb.astjln.agl.
       a.batl = 0.
   end.   
   a.dam = adam.
   a.cam = acam.
   adam=0. acam=0.
 end. 
end.
For each a:
   a.satl = a.batl - a.dam + a.cam.
   if a.satl=0 and a.batl=0 and a.dam=0 and a.cam=0 then delete a.
end.

find first a where true no-lock no-error.
if not avail a then do: Message "ОТЧЕТ ПУСТОЙ ". pause 10. return. end. 

find first txb.cmp no-lock no-error.
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  txb.cmp.name  "</P>" 
  "<P align=""left"" style=""font:bold;font-size:x-small"">Обороты основных средств с " vmc1 " по " vmc2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Nr.карт.</TD>" skip
        "<TD>Остаток <br>на начало</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>Остаток <br>на конец</TD>" skip
        "<TD>Название</TD>" skip
        "</TR>" skip.


 For each a break by a.pkop by a.gl by a.fag by a.ast :
  
 accumulate a.satl (total by a.pkop by a.gl by a.fag by a.ast). 
 accumulate a.dam  (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.cam  (total by a.pkop by a.gl by a.fag by a.ast).
 accumulate a.batl (total by a.pkop by a.gl by a.fag by a.ast).
   
if first-of(a.fag) and vibk=1 then
        put stream m-out unformatted
                     "<TR></TR><TR  style=""font:bold"">" skip
               	       "<TD> Счет </TD>" skip
                       "<TD>" a.gl "</TD>" skip
                       "<TD> группа </TD>" skip
                       "<TD>" a.fag "</TD>" skip
                       "<TD></TD><TD></TD>" skip
                     "</TR>" skip.

 if vibk=1 and last-of(a.ast) then do: 
    find  txb.ast where txb.ast.ast = a.ast no-lock no-error. 
    
        put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>" a.ast "</TD>" skip
                       "<TD>" replace(trim(string(a.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(a.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(a.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(a.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" txb.ast.name "</TD>" skip
                     "</TR>" skip.
 end. 

 if vib > 1 and vibk < 3 and last-of(a.fag) then do:
     find fagn  where txb.fagn.fag = a.fag no-lock no-error. 
      if available txb.fagn then vfagn = txb.fagn.naim. else vfagn = " ".    

        put stream m-out unformatted
                     "<TR  style=""font:bold"">" skip
               	       "<TD>Группа " a.fag "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.fag a.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.fag a.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.fag a.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.fag a.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" vfagn "</TD>" skip
                     "</TR>" skip.
     
 end.

 if vib > 2 and last-of(a.gl) then do:
     find txb.gl  where txb.gl.gl = a.gl no-lock. 
       vgln = txb.gl.des. 

        put stream m-out unformatted
                     "<TR style=""font:bold"">" skip
               	       "<TD>Счет " a.gl "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.gl a.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.gl a.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.gl a.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.gl a.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" vgln "</TD>" skip
                     "</TR>" skip.
   
 end.
 if last-of(a.pkop) then do: 
        put stream m-out unformatted
                     "<TR style=""font:bold"">" skip
               	       "<TD>ВСЕГО</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.pkop a.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.pkop a.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.pkop a.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD>" replace(trim(string(accum total by a.pkop a.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
                       "<TD></TD>" skip
                     "</TR>" skip.
 end.
end.

put stream m-out unformatted "</table><br><br>" skip.


