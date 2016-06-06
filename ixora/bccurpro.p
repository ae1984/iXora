/* bccurpro.p
 * MODULE
        Установка курсов валют
 * DESCRIPTION
        Установка прогнозных курсов валют
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        10/05/2005 madiar
 * CHANGES
        06/06/2005 madiar - автоматическое копирование прогнозных курсов на все филиалы
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        05.01.2012 evseev - копирование курсов по филиалам
        16/02/2012 evseev - добавил выбор филиала для копирования курсов
*/

{mainhead.i}

define var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define variable s-target as date.
define variable s-bday as logi.

def var v-weekbeg as int. /*первый день недели*/
def var v-weekend as int. /*последний день недели*/

/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval.
else v-weekend = 6.
/*******************************************************************************************/

/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.
/*******************************************************************************************/

s-target = g-today + 1.

/*****определение - рабочий закрываемый день или нет****************************************/
find hol where hol.hol = g-today no-lock no-error.
if not available hol and weekday(g-today) >= v-weekbeg and weekday(g-today) <= v-weekend then s-bday = true.
else s-bday = false.
/*******************************************************************************************/

/**проверяем праздничный ли день************************************************************/
repeat while month(g-today) = month(s-target):
	find hol where hol.hol = s-target no-lock no-error.
	if not available hol and weekday(s-target) >= v-weekbeg and weekday(s-target) <= v-weekend then leave. /* если день рабочий, то продалжаем закрытие опер. дня */
	else s-target = s-target + 1. /* если день праздничный то переключаемся на следующий день, пока не найдем первый рабочий */
end.
/*******************************************************************************************/

for each crc /*where lookup(string(crc.crc),"2,4,11") > 0*/ no-lock:
  find first crcpro where crcpro.crc = crc.crc and crcpro.regdt = s-target no-lock no-error.
  if not avail crcpro then do:
    create crcpro.
    crcpro.crc = crc.crc.
    crcpro.regdt = s-target.
    crcpro.who = g-ofc.
    crcpro.whn = today.
    crcpro.rate[1] = crc.rate[1].
  end.
end.

form skip
    crcpro.crc format "z9" label "Вал"
    crc.des format "x(20)" label "Название валюты"
    crcpro.regdt format "99/99/9999" label "Дата"
    crcpro.rate[1] format ">>>9.9999" label "Курс" validate(crcpro.rate[1] > 0, "Неверное значение!")
    with width 48 row 5 centered scroll 1 15 down title " КУРСЫ " frame fr1.

{jabrw.i
&start     = " "

&head      = "crcpro"

&headkey   = "crc"

&index     = "crcdt_idx"

&formname  = "sysc"

&framename = "fr1"

&where     = " crcpro.regdt = s-target "

&addcon    = "no"

&deletecon = "no"

&precreate = " "

&postadd   = " "

&prechoose = " "

&predisplay = "find crc where crc.crc = crcpro.crc no-lock no-error."

&postdisplay = " "

&display   = " crcpro.crc crc.des crcpro.regdt crcpro.rate[1] "

&highlight = " crcpro.crc crc.des crcpro.regdt crcpro.rate[1] "

&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                           update crcpro.rate[1] with frame fr1.
                           crcpro.who = g-ofc. crcpro.whn = today.
                           hide message no-pause.
                      end."

&end = "hide frame fr1. find current crcpro no-lock."
}

{r-brfilial.i &proc = " crcprocpy(s-target) "}
/*{r-branch.i &proc = " crcprocpy(s-target) "}*/

run daycloserlogwrite("Установлены прогнозные курсы").

hide message no-pause.

