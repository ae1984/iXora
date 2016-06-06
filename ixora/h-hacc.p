/* h-hacc.p
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
        h-aaa.p  - просмотр счетов одного клиента
        14/02/95 - AGA
        20/08/98 - Changed By ANRI
        07/11/01 - by sasco: show aaa.aaa = 5**** - выводить все
                   dont show aaa = ***140*** - овердрафты не показывать
        20/07/2011 lyubov - исключила из выводимого списка счетов счета О/Д
*/

DEF shared var s-cif like cif.cif.


{global.i}
{itemlist.i
       &file = "aaa"
       &where = "aaa.cif EQ s-cif and
/*                 not aaa.aaa begins '5' and */
                 aaa.sta <> 'C'
                 and substring(aaa.aaa,4,3) <> '140' "
       &frame = "row 4 column 30 scroll 1 12 down overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr and lgr.led ne ""ODA"" no-lock no-error."
       &predisp = "if avail lgr then "
       &flddisp = "aaa.aaa aaa.sta lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "cif"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }

return frame-value.
