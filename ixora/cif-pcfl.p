/* cif-pcfl.p
 * MODULE
        Новые клиенты и открытие счетов
 * DESCRIPTION
	    Платежные карты: физ.лица, инд.выпуск/перевыпуск
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2 верхнее меню Пкарты
 * AUTHOR
        17.05.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        10/06/2013 yerganat - в процедуру cif-kart добавил параметр
        22/07/2013 galina - ТЗ1854 вывод изменненных полей при контроле перевыпуска
        23/07/2013 galina - явно указала ширину фрейма fchange
        01.08.2013 Lyubov  - ТЗ 1941, в заявление подтягиеваем резидество из salary-файла
        04/10/2013 galina - ТЗ1470 выпуск, перевыпуск и допкарты доступны только для определенных продуктов
        04/10/2013 galina - ТЗ2071 по F2 для v-pcprod выводим поле code и name[2]
        01/11/2013 galina - ТЗ2162 убрала возможность редактирования вида карты при перевыпуске по причине 2
        07/11/2013 galina - ТЗ2178 убрала возможность выбора причины 2 при перевыпуске
        07/11/2013 galina - ТЗ2178
        25/11/2013 galina - ТЗ2199 подтягиваем данные по клиенту из другого филиала по ИИН
*/

{global.i}
{yes-no.i}
{chbin.i}
{nbankBik.i}
{chk-namelat.i}

def new shared var s-aaa   like aaa.aaa.
def new shared var s-cword as char.
def     shared var s-cif   like cif.cif.
def var v-aaa  like aaa.aaa no-undo.
def var v-crcc  as   char    no-undo.
def var v-rezid as   char    no-undo.
def temp-table t-pccards
    field aaa    as char
    field crc    as char
    field sname  as char
    field pcard  as char
    field pcard1 as char
    field sts    as char
    field stsn   as char
    field namef  as char.

DEFINE QUERY q1 FOR t-pccards.

def browse b1
	query q1
	displ t-pccards.aaa    label 'Счет'   format 'x(20)'
          t-pccards.crc    label 'Вал'    format 'x(03)'
          t-pccards.sname  label 'ФИО'    format 'x(35)'
          t-pccards.pcard1 label 'Карта'  format 'x(16)'
          t-pccards.stsn   label 'Статус' format 'x(12)'

    with 12 down title ' Платежные карточки клиента ' + s-cif.

DEFINE BUTTON bnew LABEL "Новое заявление".
DEFINE BUTTON badd LABEL "Доп. карта".
DEFINE BUTTON bedt LABEL "Редактировать".
DEFINE BUTTON bren LABEL "Перевыпуск".
DEFINE BUTTON bcnt LABEL "Контроль".
DEFINE BUTTON bprn LABEL "Печать".
DEFINE BUTTON bext LABEL "Выход".
def var v-schet    as char no-undo.
def var v-bank     as char no-undo.
def var v-rnn      as char no-undo.
def var v-cif      as char no-undo.
def var v-iin      as char no-undo.
def var v-sname    as char no-undo.
def var v-fname    as char no-undo.
def var v-mname    as char no-undo.
def var v-namelat1 as char no-undo.
def var v-namelat2 as char no-undo.
def var v-birth    as date no-undo.
def var v-mail     as char no-undo.
def var v-tel      as char no-undo extent 2.
def var v-addr     as char no-undo extent 2.
def var v-work     as char no-undo.
def var v-birthdt  as char no-undo.
def var v-birtplc  as char no-undo.
def var v-nomer    as char no-undo.
def var v-nomdoc   as char no-undo.
def var v-issdt1   as date no-undo.
def var v-expdt1   as date no-undo.
def var v-isswho   as char no-undo.
def var v-cword    as char no-undo.
def var v-crcname  as char no-undo.
def var v-pctype   as char no-undo.
def var v-pctypen  as char no-undo.
def var v-pctype1  as char no-undo.
def var v-pcprod   as char no-undo.
def var v-rez      as logi no-undo format "Да/Нет".
def var v-country  as char no-undo.
def var v-ccountry as char no-undo.
def var v-migrn    as char no-undo.
def var v-migrdt1  as date no-undo.
def var v-migrdt2  as date no-undo.
def var v-publicf  as logi no-undo.
def var v-position as char no-undo.
def var v-offsh    as logi no-undo.
def var v-offshd   as char no-undo.
def var v-quest1   as logi no-undo format "Да/Нет".
def var v-quest2   as logi no-undo format "Да/Нет".
def var v-lquest1  as char no-undo.
def var v-lquest2  as char no-undo.
def var v-sts      as char no-undo.
def var v-label    as char no-undo.
def var v-sup      as logi no-undo.
def var v-infile   as char no-undo.
def var v-name     as char no-undo.
def var v-latname  as char no-undo.
def var v-addr1    as char no-undo.
def var v-addr2    as char no-undo.
def var v-telh     as char no-undo.
def var v-telm     as char no-undo.
def var v-issdoc   as char no-undo.
def var v-issdt    as char no-undo.
def var v-expdt    as char no-undo.
def var v-str      as char no-undo.
def var v-type     as char no-undo.
def var v-cifm     as logi no-undo.
def var v-cifmin   as char no-undo.
def var v-crc      as int  no-undo.
def var v-new      as logi no-undo.
def var v-first    as logi no-undo.
def var famlist    as char no-undo format 'x(60)'.
def var i          as int  no-undo.
def var v-ofile    as char no-undo init 'zayav.htm'.
def var v-fio      as char no-undo.
def var v-renew    as logi no-undo.
def var v-reas     as char no-undo.
def var v-reason   as char no-undo.
def var v-newsts   as char no-undo.
def var v-contr    as logi no-undo.
def var v-id       as int  no-undo.
def var v-sel      as int  no-undo.
def var v-holder   as char no-undo.

def buffer b-pcstaff0 for pcstaff0.
def buffer b-codfr    for codfr.
def stream v-out.

form
        v-cif      label " Код клиента             " format "x(06)"  v-aaa label "           Тек.счет по платежн.карте " format "x(20)" validate(can-find(first aaa where aaa.aaa = v-aaa and aaa.cif = v-cif and can-do('220330,220430',string(aaa.gl)) and aaa.sta ne 'c' no-lock), "Нет такого счета! F2-помощь") skip(1)
        v-pcprod   label " Вид продукта            " format "x(10)" validate(can-find(first codfr where codfr.codfr = 'pcprod' and codfr.code = v-pcprod and (lookup(codfr.code,'FPA,Staff') = 0 or v-sup = yes)no-lock), "Нет такого вида продукта ПК! F2-помощь")
                                                                    v-pctype label "                       Вид карты " format "x(01)" validate(can-find(first codfr where codfr.codfr = 'pctype' and codfr.code = v-pctype and codfr.code <> 'B' no-lock), "Нет такого вида платежных карт! F2-помощь")
                                                                    v-pctypen no-label format 'x(10)' skip(1)
        v-label no-label format 'x(26)' v-rnn no-label colon 26 format "x(12)"  skip
        v-iin      label " ИИН                     " format "x(12)" validate(length(v-iin) = 12, "Некорректный ИИН") help "Введите ИИН" skip(1)
        v-sname    label " Фамилия                 " format "x(30)" skip
        v-fname    label " Имя                     " format "x(20)" skip
        v-mname    label " Отчество                " format "x(20)" skip
        v-namelat1 label " Фамилия (лат.)          " format "x(20)" validate (v-namelat1 <> '', "Поле обязательно к заполнению!") v-namelat2  label "  Имя (лат.) " format "x(20)" validate (v-namelat2 <> '', "Поле обязательно к заполнению!") skip
        v-birth    label " Дата рождения           " format "99/99/9999" v-cword  label "                   Кодовое слово " format 'x(15)' validate (v-cword <> '', "Поле обязательно к заполнению!") skip(1)
        v-mail     label " E-mail                  " format "x(50)" skip
        v-work     label " Место работы            " format "x(30)" skip
        v-tel[1]   label " Телефон домашний        " format 'x(12)' v-tel[2] label "                  Телефон моб. " format 'x(12)' skip
        v-addr[1]  label " Адрес регистрации       " format "x(70)" skip
        v-addr[2]  label " Адрес проживания        " format "x(70)" skip(1)
        v-nomdoc   label " Документ,удост.личность " format "x(15)" v-isswho label "                  Кем выдан " format 'x(15)' skip
        v-issdt1   label " Когда выдан             " format "99/99/9999"  v-expdt1 label "                   Срок действия " format '99/99/9999' skip(1)
        v-crcname  label " Вид валюты              " format "x(03)" skip
        v-rez      label " Резидент да/нет         " format "Да/нет" skip
        v-country  label " Страна                  " format "x(03)"  validate(v-country ne '' and can-find(first codfr where codfr.codfr = 'iso3166' and codfr.name[2] = v-country no-lock), "Нет такой страны в справочнике кодов стран! F2-помощь") skip
        v-migrn    label " Миграционная карта №    " format "x(10)"  skip
        v-migrdt1  label " Срок пребывания с       " format '99/99/9999' v-migrdt2 label "                              по " format '99/99/9999'skip
        v-publicf  label " Публич.должн.лицо да/нет" format "Да/нет" skip
        v-position label " Должность               " format "x(30)"  skip
        v-offsh    label " Счета в оффшорных зонах " format "Да/нет" skip
        v-offshd   label " Доп.информация по счетам" format "x(30)"  skip
        v-lquest1  no-label format 'x(26)' v-quest1 no-label colon 26 skip
        v-lquest2  no-label format 'x(26)' v-quest2 no-label colon 26

        with side-labels centered row 3 title ' Заявление на выпуск ПК ' width 100 frame frpc.
