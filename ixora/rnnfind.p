/* rnnfind.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Поиск клиентов по РНН
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
        08.12.2003 sasco
 * CHANGES
        24/08/2006 marinav - для ускорения поиска добавила запрос на физ / юр лицо
        08.09.09 marinav - добавлен признак - действующий
        14/12/2011 evseev - переход на ИИН/БИН
        10.05.2012 id00004 - добавил вторую строку для отображения организации
        25.10.2012 evseev - ТЗ-1511
*/

{chbin.i}

define temp-table tmp
            field rnn as character format 'x(12)'
            field bin as character format 'x(12)'
            field type as character format 'x(3)'
            field isIp as character format 'x(3)'
            field name as character format 'x(40)'
            index bin is primary bin type
            index name name.

def var fu as char view-as radio-set horizontal
                           radio-buttons "Да", "yes", "Нет", "no"
                           label "Физическое лицо?"
                           init "yes".
define variable v-rnn   as character format 'x(12)'.
define variable vbin   as character format 'x(12)'.
define variable v-fil   as character format 'x(5)'.
define variable v-lname as character format 'x(30)'.
define variable v-fname as character format 'x(30)'.
define variable v-mname as character format 'x(30)'.
define variable v-act as logi format 'Да/Нет'.
define variable name1 as character format 'x(50)'.
define variable name2 as character format 'x(50)'.

define query qt for tmp.

define browse bt query qt
             displ tmp.type label "Тип"
                   tmp.isIp label "ИП"
                   tmp.bin label "ИИН/БИН"
                   tmp.rnn label "РНН"
                   tmp.name label "Наименование"
             with row 1 centered 10 down title "Результаты поиска".

define frame ft bt help "ENTER - посмотреть"
             with row 1 centered overlay no-label no-box.

define frame ff
             rnn.trn   label 'РНН'
             rnn.byear label 'Дата рожд' skip
             rnn.lname label 'Фамилия' skip
             rnn.fname label 'Имя' skip
             rnn.mname label 'Отчество' skip
             "----------------------[ Документ ]----------------------" skip
             rnn.serpas label 'Серия док.'
             rnn.nompas label 'Номер док.'  skip
             rnn.datepas label 'Дата выдачи'
             rnn.orgpas label 'Кем выдан док.' skip
             "----------------------[ Адрес 1 ]-----------------------" skip
             rnn.post1 label 'Почт.'
             rnn.dist1 label 'Область' skip
             rnn.raj1 label 'Район' skip
             rnn.city1 label 'Город' skip
             rnn.street1 label 'Улица' skip
             rnn.housen1 label 'Дом'
             rnn.apartn1 label 'Кв.' skip
             "----------------------[ Адрес 2 ]-----------------------" skip
             rnn.post2 label 'Почт.'
             rnn.dist2 label 'Область' skip
             rnn.raj2 label 'Район' skip
             rnn.city2 label 'Город' skip
             rnn.street2 label 'Улица' skip
             rnn.housen2 label 'Дом'
             rnn.apartn2 label 'Кв.' skip
             "--------------------------------------------------------" skip
             rnn.citytel label 'Телефон (раб)'
             rnn.humtel label 'Телефон (дом)' skip
             "--------------------------------------------------------" skip
             v-act label 'Действующий НП'
             with row 1 centered overlay side-labels title "Физическое лицо".

define frame fu
             rnnu.trn     label 'РНН'
             rnnu.fil     label 'Форма собств.' skip
             name1 label 'Название' skip
             name2 label 'Название' skip
             "----------------------[ Адрес 1 ]-----------------------" skip
             rnnu.post1 label 'Почт.'
             rnnu.dist1 label 'Область' skip
             rnnu.raj1 label 'Район' skip
             rnnu.city1 label 'Город' skip
             rnnu.street1 label 'Улица'
             rnnu.housen1 label 'Дом'
             rnnu.apartn1 label 'Кв.' skip
             "----------------------[ Адрес 2 ]-----------------------" skip
             rnnu.post2 label 'Почт.'
             rnnu.dist2 label 'Область' skip
             rnnu.raj2 label 'Район' skip
             rnnu.city2 label 'Город' skip
             rnnu.street2 label 'Улица'
             rnnu.housen2 label 'Дом'
             rnnu.apartn2 label 'Кв.' skip
             "--------------------------------------------------------" skip
             rnnu.citytel label 'Телефон [1]'
             rnnu.numtelr label 'Телефон [2]'
             rnnu.numtelb label 'Телефон [3]' skip
             "--------------------------------------------------------" skip
             v-act label 'Действующий НП'
             with row 1 centered overlay side-labels title "Юридическое лицо".


define frame fin
             'Вы должны указать РНН или фамилию (наименование организации) / имя, отчество' skip(1)
             fu                  skip(1)
             vbin    label 'ИИН/БИН' skip
             v-rnn   label 'РНН' skip
             v-lname label 'Фамилия' skip
             v-fname label 'Имя' skip
             v-mname label 'Отчество' skip
             v-fil   label 'Форма собств' help 'ТОО, ЗАО, АО и т.д.'
             with row 2 centered 1 column side-labels overlay title 'Параметры поиска'.

on "return" of fu in frame fin apply "go" to frame fin.

update fu with frame fin.
update vbin with frame fin.

