/* rnncont.p
 * MODULE

 * DESCRIPTION
        Возможность разрешить иткрывать счет бездействующему налогоплательщику
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
        09.09.2009 marinav
 * CHANGES
        13/12/2011 evseev - ТЗ-625. Переход на ИИН/БИН
        22.01.2013 Lyubov - ТЗ №1574, изменила слова "открытие счета" на "заведение cif-кода"
*/

{chbin.i}
{global.i}
define temp-table tmp
            field rnn as character format 'x(12)'
            field bin as character format 'x(12)'
            field type as character format 'x(3)'
            field name as character format 'x(40)'
            index rnn is primary rnn type
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
define variable v-cont as logi format 'Да/Нет'.

define query qt for tmp.

define browse bt query qt
             displ tmp.type label "Тип"
                   tmp.rnn label "РНН"
                   tmp.bin label "ИИН/БИН"
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
             v-act label 'Действующий НП' skip
             "--------------------------------------------------------" skip
             v-cont label 'Разрешено заведение CIF кода ?'
             "    "  rnn.rwho no-label " " rnn.rdt no-label
             with row 1 centered overlay side-labels title "Физическое лицо".

define frame fu
             rnnu.trn     label 'РНН'
             rnnu.fil     label 'Форма собств.' skip
             rnnu.busname label 'Название' skip
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
             v-act label 'Действующий НП' skip
             "--------------------------------------------------------" skip
             v-cont label 'Разрешено заведение CIF кода ?'
             "    "  rnnu.rwho no-label " " rnnu.rdt no-label
             with row 1 centered overlay side-labels title "Юридическое лицо".


define frame fin
             'Вы должны указать РНН или фамилию (наименование организации) / имя, отчество' skip(1)
             fu                  skip(1)
             vbin   label 'ИИН/БИН' skip
             v-rnn   label 'РНН' skip
             v-lname label 'Фамилия' skip
             v-fname label 'Имя' skip
             v-mname label 'Отчество' skip
             v-fil   label 'Форма собств' help 'ТОО, ЗАО, АО и т.д.'
             with row 2 centered 1 column side-labels overlay title 'Параметры поиска'.

on "return" of fu in frame fin apply "go" to frame fin.

update fu with frame fin.

if v-bin then do:
  update vbin with frame fin.
  if vbin = '' then update v-rnn with frame fin.
end. else do:
  update v-rnn with frame fin.
end.
if v-rnn = '' and  vbin = '' then update v-lname v-fname v-mname v-fil with frame fin.

hide frame fin.

displ "Поиск. Ждите..." with row 3 centered overlay frame win. pause 0.

if vbin <> '' then do:
   for each rnn where rnn.bin = vbin no-lock:
       find tmp where tmp.bin = rnn.bin and tmp.type = "ФИЗ" no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnn.trn.
       tmp.bin = rnn.bin.
       tmp.type = "ФИЗ".
       tmp.name = caps((trim(rnn.lname) + " " + trim(rnn.fname) + " " + trim(rnn.mname))).
   end.
   for each rnnu where rnnu.bin = vbin no-lock:
       find tmp where tmp.bin = rnnu.bin and tmp.type = " ЮР" no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnnu.trn.
       tmp.bin = rnnu.bin.
       tmp.type = " ЮР".
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
       tmp.name = caps((trim(rnn.lname) + " " + trim(rnn.fname) + " " + trim(rnn.mname))).
   end.
   for each rnnu where rnnu.trn = v-rnn no-lock:
       find tmp where tmp.rnn = rnnu.trn and tmp.type = " ЮР" no-error.
       if not available tmp then create tmp.
       tmp.rnn = rnnu.trn.
       tmp.bin = rnnu.bin.
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
           tmp.type = " ЮР".
           tmp.name = caps(trim(trim(rnnu.fil) + " " + trim(rnnu.busname))).
       end.
    end.
end.


hide frame win. pause 0.

on "return" of bt do:
   if not available tmp then leave.
   if tmp.type = "ФИЗ" then do:
      if v-bin then find first rnn where rnn.bin = tmp.bin no-error.
      else find first rnn where rnn.trn = tmp.rnn no-error.
      if rnn.info[5] = '0' then v-act = yes. else v-act = no.
      if v-act = no and rnn.rwho = '' then v-cont = no. else v-cont = yes.
      displ rnn except datdok datdoki info with frame ff.
      displ v-act with frame ff.
      displ v-cont with frame ff.
      if v-act = no then update v-cont with frame ff.
      pause.
      if v-act = no and v-cont = yes then do: assign rnn.rwho = g-ofc rnn.rdt = g-today. run savelog( "rnncont", "Разрешено заведение CIF кода : " + rnn.trn + " : " + rnn.bin ). end.
      if v-act = no and v-cont = no  then do: assign rnn.rwho = "" rnn.rdt = ?.  run savelog( "rnncont", "Снято разрешено на заведение CIF кода : " + rnn.trn + " : " + rnn.bin ). end.
      hide frame ff.
      pause 0.


   end.
   if tmp.type = " ЮР" then do:
      if v-bin then find first rnnu where rnnu.bin = tmp.bin no-error.
      else find first rnnu where rnnu.trn = tmp.rnn no-error.
      if rnnu.activity = '0' then v-act = yes. else v-act = no.
      if v-act = no and rnnu.rwho = '' then v-cont = no. else v-cont = yes.
      displ rnnu except grname grdate grnom activity organiz owner enterpr
                        glava okpo buss datdok datdoki stat info with frame fu.
      displ v-act with frame fu.
      displ v-cont with frame fu.
      if v-act = no then update v-cont with frame fu.
      pause.
      if v-act = no and v-cont = yes then do: assign rnnu.rwho = g-ofc rnnu.rdt = g-today. run savelog( "rnncont", "Разрешено заведение CIF кода : " + rnnu.trn + " : " + rnnu.bin ). end.
      if v-act = no and v-cont = no  then do: assign rnnu.rwho = "" rnnu.rdt = ?.   run savelog( "rnncont", "Снято разрешено на заведение CIF кода : " + rnnu.trn + " : " + rnnu.bin ). end.
      hide frame fu.
      pause 0.
   end.
end.

open query qt for each tmp use-index name.
enable all with frame ft.
wait-for window-close of current-window focus browse bt.
hide all. pause 0.

