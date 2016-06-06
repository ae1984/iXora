/*
hand-kar
 * MODULE
        Операционка
 * DESCRIPTION
        Карточка с образцами подписей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Form-k
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        11/12/08 Levin Victor
 * BASES
 		BANK COMM
 * CHANGES
        21/01/2010 galina - определила переменную iin
        09/11/2010 madiyar - факт. и юрид. адрес
        04.09.2012 evseev - иин/бин
*/
{chk12_innbin.i}
def new shared var v-pref as char.
def new shared var v-name as char format "x(100)".
def new shared var v-addr1 as char format "x(100)".
def new shared var v-addr2 as char format "x(100)".
def new shared var pass as char format "x(70)".
def new shared var v-work as char format "x(100)".
def new shared var v-rnn as char format "x(70)".
def new shared var v-tel as char format "x(70)".
def new shared var my-log as char.
def new shared var v-iik as char.
def new shared var v-ofile as char.
def new shared var s-yur as logical.
def new shared var yur as logical.
def new shared var s-yurhand as logical.
def new shared var v-iin as char.
v-ofile = 'kart.htm'.

s-yurhand = yes.

MESSAGE "Юридическое лицо?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
  TITLE "Тип клиента" UPDATE s-yur.

if s-yur = no then do:
 def frame fr1
  v-name label 'Ф.И.О.' view-as fill-in size 70 by 1
  v-addr1 label 'Адрес прописки' view-as fill-in size 70 by 1
  v-addr2 label 'Адрес проживания' view-as fill-in size 70 by 1
  v-work label 'Место работы' view-as fill-in size 70 by 1
  pass label 'Данные паспорта (удостоверенья)' view-as fill-in size 70 by 1
  v-rnn label 'ИИН/БИН' validate((chk12_innbin(v-rnn)) ,'Неправильно введён БИН/ИИН') view-as fill-in size 70 by 1
  v-tel label 'Телефон' view-as fill-in size 70 by 1
 WITH 1 column ROW 10 centered width 100 TITLE "Заполните данные о клиенте для формирования карты ".
 my-log = ' '.
 v-iik = ' '.
update v-name v-addr1 v-addr2 v-work pass v-rnn v-tel with frame fr1.
end.

else do:
 def var chose as logical.
 MESSAGE "Юридическое лицо с печатью?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
  TITLE "Тип клиента" UPDATE s-yur.
 if s-yur = yes then do:
   def frame fr2
    v-name label 'Клиент' view-as fill-in size 70 by 1
  	v-addr1 label 'Юрид. адрес' view-as fill-in size 70 by 1
    v-addr2 label 'Факт. адрес' view-as fill-in size 70 by 1
  	v-tel  label 'Телефон клиента' view-as fill-in size 70 by 1
  WITH 1 column ROW 10 centered width 100 TITLE "Заполните данные о клиенте для формирования карты ".
  my-log = ''. v-iik = ''. pass = ''. v-rnn = ''. v-work = ''.
  update v-name v-addr1 v-addr2 v-tel with frame fr2.
 end.

 else do:
  def frame fr3
    v-name label 'Клиент Ф.И.О.' view-as fill-in size 70 by 1
  	v-addr1 label 'Юрид. адрес' view-as fill-in size 70 by 1
    v-addr2 label 'Факт. адрес' view-as fill-in size 70 by 1
  	v-tel label 'Телефон клиента' view-as fill-in size 70 by 1
 	v-rnn label 'ИИН/БИН' validate((chk12_innbin(v-rnn)) ,'Неправильно введён БИН/ИИН') view-as fill-in size 70 by 1
  WITH 1 column ROW 10 centered width 100 TITLE "Заполните данные о клиенте для формирования карты ".
  my-log = ' '.
  v-iik = ' '.
  v-work = ' '.
  yur = yes.
  pass = ' '.
  update v-name v-addr1 v-addr2 v-tel v-rnn with frame fr3.
 end.
end.
v-iin = v-rnn.
 run Form-k.