if vbin = '' then update v-rnn with frame fin.

if v-rnn = '' and vbin = '' then update v-lname v-fname v-mname v-fil with frame fin.

hide frame fin.

displ "Поиск. Ждите..." with row 3 centered overlay frame win. pause 0.

if vbin <> '' then do:
   for each rnn where rnn.bin = vbin no-lock:
       find tmp where tmp.bin = rnn.bin and tmp.type = "ФИЗ" and tmp.rnn = rnn.trn no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnn.trn.
       tmp.bin = rnn.bin.
       tmp.type = "ФИЗ".
       if rnn.info[2] = "1" or rnn.info[4] = "1" or rnn.info[4] = "2" or rnn.info[4] = "3" or rnn.info[4] = "4" then tmp.isIp = "Да". else tmp.isIp = "Нет".

       tmp.name = caps((trim(rnn.lname) + " " + trim(rnn.fname) + " " + trim(rnn.mname))).
   end.
   for each rnnu where rnnu.bin = vbin no-lock:
       find tmp where tmp.bin = rnnu.bin and tmp.type = " ЮР" and tmp.rnn = rnnu.trn no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnnu.trn.
       tmp.bin = rnnu.bin.
       tmp.type = " ЮР".
       tmp.isIp = "".
       tmp.name = caps(trim(trim(rnnu.fil) + " " + trim(rnnu.busname))).
   end.
end.
else
if v-rnn <> '' then do:
   for each rnn where rnn.trn = v-rnn no-lock:
       find tmp where tmp.rnn = rnn.trn and tmp.type = "ФИЗ" no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnn.trn.
       tmp.bin = rnn.bin.
       tmp.type = "ФИЗ".
       if rnn.info[2] = "1" or rnn.info[4] = "1" or rnn.info[4] = "2" or rnn.info[4] = "3" or rnn.info[4] = "4" then tmp.isIp = "Да". else tmp.isIp = "Нет".
       tmp.name = caps((trim(rnn.lname) + " " + trim(rnn.fname) + " " + trim(rnn.mname))).
   end.
   for each rnnu where rnnu.trn = v-rnn no-lock:
       find tmp where tmp.rnn = rnnu.trn and tmp.type = " ЮР" no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnnu.trn.
       tmp.bin = rnnu.bin.
       tmp.isIp = "".
       tmp.type = " ЮР".
       tmp.name = caps(trim(trim(rnnu.fil) + " " + trim(rnnu.busname))).
   end.
end.
else do:
   if fu = 'yes' then do:
       for each rnn where rnn.lname = v-lname and
                         (rnn.fname = v-fname or v-fname = '') and
                         (rnn.mname = v-mname or v-mname = '')
                         no-lock use-index fio:
           find tmp where tmp.rnn = rnn.trn and tmp.type = "ФИЗ" no-error.
           if not available tmp then create tmp.
           tmp.rnn = rnn.trn.
           tmp.bin = rnn.bin.
           if rnn.info[2] = "1" or rnn.info[4] = "1" or rnn.info[4] = "2" or rnn.info[4] = "3" or rnn.info[4] = "4" then tmp.isIp = "Да". else tmp.isIp = "Нет".
           tmp.type = "ФИЗ".
           tmp.name = caps((trim(rnn.lname) + " " + trim(rnn.fname) + " " + trim(rnn.mname))).
       end.
    end.
    else do:
       for each rnnu where rnnu.busname matches "*" + v-lname + "*" and
                           rnnu.fil     matches "*" + v-fil + "*"
                           no-lock :
           find tmp where tmp.rnn = rnnu.trn and tmp.type = " ЮР" no-error.
           if not available tmp then create tmp.
           tmp.rnn = rnnu.trn.
           tmp.bin = rnnu.bin.
           tmp.isIp = "".
           tmp.type = " ЮР".
           tmp.name = caps(trim(trim(rnnu.fil) + " " + trim(rnnu.busname))).
       end.
    end.
end.


hide frame win. pause 0.

on "return" of bt do:
   if not available tmp then leave.
   if tmp.type = "ФИЗ" then do:
      if v-bin then find first rnn where rnn.bin = tmp.bin no-lock no-error.
      else find first rnn where rnn.trn = tmp.rnn no-lock no-error.
      if rnn.info[5] = '0' then v-act = yes. else v-act = no.
      displ rnn except datdok datdoki rwho rdt info with frame ff.
      displ v-act with frame ff.
      pause.
      hide frame ff.
      pause 0.
   end.
   if tmp.type = " ЮР" then do:
      if v-bin then find first rnnu where rnnu.bin = tmp.bin no-lock no-error.
      else find first rnnu where rnnu.trn = tmp.rnn no-lock no-error.
      if rnnu.activity = '0' then v-act = yes. else v-act = no.

      name1 = substr(rnnu.busname,1, 50).
      name2 = substr(rnnu.busname,51, 100).

      displ rnnu except busname grname grdate grnom activity organiz owner enterpr
                        glava okpo buss datdok datdoki stat rwho rdt info with frame fu.
      displ name1 name2 v-act with frame fu.
      pause.
      hide frame fu.
      pause 0.
   end.
end.

open query qt for each tmp use-index name.
enable all with frame ft.
wait-for window-close of current-window focus browse bt.
hide all. pause 0.

