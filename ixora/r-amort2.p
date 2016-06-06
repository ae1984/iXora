/* r-amort2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        ОБОРОТЫ ПО AМОРТИЗАЦИИ ОСНОВНЫХ СРЕДСТВ
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
        07.05.10 marinav
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
define variable aamor like txb.astjln.cam.
define variable vfagn like txb.fagn.naim.
define variable vgln like txb.gl.des.
define variable v-gl3 like txb.trxlevgl.glr.

 def temp-table atldk field ast like txb.ast.ast
                      field fag like txb.ast.fag
                      field gl  like txb.ast.gl
                      field dam like txb.astjln.dam format "zzzzzz,zzz,zz9.99-"
                      field cam like txb.astjln.cam format "zzzzzz,zzz,zz9.99-"
                      field amort like txb.astjln.cam format "zzzzzz,zzz,zz9.99-"
                      field satl like txb.astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field batl like txb.astatl.atl format "zzzzzz,zzz,zz9.99-"
                      field sdata like txb.astatl.dt 
                      field bdata like txb.astatl.dt.

find first txb.cmp no-lock no-error.
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  txb.cmp.name  "</P>" 
  "<P align=""left"" style=""font:bold;font-size:x-small"">Обороты по износу основных средств за период  с " vmc1  " по " vmc2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

     For each txb.ast where txb.ast.dam[1] - txb.ast.cam[1] >  txb.ast.cam[3] - txb.ast.dam[3] and  
         (if vib=1 then txb.ast.ast = v-ast 
                   else (if vib=2  then txb.ast.fag = v-fag                       
                   else (if vib=3  then txb.ast.gl = v-gl
                   else true )))
        and (year(txb.ast.ldd) = year(vmc2) and month(txb.ast.ldd) < month(vmc2) or year(txb.ast.ldd) - year(vmc2) < 0) no-lock:

        put stream m-out unformatted
        "<TR align=""center"" >" skip
        "<TD colspan=6>" txb.ast.ast " за " string(month(vmc2)) + "/" + string(year(vmc2)) " не начислена амортизация,посл.дата.расчета " txb.ast.ldd " </TD>" skip
        "</TR>" skip.
     end. 


For each txb.ast where (if vib=1 then txb.ast.ast = v-ast 
              else (if vib=2 then txb.ast.fag = v-fag                       
              else (if vib=3 then txb.ast.gl  = v-gl
              else true))) no-lock break  by txb.ast.gl by txb.ast.fag by txb.ast.ast: 

  Find last txb.astatl where txb.astatl.ast =txb.ast.ast  and txb.astatl.dt < vmc1  use-index astdt no-lock no-error.
  if available txb.astatl then do:
    create atldk.
    atldk.ast = txb.astatl.ast.
    atldk.fag = txb.astatl.fag.
    atldk.gl   = txb.astatl.agl.
    atldk.satl = txb.astatl.nol.
    atldk.sdata = vmc1. 
  end.

  Find last txb.astatl where txb.astatl.ast = txb.ast.ast and txb.astatl.dt <= vmc2  use-index astdt no-lock no-error.
   if available txb.astatl then do:
      find first atldk where atldk.ast = txb.astatl.ast and atldk.fag= txb.astatl.fag
                              and atldk.gl= txb.astatl.agl no-error.
      if not available atldk then do: 
        create atldk.
        atldk.ast = txb.astatl.ast.
        atldk.fag = txb.astatl.fag.
      end.

       atldk.gl  = txb.astatl.agl. 
       atldk.batl = txb.astatl.nol.
       atldk.bdata = vmc2. 
    end.
end. /* For each astatl*/  
 
For each txb.astjln where txb.astjln.ajdt >= vmc1 and  txb.astjln.ajdt <= vmc2 and  substr(txb.astjln.atrx,1,1) ne "r"  and  
    (if vib=1 then txb.astjln.aast = v-ast 
              else (if vib=2  then txb.astjln.afag = v-fag                       
              else (if vib=3 then txb.astjln.agl = v-gl
              else true))) use-index astdt break  by txb.astjln.agl by txb.astjln.afag by txb.astjln.aast: 

     adam= adam + txb.astjln.d[3].
     acam= acam + txb.astjln.c[3].

 if substring(txb.astjln.apriz,1,1)="A" then aamor=aamor + txb.astjln.c[3] - txb.astjln.d[3].
         
 if last-of(txb.astjln.aast) then do:
   
   Find first atldk where atldk.ast =txb.astjln.aast and atldk.fag=txb.astjln.afag and
                          atldk.gl  =txb.astjln.agl  no-error.
   if not available atldk then do:
       create atldk.
       atldk.ast = txb.astjln.aast.
       atldk.fag = txb.astjln.afag.
       atldk.gl = txb.astjln.agl.
   end.   
   atldk.amort=aamor.
   atldk.dam = adam.
   atldk.cam = acam.

  aamor=0. adam=0. acam=0.
 
 end.
