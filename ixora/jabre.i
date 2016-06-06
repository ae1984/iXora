/* jabre.i
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
        01.02.2004 nadejda - добавлена обработка {&prevdelete}
*/

/* jjbre.i
by ja 9/08/95
modified for usage with workfiles 17/10/95
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
def var clin0 as inte.
def var dlin as inte.
def var blin as inte.
def var nrec as recid.
def var from-line as inte.
def var to-line as inte.
def var addflag as inte.
def var curflag as inte.
def var empflag as inte.
def var lop as inte.
def var vans as logi.
curflag = 1.

{{&formname}.f {&frameparm}}

{&start}
view frame {&framename}. pause 0.
{&viewframe}

clin = 0.

upper:
repeat:
clear frame {&framename} all no-pause.
find last {&head} where {&where}  no-error.
if available {&head} then do:
  lrec = recid({&head}).
find first {&head} where {&where}  no-error.
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
    clear frame {&framename} all no-pause.
end.
else do:
  if {&addcon} then do:
     {&precreate}
     create {&head}.
     {&postcreate}
     {&postadd}
     next upper.
  end.
  else do:
     pause.
     leave upper.
  end.
end.


outer:
repeat:
if empflag = 0 then do:
{&reframe}
      blin = 0.
    repeat v-cnt = 1 to dlin:
      blin = blin + 1.
      if v-cnt = clin then crec = recid({&head}).
      {&predisplay}
      display {&display} with frame {&framename}.
      {&postdisplay}
      if v-cnt ge dlin then leave.
      find next {&head} where {&where}  no-error.
      if not available {&head} then do:
        find last {&head} where {&where}  no-error.
        leave.
      end.
      down with frame {&framename}.
    end.
    if blin < clin then do: clin = blin. crec = recid({&head}). end.
    brec = recid({&head}).
  find {&head} where recid({&head}) = crec.
end.
  up blin - clin with frame {&framename}.
  color disp messages {&highlight} with frame {&framename}.
  inner:
  repeat on endkey undo, leave outer:
  hide message.
  {&prechoose}
   readkey.
if keyfunction(lastkey) = "END-ERROR" then leave upper.
if keyfunction(lastkey) = "DELETE-LINE" then do:
 if not {&deletecon} then do:
    bell.
    next inner.
 end.
 {&predelete}
  {mesg.i 882} update vans.
  if vans then do:
     vans = false.
   if clin = 1 then do:
      if trec = frec then do:
        find next {&head} where {&where}  no-error.
        if available {&head} then nrec = recid({&head}).
        else clin = 0.
      end.
      else do:
        find prev {&head} where {&where}  no-error.
        nrec = recid({&head}).
      end.
   end.
      find first {&head} where recid({&head}) = crec.
      {&prevdelete}
      delete {&head}.
      if clin = 1 then trec = nrec.
      next upper.
  end.
end.
else if keyfunction(lastkey) = "CURSOR-UP" then do:
        curflag = 1.
     if crec <> frec then do:
      color disp normal {&highlight} with frame {&framename}.
      find prev {&head} where {&where}  no-error.
      if clin > 1 then do:
         clin = clin - 1. crec = recid({&head}).
         up with frame {&framename}.
       color disp messages {&highlight} with frame {&framename}.
         next inner.
      end.
        scroll down with frame {&framename}.
        crec = recid({&head}). trec = crec.
       if blin < dlin then blin = blin + 1.
       else do:
        find {&head} where recid({&head}) = brec.
        find prev {&head} where {&where}  no-error.
        brec = recid({&head}).
        find {&head} where recid({&head}) = crec.
       end.
             {&predisplay}
        disp {&display} with frame {&framename}.
        color disp messages {&highlight} with frame {&framename}.
        next inner.
     end.
     else do:
      bell. next inner.
     end.
   end.
   else if keyfunction(lastkey) = "INSERT-MODE" then do:
   if {&addcon} = false then do:
      bell.
      next inner.
   end.
         clin0 = clin.
   insmod:
   repeat:
           {&precreate}
           create {&head}.
           {&postcreate}
      if clin >= dlin then lop = lop + 1.
         if clin < dlin then do:
           color disp normal {&highlight} with frame {&framename}.
           scroll from-current down with frame {&framename}.
           clin = clin + 1.
                {&predisplay}
           disp {&display} with frame {&framename}.
           do on endkey undo, leave:
            {&postadd}
           end.
           if keyfunction(lastkey) = "end-error" then do:
            delete {&head}.
            clin = clin0.
            next upper.
           end.
           down with frame {&framename}.
         end.
         else if clin = dlin and lop > 1 then do:
           color disp normal {&highlight} with frame {&framename}.
           scroll up with frame {&framename}.
                {&predisplay}
           disp {&display} with frame {&framename}.
          do on endkey undo, leave:
            {&postadd}
          end.
          if keyfunction(lastkey) = "end-error" then do:
            delete {&head}.
            clin = clin0.
            lop = 0.
            next upper.
          end.
         end.
         else if clin = dlin and lop = 1 then do:
                {&predisplay}
           disp {&display} with frame {&framename}.
          do on endkey undo, leave:
            {&postadd}
          end.
          if keyfunction(lastkey) = "end-error" then do:
            delete {&head}.
            clin = clin0.
            lop = 0.
            next upper.
          end.
         end.
  end. /*repeat insmod*/
     lop = 0.
 end.  /*INSERT-MODE*/
 else if keyfunction(lastkey) eq "CURSOR-DOWN" then do:
 curflag = 1.
    if crec <> lrec then do:
         color disp normal {&highlight} with frame {&framename}.
         find next {&head} where {&where}  no-error.
         if clin < dlin then do:
         clin = clin + 1. crec = recid({&head}).
         down with frame {&framename}.
         color disp messages {&highlight} with frame {&framename}.
         next inner.
    end.
         scroll up with frame {&framename}.
         crec = recid({&head}). brec = crec.
          find {&head} where recid({&head}) = trec.
          find next {&head} where {&where}  no-error.
          trec = recid({&head}).
          find {&head} where recid({&head}) = crec.
               {&predisplay}
          disp {&display} with frame {&framename}.
          color disp messages {&highlight} with frame {&framename}.
          next inner.
      end.
      else do:
        if {&addcon} then do:
           {&precreate}
           create {&head}.
           {&postcreate}
           lrec = recid({&head}).
         if clin < dlin then do:
           clin = clin + 1.
           color disp normal {&highlight} with frame {&framename}.
           down with frame {&framename}.
                {&predisplay}
           disp {&display} with frame {&framename}.
           do on endkey undo, leave:
            {&postadd}
           end.
           if keyfunction(lastkey) = "end-error" then do:
            clear frame {&framename} no-pause.
            up with frame {&framename}.
            delete {&head}.
            find last {&head} where {&where}  no-error.
            lrec = recid({&head}).
            clin = clin - 1.
            color disp messages {&highlight} with frame {&framename}.
            next inner.
           end.
           color disp messages {&highlight} with frame {&framename}.
           next upper.
         end.
         else do:
           find {&head} where recid({&head}) = trec.
           find next {&head} where {&where}.
           trec = recid({&head}).
           find {&head} where recid({&head}) = lrec.
           color disp normal {&highlight} with frame {&framename}.
           scroll up with frame {&framename}.
                {&predisplay}
           disp {&display} with frame {&framename}.
          do on endkey undo, leave:
            {&postadd}
          end.
          if keyfunction(lastkey) = "end-error" then do:
            clear frame {&framename} no-pause.
            up with frame {&framename}.
            delete {&head}.
            find last {&head} where {&where}  no-error.
            lrec = recid({&head}).
            clin = clin - 1.
            color disp messages {&highlight} with frame {&framename}.
            next inner.
           end.
           color disp messages {&highlight} with frame {&framename}.
           next upper.
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
        color disp normal {&highlight} with frame {&framename}.
           find {&head} where recid({&head}) = brec.
        if brec = lrec then do:
           down blin - clin with frame {&framename}.
           crec = brec. clin = blin.
        color disp messages {&highlight} with frame {&framename}.
           next inner.
        end.
        else do:
         find next {&head} where {&where}  no-error.
         trec = recid({&head}).
         clear frame {&framename} all no-pause.
         next outer.
        end.
    end.
    else do: bell. next inner. end.
    end. /* PAGE-DOWN */

    else if keyfunction(lastkey) = "PAGE-UP" then do:
          curflag = 1.
    if crec <> frec then do:
        color disp normal {&highlight} with frame {&framename}.
           find {&head} where recid({&head}) = trec.
        if trec = frec then do:
           up clin - 1 with frame {&framename}.
           crec = trec. clin = 1.
        color disp messages {&highlight} with frame {&framename}.
           next inner.
        end.
        else do:
         repeat v-cnt = 1 to dlin:
          find prev {&head} where {&where}  no-error.
          if not available {&head} then do:
            find {&head} where recid({&head}) = frec.
            leave.
          end.
         end.
           trec = recid({&head}).
           clear frame {&framename} all no-pause.
           next outer.
        end.
    end.
    else do: bell. next inner. end.
    end. /* PAGE-UP */

     if keyfunction(lastkey) = "HOME" then do:
           curflag = 1.
       if crec = frec then do: bell. next inner. end.
          color disp normal {&highlight} with frame {&framename}.
          find {&head} where recid({&head}) = frec.
       if trec = frec then do:
          up clin - 1 with frame {&framename}.
          crec = trec. clin = 1.
          color disp messages {&highlight} with frame {&framename}.
          next inner.
       end.
       else do:
          trec = frec. clin = 1. crec = frec.
          clear frame {&framename} all no-pause.
          next outer.
       end.
     end. /* HOME */

     if keyfunction(lastkey) = "RIGHT-END" then do:
          curflag = 1.
       if crec = lrec then do: bell. next inner. end.
          color disp normal {&highlight} with frame {&framename}.
          find {&head} where recid({&head}) = lrec.
       if brec = lrec then do:
          down blin - clin with frame {&framename}.
          crec = brec. clin = blin.
          color disp messages {&highlight} with frame {&framename}.
          next inner.
       end.
       else do:
          repeat v-cnt = 1 to dlin - 1:
             find prev {&head} where {&where}  no-error.
             if not available {&head} then do:
               find {&head} where recid({&head}) = frec.
               leave.
             end.
          end.
         trec = recid({&head}). clin = dlin.
         crec = lrec. clear frame {&framename} all no-pause.
         next outer.
       end.
     end. /*RIGHT END*/
     {&postkey}
    else do: /* other key has been pressed */
       bell.
    end.
  end. /* inner */
end. /* outer */
end. /*upper*/
{&end}
