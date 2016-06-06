/* h-vcaaa.p
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

/* h-aaa.p Валютный контроль
   Просмотр счетов одного клиента для счета комиссии в контракте
   выдаются счета только Т/С (группы 151,153,155,157,171)

   1.11.2002 nadejda создан
*/

def shared var s-cif like cif.cif.

def var v-lgrlist as char init "151,153".

find sysc where sysc.sysc = "vc-agr" no-lock no-error.
if avail sysc then v-lgrlist = sysc.chval.

{global.i}
{itemlist.i
       &file = "aaa"
       &where = "aaa.cif = s-cif and 
                 aaa.sta <> 'C' 
                 and lookup(string(aaa.lgr), v-lgrlist) > 0 "
       &frame = " centered row 5 scroll 1 12 down overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.sta lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "cif"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
