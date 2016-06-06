/* help-joudoc2.p
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
        14.04.2004 dpuchkov добавил возможность отображения проводок за "пятницу"
        17.04.2004 dpuchkov перекомпиляция
*/

/**** help-crc1.p ****/

def var vtype as char.
def var vtim1 as char.
def var vtim2 as char.
def var vsts as inte.
def var dcrccode as char format "x(3)".
def var ccrccode as char format "x(3)".
def buffer bofc for ofc.
def buffer bjl for jl.

def var vfrdate as date.

def var v-cash1 as log init false.
{global.i}

def buffer bjl2 for jl.
define temp-table jouhelp like joudoc
   index wt whn tim descending.

/* Возможность отображения проводок за пятницу */
  vfrdate = g-today.
  find last cls no-lock no-error.
  if available cls then 
    if g-today - cls.whn > 1 then vfrdate = cls.whn.
     

for each bofc where bofc.tit matches '*'+ g-ofc +  '*'  break by ofc:



   for each jl where jl.jdt = g-today and
     jl.who matches bofc.ofc and dc = 'd' and  
      jl.sts = 5 no-lock break by jh :
   for each bjl where bjl.jh = jl.jh no-lock : 
    if bjl.gl = 100100 then v-cash1 = true.
   end.


    if first-of(jh) and not v-cash1 then do:
    find jh where jh.jh = jl.jh no-lock no-error.
    if /* jh.sub eq 'ujo' or jh.sub eq 'jou') or*/ jh.sub <> 'rmz' then do:
     create jouhelp.
    if jh.sub = 'jou' then do:
      find joudoc where joudoc.docnum = jh.ref use-index joudoc no-error.
      buffer-copy joudoc to jouhelp.
    end.
    else do:
     jouhelp.docnum = jh.ref. jouhelp.who = jh.who. 
     jouhelp.jh = jh.jh.
     jouhelp.dramt = jl.dam. jouhelp.whn = jl.jdt.
     jouhelp.drcur  = jl.crc.
     jouhelp.dracctype = '1'. jouhelp.dracc = jl.acc.
     find bjl2  where bjl2.jh = jl.jh and bjl2.dc = 'c' no-lock no-error. 
     if available bjl2 then  
     do:
        if bjl2.acc <> "" then  jouhelp.cracc = bjl2.acc. 
        else jouhelp.cracc  = STRING(bjl2.gl). jouhelp.cramt = bjl2.cam.
     end.
   end.
  end. /*if sub*/
 end. /*first-of(jh)*/
      v-cash1 = false.
end. /*jl*/ 

if vfrdate <> g-today then
   for each jl where jl.jdt = vfrdate and
     jl.who matches bofc.ofc and dc = 'd' and  
      jl.sts = 5 no-lock break by jh :
   for each bjl where bjl.jh = jl.jh no-lock : 
    if bjl.gl = 100100 then v-cash1 = true.
   end.


    if first-of(jh) and not v-cash1 then do:
    find jh where jh.jh = jl.jh no-lock no-error.
    if /* jh.sub eq 'ujo' or jh.sub eq 'jou') or*/ jh.sub <> 'rmz' then do:
     create jouhelp.
    if jh.sub = 'jou' then do:
      find joudoc where joudoc.docnum = jh.ref use-index joudoc no-error.
      buffer-copy joudoc to jouhelp.
    end.
    else do:
     jouhelp.docnum = jh.ref. jouhelp.who = jh.who. 
     jouhelp.jh = jh.jh.
     jouhelp.dramt = jl.dam. jouhelp.whn = jl.jdt.
     jouhelp.drcur  = jl.crc.
     jouhelp.dracctype = '1'. jouhelp.dracc = jl.acc.
     find bjl2  where bjl2.jh = jl.jh and bjl2.dc = 'c' no-lock no-error. 
     if available bjl2 then  
     do:
        if bjl2.acc <> "" then  jouhelp.cracc = bjl2.acc. 
        else jouhelp.cracc  = STRING(bjl2.gl). jouhelp.cramt = bjl2.cam.
     end.
   end.
  end. /*if sub*/
 end. /*first-of(jh)*/
      v-cash1 = false.
end. /*jl*/ 








end.  /*bofc*/
/*for each jouhelp. displ jouhelp.docnum jouhelp.who. end. pause. return.*/
                            

{jabrw.i

&start     = "view frame joudoc1."
&head      = "jouhelp"  
&index     = "wt"
&formname  = "jouhelp2"
&framename = "jouhelp" 
&where     = "jouhelp.whn = g-today or jouhelp.whn = vfrdate " 

&addcon    = "false"
&deletecon = "false"
&precreate = " "
&prechoose = " dcrccode = "". ccrccode = "". 
               find crc where crc.crc = jouhelp.drcur no-lock no-error.
               if available crc then dcrccode = crc.code.
               find crc where crc.crc = jouhelp.crcur no-lock no-error.
               if available crc then ccrccode = crc.code.
               disp jouhelp.dracctype jouhelp.cracctype with frame jouhelp1.
               disp jouhelp.dracc jouhelp.dramt dcrccode 
                    jouhelp.cracc jouhelp.cramt ccrccode 
               with frame jouhelp1." 

&predisplay = "vtim1 = ''. vtim2 = ''.
               find first jl where jl.jh = jouhelp.jh no-lock no-error.
               if not available jl then vsts = 0.
               else do:
                 find jh where jh.jh = jouhelp.jh no-lock no-error.
                 vtim2 = string(jh.tim,'HH:MM:SS').
                 vsts = jl.sts.
               end.
               vtim1 = string(jouhelp.tim,'HH:MM:SS').
               /*if substr(jouhelp.docnum,1,3) = 'jou' then do: */
               if jouhelp.dramt ne 0 then p-amt = jouhelp.dramt . 
               else  p-amt = 55.0 . 
              /* end.   else p-amt = 55.0.*/ "

&display   = "jouhelp.docnum jouhelp.who  jouhelp.jh vsts vtim2  
              p-amt format 'zz,zzz,zzz,zz9.99-' " 

&highlight = "jouhelp.docnum  jouhelp.who /*vtim1*/ jouhelp.jh vsts vtim2  
              p-amt format 'zz,zzz,zzz,zz9.99-'  /*jouhelp.cramt jouhelp.comamt*/"
&postadd   = " "
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do 
                    on endkey undo, leave:
                    frame-value = jouhelp.docnum.
                    hide frame jouhelp.
                    hide frame jouhelp1. 
                    return.
              end."        
&end = "hide frame jouhelp."
}

