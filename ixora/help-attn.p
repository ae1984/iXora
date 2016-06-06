/* help-attn.p
 * MODULE
        Справочник департаментов модуля ЗАРПЛАТЫ
 * DESCRIPTION
        Справочник департаментов модуля ЗАРПЛАТЫ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        profcned.p , r-zatrat.p
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

def  shared temp-table v-deps
      field dep as char
      field depname as char
        index dep is primary   dep .

{global.i}
{itemlist.i
       &file = "v-deps"
       &frame = "row 4 centered scroll 1 12 down overlay "
       &where = "true"
       &flddisp = "v-deps.dep  FORMAT ""x(4)"" LABEL ""КОД ""
                   v-deps.depname FORMAT ""x(50)"" LABEL ""НАИМЕНОВАНИЕ ДЕПАРТАМЕНТА""" 
       &chkey = "dep"
       &chtype = "string"
       &index  = "dep" 
       &end  = "return  v-deps.dep." }

  