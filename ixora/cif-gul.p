/* cif-gul.p
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

/* checked */
/* cif-gua.p
*/

{global.i}

{linel.i
&var = "  "
/***
&start = "form
          gua.ssn gua.name gua.addr gua.geo
          gua.tel gua.tit gua.rel gua.birthday gua.ref
          with frame gua col 2 row 5 1 col overlay."
          ****/
&head = "cif"
&line = "gua"
&index = "cifln"
&form = "gua.ln gua.name gua.ssn gua.tit"
&frame = "row 3 col 1 scroll 1 10 down overlay title "" Гаранты "" "
&newline = "  "
&predisp = "  "
&flddisp = "gua.ln gua.name gua.ssn gua.tit"
&preupdt = " "
&newpreupdt = " "
/***
&posupdt = "pause 77.
          update
          gua.ssn gua.name gua.addr gua.geo
          gua.tel gua.tit gua.rel gua.birthday
          gua.ref with frame gua."
          *****/
&fldupdt = " "
&postplus = " "
&postminus = " "
&end = " "
}
