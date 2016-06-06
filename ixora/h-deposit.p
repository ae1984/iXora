/* h-deposit.p
 * MODULE
        Название Программного Модуля
        4-1-2
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
        30/01/2006 Natalya D. добавила выбор депозитного счёта из списка по коду клиента или по его фамилии
        06/09/2006 Natalya D. вывела депозиты во временную таблицу и добавила условие по актуальных депозитов.
*/

/* h-deposit.p
*/

define  shared variable v-cif    like cif.cif.
def temp-table taaa
    field aaa like aaa.aaa
    field name like aaa.name
    field cif like aaa.cif
    field led like lgr.led
    field des like lgr.des
    index cif cif.
def var v-coun as int init 0.
 
{global.i}

for each aaa where aaa.cif = v-cif and aaa.sta <> 'C' no-lock.
find first lgr where lgr.lgr = aaa.lgr and (lgr.led = 'CDA' or lgr.led = 'TDA') no-lock no-error.
if not avail lgr then next.
   create taaa.
   assign taaa.aaa = aaa.aaa
          taaa.name = aaa.name
          taaa.cif = aaa.cif
          taaa.led = lgr.led
          taaa.des = lgr.des.
end.
find last taaa no-lock no-error.
if not avail taaa then do: message "По этому клиенту нет депозитов". pause 5. return. end.

{itemlist.i
       &file = "taaa"
       &start = /*"def var vname as character.
		      {imesg.i 2813}
			  update vname."*/ ""
       &where = "taaa.cif = v-cif"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &findadd = " "
       &flddisp = "taaa.aaa taaa.name taaa.cif taaa.led taaa.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "cif"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end." }  
return frame-value.
