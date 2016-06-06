/* itemlist.i
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
        20.04.2004 tsoy если нет ни одной записи то скрыть фрейм
        06/02/2006 madiar - выходим из справочника только по F1, F4 и enter
*/


{&var}

{&start}

def var vcnt{&set} as int.

form {&form}
     with {&frame} frame xf{&set}.

view frame xf{&set}.
pause 0.
{&updvar}
find first {&file} where {&where} use-index {&index} no-lock no-error.
if not available {&file}
then do:
       /*{mesg.i 0211}.*/  message 'Клиент не найден'.
       frame-value = "".
       hide frame xf{&set}.
       return.
     end.
{&findadd}

outer:
repeat:
  clear frame xf{&set} all.
  repeat vcnt{&set} = 1 to frame-down(xf{&set}):
    {&predisp}
    display {&flddisp}
        with frame xf{&set}.
    down with frame xf{&set}.
    find next {&file} where {&where}
              use-index {&index}
              no-lock no-error.
    if not available {&file} then leave.
    {&findadd}
  end.
  if lastkey eq keycode("cursor-up")
  then up frame-line(xf{&set}) - 1 with frame xf{&set}.
  else up with frame xf{&set}.

  inner:
  repeat on endkey undo, leave outer:
    input clear.

    choose row {&file}.{&chkey} no-error with frame xf{&set}.
    find first {&file} where {&where} and
               {&file}.{&chkey} eq {&chtype}(frame-value)
         use-index {&index}
         no-lock no-error.
    if lastkey eq keycode("cursor-up") and frame-line(xf{&set}) = 1
    then do:
       repeat vcnt{&set} = 1 to frame-down(xf{&set}):
         find prev {&file} where {&where} use-index {&index}
                   no-lock no-error.
         if not available {&file}
         then do:
            find first {&file} where  {&where}
                       use-index {&index}
                       no-lock.
            {&findadd}
            leave.
          end.
         {&findadd}
       end.
       leave inner.
     end.
    else if lastkey eq keycode("cursor-down")  and
        frame-line(xf{&set}) = frame-down(xf{&set})
    then do:
       find next {&file} where {&where} use-index {&index}
                 no-lock no-error.
       if not available {&file}
       then find last {&file} where {&where} use-index {&index}
                  no-lock.
       {&findadd}
       leave inner.
     end.

    else if lastkey eq keycode("cursor-right")
    then do:
       find last {&file} where {&where} use-index {&index}
                 no-lock.
       {&findadd}
       leave inner.
     end.

    else if lastkey eq keycode("cursor-left")
    then do:
       find first {&file} where {&where} use-index {&index}
                  no-lock.
       {&findadd}
       leave inner.
     end.

    else do:
        {&funadd}
        if keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN" or keyfunction(lastkey) eq "END-ERROR" then leave outer.
     end.

  end. /* inner */
end. /* outer */

if keyfunction(lastkey) eq "GO" or
   keyfunction(lastkey) eq "RETURN" then frame-value = frame-value.
hide frame xf{&set}.
{&end}
