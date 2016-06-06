/* jabrcods.i
 * MODULE
        форма для справочника кодов доходов- расходов (аналигично jabrw.i)
 * DESCRIPTION
        форма для справочника кодов доходов- расходов (аналигично jabrw.i)
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
        29/04/05 nataly
 * CHANGES
        30.04.05 nataly  - из-за переполнения препроцессора обработка нажатия клавиши 'P' была вынесена в jabrcods.i
        16.05.05 nataly  - был добавлен вызов справочника   
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
                                        /* 16.05.05 nataly */
 ON HELP of cods.code  in FRAME cods DO:
  /*run help-code(cods.gl,cods.acc).
     code:screen-value = return-value.
     code = code:screen-value.*/
    message 'Помощь недоступна!' view-as alert-box.
 end.

 ON HELP of cods.dep  in FRAME cods DO:
  run help-dep(cods.dep).
     cods.dep:screen-value = return-value.
     cods.dep = cods.dep:screen-value. 
  end.                                /* 16.05.05 nataly */

view frame {&framename}. pause 0.
{&viewframe}

clin = 0.

upper:
repeat:
clear frame {&framename} all no-pause.
find last {&head} where {&where} use-index {&index} no-lock no-error.
if available {&head} then do:
  lrec = recid({&head}).
find first {&head} where {&where} use-index {&index} no-lock no-error.
  frec = recid({&head}).
  crec = frec.
  if clin = 0 then do:
    trec = frec.
    clin = 1.
  end.
  else do:
    find {&head} where recid({&head}) = trec no-lock.
  end.
  dlin = frame-down({&framename}).
    clear frame {&framename} all no-pause.
end.
else do:
  if {&addcon} then do:
   do transaction:
     {&precreate}
     create {&head}.
     {&postcreate}

     {&predisplay}
     disp {&display} with frame {&framename}.
     {&postadd}

     {&preupdate} 
     update {&update} with frame {&framename}.
     {&postupdate}
   end.
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
      find next {&head} where {&where} use-index {&index} no-lock no-error.
      if not available {&head} then do:
        find last {&head} where {&where} use-index {&index} no-lock no-error.
        leave.
      end.
      down with frame {&framename}.
    end.
    if blin < clin then do: clin = blin. crec = recid({&head}). end.
    brec = recid({&head}).
  find {&head} where recid({&head}) = crec no-lock.
end.
  up blin - clin with frame {&framename}.
  color disp messages {&highlight} with frame {&framename}.
  inner:
  repeat on endkey undo, leave outer:
  hide message.
  {&prechoose}
   readkey.
if keyfunction(lastkey) = "END-ERROR" then leave upper.
if keyfunction(lastkey) = "RETURN" then do transaction:
      find {&head} where recid({&head}) = crec exclusive-lock.
      {&preupdate}
         update {&update} with frame {&framename}.
      {&postupdate}
end.
else if keyfunction(lastkey) = "DELETE-LINE" then do:
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
        find next {&head} where {&where} use-index {&index} no-lock no-error.
        if available {&head} then nrec = recid({&head}).
        else clin = 0.
      end.
      else do:
        find prev {&head} where {&where} use-index {&index} no-lock no-error.
        nrec = recid({&head}).
      end.
   end.
     do transaction:
      find first {&head} where recid({&head}) = crec exclusive-lock.

      {&prevdelete}

      delete {&head}.
     end.
      if clin = 1 then trec = nrec.
      next upper.
  end.
