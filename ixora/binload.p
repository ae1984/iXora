/* binload.p
 * MODULE
        загрузка ИИН/БИН
 * DESCRIPTION
        Описание
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
        13.09.2012 evseev
 * BASES
        BANK COMM
 * CHANGES
        21.02.2013 evseev - tz-1629
        09.04.2013 evseev - tz-1678
        05.07.2013 evseev - tz-1544
*/

/*
1.	Условные обозначения:
БИН - бизнес идентификационный номер;
ИИН - индивидуальный идентификационный номер;
ИП - индивидуальный предприниматель;
НО - налоговый орган;
НП - налогоплательщик;
РНН - регистрационный номер налогоплательщика;
ФЛ - физическое лицо;
ЧН ¬- частный нотариус;
ЧСИ - частный судебный исполнитель;
ЮЛ - юридическое лицо.


2.	Описание сведений уполномоченного органа:
№	Название	Тип	Примечание

1	РНН	символьное

2	ИИН/БИН	символьное

3	Тип НП	числовое	1-ЮЛ;
0-ФЛ.

4	Признак резидентства	числовое	0-резидент;
1-нерезидент.

5	Постоянное учреждение	числовое	0-без образования постоянного учреждения;
1-постоянное.
Если НП резидент, то передается пустая строка.

6	Наименование ИП/ Наименование  ЮЛ	символьное	Если ФЛ, то передается пустая строка.

7	ФИО для ФЛ	символьное	Если  ЮЛ, то передается пустая строка.

8	Дата последнего снятия с регистрационного учета по местонахождению/местожительству	дата	Если снятия с регистрационного учета не производилось, то передается пустая строка.
Дата передается только в случае, если НП на текущую дату был снят с учета по местонахождению/местожительству во всех НО.

9	Причина снятия с учета	числовое	1-ликвидация, банкротство;
2-слияние (реорганизация);
3-разделение организации (реорганизация);
4-прекращение действия РНН/ИИН/БИН в связи со смертью;
5-ликвидация юридических лиц;
6-переезд за пределы Республики Казахстан;
7-признание недействительным РНН и объединение лицевых счетов;
8 - «Исключение из государственной базы данных».
В случае, если не было снятия с учета по вышеперечисленным причинам, то передается пустая строка.

10	Признак ФЛ, осуществляющего деятельность в качестве ИП, адвоката, ЧН, ЧСИ	числовое	1 – ФЛ не является ИП, ЧН, адвокатом или ЧСИ;
32 – ФЛ является ИП;
128 - ФЛ является ЧН;
64 - ФЛ является адвокатом;
256 - ФЛ является ЧСИ;
Если  ЮЛ, то передается пустое значение.

11	Признак бездействующего НП	числовое	0-действующий;
1-бездействующий.

12	Код НО по местожительству/местонахождению	числовое	Если НП не состоит в НО по  местожительству/местонахождению, то передается пустая строка.
Код НО передается без лидирующего нуля.
Код по местожительству передается лишь для ФЛ, не являющихся ИП, ЧН, ЧСИ или адвокатом.
Для ИП, адвокатов ЧН, ЧСИ, и ЮЛ передается код НО по соответствующему типу регистрационного учета (по месту нахождения ИП, адвоката, ЧН, ЧСИ, по месту нахождения/пребывания ЮЛ).

13	Наименование НО по местожительству /местонахождению	символьное	Если НП не состоит в НО по  местожительству/местонахождению, то передается пустая строка. Наименование НО по местожительству передается лишь для ФЛ, не являющихся ИП, ЧН, ЧСИ или адвокатом.
Для ИП, адвокатов ЧН, ЧСИ, и ЮЛ передается наименование НО по соответствующему типу регистрационного учета (по месту нахождения ИП, адвоката, ЧН, ЧСИ, по месту нахождения/пребывания ЮЛ).

14	Тип обработки записи	числовое	1-изменение записи о НП
2 - добавление записи о НП
3- удаление записи о НП
*/


{global.i}
define input parameter p-file as char. /*загрузка указанного файла, пример inis_RegData_2012-09-13_00-51-00.tab */
define input parameter p-ispart as logical. /*частичный - yes или нет файл*/
define input parameter p-isdel as logical. /*очищать перед загрузкой таблицу bin. yes - да, при условии что p-ispart = false*/

