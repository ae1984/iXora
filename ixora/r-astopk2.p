/* r-astopk2.p
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
        04.05.10 marinav
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

define variable adam1 as dec format "zzzzzz,zzz,zz9.99-".
define variable acam1 as dec format "zzzzzz,zzz,zz9.99-".
define variable adam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable acam3 as dec format "zzzzzz,zzz,zz9.99-".
define variable adam4 as dec format "zzzzzz,zzz,zz9.99-".
define variable acam4 as dec format "zzzzzz,zzz,zz9.99-".
define variable vt as char.
def var v-atrx as char.


if vib=1 then do:
    find txb.ast where txb.ast.ast=v-ast no-lock no-error.
    vt=". Карточка " + v-ast + " " + txb.ast.name .
end.
else if vib=2 then do:
    find txb.fagn where txb.fagn.fag=v-fag no-lock no-error.
    vt=". Группа " + v-fag + " " + txb.fagn.naim.
end.
else if vib=3 then do:
    find txb.gl where txb.gl.gl=v-gl no-lock no-error.
    vt=". Счет  " + string(v-gl) + " " + txb.gl.des.
end.


find first txb.cmp no-lock no-error.
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  txb.cmp.name  "</P>" 
  "<P align=""left"" style=""font:bold;font-size:x-small"">Операции с основными средствами за период с " vmc1 " по " vmc2  "  " vt "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Дата</TD>" skip
        "<TD>Операция</TD>" skip
        "<TD>Nr.карт.</TD>" skip
        "<TD>Дебет</TD>" skip
        "<TD>Кредит</TD>" skip
        "<TD>Кол-во</TD>" skip
        "<TD>Номер <br> операции</TD>" skip
        "<TD>Исполнитель</TD>" skip
        "<TD>Операция</TD>" skip
        "</TR>" skip.


For each txb.astjln where txb.astjln.ajdt ge vmc1 and  txb.astjln.ajdt le vmc2 and  substr(txb.astjln.atrx,1,1) ne "r"  and  
    (if vib=1 then txb.astjln.aast = v-ast 
              else (if vib=2  then txb.astjln.afag = v-fag                       
              else (if vib=3 then txb.astjln.agl = v-gl
              else true))) use-index astdt  no-lock break  by txb.astjln.agl  by substring(txb.astjln.atrx,1,1) by txb.astjln.ajh:

    accumulate txb.astjln.d[1] (total by txb.astjln.agl ). 
    accumulate txb.astjln.c[1] (total by txb.astjln.agl ).
    adam1=adam1 + txb.astjln.d[1].
    acam1=acam1 + txb.astjln.c[1].
    accumulate txb.astjln.d[3] (total by txb.astjln.agl ). 
    accumulate txb.astjln.c[3] (total by txb.astjln.agl ).
    adam3=adam3 + txb.astjln.d[3].
    acam3=acam3 + txb.astjln.c[3].
    accumulate txb.astjln.d[4] (total by txb.astjln.agl ). 
    accumulate txb.astjln.c[4] (total by txb.astjln.agl ).
    adam4=adam4 + txb.astjln.d[4].
    acam4=acam4 + txb.astjln.c[4].

    if txb.astjln.agl=0 then next.
    If first-of(txb.astjln.agl) then do:
           find txb.gl where txb.gl.gl=txb.astjln.agl no-lock.
           put stream m-out unformatted
                     "<TR></TR><TR></TR><TR  style=""font:bold"">" skip
               	       "<TD><b> Счет </TD>" skip
                       "<TD><b>" txb.astjln.agl "</TD>" skip
                       "<TD colspan=2><b>" txb.gl.des "</TD>" skip
                       "<TD></TD><TD></TD><TD></TD><TD></TD><TD></TD>" skip
                     "</TR>" skip.

    end.
    if first-of(substring(txb.astjln.atrx,1,1)) then do: 
       v-atrx=substring(txb.astjln.atrx,1,1).
       find txb.asttr where txb.asttr.asttr=v-atrx no-lock no-error.
       if avail txb.asttr then 
           put stream m-out unformatted
                     "<TR  style=""font:bold"">" skip
                       "<TD colspan=2><b>" txb.asttr.atdes "</TD>" skip
                       "<TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD><TD></TD>" skip
                     "</TR>" skip.
    end.

    if vib = 1 or (substring(txb.astjln.atrx,1,1) ne "9" and vib ne 1) then do:
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>" txb.astjln.ajdt "</TD>" skip
                       "<TD>" txb.astjln.atrx "</TD>" skip
                       "<TD>" txb.astjln.aast format "x(10)" "</TD>" skip
                       "<TD>" replace(trim(string(txb.astjln.d[1]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(txb.astjln.c[1]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" txb.astjln.aqty format "zz9" "</TD>"
                       "<TD>" txb.astjln.ajh  "</TD>"
                       "<TD>" txb.astjln.awho "</TD>"
                       "<TD>" txb.astjln.arem[1] "</TD>" skip
                     "</TR>" skip.
        if txb.astjln.d[3] ne 0 or txb.astjln.c[3] ne 0 then 
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD></TD>" skip
                       "<TD></TD>" skip
                       "<TD></TD>" skip
                       "<TD>" replace(trim(string(txb.astjln.d[3]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(txb.astjln.c[3]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD>"
                       "<TD></TD>"
                       "<TD></TD>"
                       "<TD></TD>" skip
                     "</TR>" skip.
        if txb.astjln.d[4] ne 0 or txb.astjln.c[4] ne 0 then 
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD></TD>" skip
                       "<TD></TD>" skip
                       "<TD></TD>" skip
                       "<TD>" replace(trim(string(txb.astjln.d[4]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(txb.astjln.c[4]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD>"
                       "<TD></TD>"
                       "<TD></TD>"
                       "<TD></TD>" skip
                     "</TR>" skip.

        if txb.astjln.stdt ne ? then 
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>сторнир. </TD>" skip
                       "<TD></TD>" skip
                       "<TD></TD>" skip
                       "<TD></TD>"
                       "<TD></TD>"
                       "<TD>" txb.astjln.stdt "</TD>"
                       "<TD>" txb.astjln.stjh "</TD>"
                       "<TD></TD>"
                       "<TD></TD>" skip
                     "</TR>" skip.
    end.
    if last-of(substring(txb.astjln.atrx,1,1)) then do:
         if adam1 ne 0 or acam1 ne 0 then 
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>Итого </TD>" skip
                       "<TD></TD><TD></TD>" skip
                       "<TD>" replace(trim(string(adam1  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(acam1  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD><TD></TD><TD></TD><TD></TD>" 
                     "</TR>" skip.

         if adam3 ne 0 or acam3 ne 0 then 
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>Итого </TD>" skip
                       "<TD></TD><TD></TD>" skip
                       "<TD>" replace(trim(string(adam3  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(acam3  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD><TD></TD><TD></TD><TD></TD>" 
                     "</TR>" skip.
         if adam4 ne 0 or acam4 ne 0 then
           put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>Итого </TD>" skip
                       "<TD></TD><TD></TD>" skip
                       "<TD>" replace(trim(string(adam4  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD>" replace(trim(string(acam4  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD><TD></TD><TD></TD><TD></TD>" 
                     "</TR>" skip.
         adam1=0. acam1 =0. adam3=0. acam3 =0. adam4=0. acam4 =0. 
    end.

    if last-of(txb.astjln.agl) then do:

           put stream m-out unformatted
                     "<TR  style=""font:bold"">" skip
               	       "<TD><b>Всего  </TD>" skip
                       "<TD><b>" txb.astjln.agl  "</TD><TD></TD>" skip
                       "<TD><b>" replace(trim(string(accum total by txb.astjln.agl txb.astjln.d[1]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD><b>" replace(trim(string(accum total by txb.astjln.agl txb.astjln.c[1]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD><TD></TD><TD></TD><TD></TD>" 
                     "</TR>" skip.

       if txb.astjln.d[3] ne 0 or txb.astjln.c[3] ne 0 then  
           put stream m-out unformatted
                     "<TR  style=""font:bold"">" skip
               	       "<TD></TD>" skip
                       "<TD></TD><TD></TD>" skip
                       "<TD><b>" replace(trim(string(accum total by txb.astjln.agl txb.astjln.d[3]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD><b>" replace(trim(string(accum total by txb.astjln.agl txb.astjln.c[3]  , "->>>>>>>>>>9.99")), ".", ",") "</TD>"
                       "<TD></TD><TD></TD><TD></TD><TD></TD>" 
                     "</TR>" skip.

    end.

end.

put stream m-out unformatted "</table><br><br>" skip.


