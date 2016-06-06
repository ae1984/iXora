/* linel.i
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

/* linel.i */

def buffer x{&line} for  {&line}.

def shared var    s-{&head} like {&head}.{&head}.

def var disagain as log.
def var vcnt as int.
def var vans as log.

{&var}

form {&form} with frame xf {&frame}.
view frame xf.
pause 0.
find {&head} where {&head}.{&head} = s-{&head}.

{&start}
find first {&line} where {&line}.{&head} eq {&head}.{&head} 
    use-index {&index} no-error.
 
r1:
repeat:
    if not available {&line} then do:
        pause.
        leave.
    end.
    
    view frame xf.
    pause 0.
    clear frame xf all.
    repeat vcnt = 1 to frame-down(xf):
        {&predisp}
        display {&flddisp} with frame xf.
        down with frame xf.
        find next {&line} where {&line}.{&head} eq {&head}.{&head}
                use-index {&index} no-error.

            if not available {&line} then do:
                pause.
                leave.
            end.
    end.
end.
{&end}
