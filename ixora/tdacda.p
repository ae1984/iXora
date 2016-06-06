/* tdacda.p
 * MODULE
        Операционка
 * DESCRIPTION
        Отчет по депозитам открытым депозитам ФЛ.
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
 * BASES
        BANK COMM
 * AUTHOR
        25.01.2011 id00024
 * CHANGES

 * BASES
	BANK COMM
 * CHANGES
        31/05/11 dmitriy - запретил консолидацию из филиалов
        15/03/12 id00810 - название банка из sysc
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
		21.12.2012 id00477 - ТЗ 1630 добавление столбцов Гео-код и ИИН/БИН
*/

def var v-tda as char.					/* физики */
def var v-cda as char.					/* юрики */
def var v-lstmdt as date format "99/99/9999".		/* дата начала периода */
def var v-expdt  as date format "99/99/9999".		/* дата окончания периода */
def var v-select as integer.				/* выбор который делает юзверь */
def var v-path as char no-undo.
def var v-till as char format "x(46)".					/* ход */

def var s-ourbank as char no-undo.
find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
s-ourbank = trim(bank.sysc.chval).

v-select = 0.

define temp-table menu
    field num as int
    field itm as char.

def var i as int init 0.

do i = 1 to num-entries("Депозиты физ/юр лиц|Отчет по открытым депозитам физ лиц|Отчет по открытым депозитам юр лиц", "|"):
    create menu.
    assign menu.num = i menu.itm = entry(i, "Депозиты физ/юр лиц|Отчет по открытым депозитам физ лиц|Отчет по открытым депозитам юр лиц", "|").
end.

def query q1 for menu.

def browse b1
    query q1 no-lock
    display
        menu.itm label ' ' format "x(40)"
        with 3 down title "Выберите, пожалуйта:".

def frame fr1
    b1
with width 49 no-labels overlay 1 column /* column 1 */ .

on return of b1 in frame fr1
    do:
        apply "endkey" to frame fr1.
    end.


open query q1 for each menu.

if num-results("q1") = 0 then
do:
    MESSAGE "Записи не найдены."
          VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
                 TITLE "Ошибка".
    return.
end.

b1:title = "    Выберите, пожалуйта, вариант отчета     ".
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

def frame fr2 with width 49 1 column title "    Задайте, пожалуйста, период отчета        " .

v-select = menu.num.

  if v-select = 1 then do:
	v-tda = "TDA".
	v-cda = "CDA".
	v-lstmdt = 01/01/2008.
	v-expdt = today.
  end.
  if v-select = 2 then do:
	v-tda = "TDA".
	v-cda = "TDA".
	update v-lstmdt label "Начальная дата" with frame fr2.
	update v-expdt label "Конечная дата" with frame fr2.
  end.
  if v-select = 3 then do:
	v-tda = "CDA".
	v-cda = "CDA".
	update v-lstmdt label "Начальная дата" with frame fr2.
	update v-expdt label "Конечная дата" with frame fr2.
  end.


        if v-lstmdt eq ? or v-expdt eq ? or v-expdt > today then do: message "Эх, не корректно задан период отчета " skip " Нажмите OK для выхода "  view-as alert-box title "  Ошибка  ". return. end.


define temp-table menu2
    field num2 as int
    field itm2 as char.


def query q2 for menu2.

def browse b2
    query q2 no-lock
    display
        menu2.itm2 label ' ' format "x(40)"
        with 20 down title "       ".

def frame fr3
    b2
    with width 49 no-labels column 50 row 0.



if s-ourbank = "txb00" then
do:
    on return of b2 in frame fr3 do:
        apply "endkey" to frame fr3.
    end.

    disable b1 with frame fr1.


    find first bank.cmp no-lock no-error.
    if not avail bank.cmp then do:
        message " Не найдена запись cmp " view-as alert-box error.
        return.
    end.

    /*find first bank.sysc where bank.sysc.sysc = 'bankname' no-lock no-error.
    if avail bank.sysc and bank.cmp.name matches ("*" + bank.sysc.chval + "*")  then v-path = '/data/b'.
    else v-path = '/data/'.*/
    if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
    else v-path = '/data/b'.

    def var v-filials as char no-undo.
    for each txb where txb.consolid no-lock break by txb.txb:
      if v-filials <> "" then v-filials = v-filials + " | ".
      v-filials = v-filials + string(txb.txb + 1) + ". " + txb.name.
    end.
    v-filials = " 0. КОНСОЛИДИРОВАННЫЙ ОТЧЕТ | " + v-filials.


    v-select = 0.

    do i = 1 to num-entries(v-filials, "|"):
        create menu2.
        assign menu2.num2 = i menu2.itm2 = entry(i, v-filials, "|").
    end.


    open query q2 for each menu2.

    if num-results("q2") = 0 then do:
        MESSAGE "Записи не найдены." VIEW-AS ALERT-BOX INFORMATION BUTTONS ok TITLE "Ошибка".
        return.
    end.

    b2:title = "     Выберите, пожалуйта, филиал банка     ".
    b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
    ENABLE all with frame fr3.
    apply "value-changed" to b2 in frame fr3.
    WAIT-FOR endkey of frame fr3.

    v-select = integer(entry(1,trim(menu2.itm2),'.')) + 1.



    if v-select = 0 then return.

    def frame fr4 with width 49 column 0 row 14 title "           Ход формирования отчета            ".

    output to value("tdacda.csv") append.
    put "Наименование депозита;Код клиента;ФИО вкладчика;Номер счета;Валюта;% ставка;Сумма депозита;Дата открытия;Дата Закрытия;Вид ставки;Гео-код;ИИН/БИН;" skip.
    output close.

    for each comm.txb where comm.txb.consolid and
             (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run tdacda01(v-tda,v-cda,v-lstmdt,v-expdt).
        v-till = v-till + ">>>".
        display v-till with no-label frame fr4.
        pause 0.
    end.
end.
else do:
        output to value("tdacda.csv") append.
        put "Наименование депозита;Код клиента;ФИО вкладчика;Номер счета;Валюта;% ставка;Сумма депозита;Дата открытия;Дата Закрытия;Вид ставки;Гео-код;ИИН/БИН;" skip.
        output close.

        run tdacda02(v-tda,v-cda,v-lstmdt,v-expdt).
        v-till = v-till + ">>>".
        /*display v-till with no-label frame fr4.
        pause 0.*/
end.

if connected ("txb")  then disconnect "txb".

def frame fr5 with width 49 column 0 row 17.
display "Подождите, открываю отчет...                  "  with no-label frame fr5.
pause 0.


unix silent value("cptwin tdacda.csv excel && rm tdacda.csv").