def var v-crccode as char.
on help of v-aaa in frame frpc do:
        {itemlist.i
            &file = "aaa"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " aaa.cif = v-cif and aaa.sta <> 'C' and aaa.sta <> 'E' and aaa.gl = 220430 "
            &findadd = " v-crccode = '' . find first crc where crc.crc = aaa.crc no-lock no-error. if avail crc then v-crccode = crc.code. "
            &flddisp = " aaa.aaa label 'Счет' v-crccode label 'Валюта' "
            &chkey = "aaa"
            &index  = "aaa-idx1"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-aaa = aaa.aaa.
        displ v-aaa with frame frpc.
end.
def temp-table t-change
    field namef as char
    field oldvalue as char
    field newvalue as char.


DEFINE QUERY q-change FOR t-change.

def browse b-change
	query q-change
	displ t-change.namef     label 'Наименование поля'   format 'x(20)'
          t-change.oldvalue  label 'Старое значение'    format 'x(40)'
          t-change.newvalue  label 'Новое значение'    format 'x(40)'
    with 7 down title 'Измененные данные'.

form
        v-cif      label " Код клиента             " format "x(06)" skip
        v-aaa      label " Тек.счет по пл.карте    " format "x(20)" skip
        v-pctypen  label " Вид карты               " format "x(10)" skip
        v-expdt1   label " Срок действия           " format "99/99/9999" skip
        v-fio      label " Фамилия имя отчество    " format "x(30)" skip(1)
        v-reas     label " Причина перевыпуска     " format "x(02)" validate(can-find(first codfr where codfr.codfr = 'pcreason' and codfr.code = v-reas no-lock), "Нет такой причины перевыпуска ПК! F2-помощь")
        v-reason   no-label format 'x(30)' at 30 skip(1)
        v-lquest1  no-label format 'x(26)' v-quest1 no-label colon 26 skip(1)
        v-lquest2  no-label format 'x(26)' v-quest2 no-label colon 26 skip
        with side-labels centered row 4 title ' Заявление на перевыпуск ПК ' width 70 frame frpc1.
define frame fchange b-change with overlay centered row 20 width 110.

define frame f-iin v-iin label "ИИН" format "x(12)" validate(length(v-iin) = 12 or trim(v-iin) = "-", "Длина меньше 12 знаков") help "Введите ИИН" with overlay SIDE-LABELS row 8 column 20  width 30.

def frame fr1
     b1 skip
     bnew
     badd
     bedt
     bren
     bcnt
     bprn
     bext with centered width 100 overlay row 1 top-only.

ON CHOOSE OF bext IN FRAME fr1 do:
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
end.

on help of v-pctype in frame frpc do:
    {itemlist.i
        &start = "if not v-first and v-pctype ne '' and (v-pcprod <> 'Salary' or v-sup) then do:
                        find first b-codfr where b-codfr.codfr = 'pctype' and b-codfr.code = v-pctype no-lock no-error.
                        if avail b-codfr then v-pctype1 = b-codfr.name[2].
                     end.
                     else v-pctype1 = '99'."
        &file    = "codfr"
        &set     = "1"
        &frame   = "row 6 centered scroll 1 10 down width 30 overlay "
        &where   = " codfr.codfr = 'pctype' and codfr.name[2] ne '' and codfr.name[2] <= v-pctype1 and codfr.code <> 'B' "
        &flddisp = " codfr.code label ' Код '  format 'x(3)' codfr.name[1] label ' Вид карты ' format 'x(10)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    assign v-pctype = codfr.code v-pctypen = codfr.name[1].
    displ v-pctype v-pctypen with frame frpc.
end.

on help of v-pcprod in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "2"
        &frame   = "row 6 centered scroll 1 10 down width 30 overlay "
        &where   = " codfr.codfr = 'pcprod' and (lookup(codfr.code,'FPA,Staff') = 0 or v-sup = yes)"
        &flddisp = " codfr.code label ' Код '  format 'x(10)' codfr.name[2] label ' Вид продукта ' format 'x(15)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-pcprod = codfr.code.
    displ v-pcprod with frame frpc.
end.

on help of v-country in frame frpc do:
    {itemlist.i
        &file    = "codfr"
        &set     = "3"
        &frame   = "row 20 centered scroll 1 10 down width 50 overlay "
        &where   = " codfr.codfr = 'iso3166' and codfr.name[2] ne '' "
        &flddisp = " codfr.code label ' Код1 ' codfr.name[2] label ' Код2 ' format 'x(03)' codfr.name[1] label ' Название страны ' format 'x(25)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    v-country = codfr.name[2].
    displ v-country with frame frpc.
end.



on help of v-reas in frame frpc1 do:
    {itemlist.i
        &file    = "codfr"
        &set     = "1"
        &frame   = "row 10 centered scroll 1 10 down width 70 overlay "
        &where   = " codfr.codfr = 'pcreason' "
        &flddisp = " codfr.code label ' Код '  format 'x(3)' codfr.name[1] label ' Причина перевыпуска ' format 'x(60)' "
        &chkey   = "code"
        &index   = "cdco_idx"
        &end     = "if keyfunction(lastkey) = 'end-error' then return."
     }
    assign v-reas = codfr.code v-reason = codfr.name[1].
    displ v-reas v-reason with frame frpc1.
end.
on "end-error" of frame frpc1 do:
   hide frame fchange.
end.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else do:
     message "Нет параметра ourbnk sysc!" view-as alert-box error.
     return.
end.

/* Ввод нового заявления */
ON CHOOSE OF bnew IN FRAME fr1 do:
    find first cif where cif.cif = s-cif no-lock no-error.
    if not avail cif then return.
    v-cif = cif.cif.
    find first aaa where aaa.cif = cif.cif and aaa.gl = 220430 and aaa.sta ne 'c' no-lock no-error.
    if not avail aaa then message "Сначала откройте текущий счет по ПК для этого клиента!" view-as alert-box title ' Внимание '.

    else do:
        assign v-new = yes
               v-aaa = aaa.aaa
               v-crc = aaa.crc.
        find next aaa where aaa.cif = cif.cif and aaa.gl = 220430 and aaa.sta ne 'c' no-lock no-error.
        if avail aaa then v-aaa = ''.
        clear frame frpc.
        assign v-lquest1  = " Сохранить заявление?    :"
               v-lquest2  = " Передать на контроль?   :"
               v-quest1   = no
               v-quest2   = no.
        assign v-pcprod   = ''
               v-sup      = no
               v-pctype   = ''
               v-pctypen  = ''
               v-cifm     = no
               v-rnn      = ''
               v-iin      = ''
               v-sname    = ''
               v-fname    = ''
               v-mname    = ''
               v-namelat1 = ''
               v-namelat2 = ''
               v-birth    = ?
               v-tel[1]   = ''
               v-tel[2]   = ''
               v-addr[1]  = ''
               v-addr[2]  = ''
               v-nomdoc   = ''
               v-isswho   = ''
               v-issdt1    = ?
               v-expdt1    = ?
               v-rez      = yes
               v-work     = ''
               v-migrn    = ''
               v-migrdt1  = ?
               v-migrdt2  = ?
               v-position =  ''.
        display v-cif v-aaa v-pcprod v-pctype v-pctypen with frame frpc.
        if v-bin then displ v-label v-rnn with frame frpc.
        else do:
            v-label = " РНН                     :".
            displ v-label v-rnn with frame frpc.
        end.
        display
        v-iin v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 with frame frpc.
        run save-pc.
    end.
end.
/* Ввод заявления для доп.карты*/
ON CHOOSE OF badd IN FRAME fr1 do:
    find first cif where cif.cif = s-cif no-lock no-error.
    if not avail cif then return.
    v-cif = cif.cif.
    find last pcstaff0 where pcstaff0.aaa = t-pccards.aaa and pcstaff0.cif = v-cif no-lock no-error.
    if pcstaff0.pcprod = 'FP' then do:
        find first codfr where codfr.codfr = 'pcprod' and codfr.code = 'FP' no-lock no-error.
        message 'Выпуск дополнительной карты для продукта ' + codfr.name[2] + ' запрещен!' view-as alert-box title 'ВНИМАНИЕ'.
        return.
    end.
    find first aaa where aaa.cif = cif.cif and aaa.gl = 220430 and aaa.sta ne 'c' no-lock no-error.
    if not avail aaa then message "Сначала откройте текущий счет по ПК для этого клиента!" view-as alert-box title ' Внимание '.

    else do:
        v-renew = no.
        assign v-new = yes
               v-aaa = aaa.aaa
               v-crc = aaa.crc.
        find next aaa where aaa.cif = cif.cif and aaa.gl = 220430 and aaa.sta ne 'c' no-lock no-error.
        if avail aaa then v-aaa = ''.
        clear frame frpc.
        assign v-lquest1  = " Сохранить заявление?    :"
               v-lquest2  = " Передать на контроль?   :"
               v-quest1   = no
               v-quest2   = no.
        assign v-pcprod   = ''
               v-sup      = no
               v-pctype   = ''
               v-pctypen  = ''
               v-cifm     = no
               v-rnn      = ''
               v-iin      = ''
               v-sname    = ''
               v-fname    = ''
               v-mname    = ''
               v-namelat1 = ''
               v-namelat2 = ''
               v-birth    = ?
               v-tel[1]   = ''
               v-tel[2]   = ''
               v-addr[1]  = ''
               v-addr[2]  = ''
               v-nomdoc   = ''
               v-isswho   = ''
               v-issdt1    = ?
               v-expdt1    = ?
               v-rez      = yes
               v-work     = ''
               v-migrn    = ''
               v-migrdt1  = ?
               v-migrdt2  = ?
               v-position =  ''.
        display v-cif v-aaa v-pcprod v-pctype v-pctypen with frame frpc.
        if v-bin then displ v-label v-rnn with frame frpc.
        else do:
            v-label = " РНН                     :".
            displ v-label v-rnn with frame frpc.
        end.
        display
        v-iin v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 with frame frpc.
        run save-pc.
    end.
end.

/* Редактирование */
ON CHOOSE OF bedt IN FRAME fr1 do:

	find first cif where cif.cif = s-cif no-lock no-error.
    if not avail cif then return.
    v-cif = cif.cif.

    find current t-pccards no-lock no-error.
    if not avail t-pccards then return.
    clear frame frpc.

    v-new = no.
    if can-do('new,renew',t-pccards.sts) then do:
        assign v-lquest1  = " Сохранить изменения?    :"
               v-quest1    = no
               v-lquest2  = " Передать на контроль?   :"
               v-quest2   = no.
        if t-pccards.sts = 'renew' then v-renew = yes.
        run view-pc.
        run save-pc.
    end.
	open query q1 for each t-pccards.
end.

/* перевыпуск */
ON CHOOSE OF bren IN FRAME fr1 do:
	find first cif where cif.cif = s-cif no-lock no-error.
    if not avail cif then return.
    v-cif = cif.cif.

    find current t-pccards no-lock no-error.
    if not avail t-pccards then return.
    clear frame frpc.
    if t-pccards.sts = 'ok' then do:
        assign v-lquest1  = " Сохранить изменения?    :"
               v-quest1   = no
               v-lquest2  = " Передать на контроль?   :"
               v-quest1   = no
               v-renew    = yes.
        run view-pc.
        run save-pc.
    end.
	open query q1 for each t-pccards.
end.

/* контроль */
ON CHOOSE OF bcnt IN FRAME fr1 do:
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if not can-do('*P00082*,*P00121*,*P00136*,*P00174*,*P00033*',ofc.exp[1]) then do:
        message "У вас нет прав на контроль выпуска ПК!" view-as alert-box title ' Внимание '.
        return.
    end.
    find first cif where cif.cif = s-cif no-lock no-error.
    if not avail cif then return.
    v-cif = cif.cif.

    find current t-pccards no-lock no-error.
    if not avail t-pccards then return.
    find first pcstaff0 where pcstaff0.namef = t-pccards.namef no-lock no-error.
    if pcstaff0.who = g-ofc then do:
        message "Вы не можете контролировать выпуск платежной карты, которую сами ввели/отредактировали!" view-as alert-box title ' Внимание '.
        return.
    end.

    clear frame frpc.
    if can-do('contr,recontr',t-pccards.sts) then assign v-lquest1  = " Поставить контроль?     :"
                                                         v-lquest2  = " Вернуть на доработку?   :".
    else if can-do('ready,reready',t-pccards.sts) then v-lquest1  = " Снять контроль?         :".
    else do:
        message "Для контроля статус карточки должен быть <Контроль>, для снятия отметки о контроле - <На выпуск>!" view-as alert-box title ' Внимание '.
        return.
    end.
    if can-do('recontr,reready',t-pccards.sts) then v-renew = yes.
    assign v-quest1   = no
           v-contr    = yes
           v-quest2   = no.
    run view-pc.
    run change-sts.

	open query q1 for each t-pccards.
end.

/* печать */
ON CHOOSE OF bprn IN FRAME fr1 do:
    find current t-pccards no-lock no-error.
    if not avail t-pccards then return.
    if not can-do('new,contr,ready',t-pccards.sts) then do:
        message "Печать документов выполняется для ПК со статусами Заявка, Контроль или На выпуск!" view-as alert-box title ' Внимание '.
        return.
    end.
    find first cif where cif.cif = s-cif no-lock no-error.
	if not avail cif then return.

    find first aaa where aaa.aaa = t-pccards.aaa no-lock no-error.
    if not avail aaa then return.
    assign s-aaa   = aaa.aaa
           s-cword = v-cword.
    repeat:
    run sel2(' Выберите документы для печати ',' 1. Заявление на выпуск ПК | 2. Договор текущего счета по ПК  | 3. Карточка с образцами подписей  | 4. Титульный лист | 5. Выход ', output v-sel).
    if keyfunction (lastkey) = "end-error" then return.
    case v-sel:
        when 1 then do:
            find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
            find first pcstaff0 where pcstaff0.aaa = s-aaa and pcstaff0.sts = t-pccards.sts no-lock no-error.
            assign v-name    = caps(pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname)
                       v-latname = pcstaff0.namelat
                       v-mail    = pcstaff0.mail
                       v-cword   = pcstaff0.cword
                       v-addr1   = pcstaff0.addr[1]
                       v-addr2   = pcstaff0.addr[2]
                       v-telh    = pcstaff0.tel[1]
                       v-telm    = pcstaff0.tel[2]
                       v-nomdoc  = pcstaff0.nomdoc
                       v-issdt   = string(pcstaff0.issdt,'99/99/9999')
                       v-expdt   = if pcstaff0.expdt ne ? then string(pcstaff0.expdt,'99/99/9999') else ' __/__/____'
                       v-issdoc  = pcstaff0.issdoc
                       v-rnn     = pcstaff0.rnn
                       v-iin     = pcstaff0.iin
                       v-birthdt = string(pcstaff0.birth,'99/99/9999')
                       v-birtplc = pcstaff0.bplace
                       v-nomer   = ''
                       v-rezid   = if pcstaff0.rez then 'Резидент' else 'Нерезидент'.
            if pcstaff0.cifb = v-bank then do:
                find first cmp no-lock no-error.
                if avail cmp then v-work = replace(cmp.name,'"',"'").
            end.
            else do:
                if pcstaff0.cifb begins 'txb' then v-work = v-nbankru.
                else do:
                    find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                    if avail cif then v-work = cif.name.
                end.
            end.
            v-work = replace(v-work,'"',"'").
            v-crcc = t-pccards.crc.
            find first codfr where codfr.codfr =  'pctype'
                               and codfr.code  = pcstaff0.pctype
                               no-lock no-error.
            if avail codfr then v-type = codfr.name[1].
            v-infile = pksysc.chval + (if pcstaff0.pcprod = 'salary' then 'pcsalzayav.htm' else 'pcstzayav.htm').
            {pcstdoc.i}
            output stream v-out close.

            unix silent value("cptwin " + v-ofile + " winword").
            unix silent value("rm -f " + v-ofile).
        end.
        when 2 then do:
            run pcstdog.
        end.
        when 3 then do:
            run cif-kart(0).
        end.
        when 4 then do:
            run cif-title.
        end.
        when 5 then return.
    end case.
    end.
    open query q1 for each t-pccards.
	ENABLE /*bedt bren bcnt bprn bext*/ all with frame fr1 centered overlay top-only.
end.

empty temp-table t-pccards.
for each aaa where aaa.cif = s-cif and aaa.gl = 220430 and aaa.sta ne 'c' no-lock:
    find first crc where crc.crc = aaa.crc no-lock no-error.
    if avail crc then v-crcname = crc.code.
    for each pccards where pccards.aaa = aaa.aaa no-lock:
        create t-pccards.
        assign t-pccards.aaa    = pccards.aaa
               t-pccards.crc    = v-crcname
               t-pccards.sname  = pccards.sname
               t-pccards.pcard  = pccards.pcard
               t-pccards.pcard1 = (substr(pccards.pcard,1,6) + '******' +  substr(pccards.pcard,13))
               t-pccards.sts    = pccards.sts.
        find first pcstaff0 where pcstaff0.pcard = pccards.pcard no-lock no-error.
        if avail pcstaff0 then t-pccards.namef = pcstaff0.namef.
    end.
    for each pcstaff0 where pcstaff0.aaa = aaa.aaa and pcstaff0.sts ne 'OK' no-lock:
        create t-pccards.
        assign t-pccards.aaa    = pcstaff0.aaa
               t-pccards.crc    = v-crcname
               t-pccards.sname  = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
               t-pccards.pcard  = ''
               t-pccards.pcard1 = ''
               t-pccards.sts    = pcstaff0.sts
               t-pccards.namef  = pcstaff0.namef.
    end.
    for each t-pccards:
        find first codfr where codfr.codfr = 'pcsts'
                           and codfr.code  = t-pccards.sts
                           no-lock no-error.
        if avail codfr then t-pccards.stsn = codfr.name[1].
    end.
end.

open query q1 for each t-pccards.
b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE /*bedt bren bcnt bprn bext*/ all with frame fr1 centered overlay top-only.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR WINDOW-CLOSE of frame fr1.
hide frame fr1.

procedure view-pc:
    find current t-pccards no-lock no-error.
    if v-renew then do:
        clear frame frpc1.
        find first pccards where pccards.pcard = t-pccards.pcard no-lock no-error.
        if not avail pccards then return.
        /***galina*****/

        if pccards.sts = 'contr' or pccards.sts = 'recontr' then do:
            empty temp-table t-change.
            find first pcstaff0 where pcstaff0.pcard = t-pccards.pcard no-lock no-error.
            if avail pcstaff0 then do:
                if pccards.sname <> pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname then do:
                    create t-change.
                    assign t-change.namef = 'ФИО'
                           t-change.oldvalue = pccards.sname
                           t-change.newvalue = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname.
                end.
                if pcstaff0.namelat <> pccards.namelat then do:
                    create t-change.
                    assign t-change.namef = 'Фамилия (лат.)'
                           t-change.oldvalue = pccards.namelat
                           t-change.newvalue = pcstaff0.namelat.

                end.
                if pccards.pctype <> pcstaff0.pctype then do:
                    create t-change.
                    assign t-change.namef = 'Вид карты'
                           t-change.oldvalue = pccards.pctype
                           t-change.newvalue = pcstaff0.pctype.

                end.
                find first t-change no-lock no-error.
                if avail t-change then do:
                    open query q-change for each t-change.
                    enable all with frame fchange.
                end.
            end.
        end.
        /**********/

        /*        find first pccards where pccards.pcard = t-pccards.pcard no-lock no-error.
        if not avail pccards then return.*/
        assign v-cif      = pccards.cif
               v-aaa      = pccards.aaa
               v-pctype   = pccards.pctype
               v-expdt1   = pccards.expdt
               v-fio      = pccards.sname
               v-reas     = pccards.info[2].
        find first codfr where codfr.codfr = 'pctype' and codfr.code = v-pctype no-lock no-error.
        if avail codfr then v-pctypen = codfr.name[1].

        find first codfr where codfr.codfr = 'pcreason' and codfr.code = v-reas no-lock no-error.
        if avail codfr then v-reason = codfr.name[1].
        displ v-cif v-aaa v-pctypen v-expdt1 v-fio v-reas v-reason with frame frpc1.


        if pccards.sts = 'renew' then displ v-lquest1 v-quest1 v-lquest2 v-quest2 with frame frpc1.
        else displ v-lquest1 v-quest1 with frame frpc1.
    end.
    else do:

        find first pcstaff0 where pcstaff0.namef = t-pccards.namef no-lock no-error.
        assign v-cif      = pcstaff0.cif
               v-aaa      = pcstaff0.aaa
               v-pcprod   = pcstaff0.pcprod
               v-pctype   = pcstaff0.pctype
               v-sname    = pcstaff0.sname
               v-fname    = pcstaff0.fname
               v-mname    = pcstaff0.mname
               v-namelat1 = entry(1,pcstaff0.namelat,' ')
               v-namelat2 = entry(2,pcstaff0.namelat,' ')
               v-crc      = pcstaff0.crc
               v-rnn      = pcstaff0.rnn
               v-iin      = pcstaff0.iin
               v-birth    = pcstaff0.birth
               v-mail     = pcstaff0.mail
               v-cword    = pcstaff0.cword
               v-tel[1]   = pcstaff0.tel[1]
               v-tel[2]   = pcstaff0.tel[2]
               v-addr[1]  = pcstaff0.addr[1]
               v-addr[2]  = pcstaff0.addr[2]
               v-nomdoc   = pcstaff0.nomdoc
               v-isswho   = pcstaff0.issdoc
               v-issdt1   = pcstaff0.issdt
               v-expdt1   = pcstaff0.expdt
               v-rez      = pcstaff0.rez
               v-country  = pcstaff0.country
               v-migrn    = pcstaff0.migrn
               v-migrdt1  = pcstaff0.migrdt1
               v-migrdt2  = pcstaff0.migrdt2
               v-publicf  = pcstaff0.publicf
               v-position = pcstaff0.position
               v-offsh    = pcstaff0.offsh
               v-offshd   = pcstaff0.offshd.
        find first codfr where codfr.codfr = 'pctype' and codfr.code = v-pctype no-lock no-error.
        if avail codfr then v-pctypen = codfr.name[1].

        display v-cif v-aaa v-pcprod v-pctype v-pctypen with frame frpc.

        if v-bin then displ v-label '' with frame frpc.
        else do:
            v-label = " РНН                     :".
            displ v-label v-rnn with frame frpc.
        end.
        find first crc where crc.crc = v-crc no-lock no-error.
        if avail crc then v-crcname = crc.code.

        display v-iin v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 /*v-lquest2 v-quest2*/ with frame frpc.
        if not v-contr then displ v-lquest2 v-quest2 with frame frpc.
    end.


end procedure.

procedure save-pc:

    if v-renew then do:
        v-sup = no.
        update v-reas help "Введите причину; F2- помощь; F4-выход" with frame frpc1.
        if v-reas = '2' then do:
            message 'Перевыпус по данной причине времено запрещен!' view-as alert-box.
            return.
        end.
        find first codfr where codfr.codfr = 'pcreason'
                           and codfr.code  = v-reas
                           no-lock no-error.
        if avail codfr then v-reason = codfr.name[1].
        displ v-reason with frame frpc1.

        update v-quest1 with frame frpc1.
        if not v-quest1 then do:
            v-reason = ''.
            return.
        end.
        find last pcstaff0 where pcstaff0.aaa = pccards.aaa and pcstaff0.cif = pccards.cif no-lock no-error.
        if v-reas = '5' and pcstaff0.pcprod = 'FP' then do:
                find first codfr where codfr.codfr = 'pcprod' and codfr.code = pcstaff0.pcprod no-lock no-error.
                message 'Перевыпуск по выбранной причине для продукта ' + codfr.name[2] + ' запрещен!' view-as alert-box title 'ВНИМАНИЕ'.
                return.
        end.



        if v-reas = '2' or v-reas = '4' then do:

            assign v-cif      = pcstaff0.cif
                   v-aaa      = pcstaff0.aaa
                   v-pcprod   = pcstaff0.pcprod
                   v-pctype   = pcstaff0.pctype
                   v-rnn      = pcstaff0.rnn
                   v-iin      = pcstaff0.iin
                   v-sname    = pcstaff0.sname
                   v-fname    = pcstaff0.fname
                   v-mname    = pcstaff0.mname
                   v-namelat1 = if num-entries(pcstaff0.namelat,' ') = 2 then  entry(1,pcstaff0.namelat,' ') else ''
                   v-namelat2 = if num-entries(pcstaff0.namelat,' ') = 2 then  entry(2,pcstaff0.namelat,' ') else ''
                   v-birth    = pcstaff0.birth
                   v-tel[1]   = pcstaff0.tel[1]
                   v-tel[2]   = pcstaff0.tel[2]
                   v-addr[1]  = pcstaff0.addr[1]
                   v-addr[2]  = pcstaff0.addr[2]
                   v-nomdoc   = pcstaff0.nomdoc
                   v-isswho   = pcstaff0.issdoc
                   v-issdt1   = pcstaff0.issdt
                   v-expdt1   = pcstaff0.expdt
                   v-rez      = pcstaff0.rez
                   v-country  = pcstaff0.country
                   v-migrn    = pcstaff0.migrn
                   v-migrdt1  = pcstaff0.migrdt1
                   v-migrdt2  = pcstaff0.migrdt2
                   v-position = pcstaff0.position
                   no-error.
            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
            if avail cif then v-work = cif.prefix + ' ' + cif.name.

            display v-cif v-aaa v-pcprod v-pctype v-iin v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
            v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
            v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 with frame frpc.

            repeat on endkey undo,return:
                update v-namelat1 with frame frpc.
                if not chk-namelat(v-namelat1) then leave.
            end.
            repeat on endkey undo,return:
                update v-namelat2 with frame frpc.
                if not chk-namelat(v-namelat2) then leave.
            end.
            repeat while length(trim(v-namelat1)) + length(trim(v-namelat2)) + 1 > 25:
                message 'Превышен лимит символов Embossing name. Вместо имени необходимо набрать первую букву имени' view-as alert-box.
                update v-namelat1 v-namelat2 with frame frpc.
            end.

            if v-reas = '2' then /*do:*/
                /*if v-pcprod  = 'FP' or v-pcprod  = 'STAFF' then*/ update  v-sname v-fname v-mname v-nomdoc v-isswho v-issdt1 v-expdt1 with frame frpc.
                /*else update v-pctype v-sname v-fname v-mname v-nomdoc v-isswho v-issdt1 v-expdt1 with frame frpc.*/
            /*end.*/


            assign v-lquest1  = " Сохранить изменения?    :"
                   v-quest1   = no.
            update v-quest1 with frame frpc.

            if v-quest1 then do transaction:
                find current pcstaff0 exclusive-lock no-error.
                assign pcstaff0.sname    = caps(v-sname)
                       pcstaff0.fname    = caps(v-fname)
                       pcstaff0.mname    = caps(v-mname)
                       pcstaff0.namelat  = caps(v-namelat1) + ' ' + caps(v-namelat2)
                       pcstaff0.pctype   = v-pctype
                       pcstaff0.nomdoc   = v-nomdoc
                       pcstaff0.issdoc   = v-isswho
                       pcstaff0.issdt    = v-issdt1
                       pcstaff0.expdt    = v-expdt1.
                find current pcstaff0 no-lock no-error.
            end.
        end.
        do transaction:
            find current pccards exclusive-lock no-error.
            assign pccards.info[2] = v-reas
                   pccards.info[3] = v-nomdoc
                   pccards.sts     = 'renew'
                   pccards.who     = g-ofc
                   pccards.whn     = g-today.
            find current pccards no-lock no-error.
        end.
        find current t-pccards no-lock.
        t-pccards.sts = 'renew'.
        find first codfr where codfr.codfr = 'pcsts'
                           and codfr.code = t-pccards.sts
                           no-lock no-error.
        if avail codfr then t-pccards.stsn = codfr.name[1].
        find current t-pccards no-lock.
        displ v-lquest2 v-quest2 with frame frpc1.
        update v-quest2 with frame frpc1.
        if not v-quest2 then return.
        do transaction:
            find current pccards exclusive-lock no-error.
            assign pccards.sts = 'recontr'
                   pccards.who = g-ofc
                   pccards.whn = g-today.
            find current pccard no-lock no-error.
        end.
        find current t-pccards no-lock.
        t-pccards.sts = 'recontr'.
        find first codfr where codfr.codfr = 'pcsts'
                           and codfr.code = t-pccards.sts
                           no-lock no-error.
        if avail codfr then t-pccards.stsn = codfr.name[1].
        find current t-pccards no-lock.
        /*run mail-pc.*/
    end.
    else do:
        update v-aaa help "Счет клиента по ПК; F2- помощь; F4-выход" with frame frpc.
        find first aaa where aaa.aaa = v-aaa no-lock no-error.
        find first crc where crc.crc = aaa.crc no-lock no-error.
        if avail crc then do:
            v-crcname = crc.code.
            displ v-crcname with frame frpc.
        end.

        v-first = yes.

        if v-new then do:
            find first b-pcstaff0 where b-pcstaff0.aaa = v-aaa and b-pcstaff0.sts ne 'reject' no-lock no-error.
            if avail b-pcstaff0 then assign v-pcprod  = b-pcstaff0.pcprod
                                            v-sup     = yes
                                            v-pctype  = b-pcstaff0.pctype
                                            v-first   = no.
        end.
        else do:
            find first b-pcstaff0 where b-pcstaff0.aaa = v-aaa and b-pcstaff0.sts ne 'reject' and b-pcstaff0.namef ne pcstaff0.namef no-lock no-error.
            if avail b-pcstaff0 then assign v-pcprod  = pcstaff0.pcprod
                                            v-sup     = yes
                                            v-pctype  = pcstaff0.pctype
                                            v-first   = no.
        end.
        if v-first then update v-pcprod help "Вид продукта по ПК; F2- помощь; F4-выход" with frame frpc.
        else displ v-pcprod with frame frpc.

        if (v-sup and v-pcprod = 'staff') or v-new then do:
            update v-pctype help "Вид карты; F2- помощь; F4-выход" with frame frpc.
            find first codfr where codfr.codfr = 'pctype' and codfr.code = v-pctype no-lock no-error.
            if avail codfr then do: v-pctypen = codfr.name[1]. v-holder = codfr.name[2]. end.
            displ v-pctypen with frame frpc.
        end.

        if v-new and v-sup then do:
            if yes-no ('', 'Дополнительная карта открывается на имя другого человека?') then v-cifm = yes.
        end.

        find first b-pcstaff0 where b-pcstaff0.aaa = v-aaa and b-pcstaff0.sts ne 'reject' no-lock no-error.
        find first codfr where codfr.codfr = 'pctype' and codfr.code = b-pcstaff0.pctype no-lock no-error.
        if avail codfr then do:
            if int(codfr.name[2]) < int(v-holder) then do:
                message ' Категория карты не должна быть выше, чем у основного держателя! ' view-as alert-box.
                return.
            end.
        end.

        if not v-new and pcstaff0.info[2] ne '' then v-cifm = yes.
        if not v-cifm then do:
            find first sub-cod where sub-cod.acc = v-cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'publicf' no-lock no-error.
            if avail sub-cod then v-publicf =  if sub-cod.ccode = '1' then no else yes.

            find first cif-mail where cif-mail.cif = v-cif no-lock no-error.
            if avail cif-mail then v-mail = cif-mail.mail.

            assign v-rnn      = cif.jss
                   v-iin      = cif.bin
                   v-sname    = entry(1,cif.name,' ')
                   v-fname    = entry(2,cif.name,' ')
                   v-mname    = entry(3,cif.name,' ')
                   v-namelat1 = if num-entries(cif.namelat,' ') = 2 then  entry(1,cif.namelat,' ') else ''
                   v-namelat2 = if num-entries(cif.namelat,' ') = 2 then  entry(2,cif.namelat,' ') else ''
                   v-cword    = ''/*pcstaff0.cword*/
                   v-birth    = cif.expdt
                   v-tel[1]   = cif.tel
                   v-tel[2]   = cif.fax
                   v-addr[1]  = cif.addr[1]
                   v-addr[2]  = cif.addr[2]
                   v-nomdoc   = entry(1,cif.pss,' ')
                   v-isswho   = entry(3,cif.pss,' ')
                   v-issdt1   = date(entry(2,cif.pss,' '))
                   v-expdt1   = cif.dtsrokul
                   v-rez      = if cif.irs = 1 then yes else no
                   v-country  = if cif.irs = 1 then 'KAZ' else ''
                   v-work     = cif.ref[8]
                   v-migrn    = cif.migr-number
                   v-migrdt1  = cif.migr-dt
                   v-migrdt2  = cif.migr-dt-exp
                   v-position = if v-publicf then cif.sufix else ''
                   no-error .

        end.

        if v-bin then displ v-label '' with frame frpc.
        else do:
            v-label = " РНН                     :".
            displ v-label v-rnn with frame frpc.
        end.

        display v-iin v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
        v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
        v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 with frame frpc.


        if not v-cifm then do:
            repeat on endkey undo,return:
                update v-namelat1 with frame frpc.
                if not chk-namelat(v-namelat1) then leave.
            end.
            repeat on endkey undo,return:
                update v-namelat2 with frame frpc.
                if not chk-namelat(v-namelat2) then leave.
            end.
            update v-cword with frame frpc.

            repeat while length(trim(v-namelat1)) + length(trim(v-namelat2)) + 1 > 25:
                message 'Превышен лимит символов Embossing name. Вместо имени необходимо набрать первую букву имени' view-as alert-box.
                update v-namelat1 v-namelat2 with frame frpc.
            end.

            if not v-rez then do:
                update v-country with frame frpc.
                update v-migrn with frame frpc.
                if v-migrn ne '' then update v-migrdt1 v-migrdt2 with frame frpc.
            end.
            if v-publicf then update v-position with frame frpc.
            update v-offsh with frame frpc. if v-offsh then update v-offshd with frame frpc.
        end.
        else do:
            repeat on error undo,retry on endkey undo,return:
                if v-bin then do:
                    update v-iin help "ИИН физ.лица; для нерезидента введите '-'; F4-выход" with frame frpc.
                    if trim(v-iin) eq '' then v-iin  = '-'.
                    else find first rnn where rnn.bin = v-iin no-lock no-error.
                end.
                else do:
                    update v-rnn help "РНН физ.лица; для нерезидента введите '-'; F4-выход" with frame frpc.
                    if trim(v-rnn) eq '' then v-rnn = '-'.
                    else find first rnn where rnn.trn = v-rnn no-lock no-error.
                end.
                if trim(v-rnn) eq '-' or trim(v-iin) eq '-' or avail rnn then leave.
                else do:
                    message "РНН(ИИН) отсутствует в базе НК МФ!" view-as alert-box error.
                end.
            end.
            if (v-bin and trim(v-iin) = '-') or (not v-bin and trim(v-rnn) = '-') then do:
                update v-sname with frame frpc.
                v-cifmin = "".
                run ciffind(input v-sname, output v-cifmin).
                find last cifmin where cifmin.cifmin = v-cifmin no-lock no-error.
            end.
            else do:
                find first pccards where pccards.iin = v-iin and pccards.sup = yes no-lock no-error.
                if avail pccards then do:
                    message "По ИИН " + v-iin + " уже выпускалась дополнительная карта " + pccards.pcard + ". Обратитесь в ДПК" view-as alert-box.
                    return.
                end.
                if v-bin then find last cifmin where cifmin.iin = v-iin no-lock no-error.
                else find last cifmin where cifmin.rnn = v-rnn no-lock no-error.
            end.
            if available cifmin then do:
                assign v-iin      = cifmin.iin
                       v-sname    = cifmin.fam
                       v-fname    = cifmin.name
                       v-mname    = cifmin.mname
                       v-nomdoc   = cifmin.docnum
                       v-issdt1   = cifmin.docdt
                       v-expdt1   = cifmin.docdtf
                       v-isswho   = cifmin.docwho
                       v-publicf  = if cifmin.publicf = '1' then no else yes
                       v-ccountry = cifmin.public
                       v-addr[1]  = cifmin.addr
                       v-addr[2]  = cifmin.addr
                       v-tel[1]   = cifmin.tel
                       v-birth    = cifmin.bdt.
                if cifmin.res = "1" then v-rez = yes. else v-rez = no.
                find first codfr where codfr.codfr = 'iso3166' and codfr.code = v-ccountry no-lock no-error.
                if avail codfr then v-country = codfr.name[2].
                else v-country = ''.
            end.
            else do:
                if v-bin then find first rnn where rnn.bin = v-iin no-lock no-error.
                else find first rnn where rnn.trn = v-rnn no-lock no-error.
                if available rnn then do:
                    if not v-bin then do:
                        v-iin = rnn.bin.
                        update v-iin with frame f-iin.
                    end.

                    /*************првим тут*************/
                    find first cif where cif.bin = v-iin no-lock no-error.
                    if avail cif then do:
                        find first sub-cod where sub-cod.acc = v-cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'publicf' no-lock no-error.
                        if avail sub-cod then v-publicf =  if sub-cod.ccode = '1' then no else yes.

                        find first cif-mail where cif-mail.cif = v-cif no-lock no-error.
                        if avail cif-mail then v-mail = cif-mail.mail.

                        assign v-rnn      = cif.jss
                               v-iin      = cif.bin
                               v-sname    = entry(1,cif.name,' ')
                               v-fname    = entry(2,cif.name,' ')
                               v-mname    = entry(3,cif.name,' ')
                               v-namelat1 = if num-entries(cif.namelat,' ') = 2 then  entry(1,cif.namelat,' ') else ''
                               v-namelat2 = if num-entries(cif.namelat,' ') = 2 then  entry(2,cif.namelat,' ') else ''
                               v-birth    = cif.expdt
                               v-tel[1]   = cif.tel
                               v-tel[2]   = cif.fax
                               v-addr[1]  = cif.addr[1]
                               v-addr[2]  = cif.addr[2]
                               v-nomdoc   = entry(1,cif.pss,' ')
                               v-isswho   = if num-entries(cif.pss,' ') > 2 then entry(3,cif.pss,' ') else ''
                               v-issdt1   = if num-entries(cif.pss,' ') > 1 then date(entry(2,cif.pss,' ')) else ?
                               v-expdt1   = cif.dtsrokul
                               v-rez      = if cif.irs = 1 then yes else no
                               v-country  = if cif.irs = 1 then 'KAZ' else ''
                               v-work     = cif.ref[8]
                               v-migrn    = cif.migr-number
                               v-migrdt1  = cif.migr-dt
                               v-migrdt2  = cif.migr-dt-exp
                               v-position = if v-publicf then cif.sufix else ''
                               no-error .

                        /*assign v-sname = rnn.lname
                               v-fname = rnn.fname
                               v-mname = rnn.mname.*/
                    end.
                    else run pcciffind(v-iin, output v-rnn,output v-sname,output v-fname, output v-mname, output v-namelat1,output v-namelat2,output v-birth,output v-tel[1],output v-tel[2], output v-addr[1],output v-addr[2],output v-expdt1,output v-rez,output v-country,output v-work, output v-migrn,output v-migrdt1,output v-migrdt2,output v-position,output v-nomdoc,output v-isswho,output v-issdt1).
                end.
            end.
            if not v-bin then displ v-iin with frame frpc.
            display v-sname v-fname v-mname v-namelat1 v-namelat2 v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
                    v-nomdoc v-isswho v-issdt1 v-expdt1 v-crcname v-rez v-country v-migrn v-migrdt1
                    v-migrdt2 v-publicf v-position v-offsh v-offshd v-lquest1 v-quest1 with frame frpc.
            if not v-bin then update v-iin with frame frpc.
            update v-sname v-fname v-mname with frame frpc.
            repeat on endkey undo,return:
                update v-namelat1 with frame frpc.
                if not chk-namelat(v-namelat1) then leave.
            end.
            repeat on endkey undo,return:
                update v-namelat2 with frame frpc.
                if not chk-namelat(v-namelat2) then leave.
            end.
            update v-birth v-cword v-mail v-work v-tel[1] v-tel[2] v-addr[1] v-addr[2]
                   v-nomdoc v-isswho v-issdt1 v-expdt1 v-rez with frame frpc.
            if v-rez then do:
                v-country = 'KAZ'.
                displ v-country with frame frpc.
            end.
            if not v-rez then do:
                v-country = ''.
                update v-country with frame frpc.
                update v-migrn with frame frpc.
                if v-migrn ne '' then update v-migrdt1 v-migrdt2 with frame frpc.
            end.
            if v-publicf then update v-position with frame frpc.
            update v-offsh with frame frpc.
            if v-offsh then update v-offshd with frame frpc.
        end.

        update v-quest1 with frame frpc.
        if not v-quest1 then return.
        do transaction:
            if v-new then do:
                find first pccounters where pccounters.type = "ind_issue" no-lock no-error.
                if not avail pccounters then do:
                    create pccounters.
                    assign pccounters.type    = "ind_issue"
                           pccounters.dat     = g-today
                           pccounters.counter = 1.
                end.
                else do:
                    find current pccounters exclusive-lock.
                    if pccounters.dat = g-today then pccounters.counter = pccounters.counter + 1.
                    else assign pccounters.dat     = g-today
                                pccounters.counter = 1.
                    find current pccounters no-lock.
                end.

                create pcstaff0.
                assign pcstaff0.namef    = 'ind' + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + '_' + string(pccounters.counter, "999")
                       pcstaff0.ldt      = today
                       pcstaff0.bank     = v-bank
                       pcstaff0.cif      = v-cif.
            end.
            else find current pcstaff0 exclusive-lock.
            assign
                   pcstaff0.sname    = caps(v-sname)
                   pcstaff0.fname    = caps(v-fname)
                   pcstaff0.mname    = caps(v-mname)
                   pcstaff0.namelat  = caps(v-namelat1) + ' ' + caps(v-namelat2)
                   pcstaff0.aaa      = v-aaa
                   pcstaff0.crc      = aaa.crc
                   pcstaff0.rnn      = v-rnn
                   pcstaff0.iin      = v-iin
                   pcstaff0.birth    = v-birth
                   pcstaff0.mail     = v-mail
                   pcstaff0.pcprod   = v-pcprod
                   pcstaff0.pctype   = v-pctype
                   pcstaff0.cword    = v-cword
                   pcstaff0.tel[1]   = v-tel[1]
                   pcstaff0.tel[2]   = v-tel[2]
                   pcstaff0.addr[1]  = v-addr[1]
                   pcstaff0.addr[2]  = v-addr[2]
                   pcstaff0.nomdoc   = v-nomdoc
                   pcstaff0.issdoc   = v-isswho
                   pcstaff0.issdt    = v-issdt1
                   pcstaff0.expdt    = v-expdt1
                   pcstaff0.rez      = v-rez
                   pcstaff0.country  = v-country
                   pcstaff0.migrn    = v-migrn
                   pcstaff0.migrdt1  = v-migrdt1
                   pcstaff0.migrdt2  = v-migrdt2
                   pcstaff0.publicf  = v-publicf
                   pcstaff0.position = v-position
                   pcstaff0.offsh    = v-offsh
                   pcstaff0.offshd   = v-offshd
                   pcstaff0.who      = g-ofc
                   pcstaff0.whn      = g-today
                   pcstaff0.sts      = 'new'.


            find first pcprod where pcprod.pcode  = v-pcprod
                                and pcprod.pctype = v-pctype
                                and pcprod.rez    = v-rez
                                and pcprod.crc    = aaa.crc
                                and pcprod.sup    = v-sup
            no-lock no-error.
            if avail pcprod then do:
                assign pcstaff0.ccode = pcprod.ccode
                       pcstaff0.acode = pcprod.acode.
            end.
            find current pcstaff0 no-lock no-error.

            if v-cifm then do:
                if v-cifmin = "" then do:
                    create cifmin.
                    assign cifmin.cifmin = 'cm' + string(next-value(cmnum,comm),'99999999')
                           cifmin.rwho   = g-ofc
                           cifmin.rwhn   = g-today.
                    v-cifmin = cifmin.cifmin.

                end.
                else do:
                    find last cifmin where cifmin.cifmin = v-cifmin exclusive-lock no-error.
                    if not available cifmin or trim(cifmin.fam) <> trim(v-sname) or trim(cifmin.name) <> trim(v-fname) or
                        trim(cifmin.mname) <> trim(v-mname) or cifmin.bdt <> v-birth or trim(v-nomdoc) <> trim(cifmin.docnum) then do:
                        create cifmin.
                        assign cifmin.cifmin = 'cm' + string(next-value(cmnum,comm),'99999999')
                               cifmin.rwho   = g-ofc
                               cifmin.rwhn   = g-today.
                        v-cifmin = cifmin.cifmin.
                    end.
                end.
                if v-bin = no then do:
                    assign cifmin.iin = v-iin
                           cifmin.rnn = v-rnn.
                end.
                else cifmin.iin = v-iin.
                assign cifmin.docnum  = v-nomdoc
                       cifmin.docdt   = v-issdt1
                       cifmin.docdtf  = v-expdt1
                       cifmin.publicf = if v-publicf then '2' else '1'
                       cifmin.bdt     = v-birth
                       cifmin.docwho  = v-isswho
                       cifmin.addr    = v-addr[1]
                       cifmin.tel     = v-tel[1]
                       cifmin.chwho   = g-ofc
                       cifmin.chwhn   = g-today
                       cifmin.fam     = v-sname
                       cifmin.name    = v-fname
                       cifmin.mname   = v-mname
                       cifmin.res     = if v-rez  then "1" else "0".
                find first codfr where codfr.codfr = 'iso3166' and codfr.name[2] = v-country no-lock no-error.
                if avail codfr then cifmin.public = codfr.code.
                find current cifmin no-lock no-error.
                find current pcstaff0 exclusive-lock no-error.
                pcstaff0.info[2] = v-cifmin.
                find current pcstaff0 no-lock no-error.

            end.
            else do:
                find current cif exclusive-lock.
                cif.namelat = pcstaff0.namelat.
                if not v-rez then assign cif.migr-number = v-migrn
                                         cif.migr-dt     = v-migrdt1
                                         cif.migr-dt-exp = v-migrdt2.
                find current cif no-lock no-error.
            end.
        end.
        if v-new then do:
            create t-pccards.
            assign t-pccards.aaa   = pcstaff0.aaa
                   t-pccards.crc   = v-crcname
                   t-pccards.sname = pcstaff0.sname + ' ' + pcstaff0.fname + ' ' + pcstaff0.mname
                   t-pccards.pcard = ''
                   t-pccards.sts   = pcstaff0.sts
                   t-pccards.namef = pcstaff0.namef.
            find first codfr where codfr.codfr = 'pcsts'
                               and codfr.code  = pcstaff0.sts
                               no-lock no-error.
            if avail codfr then t-pccards.stsn = codfr.name[1].
        end.
        displ v-lquest2 v-quest2 with frame frpc.
        update v-quest2 with frame frpc.
        if v-quest2 then do transaction:
            find current pcstaff0 exclusive-lock no-error.
            pcstaff0.sts = 'contr'.
            find current pcstaff0 no-lock no-error.
            find current t-pccards exclusive-lock.
            t-pccards.sts = 'contr'.
            find first codfr where codfr.codfr = 'pcsts'
                               and codfr.code  = pcstaff0.sts
                               no-lock no-error.
            if avail codfr then t-pccards.stsn = codfr.name[1].
            find current t-pccards no-lock.
            /*run mail-pc.*/
        end.

    end.
    open query q1 for each t-pccards.

end procedure.

procedure change-sts:
    if v-renew then do:
        update v-quest1 with frame frpc1.
        if not v-quest1 and t-pccards.sts = 'recontr' then do:
            displ v-lquest2 v-quest2 with frame frpc1.
            update v-quest2 with frame frpc1.
            if v-quest2 then do:
                v-newsts = 'renew'.
                run mail(pccards.who + "@fortebank.com", g-ofc + "@fortebank.com", "Корректировка данных по перевыпуску ПК", "Необходима корректировка данных по перевыпуску ПК для клиента " + s-cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)), "0", "", "").
                find current pccards exclusive-lock no-error.
                assign pccards.sts = v-newsts
                       pccards.who = g-ofc
                       pccards.whn = g-today.
                find current pccards no-lock no-error.
                find current t-pccards exclusive-lock.
                t-pccards.sts = v-newsts.
                find first codfr where codfr.codfr = 'pcsts'
                                   and codfr.code  = v-newsts
                                   no-lock no-error.
                if avail codfr then t-pccards.stsn = codfr.name[1].
                find current t-pccards no-lock.
            end.

            hide frame fchange no-pause.

            return.
        end.
        if t-pccards.sts = 'recontr' then v-newsts = 'reready'.
        if t-pccards.sts = 'reready' then v-newsts = 'renew'.

        find current pccards exclusive-lock no-error.
        assign pccards.sts = v-newsts
               pccards.who = g-ofc
               pccards.whn = g-today.
        if v-newsts = 'reready' then pccards.info[4] = ''.
        find current pccards no-lock no-error.
        find current t-pccards exclusive-lock.
        t-pccards.sts = v-newsts.
        find first codfr where codfr.codfr = 'pcsts'
                           and codfr.code  = v-newsts
                           no-lock no-error.
        if avail codfr then t-pccards.stsn = codfr.name[1].
        find current t-pccards no-lock.

        hide frame fchange no-pause.

    end.
    else do:

        update v-quest1 with frame frpc.
        if not v-quest1 and t-pccards.sts = 'contr' then do:
            displ v-lquest2 v-quest2 with frame frpc.
            update v-quest2 with frame frpc.
            if v-quest2 then do:
                v-newsts = 'new'.
                /*message pcstaff0.who . pause.*/
                run mail(pcstaff0.who + "@fortebank.com", g-ofc + "@fortebank.com", "Корректировка данных по перевыпуску ПК", "Необходима корректировка данных по перевыпуску ПК для клиента " + s-cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)), "0", "", "").

                find current pcstaff0 exclusive-lock no-error.
                assign pcstaff0.sts = v-newsts
                       pcstaff0.who = g-ofc
                       pcstaff0.whn = g-today.
                find current pcstaff0 no-lock no-error.
                find current t-pccards exclusive-lock.
                t-pccards.sts = v-newsts.
                find first codfr where codfr.codfr = 'pcsts'
                                   and codfr.code  = pcstaff0.sts
                                   no-lock no-error.
                if avail codfr then t-pccards.stsn = codfr.name[1].
                find current t-pccards no-lock.
            end.

            return.
        end.
        if t-pccards.sts = 'contr' then v-newsts = 'ready'.
        if t-pccards.sts = 'ready' then v-newsts = 'new'.

        find current pcstaff0 exclusive-lock no-error.
        assign pcstaff0.sts = v-newsts
               pcstaff0.who = g-ofc
               pcstaff0.whn = g-today.
        find current pcstaff0 no-lock no-error.
        find current t-pccards exclusive-lock.
        t-pccards.sts = v-newsts.
        find first codfr where codfr.codfr = 'pcsts'
                           and codfr.code  = pcstaff0.sts
                           no-lock no-error.
        if avail codfr then t-pccards.stsn = codfr.name[1].
        find current t-pccards no-lock.


    end.
