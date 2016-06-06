/* r-ast442.p
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
        BANK TXB
 * AUTHOR
        11.05.10  marinav
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
def input parameter vop as log .

define variable am8 like txb.astjln.dam.
define variable am10 like txb.astjln.cam.
define variable s31 like txb.astjln.cam.
define variable s33 like txb.astjln.cam.
define variable s38 like txb.astjln.cam.
define variable s425 like txb.astjln.cam.
define variable s54 like txb.astjln.cam.
define variable s56 like txb.astjln.cam.
define variable s57 like txb.astjln.cam.
define variable am9 like txb.astjln.cam.
define variable vfagn like txb.fagn.naim.
define variable vgln like txb.gl.des.

 def temp-table    a  field ast like txb.ast.ast
                      field fag like txb.ast.fag
                      field gl  like txb.ast.gl
                      field dat as date
                      field ss like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field s33 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s31 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s38 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s425 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s57 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s56 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field s54 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field sb like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ns like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field nb like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field ass like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field ab like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am8 like txb.astatl.atl format "zzz,zzz,zz9.99-" init 0
                      field am10 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9 like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field am9p like txb.astatl.atl format "zzz,zzz,zz9.99-" 
                      field rem as char 
                      field pkop like txb.fagn.pkop
                      index ast is primary gl fag ast.
                      

For each txb.ast where (if vib=1 then txb.ast.ast = v-ast 
              else (if vib=2 then txb.ast.fag = v-fag                       
              else (if vib=3 then txb.ast.gl  = v-gl
              else true))) no-lock:

 if vmc2 < g-today then do:   
   Find last txb.astatl where txb.astatl.ast =txb.ast.ast and txb.astatl.dt < vmc2 + 1  use-index astdt no-lock no-error.
   if available txb.astatl then do:
       create a.
       a.ast = txb.astatl.ast.
       a.fag = txb.astatl.fag.
       find txb.fagn where txb.fagn.fag=txb.astatl.fag no-lock no-error.
       if avail txb.fagn then a.pkop = txb.fagn.pkop.
       a.gl = txb.astatl.agl.
       a.ab = txb.astatl.atl.
       a.sb = txb.astatl.icost.
       a.nb = txb.astatl.nol.
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
       a.sb = txb.ast.dam[1] - txb.ast.cam[1].
       a.nb = txb.ast.cam[3] - txb.ast.dam[3].
       a.ab = a.sb - a.nb.
     end. 
   end.

  Find last txb.astatl where txb.astatl.ast =txb.ast.ast  and txb.astatl.dt < vmc1
                use-index astdt no-lock no-error.
  if available txb.astatl then do:
      find first a where a.ast = txb.astatl.ast and a.fag= txb.astatl.fag
                          and a.gl= txb.astatl.agl use-index ast no-error.
      if not available a then do: 
        create a.
        a.ast = txb.astatl.ast.
        a.fag = txb.astatl.fag.
        a.gl = txb.astatl.agl.
        find txb.fagn where txb.fagn.fag=txb.ast.fag no-lock no-error.
        if avail txb.fagn then a.pkop = txb.fagn.pkop.
       end.
      a.ass = txb.astatl.atl.
      a.ss = txb.astatl.icost.
      a.ns = txb.astatl.nol.
  end.

end.   

For each txb.astjln where txb.astjln.ajdt > vmc1 - 1 and  txb.astjln.ajdt < vmc2 + 1 and  substr(txb.astjln.atrx,1,1) ne "r"  and   
      (if vib=1 then txb.astjln.aast = v-ast 
              else (if vib=2  then txb.astjln.afag = v-fag                       
              else (if vib=3 then txb.astjln.agl = v-gl
              else true))) use-index astdt no-lock  break by txb.astjln.agl by txb.astjln.afag  by txb.astjln.aast:   

  if txb.astjln.atrx eq "0" then next.

  if substring(txb.astjln.atrx,1,1)="9" then am8=am8 + txb.astjln.c[3] - txb.astjln.d[3].
  else do:
         create a.
          a.dat= txb.astjln.ajdt.
          a.ast = txb.astjln.aast.
          a.fag = txb.astjln.afag.
          find txb.fagn where txb.fagn.fag=txb.astjln.afag no-lock no-error.
          if avail txb.fagn then a.pkop = txb.fagn.pkop.
          a.gl = txb.astjln.agl.
          a.rem= txb.astjln.arem[1].
         if substring(txb.astjln.atrx,1,1)="1" then do:
             a.s31=txb.astjln.d[1] - txb.astjln.c[1].
             a.am9=txb.astjln.c[3] - txb.astjln.d[3].
         end.
         else
         if substring(txb.astjln.atrx,1,1)="2" or substring(txb.astjln.atrx,1,1)="5" or substring(txb.astjln.atrx,1,1)="3" or substring(txb.astjln.atrx,1,1)="8" 
                                           or substring(txb.astjln.atrx,1,1)="4" or substring(txb.astjln.atrx,1,1)="7" then do:
             a.s57=txb.astjln.d[1] - txb.astjln.c[1].
             a.am9=txb.astjln.c[3] - txb.astjln.d[3].
         end.
         if substring(txb.astjln.atrx,1,1)="p" then do:
             a.s38  =txb.astjln.d[1] - txb.astjln.c[1].
             a.am9p =txb.astjln.c[3] - txb.astjln.d[3].
         end.
         else
         if substring(txb.astjln.atrx,1,1)="6" then do:
             a.s56  =txb.astjln.c[1] - txb.astjln.d[1].
             a.am10 =txb.astjln.d[3] - txb.astjln.c[3].
         end.
 end.

   if last-of(txb.astjln.aast) then do:
   
      Find first a where a.ast =txb.astjln.aast and a.fag=txb.astjln.afag and  a.gl  =txb.astjln.agl and a.dat=? use-index ast no-error .
      if not available a then do:
          create a.
          a.ast = txb.astjln.aast.
          a.fag = txb.astjln.afag.
          find txb.fagn where txb.fagn.fag=txb.astjln.afag no-lock no-error.
          if avail txb.fagn then a.pkop = txb.fagn.pkop.
          a.gl = txb.astjln.agl.
          a.ab = 0.
          a.sb = 0.
          a.nb = 0.
      end.   
      a.am8 =am8.
      am8=0. 
   end. 
end.

for each a where a.dat = ?:
   if a.ss=0 and a.ns=0 and a.ass=0 and a.s31=0 and a.s56=0 and a.s33=0 and
      a.s57=0 and a.s54=0 and a.s38=0 and a.s425=0 and a.am9=0 and a.am10=0 and
      a.am8=0 and a.sb=0 and a.nb=0 and a.ab=0 then delete a.
end.

find first txb.cmp no-lock no-error.
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  txb.cmp.name  "</P>" 
  "<P align=""left"" style=""font:bold;font-size:x-small"">ОТЧЕТ О ДВИЖЕНИИ ОСНОВНЫХ СРЕДСТВ  за период с " vmc1 " по " vmc2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Nr.карт.</TD>" skip
        "<TD colspan=6>Балансовая  стоимость</TD>" skip
        "<TD colspan=5>Амортизация </TD>" skip
        "<TD colspan=2>Остаточная стоимость</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.
put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>группа<br>счет</TD>" skip
        "<TD>" vmc1 "</TD>" skip
        "<TD>Приход<br> (1) </TD>" skip
        "<TD>Переоценка<br>(p) +/-</TD>" skip
        "<TD>Корректировка<br> +/- </TD>" skip
        "<TD>Выбытие<br> (6) - </TD>" skip
        "<TD>" vmc2 "</TD>" skip
        "<TD>" vmc1 "</TD>" skip
        "<TD>Начисленная <br> + </TD>" skip
        "<TD>Корректировка<br> +/- </TD>" skip
        "<TD>Выбытие <br> -</TD>" skip
        "<TD>" vmc2 "</TD>" skip
        "<TD>" vmc1 "</TD>" skip
        "<TD>" vmc2 "</TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.

 
 For each a break by a.pkop by a.gl by a.fag by a.ast :
  
     accumulate a.ss   (total by a.pkop by a.gl by a.fag by a.ast). 
     accumulate a.sb   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.ns   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.nb   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.ass   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.ab   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.am8   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.am9   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.am9p   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.am10   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s31   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s33   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s38   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s425   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s54   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s56   (total by a.pkop by a.gl by a.fag by a.ast).
     accumulate a.s57   (total by a.pkop by a.gl by a.fag by a.ast).
 
      if vop=true and a.dat ne ? then do:
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD>" a.ast "</TD>" skip
               "<TD>" a.dat "</TD>" skip
               "<TD>" replace(trim(string(a.s31 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(a.s38 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(a.s57 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(a.s56 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD></TD><TD></TD><TD></TD>" skip
               "<TD>" replace(trim(string(a.am9 + a.am9p , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(a.am10 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD colspan=4 align=""left"">" a.rem "</TD>"
               "</TR>" skip.    
      end.

     if vibk=1 and last-of(a.ast) then do: 
        
        find txb.ast where txb.ast.ast = a.ast no-lock no-error. 
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD>" a.ast "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.ss , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.s31 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.s38 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.s57 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.s56 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.sb , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.ns , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.am8 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.ast a.am9 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.ast a.am10 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.ast a.nb , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.ast a.ass , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.ast a.ab , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD align=""left"">" txb.ast.name "</TD>"
               "</TR>" skip.    

        if (accum total by a.ast a.am9p) <> 0 then 
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>"
               "<TD>" replace(trim(string(accum total by a.ast a.am9p , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>(переоц.)</TD>"
               "<TD></TD>"
               "<TD></TD>"
               "<TD></TD>"
               "</TR>" skip.    
     end. 

     if vib > 1 and vibk < 3 and last-of(a.fag) then do:
         find txb.fagn  where txb.fagn.fag = a.fag no-lock no-error. 
          if available txb.fagn then vfagn = txb.fagn.naim. else vfagn = " ".    
        
         if vibk=1 then PUT skip(1) "Гр.  ". else Put "Гр.  ".
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD>Гр." a.fag "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.ss , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.s31 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.s38 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.s57 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.s56 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.sb , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.ns , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.am8 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.fag a.am9 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.fag a.am10 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.fag a.nb , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.fag a.ass , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.fag a.ab , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD align=""left"">" vfagn "</TD>"
               "</TR>" skip.    

          if (accum total by a.fag a.am9p) <>0 then 
              put stream m-out unformatted
              "<TR align=""right"" >" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>"
               "<TD>" replace(trim(string(accum total by a.fag a.am9p , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>(переоц.)</TD>"
               "<TD></TD>"
               "<TD></TD>"
               "<TD></TD>"
               "</TR>" skip.    

     end.

     if vib > 2 and last-of(a.gl) then do:
         find txb.gl  where txb.gl.gl = a.gl no-lock. 
           vgln = txb.gl.des. 

              put stream m-out unformatted
              "<TR align=""right"" style=""font:bold"">" skip
               "<TD>" a.gl "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.ss , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.s31 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.s38 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.s57 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.s56 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.sb , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.ns , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.am8 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.gl a.am9 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.gl a.am10 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.gl a.nb , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.gl a.ass , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.gl a.ab , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD align=""left"">" vgln "</TD>"
               "</TR>" skip.    

       if (accum total by a.gl a.am9p) <>0 then 
              put stream m-out unformatted
              "<TR align=""right"" style=""font:bold"" >" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>"
               "<TD>" replace(trim(string(accum total by a.gl a.am9p , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>(переоц.)</TD>"
               "<TD></TD>"
               "<TD></TD>"
               "<TD></TD>"
               "</TR>" skip.    
             put stream m-out unformatted "<TR></TR>" skip.

     end.

     if last-of(a.pkop) then do: 

              put stream m-out unformatted
              "<TR align=""right"" style=""font:bold"" >" skip
               "<TD> ВСЕГО: </TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.ss , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.s31 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.s38 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.s57 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.s56 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.sb , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.ns , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.am8 , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
               "<TD>" replace(trim(string(accum total by a.pkop a.am9 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.pkop a.am10 , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.pkop a.nb , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.pkop a.ass , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>" replace(trim(string(accum total by a.pkop a.ab , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD></TD>"
               "</TR>" skip.    
       if (accum total by a.pkop a.am9p) <>0 then 
              put stream m-out unformatted
              "<TR align=""right"" style=""font:bold"">" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>" skip
               "<TD></TD>"
               "<TD>" replace(trim(string(accum total by a.pkop a.am9p , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
               "<TD>(переоц.)</TD>"
               "<TD></TD>"
               "<TD></TD>"
               "<TD></TD>"
               "</TR>" skip.    
     end.
end.

put stream m-out unformatted "</table><br><br>" skip.