def var v-error    as logical no-undo.
def var v-exist1   as char    no-undo.

def var v-rnn as char no-undo.
def var v-bin as char no-undo.
def var f3  as char no-undo.
def var f4  as char no-undo.
def var f5  as char no-undo.
def var f6  as char no-undo.
def var f7  as char no-undo.
def var f8  as char no-undo.
def var f9  as char no-undo.
def var f10 as char no-undo.
def var f11 as char no-undo.
def var f12 as char no-undo.
def var f13 as char no-undo.
def var f14 as char no-undo.

def var testint as int no-undo.
def var teststr as char no-undo.
def var testdate as date no-undo.
def var countpart as int no-undo.


input through value( "find tmprnn/" + p-file + ";echo $?").
repeat:
    import unformatted v-exist1.
end.
if v-exist1 <> "0" then do:
   run savelog ("binload", p-file + " файл не найден.").
   return.
end.

def var v-txt as char no-undo.
def var v-count as int no-undo.
def stream r-in.

if p-ispart then countpart = 14. else countpart = 13.

if p-ispart = false and p-isdel then do:
   message "Очистка таблицы bin. Ждите...".
   for each bin exclusive-lock:
       run bin2his("D принудительное удаление").
       delete bin.
   end.
   message "Очистка таблицы bin завершена.".
end.

message "Загрузка. Ждите...".
input stream r-in from value("tmprnn/" + p-file).
v-count = 0.
repeat:
   v-count = v-count + 1.
   import stream r-in unformatted v-txt.
   if v-txt <> "" then do:
      if num-entries(v-txt,'|') <> countpart then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'В строке не ' + string(countpart) + ' значений'.
         next.
      end.
      v-rnn  = "ошибка".  v-rnn  = trim(entry(1,  v-txt, "|")) no-error.
      v-bin  = "ошибка".  v-bin  = trim(entry(2,  v-txt, "|")) no-error.
      f3     = "ошибка".  f3     = trim(entry(3,  v-txt, "|")) no-error.
      f4     = "ошибка".  f4     = trim(entry(4,  v-txt, "|")) no-error.
      f5     = "ошибка".  f5     = trim(entry(5,  v-txt, "|")) no-error.
      f6     = "ошибка".  f6     = trim(entry(6,  v-txt, "|")) no-error.
      f7     = "ошибка".  f7     = trim(entry(7,  v-txt, "|")) no-error.
      f8     = "ошибка".  f8     = trim(entry(8,  v-txt, "|")) no-error.
      f9     = "ошибка".  f9     = trim(entry(9,  v-txt, "|")) no-error. /*значение: 2012-03-15*/
      f10    = "ошибка".  f10    = trim(entry(10, v-txt, "|")) no-error.
      f11    = "ошибка".  f11    = trim(entry(11, v-txt, "|")) no-error.
      f12    = "ошибка".  f12    = trim(entry(12, v-txt, "|")) no-error.
      f13    = "ошибка".  f13    = trim(entry(13, v-txt, "|")) no-error.
      if p-ispart then do:
         f14  = "ошибка".  f14  = trim(entry(14, v-txt, "|")) no-error.
      end. else f14 = "".

      if  v-bin = "ошибка" then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'ИИН/БИН содержит ошибку'.
         next.
      end.
      if  length(v-bin) <> 12 then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'ИИН/БИН не содержит 12 символов'.
         next.
      end.
      testint = int(f3) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 3 неверно'.
         next.
      end.
      testint = int(f4) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 4 неверно'.
         next.
      end.
      testint = int(f5) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 5 неверно'.
         next.
      end.

      testint = int(f9) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 9 неверно'.
         next.
      end.

      testint = int(f10) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 10 неверно'.
         next.
      end.
      testint = int(f11) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 11 неверно'.
         next.
      end.
      testint = int(f12) no-error.
      if error-status:error then do:
         create bin_err.
           assign
              bin_err.rdt = today
              bin_err.usr = g-ofc
              bin_err.fname = p-file
              bin_err.line = v-count
              bin_err.line_val = v-txt
              bin_err.des = 'Значение в поле 12 неверно'.
         next.
      end.

      if p-ispart then do:
          testint = int(f14) no-error.
          if error-status:error then do:
             create bin_err.
               assign
                  bin_err.rdt = today
                  bin_err.usr = g-ofc
                  bin_err.fname = p-file
                  bin_err.line = v-count
                  bin_err.line_val = v-txt
                  bin_err.des = 'Значение в поле 14 неверно'.
             next.
          end.
      end.

      if f8 <> "" then do:
         teststr = "".
         v-error = false.
         if num-entries(f8) <> 3 then v-error = true.
         teststr = trim(entry(3,  f8, "-")) no-error.
         teststr = teststr + "/" + trim(entry(2,  f8, "-")) no-error.
         teststr = teststr + "/" + trim(entry(1,  f8, "-")) no-error.
         testdate = date(teststr) no-error.
         if error-status:error then do:
             create bin_err.
               assign
                  bin_err.rdt = today
                  bin_err.usr = g-ofc
                  bin_err.fname = p-file
                  bin_err.line = v-count
                  bin_err.line_val = v-txt
                  bin_err.des = 'Значение в поле 8 неверно. Формат "9999-99-99"'.
             next.
         end.
      end.

      find first bin where bin.bin =  v-bin exclusive-lock no-error.
      if not avail bin then do:
         create bin.
             assign
             bin.dt    =  today
             bin.usr   =  g-ofc
             bin.fname =  p-file
             bin.line  =  v-count
             bin.rnn   =  v-rnn
             bin.bin   =  v-bin
             bin.f3    =  f3
             bin.f4    =  f4
             bin.f5    =  f5
             bin.f6    =  f6
             bin.f7    =  f7
             bin.f8    =  f8
             bin.f9    =  f9
             bin.f10   =  f10
             bin.f11   =  f11
             bin.f12   =  f12
             bin.f13   =  f13
             bin.f14   =  f14.
         if f8 <> "" then do:
            run bin2his("D").
            delete bin.
         end. else if f14 = "3" then do:
            run bin2his("D").
            delete bin.
         end.
      end. else do:
         run bin2his("E").
         assign
         bin.dt    =  today
         bin.usr   =  g-ofc
         bin.fname =  p-file
         bin.line  =  v-count
         bin.rnn   =  v-rnn
         bin.bin   =  v-bin
         bin.f3    =  f3
         bin.f4    =  f4
         bin.f5    =  f5
         bin.f6    =  f6
         bin.f7    =  f7
         bin.f8    =  f8
         bin.f9    =  f9
         bin.f10   =  f10
         bin.f11   =  f11
         bin.f12   =  f12
         bin.f13   =  f13
         bin.f14   =  f14.
         if f8 <> "" then do:
            run bin2his("D").
            delete bin.
         end. else if f14 = "3" then do:
            run bin2his("D").
            delete bin.
         end.
      end.
   end.
