/* tdaintrat1.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{global.i}
def input parameter s-pri as char.
def var vi as inte.
def var vpri as char.
def shared var head1 as char initial "Срок".
def shared var head11 as char initial "Ступень 1".
def shared var head12 as char initial "Ступень 2".
def shared var head13 as char initial "Ступень 3".
def shared var head14 as char initial "Ступень 4".
def shared var head15 as char initial "Ступень 5".
def shared temp-table gpri 
    field gpri as char
    field name as char
    field itype as inte
    field rate like pri.rate
    field tlimit like pri.tlimit.
def shared temp-table vrate 
    field vterm as inte 
    field rate like pri.rate extent 5.
def shared frame ss.
def shared frame ss1.
find first gpri where gpri.gpri = s-pri.

{jabre.i
   &head = "vrate"
   &headkey = "vterm"
   &where = "true"
   &formname = "tdainttab"
   &framename = "ss"
   &addcon = "false"
   &deletecon = "false"
   &prechoose = "message 'F4-Вернуться к заголовкам'."
   &predisplay = " "
   &display = "vrate.vterm vrate.rate"
   &highlight = "vrate.vterm"
   &postkey = " "
   &postadd = " "
   &predelete = " " 
   &end = "hide frame ss.
           hide frame ss1.
           hide frame ss2.
          " 
}
