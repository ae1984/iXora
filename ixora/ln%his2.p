/* ln%his2.p
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
        03/08/2004 tsoy   - добавил в сохранение истории новые параметры ( Коммисисия за кред.линию, Пролонгация 1, 
                                                                           Пролонгация 2, Валюта индексации, Курс договора)

*/

/* LOAN PRINCIPAL VALUE RETURN SCHEDULE */
def output parameter flag as inte.
def input-output parameter clinn as inte.
def input-output parameter trecc as recid.
def shared var s-lon like lnsch.lnn.
def var fufu as inte.
upper:
repeat:

{jjbr.i
&start = "if fufu = 0 then do: fufu = 1. clin = clinn. trec = trecc. end."
&head = "ln%his"
&headkey = "f0"
&dttype = "string"
&where = "ln%his.lon = s-lon and ln%his.stdat > date(1,1,1000)"
&index = "ln%"
&formname = "ln%his2"
&framename = "ln%his2"
&addcon = "false"
&start = " "
&predisplay = " "
&prechoose = "disp ln%his.who ln%his.whn with frame ln%hism."
&display = "ln%his.f0 ln%his.long2 ln%his.lcnt ln%his.gua 
            ln%his.grp ln%his.pnlt1 ln%his.pnlt2 ln%his.comln ln%his.kcrc ln%his.drate "
&postdisplay = " "
&postadd = " "
&postkey = "else if lastkey = 504 then do:
            flag = 1. clinn = clin. trecc = trec. leave outer. end."
&end = "leave upper."
}
end. /* upper */
 