end.


put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Nr.карт.</TD>" skip
        "<TD>Амортизация <br>на начало</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>В том числе <br>расчит.амортиз</TD>" skip
        "<TD>Амортизация <br>на конец</TD>" skip
        "<TD>Название</TD>" skip
        "</TR>" skip.

For each atldk break by atldk.gl by atldk.fag by atldk.ast :
  
    accumulate atldk.satl (total by atldk.gl by atldk.fag by atldk.ast). 
    accumulate atldk.dam  (total by atldk.gl by atldk.fag by atldk.ast).
    accumulate atldk.cam  (total by atldk.gl by atldk.fag by atldk.ast).
    accumulate atldk.amort(total by atldk.gl by atldk.fag by atldk.ast).
    accumulate atldk.batl (total by atldk.gl by atldk.fag by atldk.ast).
   
   if first-of(atldk.fag) and vibk=1 then
       put stream m-out unformatted
       "<TR></TR><TR align=""left"" style=""font:bold"">" skip
        "<TD colspamn=2> Счет  " atldk.gl  " группа " atldk.fag "</TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "<TD></TD>" skip
        "</TR>" skip.

   if vibk=1  and last-of(atldk.ast) then do: 
       find txb.ast where txb.ast.ast = atldk.ast no-lock no-error. 
    
       put stream m-out unformatted
       "<TR align=""right"" >" skip
        "<TD align=""left"">" atldk.ast "</TD>" skip
        "<TD>" replace(trim(string(atldk.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(atldk.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(atldk.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(atldk.amort , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(atldk.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""left"">" txb.ast.name   format "x(30)" "</TD>" skip
        "</TR>" skip.
   end. 

  if vib > 1 and vibk < 3 and last-of(atldk.fag) then do:
      find txb.fagn  where txb.fagn.fag = atldk.fag no-lock no-error. 
      if available txb.fagn then vfagn = txb.fagn.naim. else vfagn = " ".    
                                         
       put stream m-out unformatted
       "<TR align=""right""  style=""font:bold"">" skip
        "<TD align=""left"">Итого Груп. " atldk.fag "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.fag atldk.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.fag atldk.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.fag atldk.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.fag atldk.amort , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.fag atldk.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""left"">" vfagn  format "x(30)" "</TD>" skip
        "</TR>" skip.
  end.


  if vib > 2 and last-of(atldk.gl) then do:
     find first txb.trxlevgl where txb.trxlevgl.gl = atldk.gl and txb.trxlevgl.lev = 3 no-lock no-error.
     if available txb.trxlevgl then v-gl3 = txb.trxlevgl.glr. else v-gl3=?.   
     find txb.gl where txb.gl.gl = v-gl3 no-lock no-error. 
     if available txb.gl then vgln = txb.gl.des. else vgln = " ".  
     
       put stream m-out unformatted
       "<TR align=""right""  style=""font:bold"">" skip
        "<TD align=""left"">Итого Счет  " v-gl3 "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.gl atldk.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.gl atldk.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.gl atldk.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.gl atldk.amort , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total by atldk.gl atldk.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD align=""left"">" vgln  format "x(30)" "</TD>" skip
        "</TR><TR></TR>" skip.
   end.
end.


 if  vib = 4 then do:
       put stream m-out unformatted
       "<TR align=""center""  style=""font:bold"">" skip
        "<TD>ВСЕГО</TD>" skip
        "<TD>" replace(trim(string(accum total atldk.satl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total atldk.dam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total atldk.cam , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total atldk.amort , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD>" replace(trim(string(accum total atldk.batl , "->>>>>>>>>>9.99")), ".", ",") "</TD>" skip
        "<TD></TD>" skip
        "</TR><TR></TR>" skip.
 end.

