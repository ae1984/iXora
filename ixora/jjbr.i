/* jjbr.i
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

/* jjbr.i
*/
define variable v-cnt as integer.
def var kuku as char format "x(20)".
def var mumu as char format "x(20)".
def var curline as inte.
def var crec as recid.
def var frec as recid.
def var lrec as recid.
def var trec as recid.
def var brec as recid.
def var clin as inte.
def var dlin as inte.
def var blin as inte.
def var from-line as inte.
def var to-line as inte.
def var addflag as inte. 
def var curflag as inte.
def var empflag as inte.
curflag = 1.
{{&formname}.f {&frameparm}}

{&start}
view frame {&framename}. pause 0.
{&viewframe}

find last {&head} where {&where} use-index {&index} no-error.
if available {&head} then do:
  lrec = recid({&head}).
find first {&head} where {&where} use-index {&index} no-error.
  frec = recid({&head}).
  crec = frec.
  if clin = 0 then do:
    trec = frec.
    clin = 1.
  end.
  else do:
    find {&head} where recid({&head}) = trec.
  end.
  dlin = frame-down({&framename}).

  from-line = 1.
    to-line = dlin.

    clear frame {&framename} all no-pause.
end.
else empflag = 1.
outer:
repeat:
if empflag = 0 then do:
{&reframe}
if to-line = dlin and from-line = 1 then blin = 0.
    repeat v-cnt = from-line to to-line:
      if to-line = dlin and from-line = 1 then blin = blin + 1.
      if v-cnt = clin then crec = recid({&head}).
      {&predisplay}
      display {&display} with frame {&framename}.
      display {&display1} with frame {&framename}.
      {&postdisplay}
      if v-cnt ge dlin then leave.
      find next {&head} where {&where} use-index {&index} no-error.
      if not available {&head} then do:
        find last {&head} where {&where} use-index {&index} no-error.
        leave.
      end.
      down with frame {&framename}.
    end.
    if blin < clin then do: clin = blin. crec = recid({&head}). end.
  if to-line = dlin and from-line = 1 then brec = recid({&head}).
  find {&head} where recid({&head}) = crec.
  kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
  mumu = kuku.
end.
  inner:
  repeat on endkey undo, leave outer:
 if empflag = 0 then do:
 if curflag = 0 then kuku = mumu.
     curflag = 0. 
if addflag = 1 then do:
     {&postadd} 
     find last {&head} where {&where} use-index {&index} no-error.
     lrec = recid({&head}). brec = lrec.
     find {&head} where recid({&head}) = trec.
     from-line = 1. to-line = dlin.
     clear frame {&framename} all.
     addflag = 0.
     next outer. 
end.
  hide message.
  {&prechoose}
    mumu = kuku.
  choose row {&head}.{&headkey}
         go-on("CURSOR-UP" "CURSOR-DOWN" "PAGE-DOWN" "PAGE-UP"
               "HOME" "END" "RETURN" "TAB" " " {&postgo-on})
         keys kuku no-error with frame {&framename}.
end.
else readkey.
if lastkey = 404 then leave outer.
       
