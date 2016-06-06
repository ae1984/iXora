/* trxlevgl.p
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

def shared var g-lang as char.
def var vglr as inte.
def var vglr0 as inte.
def shared var vgl as inte.
def shared var vsub as char.
def var yn as log init false . 
find gl where gl.gl = vgl no-lock no-error.
if not available gl then do:
  bell. bell. bell.
  return.
end.
if gl.level > 1 or gl.sub = '' then do:
  find  first  trxlevgl  where trxlevgl.gl = vgl no-error . 
  if avail trxlevgl then do:
  yn = false . 
  Message 
"Некорректные настройки уровней ! Корректировать старые настройки ?"
 update yn . 
  if yn then do:
      for each trxlevgl where trxlevgl.gl = vgl exclusive-lock . 
       delete trxlevgl . 
      end.  
  Message "Ok" . pause . 
  end.
  end. 
  return.
end.

find trxlevgl where trxlevgl.gl = vgl 
                    and trxlevgl.level = 1 
                    and trxlevgl.subled = vsub 
                    and trxlevgl.glr = vgl no-lock no-error.
if not available trxlevgl then do transaction:
   create trxlevgl.
   trxlevgl.gl = vgl.
   trxlevgl.glr = vgl.
   trxlevgl.subled = vsub.
   trxlevgl.level = 1.
end.   

{jabro.i
&start     = "view frame trxlevgl."
&head      = "trxsublv"
&headkey   = "level"
&index     = "subledlv"
&formname  = "trxlevgl"
&framename = "trxlevgl"
&where     = "trxsublv.subled = vsub"
&addcon    = "false"
&deletecon = "false"
&predelete = " " 
&precreate = " "
&postadd   = " " 
&prechoose = "/*message 'F4-exit'.*/"
&predisplay = "find trxlevgl where trxlevgl.gl = vgl 
                    and trxlevgl.level = trxsublv.level 
                    and trxlevgl.subled = vsub no-lock no-error.
               if available trxlevgl then vglr = trxlevgl.glr.
               else vglr = 0."
&display   = " trxsublv.level trxsublv.des vglr"
&highlight = " trxsublv.level trxsublv.des vglr"
&postkey   = " else if keyfunction(lastkey) = 'RETURN' then do transaction:
               find trxlevgl where trxlevgl.gl = vgl 
                    and trxlevgl.level = trxsublv.level 
                    and trxlevgl.subled = vsub no-lock no-error.
               if available trxlevgl then vglr = trxlevgl.glr.
               else vglr = 0.
                 if vglr = vgl then do:
                    bell.
                    next inner.
                 end.
                        vglr0 = vglr.
                 update vglr with frame trxlevgl.
                 find gl where gl.gl = vglr and gl.totact = false 
                 no-lock no-error.
                 if not available gl then do:
                    bell.
                    vglr = vglr0.
                    disp vglr with frame trxlevgl.
                    next inner.
                 end.
                if 
             /*   gl.subled <> '' and   */ 
                (gl.subled <> vsub or gl.level <> trxsublv.level) 
                or gl.totact 
                then do:
                         bell.
                         vglr = vglr0.
                         disp vglr with frame trxlevgl.
                         next inner.
                   end.
                 find trxlevgl where trxlevgl.gl = vgl 
                      and trxlevgl.level = trxsublv.level 
                      and trxlevgl.subled = vsub exclusive-lock no-error.
                 if not available trxlevgl then do:
                    create trxlevgl.
                    trxlevgl.gl = vgl.
                    trxlevgl.subled = vsub.
                    trxlevgl.level = trxsublv.level.
                    trxlevgl.glr = vglr.
                 end.
                 else trxlevgl.glr = vglr.
                 if trxlevgl.glr = 0 then delete trxlevgl.
                 next upper.
               end."
&end = "hide frame trxlevgl."
}
hide message.
