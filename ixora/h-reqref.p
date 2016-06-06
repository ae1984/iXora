/* h-reqref.p
 * MODULE
        Окно отправленных сообщений
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
     reqnull.p
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        02.03.2004 tsoy
 * CHANGES
*/


{global.i}

{itemlist.i 
       &file    = "rrr"
       &start   = " "
       &where   = "rrr.rrr <>"""""
       &frame   = "row 5 centered scroll 1 12 down overlay  "
       &flddisp = "rrr.vdt LABEL ""Дата Валют."" rrr.rrr format ""x(20)"" LABEL ""Референс"" rrr.amt LABEL ""Сумма"""
       &chkey   = "rrr"
       &chtype  = "string"
       &index   = "rrr"
}
