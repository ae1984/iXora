/* rmzsend.p
 * MODULE
        Название Программного Модуля
	Платежная система
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Формирование платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
	rmzsend1.p
 * MENU
        5-3-5-10
 * AUTHOR
	18.11.02 KOVAL
 * CHANGES
	23/12/2004 u00121 выделил платежи ДРР в отдельный пункт (LB-ДРР) СЗ ї 1279 от 22/12/2004
        16/05/2005 kanat - добавил обработку платежей по ПКО
        05/10/2005 rundoll - добавил очередь для срочных платежей
        19/08/2013 galina  - добавла обработку СМЭП
*/


{global.i}
run comm-con.

run sel("Выберите очередь","       LB        |       LBG       |   V2-Обычные   |   V2-Пенсионные  |       LB-ДРР    |        DRLB      |       DRPR      |       DRLBG     |       LBGS     |       SMEP     ").

case return-value:
 when "1" then do:
 	run rmzsend1.p("LB", "SCLEAR00",1,'a') "clrdoc" "".
 end.
 when "2" then do:
 	run rmzsend1.p("LBG","SGROSS00",2,'a') "clrdog" "g".
 end.
 when "3" then do:
 	run rmzsend1.p("V2","SCLEAR00",1,'n') "clrdoc" "".
 end.
 when "4" then do:
 	run rmzsend1.p("V2","SCLEAR00",1,'p') "clrdoc" "".
 end.
 when "5" then do:
 	run rmzsend1.p("LB","SCLEAR00",1,'PRR') "clrdoc" "". /*выделил платежи ДРР в отдельный пункт СЗ ї 1279 от 22/12/2004 - u00121 23/12/2004*/
 end.

/* 16/05/2005 kanat - добавил обработку платежей по ПКО */

 when "6" then do:
 run drrmzm(1,"mailps",g-today,"DRLB").
                for each que where que.pid = "DRLB" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.
 end.

 when "7" then do:
 run drrmzm(1,"mailps",g-today,"DRPR").
                for each que where que.pid = "DRPR" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.
 end.

 when "8" then do:
 run drrmzm(1,"mailps",g-today,"DRLBG").
                for each que where que.pid = "DRLBG" exclusive-lock.
                que.dw = today.
                que.tw = time.
                que.con = "F".
                que.rcod = "0".
                end.
                release que.
 end.

 when "9" then do:
        run rmzsend1.p("LBG","SGROSS00",2,'s') "clrdog" "g".
 end.
 when "10" then do:

 	run rmzsend1.p("SMP","SMEP0000",6,'n') "clrdos" "s".
 end.

/* 16/05/2005 kanat - добавил обработку платежей по ПКО */
end case.

