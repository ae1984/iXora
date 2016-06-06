/* r-gltup3.f
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

/* r-gltup3.f
*/
              vgl validate(vgl eq 0 or can-find(gl where gl.gl eq vgl),
                                                          "RECORD NOT FOUND...")
              help "ENTER 0 FOR ALL ACCOUNT OR INDIVIDUAL ACCOUNT#."
              fdt validate (sysc.daval le fdt, 
                " В база информация с  " + string(sysc.daval) )
              tdt validate (g-today ge tdt, "Последняя дата " 
              + string(g-today) )
              with row 8 centered no-box side-label frame opt.