end procedure.

/*procedure mail-pc:
    for each ofc where can-do('*P00082*,*P00121*,*P00136*,*P00174*,*P00033*',ofc.exp[1]) no-lock:
        if ofc.ofc = "id00801" and v-bank ne 'txb16' then next.
        if ofc.ofc = "id00544" then next.
        run mail(ofc.ofc + "@fortebank.com", /*g-ofc + "@fortebank.com"*/ "FORTEBANK <abpk@fortebank.com>", "Необходим контроль выпуска ПК", "Необходим контроль выпуска ПК для клиента " + s-cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)), "0", "", "").
    end.
end procedure.*/

procedure ciffind:
    def input  param vv     as char.
    def output param result as char.
    assign famlist = ''
           i       = 0.
    if v-bin then do:
        FOR EACH cifmin where cifmin.iin = v-iin and cifmin.fam = v-sname no-lock.
            i = i + 1.
            if famlist <> "" then famlist = famlist + "|".
            famlist = famlist + cifmin.cifmin + " " + cifmin.fam + " " + cifmin.name + " " + cifmin.mname + " " + string(bdt).
        end.
    end.
    else do:
        FOR EACH cifmin where cifmin.rnn = v-rnn and cifmin.fam = v-sname no-lock.
            i = i + 1.
            if famlist <> "" then famlist = famlist + "|".
            famlist = famlist + cifmin.cifmin + " " + cifmin.fam + " " + cifmin.name + " " + cifmin.mname + " " + string(bdt).
        end.
    end.
    if i > 0 then do:
       run sels(" Выберите Фамилию ", famlist).
       if keyfunction(lastkey) = "end-error" then return.
       result = entry(1,return-value," ").
    end.
end procedure.