else if keyfunction(lastkey) = "CURSOR-UP" then do:
        curflag = 1.
     if crec <> frec then do:
      find prev {&head} where {&where} use-index {&index} no-error. 
       if clin > 1 then do:
         kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
         clin = clin - 1. crec = recid({&head}). next inner.
       end. 
        clear frame {&framename} no-pause.
        scroll down with frame {&framename}.
        crec = recid({&head}). trec = crec.
       if blin < dlin then blin = blin + 1.
       else do:
        find {&head} where recid({&head}) = brec.
        find prev {&head} where {&where} use-index {&index} no-error.
        brec = recid({&head}).
        find {&head} where recid({&head}) = crec.
       end.
        from-line = 1. to-line = 2.       
        next outer.
     end.
     else do:
      bell. next inner.
     end.
   end.

    else
   if keyfunction(lastkey) eq "CURSOR-DOWN" then do:
         curflag = 1.
    if crec <> lrec then do: 
       find next {&head} where {&where} use-index {&index} no-error.
        if clin < dlin then do:
          kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
          clin = clin + 1. crec = recid({&head}).
          next inner. 
        end. 
         clear frame {&framename} no-pause.
         scroll up with frame {&framename}.
         up 1 with frame {&framename}.
         crec = recid({&head}). brec = crec.
          find {&head} where recid({&head}) = trec.
          find next {&head} where {&where} use-index {&index} no-error.
          trec = recid({&head}).
          find {&head} where recid({&head}) = crec.
          find prev {&head} where {&where} use-index {&index} no-error.
          from-line = dlin - 1. to-line = dlin.
         next outer.
      end.
      else do:
        if {&addcon} then do:
           {&precreate} 
           create {&head}.
           {&postcreate}
           lrec = recid({&head}). 
           addflag = 1.        
         if clin < dlin then do:
           clin = clin + 1. blin = clin.
           from-line = clin - 1. to-line = clin. 
           find {&head} where recid({&head}) = crec.
           clear frame {&framename}.
           crec = lrec.
           next outer.
         end.
         else do:
           clear frame {&framename} no-pause.
           scroll up with frame {&framename}.
           up 1 with frame {&framename}.
           clear frame {&framename}.
           find {&head} where recid({&head}) = trec.
           find next {&head} where {&where} use-index {&index} no-error.
           trec = recid({&head}).
           find {&head} where recid({&head}) = crec.
           from-line = dlin - 1. to-line = dlin.
           next outer.
         end.
        end.
        else do:
          bell. next inner.
        end.
      end.
    end.

    else if keyfunction(lastkey) = "PAGE-DOWN" then do:
          curflag = 1.
    if crec <> lrec then do:
           find {&head} where recid({&head}) = brec.
        if brec = lrec then do:
           crec = brec. clin = blin.
           kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
           next inner.
        end.
        else do:
         find next {&head} where {&where} use-index {&index} no-error.
         from-line = 1. to-line = dlin. trec = recid({&head}).
         clear frame {&framename} all.
         next outer.
        end.
    end.
    else do: bell. next inner. end.
    end. /* PAGE-DOWN */

    else if keyfunction(lastkey) = "PAGE-UP" then do:
          curflag = 1.
    if crec <> frec then do:
           find {&head} where recid({&head}) = trec.
        if trec = frec then do:
           crec = trec. clin = 1.
           kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
           next inner.
        end.
        else do:
         repeat v-cnt = 1 to dlin:
          find prev {&head} where {&where} use-index {&index} no-error.
          if not available {&head} then do:
            find {&head} where recid({&head}) = frec.
            leave.
          end.
         end.
           trec = recid({&head}). from-line = 1. to-line = dlin. 
           clear frame {&framename} all.
           next outer.
        end.
    end.
    else do: bell. next inner. end.
    end. /* PAGE-UP */
 
     if keyfunction(lastkey) = "HOME" then do:
           curflag = 1.
       if crec = frec then do: bell. next inner. end.
          find {&head} where recid({&head}) = frec.
       if trec = frec then do:
          crec = trec. clin = 1.
          kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
          next inner.
       end.
       else do:
          from-line = 1. to-line = dlin. trec = frec. clin = 1. crec = frec.
          clear frame {&framename} all.
          next outer.
       end.
     end. /* HOME */
  
     if keyfunction(lastkey) = "RIGHT-END" then do:
          curflag = 1.
       if crec = lrec then do: bell. next inner. end.
          find {&head} where recid({&head}) = lrec.
       if brec = lrec then do:
          crec = brec. clin = blin.
          kuku = trim({&dttype}({&head}.{&headkey} {&dtfor})).
          next inner.
       end.
       else do:
          repeat v-cnt = 1 to dlin - 1:
             find prev {&head} where {&where} use-index {&index} no-error.
             if not available {&head} then do:
               find {&head} where recid({&head}) = frec.
               leave.
             end.
          end.
         trec = recid({&head}). from-line = 1. to-line = dlin. clin = dlin.
         crec = lrec. clear frame {&framename} all.
         next outer.
       end.
     end. /*RIGHT END*/
     {&postkey}  
    else do: /* other key has been pressed */
       bell.
    end.
  end. /* inner */
end. /* outer */
{&end}
