/* cifedt.p
 * MODULE
     Клиентская база
 * DESCRIPTION
     Ввод и редактирование данных клиента, открытие счетов
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
        31/12/99 pragma
 * CHANGES
        12/03/09 marinav - проверка клиента на специнструкции
        08.09.09 marinav - добавлен признак - действующий налогоплательщик
        25/01/2011 evseev - добавил шареные переменные s-name s-geo.
        13/02/2011 dmitriy - перекомпиляция
        13.06.2011 aigul - перекомпиляция в связи с изменениями с cif.f
        13.06.2011 lyubov - добавила возможность открыть счет физ.лицу, если он числится как бездейств. налогопл-к, убрала возможность вносить вручную гео-код
        20/06/2011 lyubov - вернула старую версию (Служебная записка от 17.06.2011 г. об отмене ТЗ)
        07/10/2011 evseev - переход на ИИН/БИН
        30.05.2012 evseev - проверка бездействующих налогоплательщиков из inacttaxpayer
        22.01.2013 Lyubov - ТЗ №1574, изменила проверку бездействующих налогоплательщиков, убрала поиск по inacttaxpayer
        30.01.2013 evseev - tz-1646
        09.04.2013 evseev - tz-1678
*/


{mainhead.i CFENTE}
{chbin.i}
def var v-rnn as char format "x(12)".
def var vbin as char format "x(12)".
def var v-geo as char format "x(3)".
def var v-name as char format "x(12)".
def var v-cod as char format "x(12)".
def var vvname as cha .
def var vname like cif.sname.
def var v-aaa as char format "x(60)".
def new shared var s-name like cif.name.
def new shared var s-geo as char.

def new shared temp-table temp
    field bank as char format 'x(60)'
    field aaa  like bank.aaa.aaa
    field crc  as char
    field cif  like bank.aaa.cif
    field name like bank.aaa.name
    field bal  as decimal
    index main is primary cif aaa.



{sixn.i
 &head = cif
 &headkey = cif
 &option = CIF
 &numsys = auto
 &numprg = xxx
 &keytype = string
 &nmbrcode = CIF
 &checkrnn = "run check."
 &subprg = s-cif
 &postadd = "
 cif.regdt = g-today.
 cif.who = g-ofc.
 cif.whn = g-today.
 cif.tim = time.
 cif.ofc = g-ofc.
 cif.jss = v-rnn.
 cif.bin = vbin.
"
}

/* ten - проверка по существующим РНН */
procedure check.

def frame fr " Введите номер РНН ! " skip(1) v-rnn  no-label at 5 skip(1)
       with centered row 4.
def frame fr3 " Введите номер ИИН/БИН ! " skip(1) vbin  no-label at 5 skip(1)
       with centered row 4.

def frame fr2 " Выберите гео-код клиента ! " skip(1) v-geo no-label v-name no-label  help "F2-выбор" at 5 skip(1) /*help "F2-выбор"*/
       with centered row 4.

on help of v-geo in frame fr2 do:
   run h-codfr('locat', output v-cod).
   v-geo = v-cod.
   find first codfr where codfr.codfr = 'locat' and codfr.code = v-geo no-lock no-error.
  if avail codfr then  do : v-name = codfr.name[1].  displ v-geo v-name with frame fr2. end.
  else displ v-geo  with frame fr2.
end.

v-log = false.
update v-geo with frame fr2.

s-geo = v-geo.
if v-geo = '1' then do:
    update vbin with frame fr3.

    find first fakecompany where fakecompany.bin = vbin no-lock no-error.
    if avail fakecompany then do:
        message "Данный ИИН/БИН находится в списке лжепредприятий! Клиент не может быть открыт!" view-as alert-box.
        v-log = true.
    end.

    find first rnn where rnn.bin = vbin no-lock no-error.
    if not avail rnn then do:
        find first rnnu where rnnu.bin = vbin no-lock no-error.
        if not avail rnnu then do:
            message "Данный ИИН/БИН отсутствует в НК МФ ! Клиент не может быть открыт!" view-as alert-box.
            v-log = true.
        end.
        else do:
            if  rnnu.activity = '1' and rnnu.rwho = '' then do:
                message "Налогоплательщик является бездействующим ! Клиент не может быть открыт! [1]" view-as alert-box.
                v-log = true.
            end.
        end.
    end.
    else do:
        s-name = rnn.lname + ' ' + rnn.fname + ' ' + rnn.mname.
        if rnn.info[2] = '1' and rnn.info[5] = '1' and rnn.rwho = '' then do:
            message "Налогоплательщик является бездействующим ! Клиент не может быть открыт! [1]" view-as alert-box.
            v-log = true.
        end.
        if rnn.info[4] > '0' and rnn.info[5] = '1' and rnn.rwho = '' then do:
            message "Налогоплательщик является бездействующим ! Клиент не может быть открыт! [1.1]" view-as alert-box.
            v-log = true.
        end.
    end.

    if v-log = false then do:

        def var v-s as char no-undo.
        if v-bin then v-s = vbin. else v-s = v-rnn.
        {r-branch.i &proc = "cifnk(v-s)"}

        v-aaa = ''.
        for each temp.
           v-aaa = v-aaa + temp.aaa + " " + temp.crc + ", " .
        end.
        find first temp no-lock no-error.
        if v-aaa ne "" then do:
                 message "Данный РНН уже существует. Клиент: " + temp.name + ", код: "  temp.cif +
                              " в " + temp.bank + ". Счета " + v-aaa +
                              " заблокированы инкассовыми распоряжениями/предписаниями налоговых органов, дополнительный код не может быть открыт!" view-as alert-box .
                 v-log = true.
        end.
        else do:
            if v-bin then
                find first cif where cif.bin = vbin no-lock no-error.
            else
                find first cif where cif.jss = v-rnn no-lock no-error.

            if avail cif  then do:
                        def var s as char no-undo.
                        if v-bin then s = "ИИН/БИН". else s = "РНН".
                        message "Данный " + s + " уже существует клиент: " + cif.name + " код: " + cif.cif +
                              "\n Создать еще один T-код? " view-as
                            alert-box QUESTION BUTTONS YES-NO UPDATE b2 AS LOGICAL  .
                       if b2 = true then  v-log = false. else v-log = true.
            end.
        end.
    end.
end.
else do:
 {imesg.i 2808} update vname.
 vvname = '*' + vname + '*' .
 find first cif where  ( caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vvname or
   caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vvname ) no-lock no-error.
  if avail cif then do:

             message "Клиент "  + cif.name + " код: " + cif.cif + "\n Создать еще один T-код? " view-as
                alert-box QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL  .
            if b = true then  v-log = false. else v-log = true.
 end.
  else do:  message 'no client'. pause 400. end.
end.
end procedure.


