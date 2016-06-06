/* taxrnn.i
 * MODULE
        База РНН
 * DESCRIPTION
        Ввод/редактирование базы РНН
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.4.15
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        15.11.2003 nadejda - добавила прописывание полей rwho, rdt
        08.09.2005 sasco   - убрал прописывание полей rwho, rdt :-)
        28.09.2005 u00121  - при работе с юр лицами исправил    find current comm.rnn no-lock.  на    find current comm.rnnu no-lock.
        05/07/2006 u00568 evgeniy - добавил автоопределение - юр/физ и проверку на контрольный ключ + оптимизация
        06/07/2006 u00568 evgeniy - теперь удобнее и правильнее.
        17.06.10   marinav - заполнить поля кто и когда
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        04.09.2012 evseev - иин/бин
*/

{getfromrnn.i}
{comm-rnn.i}


def var isfiz as log init yes format "да/нет".
def shared var g-ofc as char.

isfiz = not is_it_jur_person_rnn(nn).
if isfiz then
  find first comm.rnn where comm.rnn.bin = nn no-lock no-error.
else
  find first comm.rnnu where comm.rnnu.bin = nn no-lock no-error.


if not avail rnnu and not avail rnn then do:
    if length(nn) <> 12 then do:
      message "Длина ИИН/БИН не 12!~nНе разрешено добавлять в базу данных" view-as alert-box title "Внимание".
      return nn.
    end.
    if nn = fill (substring (nn, 1, 1), 12) then do:
      message "Неверный ИИН/БИН!~Не разрешено добавлять в базу данных" view-as alert-box title "Внимание".
      return nn.
    end.

    /*if comm-rnn(nn) then do:
     message "Не верный РНН!~nНе прошел проверку на контрольный ключ!" view-as alert-box title "Внимание".
     return nn.
    end.*/
end.

def frame sfrnn
    comm.rnn.bin view-as text format "999999999999" label "ИИН/БИН" skip
    comm.rnn.lname format "x(35)" label "Фамилия" skip
    comm.rnn.fname format "x(20)" label "Имя" skip
    comm.rnn.mname format "x(20)" label "Отчество" skip
    comm.rnn.street1 format "x(30)" label "Улица" skip
    comm.rnn.housen1 format "x(7)"  label "Дом" skip
    comm.rnn.apartn1 format "x(5)"  label "Кв-ра"
    with side-labels centered overlay view-as dialog-box.

def frame sfrnnu
    comm.rnnu.bin view-as text format "999999999999" label "ИИН/БИН" skip
    comm.rnnu.busname format "x(50)" label "Наименование" skip
    comm.rnnu.street1 format "x(30)" label "Улица" skip
    comm.rnnu.housen1 format "x(7)"  label "Дом" skip
    comm.rnnu.apartn1 format "x(5)"  label "Кв-ра"
    with side-labels centered overlay view-as dialog-box.


if isfiz then do transaction on error undo, return:
   find first comm.rnn where comm.rnn.bin = nn USE-INDEX bin exclusive-lock no-error.
   if not avail comm.rnn then create comm.rnn.
   comm.rnn.bin = nn.
   update
     comm.rnn.bin skip
     comm.rnn.lname validate( (length(rnn.lname) > 0 ), "Поле Фамилия должно быть заполнено") skip
     comm.rnn.fname validate( (length(rnn.fname) > 0 ), "Поле Имя должно быть заполнено") skip
     comm.rnn.mname skip
     comm.rnn.street1 skip
     comm.rnn.housen1 skip
     comm.rnn.apartn1
     WITH side-labels 1 column FRAME sfrnn.
   hide frame sfrnn.

   comm.rnn.rwho = g-ofc.
   comm.rnn.rdt = today.

   find current comm.rnn no-lock.
   release rnnu.
   return comm.rnn.bin.
end.
else do transaction on error undo, return:
   find first comm.rnnu where comm.rnnu.bin = nn USE-INDEX bin exclusive-lock no-error.
   if not avail rnnu then create comm.rnnu.
   comm.rnnu.bin = nn.
   update
     comm.rnnu.bin skip
     comm.rnnu.busname validate( (length(rnnu.busname) > 0 ), "Поле Наименование должно быть заполнено") skip
     comm.rnnu.street1 skip
     comm.rnnu.housen1 skip
     comm.rnnu.apartn1
     WITH side-labels 1 column FRAME sfrnnu.
   hide frame sfrnnu.

   comm.rnnu.rwho = g-ofc.
   comm.rnnu.rdt = today.

   find current comm.rnnu no-lock. /*28.09.2005 u00121 - здесь было comm.rnn, соответсвенно ругался при работе с юр лицом*/
   release rnn.
   return comm.rnnu.bin.
end.