end.
input stream r-in close.
/*message "Загрузка ИИН/БИН завершена."  view-as alert-box.*/

create histloadfile.
   assign histloadfile.module = "bin"
        histloadfile.regdt = today
        histloadfile.tm = time
        histloadfile.ofc  = g-ofc
        histloadfile.fname =  p-file.

procedure bin2his:
   define input parameter sts as char.
   create bin_hist.
     assign
         bin_hist.rdt   =  today  .
         bin_hist.sts   =  sts    .
         bin_hist.dt    =  bin.dt .
         bin_hist.usr   =  g-ofc  .
         bin_hist.fname =  bin.fname .
         bin_hist.line  =  bin.line  .
         bin_hist.rnn   =  bin.rnn   .
         bin_hist.bin   =  bin.bin   .
         bin_hist.f3    =  bin.f3    .
         bin_hist.f4    =  bin.f4    .
         bin_hist.f5    =  bin.f5    .
         bin_hist.f6    =  bin.f6    .
         bin_hist.f7    =  bin.f7    .
         bin_hist.f8    =  bin.f8    .
         bin_hist.f9    =  bin.f9    .
         bin_hist.f10   =  bin.f10   .
         bin_hist.f11   =  bin.f11   .
         bin_hist.f12   =  bin.f12   .
         bin_hist.f13   =  bin.f13   .
         bin_hist.f14   =  bin.f14   .
         bin_hist.f15   =  bin.f15   .
end procedure.