end.
else if keyfunction(lastkey) = "CURSOR-UP" then do:
        curflag = 1.
     if crec <> frec then do:
      color disp normal {&highlight} with frame {&framename}.
      find prev {&head} where {&where} use-index {&index} no-lock no-error.
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
        find {&head} where recid({&head}) = brec no-lock.
        find prev {&head} where {&where} use-index {&index} no-lock no-error.
        brec = recid({&head}).
        find {&head} where recid({&head}) = crec no-lock.
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
            {&preupdate}
            update {&update} with frame {&framename}.
            {&postupdate}
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
            {&preupdate}
            update {&update} with frame {&framename}.
            {&postupdate}
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
            {&preupdate}
            update {&update} with frame {&framename}.
            {&postupdate}
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
         find next {&head} where {&where} use-index {&index} no-lock no-error.
         if clin < dlin then do:
         clin = clin + 1. crec = recid({&head}).
         down with frame {&framename}.
         color disp messages {&highlight} with frame {&framename}.
         next inner.
    end.
         scroll up with frame {&framename}.
         crec = recid({&head}). brec = crec.
          find {&head} where recid({&head}) = trec no-lock.
          find next {&head} where {&where} use-index {&index} no-lock no-error.
          trec = recid({&head}).
          find {&head} where recid({&head}) = crec no-lock.
               {&predisplay}
          disp {&display} with frame {&framename}.
          color disp messages {&highlight} with frame {&framename}.
          next inner.
      end.
      else do:
        if {&addcon} then do:
         do transaction:
           {&precreate}
           create {&head}.
           {&postcreate}
         end.
           lrec = recid({&head}).
         if clin < dlin then do:
           clin = clin + 1.
           color disp normal {&highlight} with frame {&framename}.
           down with frame {&framename}.
                {&predisplay}
           disp {&display} with frame {&framename}.
           do on endkey undo, leave:
            do transaction:
             {&postadd}
            {&preupdate}
            update {&update} with frame {&framename}.
            {&postupdate}
            end.
           end. 
           if keyfunction(lastkey) = "end-error" then do:
            clear frame {&framename} no-pause.
            up with frame {&framename}.
            do transaction:
             delete {&head}.
            end.
            find last {&head} where {&where} use-index {&index} no-lock no-error.
            lrec = recid({&head}).
            clin = clin - 1.
            color disp messages {&highlight} with frame {&framename}.
            next inner.
           end.
           color disp messages {&highlight} with frame {&framename}.
           next upper.
         end.
         else do:
           find {&head} where recid({&head}) = trec no-lock.
           find next {&head} where {&where} no-lock no-error.
           trec = recid({&head}).
           find {&head} where recid({&head}) = lrec exclusive-lock.
           color disp normal {&highlight} with frame {&framename}.
           scroll up with frame {&framename}.
                {&predisplay}
           disp {&display} with frame {&framename}.
          do on endkey undo, leave:
           do transaction:
            {&postadd}
            {&preupdate}
            update {&update} with frame {&framename}.
            {&postupdate}
           end.
          end.
          if keyfunction(lastkey) = "end-error" then do:
            clear frame {&framename} no-pause.
            up with frame {&framename}.
            do transaction:
               delete {&head}.
            end.
            find last {&head} where {&where} use-index {&index} no-lock no-error.
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
           find {&head} where recid({&head}) = brec no-lock.
        if brec = lrec then do:
           down blin - clin with frame {&framename}.
           crec = brec. clin = blin.
        color disp messages {&highlight} with frame {&framename}.
           next inner.
        end.
        else do:
         find next {&head} where {&where} use-index {&index} no-lock no-error.
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
           find {&head} where recid({&head}) = trec no-lock.
        if trec = frec then do:
           up clin - 1 with frame {&framename}.
           crec = trec. clin = 1.
        color disp messages {&highlight} with frame {&framename}.
           next inner.
        end.
        else do:
         repeat v-cnt = 1 to dlin:
          find prev {&head} where {&where} use-index {&index} no-lock no-error.
          if not available {&head} then do:
            find {&head} where recid({&head}) = frec no-lock.
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
          find {&head} where recid({&head}) = frec no-lock.
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
          find {&head} where recid({&head}) = lrec no-lock.
       if brec = lrec then do:
          down blin - clin with frame {&framename}.
          crec = brec. clin = blin.
          color disp messages {&highlight} with frame {&framename}.
          next inner.
       end.
       else do:
          repeat v-cnt = 1 to dlin - 1:
             find prev {&head} where {&where} use-index {&index} no-lock no-error.
             if not available {&head} then do:
               find {&head} where recid({&head}) = frec no-lock.
               leave.
             end.
          end.
         trec = recid({&head}). clin = dlin.
         crec = lrec. clear frame {&framename} all no-pause.
         next outer.
       end.
     end. /*RIGHT END*/
     {&postkey}   /*29/04/05 nataly*/
      else if keyfunction(lastkey) = 'P' then 
                            do:
                               s_rowid = rowid(cods).
                               output to cods.img .
                               display 'Код    Подр Счет ГК Корр счет Приз       Описание  ' skip.
                               display '-------------------------------------------------'  .
                               for each cods:
                                   display cods.code format 'x(7)' no-label cods.dep  format 'x(3)' no-label  
                                    cods.gl  format 'zzzzz9' no-label cods.acc format 'x(10)' no-label 
                                    cods.lookaaa no-label  cods.des format 'x(40)' no-label skip.
                               end.
                               output close.
                               output to terminal.
                               run menu-prt('cods.img').
                               find cods where rowid(cods) = s_rowid no-lock.
                       end.         /*29/04/05 nataly*/
                   else if keyfunction(lastkey) = 'F' then 
                      do:
                         update s-mask /* help 'Маска для поиска (последнюю * можно не писать)' */
                         label 'Введите маску' skip
                         '(Последнюю * можно не писать)' with side-labels 
                         color messages overlay row 5 centered frame maskfr.
                         hide frame maskfr.
                         if s-mask <> '' and substr (s-mask, length(s-mask), 1) <> '*' then
                         s-mask = s-mask + '*'.
                         find first cods where cods.code matches s-mask and (s-entries = '' or lookup(cods.code, s-entries) > 0) use-index codegl_id no-lock no-error.
                         if not avail cods then do:
                            message 'Не найдены записи в cods по маске ' s-mask '. Возврат к default'
                                     view-as alert-box title ''. 
                            s-mask = '*'.
                            find first cods where cods.code matches s-mask and (s-entries = '' or lookup(cods.code, s-entries) > 0)  use-index codegl_id no-lock no-error.
                         end.
                         trec = recid(cods).
                         next upper.
                     end. 

    else do: /* other key has been pressed */
       bell.
    end.
  end. /* inner */
end. /* outer */
end. /*upper*/
{&end}
