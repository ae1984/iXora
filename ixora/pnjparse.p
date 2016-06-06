/* pnjparse.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Поиск реестров отправленных пенсионных платежей за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.3.9.8
 * AUTHOR
        02.02.2004 sasco
 * CHANGES
        29.03.2004 sasco Исправил парсинг свифтовки (обработка отдельного плательщика)
*/

{msg-box.i}

define temp-table trz
            field rmz like remtrz.remtrz
            field rdt as date
            field ref as character 
            field rnn as character format 'x(12)'
            field name as character format 'x(50)'
            field acc like aaa.aaa
            field sum as character 
            field npp as character
            field pacc as character 
            field prnn as character 
            field pname as character 
            index idx_trz is primary rmz.

define temp-table tsw
            field rmz like remtrz.remtrz
            field npp as integer 
            field sum as character format 'x(15)'
            field sik as character format 'x(16)'
            field ln as character format 'x(50)'
            field fn as character format 'x(50)'
            field mn as character format 'x(50)'
            field bdate as date
            field rnn as character format 'x(12)'
            index idx_tsw is primary rmz.

define variable v-dir as character initial "./".
define variable nam1 as character initial "".
define variable nam2 as character initial "".
define variable v-d1 as date initial today.
define variable v-d2 as date initial today.

find sysc where sysc.sysc = "PSJIN" no-lock no-error.
v-dir = sysc.chval.

/* ------------------------------ */

update v-d1 label "Период с..." v-d2 label "по..." with row 2 centered side-labels frame getdat title "Реестры пенс. платежей".
hide frame getdat.

message "Включить платежи со счетов клиентов? " update chkaaa as logical.

/* ------------------------------ */

for each remtrz where remtrz.rdt >= v-d1 and remtrz.rdt <= v-d2 no-lock:
    if substr (remtrz.rcvinfo[1], 2, 3) <> "PSJ" then next.
    run SHOW-MSG-BOX (remtrz.remtrz + " " + string (remtrz.rdt)).
    run PARSESWT (v-dir + remtrz.remtrz, remtrz.remtrz).
end.

/* ------------------------------ */

find first tsw no-error.
if not avail tsw then do:
   run HIDE-MSG-BOX.
   message "За указанный период данных нет!" view-as alert-box title "".
   return.
end.

/* ------------------------------ */

run SHOW-MSG-BOX ("Формирование отчета...").

output to rpt.csv.
put unformatted "RMZ;Дата;N плат/пор;Сумма RMZ;"
                "Отправитель;РНН;Счет;"
                "Получатель;РНН;Счет;"
                "Плательщик;РНН;СИК;Сумма;Дата рожд" skip.

FOR EACH trz:

    if not chkaaa then do:
       find aaa where aaa.aaa = trz.acc no-lock no-error.
       if available aaa then next.
    end.
    
    for each tsw where tsw.rmz = trz.rmz:
        put unformatted trz.rmz ";" trz.rdt ";" trz.npp ";" trz.sum ";"
                        trz.name ";`" trz.rnn ";`" trz.acc ";" 
                        trz.pname ";`" trz.prnn ";`" trz.pacc ";".
        put unformatted tsw.ln + " " + tsw.fn + " " + tsw.mn ";`" tsw.rnn ";" tsw.sik ";" tsw.sum ";" tsw.bdate 
                        skip.
    end.

end.
output close.
unix silent cptwin rpt.csv excel.

run HIDE-MSG-BOX.

/* ------------------------------ */

/* ------------------ */
/* ПАРСИНГ СВИФТОВОК  */
/* ------------------ */
procedure PARSESWT.

   define input parameter v-file as char.
   define input parameter v-rmz as char.

   define variable st as character.
   define variable log as logical.
   define variable i as integer.

   log = FALSE.
   input from value (v-file).

   create trz.
   assign trz.rmz = v-rmz.

   do while true on endkey undo, leave:
      import unformatted st.

      /* разбор заголовка */
      if st begins ":50:/D/" then do:

         trz.acc = SUBSTR (st, 8).

         import unformatted st.
         trz.rnn = SUBSTR (st, 6).

         import unformatted st.
         trz.name = SUBSTR (st, 7).

      end.

      if st begins ":59:" then do:

         trz.pacc = SUBSTR (st, 5).

         import unformatted st.
         trz.prnn = SUBSTR (st, 6).

         import unformatted st.
         trz.pname = SUBSTR (st, 7).

      end.

      if st begins ":32A:" then assign trz.rdt = DATE (SUBSTR(st, 10, 2) + "/" + SUBSTR(st, 8, 2) + "/" + SUBSTR(st, 6, 2))
                                       trz.sum = SUBSTR(st, 15).

      if st begins ":70:/NUM/" then assign trz.npp = substr (st, 10).

      if st begins ":20:" then trz.ref = SUBSTR (st, 5).

      /* разбор списка */
      if st begins ":21:" then do:

         create tsw.
         tsw.rmz = v-rmz.

         tsw.npp = INTEGER (SUBSTR(st, 5)).
         
      end.

      if st begins ':32B:' then tsw.sum = SUBSTR(st, 9).
      if st begins ':70:/OPV/' then tsw.sik = SUBSTR(st, 10).
      if st begins '//FM/' then tsw.ln = entry(1, SUBSTR(st, 6), "/").
      if st begins '//NM/' then tsw.fn = entry(1, SUBSTR(st, 6), "/").
      if st begins '//FT/' then tsw.mn = entry(1, SUBSTR(st, 6), "/").
      if st begins '//DT/' then tsw.bdate = DATE (SUBSTR(st, 12, 2) + "/" + SUBSTR(st, 10, 2) + "/" + SUBSTR(st, 6, 4)).
      if st begins '//RNN/' then tsw.rnn = SUBSTR(st, 7).

   end.
   input close.

end procedure.

