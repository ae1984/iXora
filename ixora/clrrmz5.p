/* clrrmz5.p
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
*/

{mainhead.i}
def temp-table brm 
     field  remtrz like  remtrz.remtrz
     field  rbank  like remtrz.rbank
     field  cracc like  remtrz.cracc
     field payment like remtrz.payment
     field jh2 like remtrz.jh2
     field valdt2 like remtrz.valdt2
     field source like remtrz.source.

def var cors like remtrz.cracc init "lat210.ls".
def new shared var s-sta as char.
def new shared var s-ref as char.
def stream m-out.
def var s-remtrz like remtrz.remtrz.
def var i as int initial 0.
def var v-ans as log initial no.
def var protfile as char format "x(30)".
def var errfile as char format "x(30)".
def var vpath as char format "x(30)".
def var vunique as char format "x(30)".
def var vmenu as char extent 3.
def var totbank like rem.payment.
def var utime as char format "x(8)".
def var over as char format "x(3)".
def var s-aaa like aaa.aaa.
def var v-dat as date.
def var intv like sysc.inval.

find sysc where sysc.sysc = 'PRTDIR' no-lock no-error.
if available sysc then vpath = sysc.chval.

find sysc where sysc.sysc =  'pspygl' no-lock no-error.
if avail sysc then intv = sysc.inval.

utime = string(time,"hh:mm:ss").

i = 0.
{imag.f}

v-dat = g-today.
update v-dat cors with  frame dnk.

{rmzauto2.f}
{mesg.i 881} update v-ans.
if v-ans then do:
utime = string(time,"hh:mm:ss").
/*vunique = string(day(today),"99") + string(month(today),"99")
                                 + string(year(today) - 1900,"99")
                                 + "_" + utime.

protfile = trim(vpath) + "rmoautoprot_" + trim(vunique).
  */

for  each  jl where jl.gl  = intv and jl.jdt  = v-dat and
 jl.dam > 0 and  jl.rem[1] begins "rmz" use-index jdt no-lock.
  s-remtrz = substr(jl.rem[1],1,10).

find remtrz  where   remtrz.remtrz  = s-remtrz no-lock no-error.
 if avail remtrz and (cors = "ALL" or remtrz.cracc  = cors) then do:
      find first clrdoc  where clrdoc.rdt = v-dat
      and clrdoc.rem  eq remtrz.remtrz 
      use-index rem no-lock no-error.
  if not avail clrdoc then do:
     find last  brm where  brm.remtrz =  remtrz.remtrz no-error.
      if  avail brm then next.
      if remtrz.cover eq 4 then next.
   /*   else do: */
   create  brm.
   brm.remtrz = remtrz.remtrz.
   brm.rbank  = remtrz.rbank.
   brm.cracc  = remtrz.cracc.
   brm.payment = remtrz.payment.
   brm.jh2     = remtrz.jh2.
   brm.valdt2  = remtrz.valdt2.
   brm.source = remtrz.source.
     /* end. */
  end. 
  end.
 end.

output  to rpt.img.

{autormz2.f}


for each brm 
no-lock break by brm.cracc by brm.rbank :

 i = i + 1.
        totbank = totbank + brm.payment.
   put  brm.remtrz ' ' brm.rbank ' ' brm.cracc ' '
                        brm.payment ' ' brm.valdt2 ' ' 
                        brm.jh2    
                          '  ' brm.source skip.
                        over = "".

   if last-of(brm.rbank) then do:
       put  
         fill("-",80) format "x(80)" skip
         totbank at 34 skip(1).
         totbank = 0.
    end.
    s-remtrz =  brm.remtrz.
end. /*for each brm*/
    
    put  "                 Обработано    "  i  skip (1).

    put   fill("=",80) format "x(80)" skip(5).
    output  close.
    unix silent value(dest) rpt.img.
end. /* v-ans  = true */


