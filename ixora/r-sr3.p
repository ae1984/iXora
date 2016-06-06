/* r-sr3.p
 * MODULE
	Отчетность
 * DESCRIPTION
	Остатки по сроч.счетам сроком менее 3 мес
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
	nmenu
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	r-srokm3.p
 * MENU
        Перечень пунктов Меню Прагмы 
	8-9-1-3
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        25.11.2004 suchkov - Добавил Атырау. Как руки дойдут, переделаю нормально, честно!
	27.04.2006 u00121  - переделал конекты к базам филиалов, через comm.txb - теперь точно все по нормальному, честно :)
*/
def var v-pass as char.

for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

def var v-dat as date.
v-dat = today.
update v-dat label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .


unix silent value ("echo > a0.out").

{r-branch.i &proc = "r-srokm3(input v-dat)"}

run menu-prt( 'a0.out' ).

