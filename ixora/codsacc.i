/* codsacc.i
 * MODULE
        Модуль генерации проводок
 * DESCRIPTION
        Модуль генерации проводок
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
        16.05.05 nataly 
 * CHANGES
*/
            if cods.lookaaa  then do: 
               find ast where string(ast.ast) = {&acc} no-lock no-error.
               if avail ast then do: 
                 find codfr where codfr.codfr = 'sproftcn' and codfr.code = ast.attn no-lock no-error.
                 if avail codfr then  v-dep = codfr.name[4] . else v-dep = '000'. 
               end.
            end.
